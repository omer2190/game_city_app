import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';

/// Geometry of a level frame image, measured from the actual PNG assets.
///
/// All coordinates are in the original image pixel space.
class LevelFrameGeometry {
  const LevelFrameGeometry({
    required this.imgW,
    required this.imgH,
    required this.holeCx,
    required this.holeCy,
    required this.holeH,
    required this.holePts,
  });

  /// Full frame image size (px).
  final double imgW;
  final double imgH;

  /// Center of the transparent hole (px).
  final double holeCx;
  final double holeCy;

  /// Height of the hole (px). Used as the reference dimension when scaling.
  final double holeH;

  /// Normalized hole boundary points (right side, top → bottom).
  ///
  /// `dx` is the half-width divided by `holeH / 2`, `dy` is the offset from
  /// the hole center divided by `holeH / 2`.
  final List<Offset> holePts;

  /// Maximum normalized half-width of the hole.
  double get maxHalfWidth {
    var max = 0.0;
    for (final p in holePts) {
      if (p.dx > max) max = p.dx;
    }
    return max;
  }
}

/// Level assets (frames + emojis) and helpers.
///
/// There are 8 levels. Each level has a frame image (`assets/images/frem/`)
/// that is overlaid on the user avatar, and an emoji image
/// (`assets/images/emojis/`) shown next to the user name.
class LevelAssets {
  LevelAssets._();

  static const int maxLevel = 8;

  static const List<String> frameAssets = [
    'assets/images/frem/frem1.png',
    'assets/images/frem/frem2.png',
    'assets/images/frem/frem3.png',
    'assets/images/frem/frem4.png',
    'assets/images/frem/frem5.png',
    'assets/images/frem/frem6.png',
    'assets/images/frem/frem7.png',
    'assets/images/frem/frem8.png',
  ];

  static const List<String> emojiAssets = [
    'assets/images/emojis/emojis1.png',
    'assets/images/emojis/emojis2.png',
    'assets/images/emojis/emojis3.png',
    'assets/images/emojis/emojis4.png',
    'assets/images/emojis/emojis5.png',
    'assets/images/emojis/emojis6.png',
    'assets/images/emojis/emojis7.png',
    'assets/images/emojis/emojis8.png',
  ];

  /// Known level names (English + Arabic) used as a fallback when the level
  /// field is not numeric.
  static const List<String> _levelNames = [
    'Bronze',
    'برونزي',
    'Silver',
    'فضي',
    'Gold',
    'ذهبي',
    'Platinum',
    'بلاتيني',
    'Diamond',
    'ماسي',
    'Master',
    'ماستر',
    'Grand Master',
    'غراند ماستر',
    'Shocker Daddy',
    'شوكر دادي',
  ];

