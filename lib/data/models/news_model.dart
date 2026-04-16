import 'package:game_city_app/data/models/user_model.dart';

class NewsResponse {
  final List<News>? news;
  final List<NewsType>? newsTypes;
  final int? total;
  final int? page;
  final int? totalPages;
  final int? limit;

  NewsResponse({
    this.news,
    this.newsTypes,
    this.total,
    this.page,
    this.totalPages,
    this.limit,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      news: json['news'] != null
          ? (json['news'] as List).map((i) => News.fromJson(i)).toList()
          : null,
      newsTypes: json['newsTypes'] != null
          ? (json['newsTypes'] as List)
                .map((i) => NewsType.fromJson(i))
                .toList()
          : null,
      total: json['total'],
      page: json['page'],
      totalPages: json['totalPages'],
      limit: json['limit'],
    );
  }
}

class NewsType {
  final String? id;
  final String? title;

  NewsType({this.id, this.title});

  factory NewsType.fromJson(Map<String, dynamic> json) {
    return NewsType(id: json['_id'], title: json['title']);
  }
}

class News {
  final String? id;
  final UserModel? userId;
  final String? title;
  final String? contentNew;
  final NewsType? newsType;
  final List<String>? images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  News({
    this.id,
    this.userId,
    this.title,
    this.contentNew,
    this.newsType,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['_id'],
      userId: json['userId'] != null
          ? UserModel.fromJson(json['userId'])
          : null,
      title: json['title'],
      contentNew: json['contentNew'],
      newsType: json['newsType'] != null
          ? NewsType.fromJson(json['newsType'])
          : null,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e?.toString() ?? '').toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      v: json['__v'],
    );
  }
}
