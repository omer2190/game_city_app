enum MatchmakingStatus { searching, matched, cancelled }

class MatchmakingRecord {
  final String? id;
  final String? userId; // Our user ID
  final String? gameId;
  final String? type; // 'solo' or 'team'
  final String? notes;
  final MatchmakingStatus? status;
  final DateTime? createdAt;
  final MatchResult? match; // For when a match is found immediately

  MatchmakingRecord({
    this.id,
    this.userId,
    this.gameId,
    this.type,
    this.notes,
    this.status,
    this.createdAt,
    this.match,
  });

  factory MatchmakingRecord.fromJson(Map<String, dynamic> json) {
    return MatchmakingRecord(
      id: json['_id'],
      userId: json['userId'],
      gameId: json['gameId'],
      type: json['type'],
      notes: json['notes'],
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      match: json['match'] != null ? MatchResult.fromJson(json['match']) : null,
    );
  }

  static MatchmakingStatus? _parseStatus(String? status) {
    if (status == 'searching') return MatchmakingStatus.searching;
    if (status == 'matched') return MatchmakingStatus.matched;
    if (status == 'cancelled') return MatchmakingStatus.cancelled;
    return null;
  }
}

class MatchResult {
  final String? withUserId;
  final String? userName;
  final String? firstName;
  final String? lastName;
  final List<String>? userImages;
  final String? gameId;
  final String? type;
  final String? notes;

  MatchResult({
    this.withUserId,
    this.userName,
    this.firstName,
    this.lastName,
    this.userImages,
    this.gameId,
    this.type,
    this.notes,
  });

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    String? id;
    String? uName;
    String? fName;
    String? lName;
    List<String>? images;

    // Detect if nested object is in 'with' or 'matchWith' (backend fluctuates)
    final userObj = json['with'] ?? json['matchWith'];

    if (userObj is Map) {
      final map = Map<String, dynamic>.from(userObj);
      id = map['_id'] ?? map['id'];
      uName = map['userName'];
      fName = map['firstName'];
      lName = map['lastName'];
      if (map['userImage'] is List) {
        images = (map['userImage'] as List).cast<String>();
      } else if (map['userImage'] is String) {
        images = [map['userImage'] as String];
      }
    } else if (userObj != null) {
      id = userObj.toString();
    }

    return MatchResult(
      withUserId: id,
      userName: uName,
      firstName: fName,
      lastName: lName,
      userImages: images,
      gameId: json['gameId'],
      type: json['type'],
      notes: json['notes'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'withUserId': withUserId,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'userImages': userImages,
      'gameId': gameId,
      'type': type,
      'notes': notes,
    };
  }
}