  static const List<LevelFrameGeometry> geometries = [
    // ── Level 1-3: shield / diamond shape ────────────────────────────────
    LevelFrameGeometry(
      imgW: 2008,
      imgH: 2376,
      holeCx: 1004,
      holeCy: 1468,
      holeH: 1813,
      holePts: [
        Offset(0.000, -1.001),
        Offset(0.632, -0.901),
        Offset(0.750, -0.801),
        Offset(0.899, -0.702),
        Offset(0.988, -0.601),
        Offset(1.033, -0.501),
        Offset(1.065, -0.402),
        Offset(1.088, -0.301),
        Offset(1.101, -0.201),
        Offset(1.105, -0.101),
        Offset(1.100, -0.001),
        Offset(1.086, 0.099),
        Offset(1.063, 0.199),
        Offset(1.029, 0.299),
        Offset(0.983, 0.399),
        Offset(0.925, 0.499),
        Offset(0.851, 0.599),
        Offset(0.757, 0.699),
        Offset(0.635, 0.799),
        Offset(0.460, 0.899),
        Offset(0.000, 0.999),
      ],
    ),
    LevelFrameGeometry(
      imgW: 2007,
      imgH: 2376,
      holeCx: 1003,
      holeCy: 1468,
      holeH: 1813,
      holePts: [
        Offset(0.000, -1.001),
        Offset(0.632, -0.901),
        Offset(0.750, -0.801),
        Offset(0.899, -0.702),
        Offset(0.988, -0.601),
        Offset(1.033, -0.501),
        Offset(1.065, -0.402),
        Offset(1.088, -0.301),
        Offset(1.101, -0.201),
        Offset(1.105, -0.101),
        Offset(1.100, -0.001),
        Offset(1.086, 0.099),
        Offset(1.063, 0.199),
        Offset(1.029, 0.299),
        Offset(0.983, 0.399),
        Offset(0.925, 0.499),
        Offset(0.851, 0.599),
        Offset(0.757, 0.699),
        Offset(0.635, 0.799),
        Offset(0.460, 0.899),
        Offset(0.000, 0.999),
      ],
    ),
    LevelFrameGeometry(
      imgW: 2008,
      imgH: 2376,
      holeCx: 1004,
      holeCy: 1468,
      holeH: 1813,
      holePts: [
        Offset(0.000, -1.001),
        Offset(0.632, -0.901),
        Offset(0.750, -0.801),
        Offset(0.899, -0.702),
        Offset(0.988, -0.601),
        Offset(1.033, -0.501),
        Offset(1.065, -0.402),
        Offset(1.088, -0.301),
        Offset(1.101, -0.201),
        Offset(1.105, -0.101),
        Offset(1.100, -0.001),
        Offset(1.086, 0.099),
        Offset(1.063, 0.199),
        Offset(1.029, 0.299),
        Offset(0.983, 0.399),
        Offset(0.925, 0.499),
        Offset(0.851, 0.599),
        Offset(0.757, 0.699),
        Offset(0.635, 0.799),
        Offset(0.460, 0.899),
        Offset(0.000, 0.999),
      ],
    ),
    // ── Level 4-7: circle with a slightly pinched top ────────────────────
    LevelFrameGeometry(
      imgW: 2007,
      imgH: 2926,
      holeCx: 1003,
      holeCy: 1922,
      holeH: 2004,
      holePts: [
        Offset(0.000, -1.000),
        Offset(0.436, -0.900),
        Offset(0.509, -0.800),
        Offset(0.590, -0.701),
        Offset(0.720, -0.601),
        Offset(0.856, -0.500),
        Offset(0.917, -0.400),
        Offset(0.954, -0.300),
        Offset(0.980, -0.201),
        Offset(0.995, -0.101),
        Offset(1.000, 0.000),
        Offset(0.995, 0.100),
        Offset(0.980, 0.200),
        Offset(0.954, 0.299),
        Offset(0.917, 0.399),
        Offset(0.866, 0.500),
        Offset(0.800, 0.600),
        Offset(0.714, 0.700),
        Offset(0.600, 0.799),
        Offset(0.437, 0.899),
        Offset(0.000, 1.000),
      ],
    ),
    LevelFrameGeometry(
      imgW: 2357,
      imgH: 3114,
      holeCx: 1178,
      holeCy: 2110,
      holeH: 2004,
      holePts: [
        Offset(0.000, -1.000),
        Offset(0.436, -0.900),
        Offset(0.509, -0.800),
        Offset(0.590, -0.701),
        Offset(0.720, -0.601),
        Offset(0.856, -0.500),
        Offset(0.917, -0.400),
        Offset(0.954, -0.300),
        Offset(0.980, -0.201),
        Offset(0.995, -0.101),
        Offset(1.000, 0.000),
        Offset(0.995, 0.100),
        Offset(0.980, 0.200),
        Offset(0.954, 0.299),
        Offset(0.917, 0.399),
        Offset(0.866, 0.500),
        Offset(0.800, 0.600),
        Offset(0.714, 0.700),
        Offset(0.600, 0.799),
        Offset(0.437, 0.899),
        Offset(0.000, 1.000),
      ],
    ),
    LevelFrameGeometry(
      imgW: 2534,
      imgH: 3139,
      holeCx: 1267,
      holeCy: 2135,
      holeH: 2004,
      holePts: [
        Offset(0.000, -1.000),
        Offset(0.436, -0.900),
        Offset(0.509, -0.800),
        Offset(0.590, -0.701),
        Offset(0.720, -0.601),
        Offset(0.856, -0.500),
        Offset(0.917, -0.400),
        Offset(0.954, -0.300),
        Offset(0.980, -0.201),
        Offset(0.995, -0.101),
        Offset(1.000, 0.000),
        Offset(0.996, 0.100),
        Offset(0.980, 0.200),
        Offset(0.955, 0.299),
        Offset(0.917, 0.399),
        Offset(0.866, 0.500),
        Offset(0.800, 0.600),
        Offset(0.714, 0.700),
        Offset(0.600, 0.799),
        Offset(0.437, 0.899),
        Offset(0.000, 1.000),
      ],
    ),
    LevelFrameGeometry(
      imgW: 2775,
      imgH: 3362,
      holeCx: 1380,
      holeCy: 2358,
      holeH: 2004,
      holePts: [
        Offset(0.000, -1.000),
        Offset(0.436, -0.900),
        Offset(0.509, -0.800),
        Offset(0.590, -0.701),
        Offset(0.720, -0.601),
        Offset(0.856, -0.500),
        Offset(0.917, -0.400),
        Offset(0.954, -0.300),
        Offset(0.980, -0.201),
        Offset(0.995, -0.101),
        Offset(1.000, 0.000),
        Offset(0.995, 0.100),
        Offset(0.980, 0.200),
        Offset(0.954, 0.299),
        Offset(0.917, 0.399),
        Offset(0.866, 0.500),
        Offset(0.800, 0.600),
        Offset(0.714, 0.700),
        Offset(0.600, 0.799),
        Offset(0.437, 0.899),
        Offset(0.000, 1.000),
      ],
    ),
    // ── Level 8: circle with a more decorated top ────────────────────────
    LevelFrameGeometry(
      imgW: 2511,
      imgH: 3392,
      holeCx: 1367,
      holeCy: 2388,
      holeH: 2004,
      holePts: [
        Offset(0.000, -1.000),
        Offset(0.415, -0.900),
        Offset(0.509, -0.800),
        Offset(0.590, -0.701),
        Offset(0.720, -0.601),
        Offset(0.782, -0.500),
        Offset(0.775, -0.400),
        Offset(0.787, -0.300),
        Offset(0.888, -0.201),
        Offset(0.938, -0.101),
        Offset(0.980, 0.000),
        Offset(0.995, 0.100),
        Offset(0.980, 0.200),
        Offset(0.954, 0.299),
        Offset(0.917, 0.399),
        Offset(0.866, 0.500),
        Offset(0.800, 0.600),
        Offset(0.714, 0.700),
        Offset(0.600, 0.799),
        Offset(0.437, 0.899),
        Offset(0.000, 1.000),
      ],
    ),
  ];

