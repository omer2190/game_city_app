import 'package:get/get.dart';

import '../../../core/services/installed_games_service.dart';
import '../../../data/models/installed_game_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/games_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/user_play_now_controller.dart';

/// Sync state of a single installed game.
enum InstalledGameSyncStatus {
  /// Nothing done yet.
  idle,

  /// Searching for it in the system right now.
  syncing,

  /// Found and added to the user's "العب الآن" library.
  added,

  /// Already exists in the "العب الآن" library.
  already,

  /// Advanced search started (not found immediately).
  queued,

  /// Not found in the system.
  notFound,

  /// Something went wrong.
  error,
}

class InstalledGamesController extends GetxController {
  final InstalledGamesService _service = const InstalledGamesService();
  final GamesRepository _gamesRepository = GamesRepository();
  final AuthRepository _authRepository = AuthRepository();

  late final UserPlayNowController _playNowController;

  /// Games detected on the device.
  final games = <InstalledGameModel>[].obs;

  /// Selected games (by [InstalledGameModel.uniqueId]).
  final selected = <String>{}.obs;

  /// Per-game sync status.
  final statuses = <String, InstalledGameSyncStatus>{}.obs;

  final isLoading = false.obs;
  final isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _playNowController = Get.isRegistered<UserPlayNowController>()
        ? Get.find<UserPlayNowController>()
        : Get.put(UserPlayNowController());
  }

  /// Scans the current device (Android or Windows) for installed games.
  Future<void> detectInstalledGames() async {
    if (isLoading.value) return;
    isLoading(true);
    try {
      final found = await _service.fetchInstalledGames();
      games.assignAll(found);
      selected.clear();
      statuses.clear();
      if (found.isEmpty) {
        Get.snackbar(
          'لا توجد نتائج',
          'لم يتم العثور على ألعاب مثبتة على الجهاز.',
        );
      } else {
        Get.snackbar('تم الفحص', 'تم العثور على ${found.length} لعبة مثبتة.');
      }
    } catch (e) {
      Get.snackbar('خطأ', '$e');
    } finally {
      isLoading(false);
    }
  }

  bool isSelected(InstalledGameModel game) => selected.contains(game.uniqueId);

  void toggleSelection(InstalledGameModel game) {
    if (!selected.remove(game.uniqueId)) {
      selected.add(game.uniqueId);
    }
  }

  void toggleSelectAll() {
    if (selected.length == games.length) {
      selected.clear();
    } else {
      selected.assignAll(games.map((g) => g.uniqueId));
    }
  }

  InstalledGameSyncStatus statusOf(InstalledGameModel game) =>
      statuses[game.uniqueId] ?? InstalledGameSyncStatus.idle;

  /// For every selected game: searches for it in the system first,
  /// then adds the found game to the user's "العب الآن" library.
  Future<void> syncSelectedToPlayNow() async {
    final toSync = games.where((g) => selected.contains(g.uniqueId)).toList();
    if (toSync.isEmpty) {
      Get.snackbar('تنبيه', 'اختر لعبة واحدة على الأقل أولاً.');
      return;
    }
    if (isSyncing.value) return;
    isSyncing(true);

    var added = 0;
    var queued = 0;
    var failed = 0;
    try {
      for (final game in toSync) {
        final status = await _searchAndSync(game);
        switch (status) {
          case InstalledGameSyncStatus.added:
          case InstalledGameSyncStatus.already:
            added++;
          case InstalledGameSyncStatus.queued:
            queued++;
          default:
            failed++;
        }
      }

      Get.snackbar(
        'اكتمل المزامنة',
        'تمت الإضافة: $added • قيد البحث المتقدم: $queued • فشل: $failed',
      );
    } finally {
      isSyncing(false);
    }
  }

  /// Syncs a single installed game (used by the per-item add button).
  Future<void> syncSingleGame(InstalledGameModel game) async {
    if (isSyncing.value) return;
    final status = await _searchAndSync(game);
    switch (status) {
      case InstalledGameSyncStatus.added:
        Get.snackbar('نجاح', 'تمت إضافة "${game.name}" إلى العب الآن.');
      case InstalledGameSyncStatus.already:
        Get.snackbar('تنبيه', '"${game.name}" موجودة مسبقاً في العب الآن.');
      case InstalledGameSyncStatus.queued:
        Get.snackbar('جاري البحث', 'بدأنا بحثاً متقدماً عن "${game.name}".');
      case InstalledGameSyncStatus.notFound:
        Get.snackbar(
          'غير موجودة',
          'لم يتم العثور على "${game.name}" في النظام.',
        );
      case InstalledGameSyncStatus.error:
        Get.snackbar('خطأ', 'فشل مزامنة "${game.name}".');
      case InstalledGameSyncStatus.syncing:
      case InstalledGameSyncStatus.idle:
        break;
    }
  }

  /// 1) Searches the game in the system (`search-or-request` endpoint).
  /// 2) If found, adds it to the user's "العب الآن" library.
  Future<InstalledGameSyncStatus> _searchAndSync(
    InstalledGameModel game,
  ) async {
    statuses[game.uniqueId] = InstalledGameSyncStatus.syncing;
    try {
      final result = await _gamesRepository.searchGlobalGame(game.name);
      final int statusCode = result['statusCode'] ?? 500;

      String? gameId;

      if (statusCode == 200) {
        // Scenario 1: found locally in our library.
        final found = result['game'];
        if (found is Map<String, dynamic>) {
          gameId = (found['_id'] ?? found['id'])?.toString();
        } else if (found is List && found.isNotEmpty) {
          final first = found.first;
          if (first is Map<String, dynamic>) {
            gameId = (first['_id'] ?? first['id'])?.toString();
          }
        }
      } else if (statusCode == 201) {
        // Scenario 2: found externally and added to the library.
        final foundGames = result['games'];
        if (foundGames is List && foundGames.isNotEmpty) {
          final first = foundGames.first;
          if (first is Map<String, dynamic>) {
            gameId = (first['_id'] ?? first['id'])?.toString();
          }
        }
      } else if (statusCode == 202) {
        // Scenario 3: advanced search queued.
        statuses[game.uniqueId] = InstalledGameSyncStatus.queued;
        return InstalledGameSyncStatus.queued;
      }

      if (gameId == null || gameId.isEmpty) {
        statuses[game.uniqueId] = InstalledGameSyncStatus.notFound;
        return InstalledGameSyncStatus.notFound;
      }

      if (_playNowController.isPlaying(gameId)) {
        statuses[game.uniqueId] = InstalledGameSyncStatus.already;
        return InstalledGameSyncStatus.already;
      }

      final response = await _authRepository.addGameToPlayNow(gameId);
      if (response['playNow'] != null) {
        _playNowController.playNowList.assignAll(
          _extractIds(response['playNow']),
        );
        Get.find<AuthController>().refreshProfile();
        statuses[game.uniqueId] = InstalledGameSyncStatus.added;
        return InstalledGameSyncStatus.added;
      }

      statuses[game.uniqueId] = InstalledGameSyncStatus.error;
      return InstalledGameSyncStatus.error;
    } catch (_) {
      statuses[game.uniqueId] = InstalledGameSyncStatus.error;
      return InstalledGameSyncStatus.error;
    }
  }

  List<String> _extractIds(dynamic playNow) {
    if (playNow is! List) return [];
    return playNow
        .map((item) {
          if (item is String) return item;
          if (item is Map<String, dynamic>) {
            return (item['_id'] ?? item['id'])?.toString() ?? '';
          }
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }
}
