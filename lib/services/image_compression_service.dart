import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ImageCompressionService extends GetxService {
  static ImageCompressionService get to => Get.find();

  // Şəkil sıxışdırma konfiqurasiyası
  static const int maxFileSize = 2 * 1024 * 1024; // 2MB

  // Şəkil sıxışdırma
  Future<File?> compressImage(File file) async {
    try {
      // Müvəqqəti qovluq
      final tempDir = await path_provider.getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${tempDir.path}/compressed_$timestamp.jpg';

      // Sıxışdırma
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
        rotate: 0,
      );

      return result != null ? File(result.path) : null;
    } catch (e, stackTrace) {
      debugPrint('Şəkil sıxışdırma xətası: $e');
      // Sentry-ə xətanı göndər
      await Get.find<dynamic>().captureException(
        e,
        stackTrace: stackTrace,
        extra: {'originalPath': file.path},
      );
      return null;
    }
  }

  // Çoxlu şəkil sıxışdırma
  Future<List<File>> compressImages(List<File> files) async {
    final compressedFiles = <File>[];

    for (final file in files) {
      final compressed = await compressImage(file);
      if (compressed != null) {
        compressedFiles.add(compressed);
      }
    }

    return compressedFiles;
  }

  // Şəklin ölçüsünü yoxla
  bool needsCompression(File file) {
    return file.lengthSync() > maxFileSize;
  }
}