  /// Returns the 1-based level of [user], or null when unknown.
  static int? levelOf(UserModel user) {
    final raw = user.level;
    if (raw != null && raw.isNotEmpty && raw != 'null') {
      final n = int.tryParse(raw);
      if (n != null && n >= 1 && n <= maxLevel) return n;
    }
    final name = user.levelName ?? user.levelArabicName;
    if (name != null && name.isNotEmpty) {
      final idx = _levelNames.indexOf(name);
      if (idx >= 0) return (idx ~/ 2) + 1;
    }
    return null;
  }

  /// Returns the 1-based level from a raw user map, or null when unknown.
  static int? levelFromMap(Map<String, dynamic> json) {
    final raw = json['level'];
    if (raw != null) {
      final s = raw.toString();
      if (s.isNotEmpty && s != 'null') {
        final n = int.tryParse(s);
        if (n != null && n >= 1 && n <= maxLevel) return n;
      }
    }
    final name = json['levelName'] ?? json['levelArabicName'];
    if (name != null) {
      final s = name.toString();
      if (s.isNotEmpty) {
        final idx = _levelNames.indexOf(s);
        if (idx >= 0) return (idx ~/ 2) + 1;
      }
    }
    return null;
  }

  static String? frameAssetFor(int level) =>
      (level >= 1 && level <= maxLevel) ? frameAssets[level - 1] : null;

  static String? emojiAssetFor(int level) =>
      (level >= 1 && level <= maxLevel) ? emojiAssets[level - 1] : null;

  static LevelFrameGeometry? geometryFor(int level) =>
      (level >= 1 && level <= maxLevel) ? geometries[level - 1] : null;
}

/// Clips a widget to the exact shape of a level frame hole.
class LevelHoleClipper extends CustomClipper<Path> {
  LevelHoleClipper(this.holePts);

  final List<Offset> holePts;

  @override
  Path getClip(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.height / 2;

    for (int i = 0; i < holePts.length; i++) {
      final x = cx + holePts[i].dx * r;
      final y = cy + holePts[i].dy * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    // Mirror back up the left side.
    for (int i = holePts.length - 2; i >= 1; i--) {
      path.lineTo(cx - holePts[i].dx * r, cy + holePts[i].dy * r);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant LevelHoleClipper oldClipper) =>
      oldClipper.holePts != holePts;
}

/// Small level emoji shown next to the user name.
class LevelEmoji extends StatelessWidget {
  const LevelEmoji({super.key, required this.level, this.height = 22});

  /// 1-based level (1..8). Levels outside the range render nothing.
  final int level;

  final double height;

  @override
  Widget build(BuildContext context) {
    final asset = LevelAssets.emojiAssetFor(level);
    if (asset == null) return const SizedBox.shrink();
    return Image.asset(asset, height: height, fit: BoxFit.contain);
  }
}
