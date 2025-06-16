import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> uploadImages(List<File> images, String listingId) async {
    try {
      print(
          'StorageService: Starting upload of ${images.length} images for listing $listingId');
      List<String> downloadUrls = [];

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        print('StorageService: Uploading image ${i + 1}/${images.length}');

        final fileName =
            '${listingId}_${i}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
        final ref = _storage.ref().child('listings').child(fileName);

        print('StorageService: Starting upload for file: $fileName');

        // Add proper metadata to avoid null pointer exception
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'listingId': listingId,
            'imageIndex': i.toString(),
          },
        );

        final uploadTask = ref.putFile(file, metadata);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print(
            'StorageService: Upload completed for image ${i + 1}, URL: $downloadUrl');

        downloadUrls.add(downloadUrl);
      }

      print(
          'StorageService: All images uploaded successfully. Total URLs: ${downloadUrls.length}');
      return downloadUrls;
    } catch (e) {
      print('StorageService: Error uploading images: $e');
      Get.snackbar('Xəta', 'Şəkillər yüklənə bilmədi: $e');
      return [];
    }
  }

  Future<String?> uploadSingleImage(
    File image,
    String folder,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref().child(folder).child(fileName);
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Xəta', 'Şəkil yüklənə bilmədi: $e');
      return null;
    }
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  Future<bool> deleteListingImages(List<String> imageUrls) async {
    try {
      for (String imageUrl in imageUrls) {
        await deleteImage(imageUrl);
      }
      return true;
    } catch (e) {
      print('Error deleting listing images: $e');
      return false;
    }
  }
}
