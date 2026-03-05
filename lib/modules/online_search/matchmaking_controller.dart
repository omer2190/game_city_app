import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../../data/models/matchmaking_model.dart';
import '../../../data/repositories/matchmaking_repository.dart';
import '../../../modules/auth/controllers/auth_controller.dart';

class MatchmakingController extends GetxController {
  final MatchmakingRepository _repository = MatchmakingRepository();
  final AuthController _authController = Get.find<AuthController>();

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  var isLoading = false.obs;
  var isSearching = false.obs;
  var matchFound = false.obs;
  var matchResult = Rxn<MatchResult>();

  var selectedGameId = Rxn<String>();
  var selectedType = 'solo'.obs; // 'solo' or 'team'
  final notesController = TextEditingController();

  var myGames = <Map<String, dynamic>>[].obs;

  final GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadMyGames();
    _checkExistingSearch();
    _initPusher();

    notesController.text = box.read('last_search_note') ?? '';

    // Update games if user profile updates
    ever(_authController.userModel, (_) => _loadMyGames());
  }

  void _loadMyGames() {
    final user = _authController.userModel.value;
    if (user?.playNow != null) {
      myGames.value = user!.playNow!.map((e) {
        if (e is Map<String, dynamic>) {
          return {
            'id': e['_id'] ?? e['id'],
            'title': e['title'] ?? e['name'] ?? 'Unknown Game',
            'image': e['image'] ?? '',
          };
        }
        // If it's just a string ID, we can't show name easily without fetching.
        // For now, fallback to ID as title.
        return {'id': e.toString(), 'title': 'Game ID: $e', 'image': ''};
      }).toList();
    }
  }

  Future<void> _initPusher() async {
    try {
      // TODO: Replace with actual key and cluster from config
      await pusher.init(
        apiKey: "2bac0c3ed80bb878c0b0",
        cluster: "eu",
        onEvent: _onPusherEvent,
      );

      final userId = _authController.userModel.value?.id;
      if (userId != null) {
        await pusher.subscribe(channelName: "user-$userId");
        await pusher.connect();
      }
    } catch (e) {
      debugPrint("Pusher init error: $e");
    }
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.eventName == 'matchmaking:found') {
      try {
        final rawData = event.data is String
            ? jsonDecode(event.data)
            : event.data;
        final data = Map<String, dynamic>.from(rawData);

        // Result can be { success, message, match: { with, ... } }
        // or just the match object itself if it's sent directly
        final matchData = data.containsKey('match') ? data['match'] : data;

        final match = MatchResult.fromJson(
          Map<String, dynamic>.from(matchData),
        );
        _handleMatchFound(match);
      } catch (e) {
        debugPrint("Error parsing pusher event: $e");
      }
    }
  }

  Future<void> startSearch() async {
    if (selectedGameId.value == null) {
      Get.snackbar('Error', 'Please select a game first');
      return;
    }

    try {
      isLoading(true);
      box.write('last_search_note', notesController.text);
      final result = await _repository.startSearch(
        gameId: selectedGameId.value!,
        type: selectedType.value,
        notes: notesController.text,
      );

      if (result.status == MatchmakingStatus.matched && result.match != null) {
        _handleMatchFound(result.match!);
        //
      } else {
        isSearching(true);
        matchFound(false);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start search: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> cancelSearch() async {
    try {
      isLoading(true);
      await _repository.cancelSearch();
      isSearching(false);
      matchFound(false);
      matchResult.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel search');
    } finally {
      isLoading(false);
      isSearching(false);
      matchFound(false);
      matchResult.value = null;
    }
  }

  Future<void> _checkExistingSearch() async {
    try {
      final status = await _repository.checkStatus();
      if (status != null) {
        if (status.status == MatchmakingStatus.searching) {
          isSearching(true);
          selectedGameId.value = status.gameId;
          selectedType.value = status.type ?? 'solo';
          notesController.text = status.notes ?? '';
        } else if (status.status == MatchmakingStatus.matched) {
          // Maybe show history or just reset
        }
      }
    } catch (e) {
      // Ignore
    }
  }

  void _handleMatchFound(MatchResult match) {
    isSearching(false);
    matchFound(true);
    matchResult.value = match;

    final userId = match.withUserId;
    if (userId != null) {
      Get.snackbar(
        'تم العثور على لاعب!',
        'لقد تم مطابقتك مع ${match.userName ?? match.firstName ?? "Gamer"}!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xff9c27b0).withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
