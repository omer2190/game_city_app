import 'package:game_city_app/data/models/game_model.dart';
import 'package:game_city_app/data/models/news_model.dart';

class HomeDashboardModel {
  final List<Advertisement>? advertisements;
  final List<RandomUser>? randomFriends;
  final List<Game>? latestFreeGames;
  final List<News>? latestNews;
  final List<RandomUser>? randomMatchmakers;
  final List<Game>? wishlistGames;

  HomeDashboardModel({
    this.advertisements,
    this.randomFriends,
    this.latestFreeGames,
    this.latestNews,
    this.randomMatchmakers,
    this.wishlistGames,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      advertisements: json['advertisements'] != null
          ? (json['advertisements'] as List)
                .map((i) => Advertisement.fromJson(i))
                .toList()
          : null,
      randomFriends: json['randomFriends'] != null
          ? (json['randomFriends'] as List)
                .map((i) => RandomUser.fromJson(i))
                .toList()
          : null,
      latestFreeGames: json['latestFreeGames'] != null
          ? (json['latestFreeGames'] as List)
                .map((i) => Game.fromJson(i))
                .toList()
          : null,
      latestNews: json['latestNews'] != null
          ? (json['latestNews'] as List).map((i) => News.fromJson(i)).toList()
          : null,
      randomMatchmakers: json['randomMatchmakers'] != null
          ? (json['randomMatchmakers'] as List)
                .map((i) => RandomUser.fromJson(i))
                .toList()
          : null,
      wishlistGames: json['wishlistGames'] != null
          ? (json['wishlistGames'] as List)
                .map((i) => Game.fromJson(i['game'] ?? i))
                .toList()
          : null,
    );
  }
}

class Advertisement {
  final String? id;
  final String? imageUrl;
  final String? newsId;
  final DateTime? startDate;
  final DateTime? endDate;

  Advertisement({
    this.id,
    this.imageUrl,
    this.newsId,
    this.startDate,
    this.endDate,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['_id'],
      imageUrl: json['imageUrl'],
      newsId: json['newsId'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

class RandomUser {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final List<String>? userImage;

  RandomUser({
    this.id,
    this.firstName,
    this.lastName,
    this.userName,
    this.userImage,
  });

  factory RandomUser.fromJson(Map<String, dynamic> json) {
    return RandomUser(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      userName: json['userName'],
      userImage: json['userImage'] != null
          ? List<String>.from(json['userImage'])
          : null,
    );
  }

  String get fullName =>
      [firstName, lastName].where((e) => e != null).join(' ');
}
