import 'dart:typed_data';

/// A game detected as installed on the user's device
/// (Android apps or Windows programs/Steam/Epic games).
class InstalledGameModel {
  /// Display name of the game (e.g. "FIFA 25", "Elden Ring").
  final String name;

  /// Unique identifier on the device:
  /// - Android: package name (e.g. com.ea.gp.fifamobile)
  /// - Windows: source key (e.g. steam_440 or name + source)
  final String packageName;

  /// App icon bytes if available (Android).
  final Uint8List? icon;

  /// Where the game was found: 'android' | 'steam' | 'epic' | 'windows'.
  final String source;

  /// Human readable source label.
  final String sourceLabel;

  const InstalledGameModel({
    required this.name,
    required this.packageName,
    this.icon,
    required this.source,
    required this.sourceLabel,
  });

  /// Stable unique id used for selection/sync state.
  String get uniqueId => '$source:$packageName';

  Map<String, dynamic> toJson() => {
    'name': name,
    'packageName': packageName,
    'source': source,
    'sourceLabel': sourceLabel,
  };
}
