class Game {
  final String? id;
  final String? title;
  final String? slug;
  final String? status;
  final String? description;
  final String? url;
  final String? image;
  final List<String>? screenshots;
  final ExternalIds? externalIds;
  final String? released;
  final double? rating;
  final int? metacritic;
  final List<String>? platforms;
  final List<String>? genres;
  final String? developer;
  final String? publisher;
  final String? store;
  final List<String>? sourceTypes;
  final GameDeal? deal;
  final bool? isFree;
  final String? freeType;
  final String? instructions;
  final String? worth;
  final bool? notified;
  final Map<String, dynamic>? meta;
  final String? createdAt;
  final String? updatedAt;

  Game({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.url,
    this.image,
    this.screenshots,
    this.externalIds,
    this.released,
    this.status,
    this.rating,
    this.metacritic,
    this.platforms,
    this.genres,
    this.developer,
    this.publisher,
    this.store,
    this.sourceTypes,
    this.deal,
    this.isFree,
    this.freeType,
    this.instructions,
    this.worth,
    this.notified,
    this.meta,
    this.createdAt,
    this.updatedAt,
  });

  String? get genre {
    if (genres != null && genres!.isNotEmpty) return genres!.first;
    if (meta != null && meta!['genre'] != null) return meta!['genre'];
    return null;
  }

  String? get endDate => deal?.expiry;

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['_id'],
      title: json['title'],
      slug: json['slug'],
      status: json['status'],
      description: json['description'],
      url: json['url'],
      image: json['image'],
      screenshots: json['screenshots'] != null
          ? (json['screenshots'] as List)
                .map((e) => e?.toString() ?? '')
                .toList()
          : null,
      externalIds: json['externalIds'] != null
          ? ExternalIds.fromJson(json['externalIds'])
          : null,
      released: json['released'],
      rating: json['rating']?.toDouble(),
      metacritic: json['metacritic'],
      platforms: json['platforms'] != null
          ? (json['platforms'] as List).map((e) => e?.toString() ?? '').toList()
          : null,
      genres: json['genres'] != null
          ? (json['genres'] as List).map((e) => e?.toString() ?? '').toList()
          : null,
      developer: json['developer'],
      publisher: json['publisher'],
      store: json['store'],
      sourceTypes: json['sourceTypes'] != null
          ? (json['sourceTypes'] as List)
                .map((e) => e?.toString() ?? '')
                .toList()
          : null,
      deal: json['deal'] != null ? GameDeal.fromJson(json['deal']) : null,
      isFree: json['isFree'],
      freeType: json['freeType'],
      instructions: json['instructions'],
      worth: json['worth'],
      notified: json['notified'],
      meta: json['meta'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'slug': slug,
      'status': status,
      'description': description,
      'url': url,
      'image': image,
      'screenshots': screenshots,
      'externalIds': externalIds?.toJson(),
      'released': released,
      'rating': rating,
      'metacritic': metacritic,
      'platforms': platforms,
      'genres': genres,
      'developer': developer,
      'publisher': publisher,
      'store': store,
      'sourceTypes': sourceTypes,
      'deal': deal?.toJson(),
      'isFree': isFree,
      'freeType': freeType,
      'instructions': instructions,
      'worth': worth,
      'notified': notified,
      'meta': meta,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Countdown helpers for coming soon games
  Map<String, int> get countdown {
    final dateStr = released ?? deal?.expiry;
    if (dateStr == null) return {'days': 0, 'hours': 0, 'minutes': 0};
    try {
      final releaseDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (releaseDate.isBefore(now)) {
        return {'days': 0, 'hours': 0, 'minutes': 0};
      }

      final difference = releaseDate.difference(now);
      return {
        'days': difference.inDays,
        'hours': difference.inHours % 24,
        'minutes': difference.inMinutes % 60,
      };
    } catch (e) {
      return {'days': 0, 'hours': 0, 'minutes': 0};
    }
  }

  String get remainingTime {
    final dateStr = released ?? deal?.expiry;
    if (dateStr == null) return "";
    try {
      final releaseDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (releaseDate.isBefore(now)) return "صدرت بالفعل";

      final difference = releaseDate.difference(now);

      int years = releaseDate.year - now.year;
      int months = releaseDate.month - now.month;
      int days = releaseDate.day - now.day;

      if (days < 0) {
        months -= 1;
        days += DateTime(releaseDate.year, releaseDate.month, 0).day;
      }
      if (months < 0) {
        years -= 1;
        months += 12;
      }

      if (years > 0) {
        return "$years سنة و $months شهر و $days يوم";
      } else if (months > 0) {
        return "$months شهر و $days يوم";
      } else if (difference.inDays > 0) {
        return "${difference.inDays} يوم";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} ساعة";
      } else {
        return "أقل من ساعة";
      }
    } catch (e) {
      return "";
    }
  }
}

class ExternalIds {
  final dynamic rawg;
  final String? freeToGame;
  final String? itad;
  final String? steam;
  final dynamic gamerpower;

  ExternalIds({
    this.rawg,
    this.freeToGame,
    this.itad,
    this.steam,
    this.gamerpower,
  });

  factory ExternalIds.fromJson(Map<String, dynamic> json) {
    return ExternalIds(
      rawg: json['rawg'],
      freeToGame: json['freeToGame'],
      itad: json['itad'],
      steam: json['steam'],
      gamerpower: json['gamerpower'],
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      'rawg': rawg,
      'freeToGame': freeToGame,
      'itad': itad,
      'steam': steam,
      'gamerpower': gamerpower,
    };
  }
}

class GameDeal {
  final String? shopName;
  final double? price;
  final double? regularPrice;
  final int? cut;
  final String? url;
  final String? expiry;
  final String? timestamp;
  final String? worth;

  GameDeal({
    this.shopName,
    this.price,
    this.regularPrice,
    this.cut,
    this.url,
    this.expiry,
    this.timestamp,
    this.worth,
  });

  String? get displayWorth =>
      worth ?? (regularPrice != null ? '\$$regularPrice' : null);

  factory GameDeal.fromJson(Map<String, dynamic> json) {
    return GameDeal(
      shopName: json['shopName'],
      price: json['price']?.toDouble(),
      regularPrice: json['regularPrice']?.toDouble(),
      cut: json['cut'],
      url: json['url'],
      expiry: json['expiry'],
      timestamp: json['timestamp'],
      worth: json['worth'],
    );
  }
  // to json
  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'price': price,
      'regularPrice': regularPrice,
      'cut': cut,
      'url': url,
      'expiry': expiry,
      'timestamp': timestamp,
      'worth': worth,
    };
  }
}
