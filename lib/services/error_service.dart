import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Xəta növləri
enum ErrorType { network, auth, database, validation, unknown }

class ErrorService extends GetxService {
  static ErrorService get to => Get.find();

  // Xətanı emal et və uyğun mesajı qaytarır
  String handleError(dynamic error, {ErrorType type = ErrorType.unknown}) {
    String message;

    switch (type) {
      case ErrorType.network:
        message = 'İnternet bağlantısı xətası';
        break;
      case ErrorType.auth:
        message = 'Giriş xətası';
        break;
      case ErrorType.database:
        message = 'Məlumat bazası xətası';
        break;
      case ErrorType.validation:
        message = 'Məlumatlar düzgün deyil';
        break;
      case ErrorType.unknown:
      default:
        message = 'Gözlənilməz xəta baş verdi';
    }

    // Xətanı konsola yaz
    debugPrint('ERROR [$type]: $error');

    return message;
  }

  // Xəta mesajını göstər
  void showError(String message) {
    Get.snackbar(
      'Xəta',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
    );
  }

  // Try-catch helper
  Future<T?> tryBlock<T>(
    Future<T> Function() block, {
    ErrorType type = ErrorType.unknown,
    bool showMessage = true,
  }) async {
    try {
      return await block();
    } catch (e) {
      final message = handleError(e, type: type);
      if (showMessage) {
        showError(message);
      }
      return null;
    }
  }
}
