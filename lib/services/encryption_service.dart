import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';

class EncryptionService extends GetxService {
  static EncryptionService get to => Get.find();

  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;

  @override
  void onInit() {
    super.onInit();
    _initializeEncryption();
  }

  void _initializeEncryption() {
    // 32 bit key for AES-256
    _key = Key.fromSecureRandom(32);
    // 16 bytes IV for AES
    _iv = IV.fromSecureRandom(16);
    // AES encrypter yaradırıq
    _encrypter = Encrypter(AES(_key));
  }

  // String şifrələmə
  String encrypt(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  // String deşifrələmə
  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  // Map şifrələmə
  Map<String, dynamic> encryptMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is String) {
        return MapEntry(key, encrypt(value));
      }
      return MapEntry(key, value);
    });
  }

  // Map deşifrələmə
  Map<String, dynamic> decryptMap(Map<String, dynamic> encryptedData) {
    return encryptedData.map((key, value) {
      if (value is String) {
        return MapEntry(key, decrypt(value));
      }
      return MapEntry(key, value);
    });
  }

  // Şifrələnmiş data yoxlama
  bool isEncrypted(String text) {
    try {
      Encrypted.fromBase64(text);
      return true;
    } catch (_) {
      return false;
    }
  }
}
