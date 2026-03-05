import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';
import '../models/game_model.dart';

class GamesRepository {
  final ApiClient _apiClient = ApiClient();

  /// Unified endpoint for getting games.
  /// Type can be 'free', 'discounted', 'global', 'coming_soon', 'giveaway', 'all'.
  Future<Map<String, dynamic>> getGames({
    String type = 'all',
    int page = 1,
    int limit = 20,
    String? search,
    String? platform,
  }) async {
    final queryParams = {
      'type': type,
      'page': page.toString(),
      // 'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (platform != null && platform.isNotEmpty) 'platform': platform,
    };

    final uri = Uri.parse(
      ApiConstants.games,
    ).replace(queryParameters: queryParams);
    final response = await _apiClient.get(uri.toString());
    return response as Map<String, dynamic>;
  }

  Future<Game?> getGameById(String id) async {
    final response = await _apiClient.get('${ApiConstants.games}/$id');
    if (response is Map<String, dynamic> && response['success'] == true) {
      return Game.fromJson(response['item']);
    }
    return null;
  }

  Future<Map<String, dynamic>> searchOrRequestGame(String name) async {
    final response = await _apiClient.post(
      ApiConstants.gameSearchOrRequest,
      body: {'name': name},
    );
    return response as Map<String, dynamic>;
  }

  // --- Wrapper Methods for Backward Compatibility ---

  Future<List<Game>> getFreeGames() async {
    final response = await getGames(type: 'free', limit: 100);
    if (response['items'] != null) {
      final List<dynamic> items = response['items'];
      return items.map((item) => Game.fromJson(item)).toList();
    }
    return [];
  }

  Future<List<Game>> getTotallyFreeGames() async {
    final response = await getGames(type: 'giveaway', limit: 100);
    if (response['items'] != null) {
      final List<dynamic> items = response['items'];
      return items.map((item) => Game.fromJson(item)).toList();
    }
    return [];
  }

  Future<List<Game>> getDiscountedGames() async {
    final response = await getGames(type: 'discounted', limit: 100);
    if (response['items'] != null) {
      final List<dynamic> items = response['items'];
      return items.map((item) => Game.fromJson(item)).toList();
    }
    return [];
  }

  Future<List<dynamic>> getGlobalGames({
    int page = 1,
    String search = '',
  }) async {
    final response = await getGames(type: 'global', page: page, search: search);
    return response['items'] ?? [];
  }

  Future<Map<String, dynamic>> searchGlobalGame(String name) async {
    return searchOrRequestGame(name);
  }

  Future<List<Game>> getComingSoonGames() async {
    final response = await getGames(type: 'coming_soon', limit: 100);
    if (response['items'] != null) {
      final List<dynamic> items = response['items'];
      return items.map((item) => Game.fromJson(item)).toList();
    }
    return [];
  }
}
