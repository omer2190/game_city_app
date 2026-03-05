import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _apiClient.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    return await _apiClient.post(
      ApiConstants.googleLogin,
      body: {'idToken': idToken},
    );
  }

  Future<Map<String, dynamic>> register({
    required String userName,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return await _apiClient.post(
      ApiConstants.register,
      body: {
        'userName': userName,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _apiClient.get(ApiConstants.userProfile);
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> body) async {
    return await _apiClient.put(ApiConstants.updateUser, body: body);
  }

  Future<Map<String, dynamic>> updateUserImage(String filePath) async {
    return await _apiClient.dioMultipartRequest(
      ApiConstants.updateUser,
      method: 'PUT',
      fileKey: 'userImage',
      filePath: filePath,
    );
  }

  Future<Map<String, dynamic>> addGameToPlayNow(String gameId) async {
    return await _apiClient.post(
      '${ApiConstants.baseUrl}/api/users/play-now/add',
      body: {'gameId': gameId},
    );
  }

  Future<Map<String, dynamic>> removeGameFromPlayNow(String gameId) async {
    return await _apiClient.post(
      '${ApiConstants.baseUrl}/api/users/play-now/remove',
      body: {'gameId': gameId},
    );
  }

  Future<List<dynamic>> getUserInfoTypes() async {
    return await _apiClient.get(ApiConstants.userInfoTypes);
  }

  Future<Map<String, dynamic>> addUserInfo(String typeId, String value) async {
    return await _apiClient.post(
      ApiConstants.userInfo,
      body: {'UserInfoTypeId': typeId, 'value': value},
    );
  }

  Future<Map<String, dynamic>> deleteUserInfo(String infoId) async {
    return await _apiClient.delete('${ApiConstants.userInfo}/$infoId');
  }

  Future<List<dynamic>> getSocialMediaServices() async {
    return await _apiClient.get(ApiConstants.socialMedia);
  }

  Future<Map<String, dynamic>> addSocialMediaLink({
    required String socialMediaId,
    required String username,
  }) async {
    return await _apiClient.post(
      ApiConstants.socialMediaLink,
      body: {'socialMediaId': socialMediaId, 'username': username},
    );
  }

  Future<Map<String, dynamic>> deleteSocialMediaLink(String linkId) async {
    return await _apiClient.delete('${ApiConstants.socialMediaLink}/$linkId');
  }
}
