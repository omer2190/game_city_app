import 'user_model.dart';

class InvitationModel {
  final String? id;
  final String? inviterId;
  final UserModel? invitee;
  final UserModel? inviter;
  final String? code;
  final String? createdAt;

  InvitationModel({
    this.id,
    this.inviterId,
    this.invitee,
    this.inviter,
    this.code,
    this.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: (json['_id'] ?? json['id'])?.toString(),
      inviterId: json['inviterId']?.toString(),
      invitee: json['inviteeId'] != null && json['inviteeId'] is Map
          ? UserModel.fromJson(json['inviteeId'])
          : null,
      inviter: json['inviterId'] != null && json['inviterId'] is Map
          ? UserModel.fromJson(json['inviterId'])
          : null,
      code: json['code'],
      createdAt: json['createdAt'],
    );
  }
}

class InvitationValidationResult {
  final bool valid;
  final String? message;
  final UserModel? user;

  InvitationValidationResult({required this.valid, this.message, this.user});

  factory InvitationValidationResult.fromJson(Map<String, dynamic> json) {
    return InvitationValidationResult(
      valid: json['valid'] ?? false,
      message: json['message'],
      user: json['user'] != null && json['user'] is Map
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }
}

class MyCodeResponse {
  final String? codeInvite;

  MyCodeResponse({this.codeInvite});

  factory MyCodeResponse.fromJson(Map<String, dynamic> json) {
    return MyCodeResponse(codeInvite: json['codeInvite']);
  }
}

class MyTeamResponse {
  final List<InvitationModel> team;

  MyTeamResponse({required this.team});

  factory MyTeamResponse.fromJson(Map<String, dynamic> json) {
    return MyTeamResponse(
      team: (json['team'] as List? ?? [])
          .map((e) => InvitationModel.fromJson(e))
          .toList(),
    );
  }
}

class WhoInvitedMeResponse {
  final InvitationModel? invitedBy;

  WhoInvitedMeResponse({this.invitedBy});

  factory WhoInvitedMeResponse.fromJson(Map<String, dynamic> json) {
    return WhoInvitedMeResponse(
      invitedBy: json['invitedBy'] != null && json['invitedBy'] is Map
          ? InvitationModel.fromJson(json['invitedBy'])
          : null,
    );
  }
}
