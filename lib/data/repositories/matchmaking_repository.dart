import '../models/matchmaking_model.dart';
import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';

class MatchmakingRepository {
  final ApiClient _apiClient = ApiClient();

  // ApiClient post/get methods handle token automatically if present in GetStorage

  Future<MatchmakingRecord> startSearch({
    required String gameId,
    required String type,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.baseUrl}/api/matchmaking/start', // Assuming /api prefix as per ApiConstants.login pattern
      body: {'gameId': gameId, 'type': type, 'notes': notes},
    );

    // According to spec:
    // One response: { success: true, message: "Match found immediately!", match: {...} }
    // Another: { success: true, message: "Started searching...", data: {...} }

    if (response['match'] != null) {
      return MatchmakingRecord(
        status: MatchmakingStatus.matched,
        match: MatchResult.fromJson(response['match']),
      );
    }

    if (response['data'] != null) {
      return MatchmakingRecord.fromJson(response['data']);
    }

    throw Exception('Unexpected response format from matchmaking/start');
  }

  Future<void> cancelSearch() async {
    await _apiClient.post('${ApiConstants.baseUrl}/api/matchmaking/cancel');
  }

  Future<MatchmakingRecord?> checkStatus() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/api/matchmaking/status',
      );
      // Assuming response is the record itself based on spec:
      // "content: application/json: schema: $ref: '#/components/schemas/MatchmakingRecord'"
      return MatchmakingRecord.fromJson(response);
    } catch (e) {
      // If 404 or other error, return null or rethrow
      return null;
    }
  }
}
