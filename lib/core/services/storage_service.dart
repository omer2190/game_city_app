import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GetStorage {
  static SharedPreferences? _prefs;

  factory GetStorage() {
    return _instance;
  }

  static final GetStorage _instance = GetStorage._internal();

  GetStorage._internal();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('StorageService: SharedPreferences initialized: ${_prefs != null}');
  }

  dynamic read<T>(String key) {
    if (_prefs == null) {
      print('CRITICAL: _prefs is null inside read() fetching key: $key');
      return null;
    }
    var val = _prefs!.get(key);
    if (val is String) {
      try {
        // Attempt to decode JSON in case it was explicitly encoded (e.g., Map or List)
        return jsonDecode(val);
      } catch (e) {
        // Not a JSON string
        return val;
      }
    }
    return val;
  }

  Future<bool> write(String key, dynamic value) async {
    if (_prefs == null) {
      print('CRITICAL: _prefs is null inside write(), initializing...');
      await init();
    }
    if (_prefs == null) return false;

    if (value == null) {
      return await _prefs!.remove(key);
    }

    bool success = false;
    if (value is String) {
      success = await _prefs!.setString(key, value);
    } else if (value is int) {
      success = await _prefs!.setInt(key, value);
    } else if (value is double) {
      success = await _prefs!.setDouble(key, value);
    } else if (value is bool) {
      success = await _prefs!.setBool(key, value);
    } else if (value is List<String>) {
      success = await _prefs!.setStringList(key, value);
    } else {
      // Encode maps, objects or unhandled types to json string
      success = await _prefs!.setString(key, jsonEncode(value));
    }
    return success;
  }

  Future<void> remove(String key) async {
    if (_prefs == null) return;
    await _prefs!.remove(key);
  }

  bool hasData(String key) {
    if (_prefs == null) {
      print('CRITICAL: _prefs is null inside hasData()');
      return false;
    }
    return _prefs!.containsKey(key);
  }
}
