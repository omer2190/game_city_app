import 'user_model.dart';

class Comments {
  String? id;
  UserModel? userId;
  String? newsId;
  String? content;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Comments({
    this.id,
    this.userId,
    this.newsId,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Comments.fromJson(Map<String, dynamic> json) => Comments(
    id: json["_id"],
    userId: json["userId"] == null ? null : UserModel.fromJson(json["userId"]),
    newsId: json["newsId"],
    content: json["content"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    // "userId": userId?.toJson(),
    "newsId": newsId,
    "content": content,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
