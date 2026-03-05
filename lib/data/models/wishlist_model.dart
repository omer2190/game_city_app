import 'game_model.dart';

class WishlistEntry {
  final String id;
  final String user;
  final Game game;
  final DateTime createdAt;
  final DateTime updatedAt;

  WishlistEntry({
    required this.id,
    required this.user,
    required this.game,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WishlistEntry.fromJson(Map<String, dynamic> json) {
    return WishlistEntry(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      game: Game.fromJson(json['game'] ?? {}),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
