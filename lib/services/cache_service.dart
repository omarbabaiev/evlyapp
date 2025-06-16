import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Cache-də saxlanılan data strukturu
class CacheItem {
  final dynamic data;
  final DateTime timestamp;

  CacheItem(this.data, this.timestamp);

  Map<String, dynamic> toJson() => {
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CacheItem.fromJson(Map<String, dynamic> json) {
    return CacheItem(
      json['data'],
      DateTime.parse(json['timestamp']),
    );
  }
}

class CacheService extends GetxService {
  static CacheService get to => Get.find();
  final _storage = GetStorage();

  // Cache müddəti (24 saat)
  static const Duration _cacheExpiration = Duration(hours: 24);

  // Data cache-ə yaz
  Future<void> setCache(String key, dynamic data) async {
    final cacheItem = CacheItem(data, DateTime.now());
    await _storage.write(key, jsonEncode(cacheItem.toJson()));
  }

  // Cache-dən data oxu
  Future<T?> getCache<T>(String key) async {
    try {
      final jsonStr = _storage.read(key);
      if (jsonStr == null) return null;

      final cacheItem = CacheItem.fromJson(jsonDecode(jsonStr));

      // Cache müddətini yoxla
      if (DateTime.now().difference(cacheItem.timestamp) > _cacheExpiration) {
        await _storage.remove(key);
        return null;
      }

      return cacheItem.data as T;
    } catch (e) {
      await _storage.remove(key);
      return null;
    }
  }

  // Cache-i təmizlə
  Future<void> clearCache(String key) async {
    await _storage.remove(key);
  }

  // Bütün cache-i təmizlə
  Future<void> clearAllCache() async {
    await _storage.erase();
  }

  // Cache-də data var ya yox
  bool hasCache(String key) {
    return _storage.hasData(key);
  }
}
