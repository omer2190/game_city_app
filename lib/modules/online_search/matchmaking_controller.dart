import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:game_city_app/core/services/storage_service.dart';
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
  var matchedRecords = <MatchmakingRecord>[].obs;

  var selectedGameId = Rxn<String>();
  var selectedType = 'solo'.obs; // 'solo' or 'team'
  final notesController = TextEditingController();

  var myGames = <Map<String, dynamic>>[].obs;

  final GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadMyGames();
    // Disabled background status check as we no longer use real-time tracking
    // _checkExistingSearch();
    // _initPusher();

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

      matchedRecords.value = result;
      isSearching(false);
      matchFound(true);

      if (result.isNotEmpty) {
        Get.snackbar(
          'تم العثور على لاعبين!',
          'لقد تم مطابقتك مع ${result.length} لاعبين',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xff9c27b0).withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start search: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> cancelSearch() async {
    isSearching(false);
    matchFound(false);
    matchResult.value = null;
    matchedRecords.clear();
  }
}
