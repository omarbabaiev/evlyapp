import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import '../services/storage_service.dart';

class AddListingController extends GetxController {
  static AddListingController get to => Get.find();

  final RxList<File> selectedImages = <File>[].obs;
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxDouble price = 0.0.obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Ev', 'icon': Icons.home},
    {'name': 'Torpaq', 'icon': Icons.landscape},
    {'name': 'Mənzil', 'icon': Icons.apartment},
    {'name': 'Ofis', 'icon': Icons.business},
    {'name': 'Mağaza', 'icon': Icons.store},
  ];

  void setTitle(String value) {
    title.value = value;
  }

  void setDescription(String value) {
    description.value = value;
  }

  void setPrice(double value) {
    price.value = value;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar('Xəta', 'Şəkil seçilə bilmədi');
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> createListing() async {
    print('AddListingController: Starting createListing...');
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      print('AddListingController: Loading started');

      final user = AuthService.to.currentUser.value;
      if (user == null) {
        print('AddListingController: No user found');
        Get.snackbar('Xəta', 'İstifadəçi məlumatları tapılmadı');
        return;
      }

      print('AddListingController: User found: ${user.uid}');

      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        print(
            'AddListingController: Uploading ${selectedImages.length} images...');
        try {
          // Generate a unique listing ID for folder organization
          final tempListingId =
              DateTime.now().millisecondsSinceEpoch.toString();
          imageUrls = await StorageService.to.uploadImages(
            selectedImages,
            tempListingId,
          );

          if (imageUrls.isEmpty) {
            print(
                'AddListingController: Image upload failed, proceeding without images');
            // Continue without images instead of failing
            // Get.snackbar('Xəta', 'Şəkillər yüklənə bilmədi');
            // return;
          } else {
            print(
                'AddListingController: Images uploaded successfully: ${imageUrls.length}');
          }
        } catch (e) {
          print(
              'AddListingController: Image upload error: $e, proceeding without images');
          // Continue without images
        }
      }

      // Sanitize inputs
      final sanitizedTitle = SecurityService.to.sanitizeInput(title.value);
      final sanitizedDescription = SecurityService.to.sanitizeInput(
        description.value,
      );

      print('AddListingController: Creating listing object...');

      // Create listing data map instead of ListingModel object
      final listingData = {
        'title': sanitizedTitle,
        'description': sanitizedDescription,
        'price': price.value,
        'category': selectedCategory.value,
        'images': imageUrls,
        'userId': user.uid,
        'city': 'Bakı',
        'phone': '1234567890',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      print('AddListingController: Saving to Firestore...');
      final success =
          await FirestoreService.to.createListingFromData(listingData);

      if (success) {
        print('AddListingController: Listing created successfully');
        // Increment user listing count
        SecurityService.to.incrementUserListingCount(user.uid);

        Get.back();
        Get.snackbar('Uğur', 'Elan yaradıldı');
        _resetForm();
      } else {
        print('AddListingController: Failed to create listing');
        Get.snackbar('Xəta', 'Elan yaradıla bilmədi');
      }
    } catch (e) {
      print('AddListingController: Error creating listing: $e');
      Get.snackbar('Xəta', 'Bir xəta baş verdi: $e');
    } finally {
      isLoading.value = false;
      print('AddListingController: Loading finished');
    }
  }

  bool _validateForm() {
    final security = SecurityService.to;
    final user = AuthService.to.currentUser.value;

    if (user == null) {
      Get.snackbar('Xəta', 'İstifadəçi məlumatları tapılmadı');
      return false;
    }

    // Rate limiting check
    if (security.isRateLimited('create_listing')) {
      Get.snackbar('Xəta', 'Çox tez-tez elan yaradırsınız. Bir az gözləyin.');
      return false;
    }

    // User permission check
    if (!security.canUserCreateListing(user.uid)) {
      Get.snackbar('Xəta', 'Maksimum elan limitinə çatdınız (10 elan)');
      return false;
    }

    // Title validation
    if (!security.isValidTitle(title.value)) {
      Get.snackbar('Xəta', 'Başlıq 3-100 simvol arasında olmalıdır');
      return false;
    }

    // Description validation
    if (!security.isValidDescription(description.value)) {
      Get.snackbar('Xəta', 'Təsvir 10-1000 simvol arasında olmalıdır');
      return false;
    }

    // Price validation
    if (!security.isValidPrice(price.value)) {
      Get.snackbar('Xəta', 'Düzgün qiymət daxil edin (0-999,999,999)');
      return false;
    }

    // Category validation
    if (selectedCategory.value.isEmpty) {
      Get.snackbar('Xəta', 'Kateqoriya seçin');
      return false;
    }

    // Content validation
    if (security.containsInappropriateContent(title.value) ||
        security.containsInappropriateContent(description.value)) {
      Get.snackbar('Xəta', 'Uygunsuz məzmun aşkar edildi');
      return false;
    }

    return true;
  }

  void _resetForm() {
    selectedImages.clear();
    title.value = '';
    description.value = '';
    price.value = 0.0;
    selectedCategory.value = '';
  }
}
