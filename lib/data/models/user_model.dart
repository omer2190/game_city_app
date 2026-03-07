class UserModel {
  final String? id;
  final String? userName;
  final String? email;
  final String? firstName;
  final String? lastName;
  final List<String>? userImage;
  final List<String>? role;
  final int? points;
  final String? gender;
  final UserProfile? userProfile;
  final List<SocialMediaService>? socialMedia;
  final List<dynamic>? playNow;
  final String? chatRoomId;
  final String? createdAt;
  final String? birthDate;
  final String? phone;
  final List<GeneralInfoItem>? generalInfo;
  final bool? isFriend;
  final bool? isVerified;

  UserModel({
    this.id,
    this.userName,
    this.email,
    this.firstName,
    this.lastName,
    this.userImage,
    this.role,
    this.points,
    this.gender,
    this.userProfile,
    this.socialMedia,
    this.playNow,
    this.chatRoomId,
    this.createdAt,
    this.birthDate,
    this.phone,
    this.generalInfo,
    this.isFriend,
    this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> displayData = json;

    // Check for nested user data (common in the new API response and other contexts)
    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      displayData = json['user'];
    } else if (json.containsKey('sender') &&
        json['sender'] is Map<String, dynamic>) {
      displayData = json['sender'];
    } else if (json.containsKey('from') &&
        json['from'] is Map<String, dynamic>) {
      displayData = json['from'];
    } else if (json.containsKey('recipient') &&
        json['recipient'] is Map<String, dynamic>) {
      displayData = json['recipient'];
    } else if (json.containsKey('friend') &&
        json['friend'] is Map<String, dynamic>) {
      displayData = json['friend'];
    }

    // Check for various ID fields
    String? requestId =
        (json['requestId'] ??
                displayData['requestId'] ??
                displayData['_id'] ??
                displayData['id'])
            ?.toString();

    // Map general info from userInfos if available, otherwise from generalInfo
    List<GeneralInfoItem>? generalInfoList;
    if (json.containsKey('userInfos') && json['userInfos'] is List) {
      generalInfoList = (json['userInfos'] as List)
          .map((i) => GeneralInfoItem.fromJson(i))
          .toList();
    } else if (displayData.containsKey('generalInfo') &&
        displayData['generalInfo'] is List) {
      generalInfoList = (displayData['generalInfo'] as List)
          .map((i) => GeneralInfoItem.fromJson(i))
          .toList();
    }

    List<SocialMediaService>? socialMediaList;
    if (json.containsKey('socialMedia') && json['socialMedia'] is List) {
      socialMediaList = (json['socialMedia'] as List)
          .map((i) => SocialMediaService.fromJson(i))
          .toList();
    } else if (displayData.containsKey('socialMedia') &&
        displayData['socialMedia'] is List) {
      socialMediaList = (displayData['socialMedia'] as List)
          .map((i) => SocialMediaService.fromJson(i))
          .toList();
    }

    final bool? isFriendVal = json['isFriend'] ?? displayData['isFriend'];

    return UserModel(
      createdAt: displayData['createdAt'],
      birthDate: displayData['birthDate'],
      phone: displayData['phone'],
      generalInfo: generalInfoList,
      isFriend: isFriendVal,
      isVerified: displayData['isVerified'],
      id: requestId,
      userName: displayData['userName'],
      email: displayData['email'],
      firstName: displayData['firstName'],
      lastName: displayData['lastName'],
      userImage: displayData['userImage'] != null
          ? List<String>.from(displayData['userImage'])
          : null,
      role: displayData['role'] != null
          ? List<String>.from(displayData['role'])
          : null,
      points: displayData['points'],
      gender: displayData['gender'],
      userProfile: displayData['userProfile'] != null
          ? UserProfile.fromJson(displayData['userProfile'])
          : null,
      socialMedia: socialMediaList,
      playNow: displayData['playNow'],
      chatRoomId:
          displayData['chatRoomId'] ??
          json['chatRoomId'] ??
          displayData['roomId'] ??
          json['roomId'],
    );
  }
}

class GlobalGame {
  final String? id;
  final String? name;
  final String? backgroundImage;
  final List<String>? genres;
  final double? rating;

  GlobalGame({
    this.id,
    this.name,
    this.backgroundImage,
    this.genres,
    this.rating,
  });

  factory GlobalGame.fromJson(Map<String, dynamic> json) {
    return GlobalGame(
      id: (json['_id'] ?? json['id'])?.toString(),
      name: json['name'],
      backgroundImage: json['backgroundImage'],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}

class UserProfile {
  final String? bio;
  final String? primaryColor;
  final List<String>? bgProfile;

  UserProfile({this.bio, this.primaryColor, this.bgProfile});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'],
      primaryColor: json['primaryColor'],
      bgProfile: json['bgProfile'] != null
          ? List<String>.from(json['bgProfile'])
          : null,
    );
  }
}

class GeneralInfoItem {
  final String? id;
  final String title;
  final String text;
  final String? typeId;

  GeneralInfoItem({
    this.id,
    required this.title,
    required this.text,
    this.typeId,
  });

  factory GeneralInfoItem.fromJson(Map<String, dynamic> json) {
    // Handle the nested structure: UserInfoTypeId { name } and value
    String title = '';
    String? typeId;
    if (json.containsKey('UserInfoTypeId') &&
        json['UserInfoTypeId'] is Map<String, dynamic>) {
      title = json['UserInfoTypeId']['name'] ?? '';
      typeId = json['UserInfoTypeId']['_id']?.toString();
    } else {
      title = json['title'] ?? '';
      typeId = json['typeId']?.toString();
    }

    return GeneralInfoItem(
      id: (json['_id'] ?? json['id'])?.toString(),
      title: title,
      text: json['value'] ?? json['text'] ?? '',
      typeId: typeId,
    );
  }
}

class SocialMediaService {
  final String id;
  final String? name;
  final String? key;
  final String? value;
  final String? icon;

  SocialMediaService({
    required this.id,
    this.name,
    this.key,
    this.value,
    this.icon,
  });

  factory SocialMediaService.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? serviceInfo;
    if (json['socialMediaId'] is Map<String, dynamic>) {
      serviceInfo = json['socialMediaId'];
    }

    String? key = (json['key'] ?? serviceInfo?['key'])?.toString();
    // Normalize common keys
    if (key == 'fasbook') key = 'facebook';

    String? name = (json['name'] ?? serviceInfo?['name'])?.toString();
    if ((name == null || name.isEmpty) && key != null && key.isNotEmpty) {
      name = key[0].toUpperCase() + key.substring(1);
    }

    return SocialMediaService(
      id:
          (json['_id'] ??
                  json['id'] ??
                  serviceInfo?['_id'] ??
                  serviceInfo?['id'] ??
                  '')
              .toString(),
      name: name,
      key: key,
      value: (json['username'] ?? json['value'] ?? json['link'])?.toString(),
      icon: (json['icon'] ?? serviceInfo?['icon'])?.toString(),
    );
  }
}
