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
  final GamePriceInfo? priceInfo;
  final bool? isFree;
  final String? freeType;
  final String? instructions;
  final String? worth;
  final bool? notified;
  final Map<String, dynamic>? meta;
  final Map<String, dynamic>? rawg;
  final String? trailerUrl; // rawg trailer
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
    this.priceInfo,
    this.isFree,
    this.freeType,
    this.instructions,
    this.worth,
    this.notified,
    this.meta,
    this.rawg,
    this.trailerUrl,
    this.createdAt,
    this.updatedAt,
  });

  String? get genre {
    if (genres != null && genres!.isNotEmpty) return genres!.first;
    if (meta != null && meta!['genre'] != null) return meta!['genre'];
    return null;
  }

  // --- Pricing helpers -----------------------------------------------------
  /// Whether this game has a discount (from deal.cut or priceInfo.cut)
  bool get hasDiscount {
    if (deal?.cut != null && deal!.cut! > 0) return true;
    if (priceInfo?.cut != null && priceInfo!.cut! > 0) return true;
    return false;
  }

  /// Whether this game is free (permanently or temporarily)
  bool get isFreeGame => isFree == true;

  /// Whether this game is a limited-time free game
  bool get isFreeLimited => freeType == 'temporary';

  /// Discount percentage (0-100)
  int? get discountPercent {
    if (deal?.cut != null && deal!.cut! > 0) return deal!.cut;
    return priceInfo?.cut;
  }

  /// Current display price string
  String? get displayPrice {
    if (isFreeGame) return 'مجاني';
    if (deal?.price != null) return '\$${deal!.price!.toStringAsFixed(2)}';
    if (priceInfo?.current != null) {
      return '\$${priceInfo!.current!.toStringAsFixed(2)}';
    }
    return worth;
  }

  /// Original price string (before discount)
  String? get displayOriginalPrice {
    if (deal?.regularPrice != null) {
      return '\$${deal!.regularPrice!.toStringAsFixed(2)}';
    }
    if (priceInfo?.regular != null) {
      return '\$${priceInfo!.regular!.toStringAsFixed(2)}';
    }
    return worth;
  }

  /// The expiry date for time-sensitive deals
  String? get endDate => deal?.expiry;

  /// Whether this game has any pricing information at all
  bool get hasPriceInfo =>
      isFreeGame ||
      deal != null ||
      priceInfo != null ||
      (worth != null && worth!.isNotEmpty);

  // --- RAWG helpers --------------------------------------------------------
  List<dynamic>? get rawgRequirements => rawg?['requirements'];
  Map<String, dynamic>? get rawgEsrb => rawg?['esrbRating'];
  List<dynamic>? get rawgStores => rawg?['stores'];
  List<dynamic>? get rawgTags => rawg?['tags'];
  List<dynamic>? get rawgRatings => rawg?['ratings'];
  int? get rawgPlaytime => rawg?['playtime'];
  String? get rawgWebsite => rawg?['website'];
  String? get rawgDescription =>
      rawg?['descriptionRaw'] ?? rawg?['description'];

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['_id'],
      title: json['title'],
      slug: json['slug'],
      status: json['status'],
      description: json["descriptionAr"] ?? json['description'],
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
      priceInfo: json['priceInfo'] != null
          ? GamePriceInfo.fromJson(json['priceInfo'])
          : null,
      isFree: json['isFree'],
      freeType: json['freeType'],
      instructions: json['instructions'],
      worth: json['worth'],
      notified: json['notified'],
      meta: json['meta'],
      rawg: json['rawg'] != null
          ? Map<String, dynamic>.from(json['rawg'] as Map)
          : null,
      trailerUrl: json['trailerUrl'],
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
      'priceInfo': priceInfo?.toJson(),
      'isFree': isFree,
      'freeType': freeType,
      'instructions': instructions,
      'worth': worth,
      'notified': notified,
      'meta': meta,
      'rawg': rawg,
      'trailerUrl': trailerUrl,
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

class GamePriceInfo {
  final double? current;
  final double? regular;
  final int? cut;
  final String? storeName;
  final String? storeUrl;
  final String? currency;
  final String? updatedAt;

  GamePriceInfo({
    this.current,
    this.regular,
    this.cut,
    this.storeName,
    this.storeUrl,
    this.currency,
    this.updatedAt,
  });

  factory GamePriceInfo.fromJson(Map<String, dynamic> json) {
    return GamePriceInfo(
      current: json['current']?.toDouble(),
      regular: json['regular']?.toDouble(),
      cut: json['cut'],
      storeName: json['storeName'],
      storeUrl: json['storeUrl'],
      currency: json['currency'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'regular': regular,
      'cut': cut,
      'storeName': storeName,
      'storeUrl': storeUrl,
      'currency': currency,
      'updatedAt': updatedAt,
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
