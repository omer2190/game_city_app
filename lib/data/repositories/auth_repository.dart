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

  Future<Map<String, dynamic>> loginWithGoogle(
    String idToken, {
    String? inviteCode,
  }) async {
    final body = <String, dynamic>{'idToken': idToken};
    if (inviteCode != null && inviteCode.isNotEmpty) {
      body['inviteCode'] = inviteCode;
    }
    return await _apiClient.post(ApiConstants.googleLogin, body: body);
  }

  Future<Map<String, dynamic>> verifyAccount(String email, String code) async {
    return await _apiClient.post(
      ApiConstants.verifyAccount,
      body: {'email': email, 'code': code},
    );
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _apiClient.post(
      ApiConstants.forgotPassword,
      body: {'email': email},
    );
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return await _apiClient.post(
      ApiConstants.resetPassword,
      body: {'email': email, 'code': code, 'newPassword': newPassword},
    );
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _apiClient.post(
      ApiConstants.changePassword,
      body: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  Future<Map<String, dynamic>> register({
    required String userName,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? inviteCode,
  }) async {
    final body = <String, dynamic>{
      'userName': userName,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    };
    if (inviteCode != null && inviteCode.isNotEmpty) {
      body['inviteCode'] = inviteCode;
    }
    return await _apiClient.post(ApiConstants.register, body: body);
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

  Future<Map<String, dynamic>> updateUserBackgroundImage(
    String filePath,
  ) async {
    return await _apiClient.dioMultipartRequest(
      ApiConstants.updateUser,
      method: 'PUT',
      fileKey: 'bgProfile',
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

  // ─── Invitation Methods ───────────────────────────────────────────

  Future<Map<String, dynamic>> validateInviteCode(String code) async {
    return await _apiClient.get(ApiConstants.validateInviteCode(code));
  }

  Future<Map<String, dynamic>> getMyInviteCode() async {
    return await _apiClient.get(ApiConstants.myInviteCode);
  }

  Future<Map<String, dynamic>> getMyTeam() async {
    return await _apiClient.get(ApiConstants.myTeam);
  }

  Future<Map<String, dynamic>> getWhoInvitedMe() async {
    return await _apiClient.get(ApiConstants.whoInvitedMe);
  }

  Future<Map<String, dynamic>> joinWithInviteCode(String code) async {
    return await _apiClient.post(
      ApiConstants.joinWithInviteCode,
      body: {'code': code},
    );
  }
}
