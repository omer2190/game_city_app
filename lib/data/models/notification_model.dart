class NotificationModel {
  final String? id;
  final String? userId;
  final String? title;
  final String? body;
  final String? type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.type,
    this.data,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
