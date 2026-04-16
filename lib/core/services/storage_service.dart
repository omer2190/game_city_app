import 'dart:convert';
import 'package:get_storage/get_storage.dart' as gs;

class StorageService {
  static final gs.GetStorage _box = gs.GetStorage();

  static Future<void> init() async {
    await gs.GetStorage.init();
    print('StorageService: GetStorage initialized');
  }

  dynamic read<T>(String key) {
    var val = _box.read(key);
    if (val is String) {
      try {
        return jsonDecode(val);
      } catch (e) {
        return val;
      }
    }
    return val;
  }

  Future<void> write(String key, dynamic value) async {
    if (value == null) {
      await _box.remove(key);
      return;
    }

    if (value is String ||
        value is int ||
        value is double ||
        value is bool ||
        value is List) {
      await _box.write(key, value);
    } else {
      await _box.write(key, jsonEncode(value));
    }
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  bool hasData(String key) {
    return _box.hasData(key);
  }

  Future<void> clear() async {
    await _box.erase();
  }
}

class GetStorage {
  static final gs.GetStorage _box = gs.GetStorage();

  static Future<void> init() async => gs.GetStorage.init();

  dynamic read(String key) => _box.read(key);
  Future<void> write(String key, dynamic value) => _box.write(key, value);
  Future<void> remove(String key) => _box.remove(key);
  bool hasData(String key) => _box.hasData(key);
  Future<void> erase() => _box.erase();
}
