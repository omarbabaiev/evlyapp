import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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

  // Yeni əlavə edilən dəyişənlər
  final RxString listingType = 'Satıram'.obs; // Satıram və ya Kirayə verirəm
  final RxString propertyType = ''.obs; // Əmlakın növü
  final RxString city = 'Bakı'.obs; // Şəhər
  final RxString district = ''.obs; // Rayon
  final RxInt roomCount = 0.obs; // Otaq sayı
  final RxDouble area = 0.0.obs; // Sahə, m²
  final RxInt floor = 0.obs; // Mərtəbə
  final RxInt totalFloors = 0.obs; // Mərtəbələrin sayı
  final RxBool isNewBuilding = true.obs; // Yeni tikili / Köhnə tikili
  final RxBool hasRepair = true.obs; // Təmirli / Təmirsiz
  final RxString phone = ''.obs; // Telefon nömrəsi
  final RxString ownerName = ''.obs; // Elan sahibinin adı
  final RxString ownerEmail = ''.obs; // Elan sahibinin e-mail-i
  final RxBool isOwner = true.obs; // Sahibi/Vasitəçi

  final ImagePicker _picker = ImagePicker();

  static const int maxImages = 30;
  static const int minImages = 4;
  static const int maxTitleLength = 60;
  static const int maxDescriptionLength = 3000;
  static const double maxPrice = 10000000;

  // Əmlak növləri
  final List<String> propertyTypes = [
    'Mənzil',
    'Həyət evi/Bağ evi',
    'Ofis',
    'Obyekt',
    'Torpaq',
    'Qaraj',
  ];

  // Şəhərlər
  final List<String> cities = [
    'Bakı',
    'Gəncə',
    'Sumqayıt',
    'Mingəçevir',
    'Şəki',
    'Lənkəran',
  ];

  // Rayonlar (Bakı üçün)
  final Map<String, List<String>> districts = {
    'Bakı': [
      'Yasamal',
      'Nəsimi',
      'Nərimanov',
      'Xətai',
      'Binəqədi',
      'Sabunçu',
      'Suraxanı',
      'Nizami',
      'Xəzər',
      'Qaradağ',
      'Pirallahı',
      'Səbail',
    ],
    'Gəncə': ['Kəpəz', 'Nizami'],
    'Sumqayıt': ['Mərkəz', 'Şimal', 'Cənub'],
  };

  @override
  void onInit() {
    super.onInit();
    // Şəhər dəyişdikdə rayon listini yenilə
    ever(city, (_) {
      district.value = '';
    });
  }

  void setListingType(String type) {
    listingType.value = type;
  }

  void setPropertyType(String type) {
    propertyType.value = type;
  }

  void setCity(String value) {
    city.value = value;
  }

  void setDistrict(String value) {
    district.value = value;
  }

  void setRoomCount(int value) {
    roomCount.value = value;
  }

  void setArea(double value) {
    area.value = value;
  }

  void setFloor(int value) {
    floor.value = value;
  }

  void setTotalFloors(int value) {
    totalFloors.value = value;
  }

  void setIsNewBuilding(bool value) {
    isNewBuilding.value = value;
  }

  void setHasRepair(bool value) {
    hasRepair.value = value;
  }

  void setPhone(String value) {
    phone.value = value;
  }

  void setOwnerName(String value) {
    ownerName.value = value;
  }

  void setOwnerEmail(String value) {
    ownerEmail.value = value;
  }

  void setIsOwner(bool value) {
    isOwner.value = value;
  }

  void setTitle(String value) {
    if (value.length > maxTitleLength) return;
    title.value = value;
  }

  void setDescription(String value) {
    if (value.length > maxDescriptionLength) return;
    description.value = value;
  }

  void setPrice(double value) {
    if (value > maxPrice) return;
    price.value = value;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // Əmlak növünə görə hansı əlavə məlumatların tələb olunduğunu yoxlayır
  bool requiresRoomCount() {
    return ['Mənzil', 'Həyət evi/Bağ evi', 'Ofis'].contains(propertyType.value);
  }

  bool requiresFloor() {
    return ['Mənzil', 'Ofis', 'Obyekt'].contains(propertyType.value);
  }

  bool requiresBuildingType() {
    return ['Mənzil', 'Ofis'].contains(propertyType.value);
  }

  bool requiresRepairStatus() {
    return ['Mənzil', 'Həyət evi/Bağ evi', 'Ofis', 'Obyekt']
        .contains(propertyType.value);
  }

  Future<File> _addWatermarkFlutter(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);

    // Watermark parametrləri
    const watermarkText = 'Evly';
    final random = Random();
    final watermarkCount = 3 + random.nextInt(3); // 3-5 watermark
    for (int i = 0; i < watermarkCount; i++) {
      final opacity = 0.18 + random.nextDouble() * 0.04; // 0.18-0.22
      final fontSize =
          image.width * (0.045 + random.nextDouble() * 0.015); // kiçik
      final textStyle = GoogleFonts.poppins(
        color: Colors.white.withOpacity(opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(text: watermarkText, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // Random, bir-birindən aralı yerlər
      final margin = 24.0;
      final maxX = image.width - textPainter.width - margin;
      final maxY = image.height - textPainter.height - margin;
      final x = margin + random.nextDouble() * (maxX - margin);
      final y = margin + random.nextDouble() * (maxY - margin);
      textPainter.paint(canvas, Offset(x, y));
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    // Yeni fayl yaradıb yaz
    final tempDir = await getTemporaryDirectory();
    final wmFile =
        File('${tempDir.path}/wm_${DateTime.now().millisecondsSinceEpoch}.png');
    await wmFile.writeAsBytes(pngBytes!.buffer.asUint8List());
    return wmFile;
  }

  Future<void> pickImage() async {
    try {
      if (selectedImages.length >= maxImages) {
        Get.snackbar('Limit', 'Ən çox $maxImages şəkil əlavə edə bilərsiniz');
        return;
      }
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        File file = File(image.path);
        selectedImages.add(file);
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
          // Watermark-lı şəkillər hazırla
          List<File> watermarkedImages = [];
          for (final file in selectedImages) {
            final wmFile = await _addWatermarkFlutter(file);
            watermarkedImages.add(wmFile);
          }
          // Generate a unique listing ID for folder organization
          final tempListingId =
              DateTime.now().millisecondsSinceEpoch.toString();
          imageUrls = await StorageService.to.uploadImages(
            watermarkedImages,
            tempListingId,
          );

          if (imageUrls.isEmpty) {
            print(
                'AddListingController: Image upload failed, proceeding without images');
          } else {
            print(
                'AddListingController: Images uploaded successfully: ${imageUrls.length}');
          }
        } catch (e) {
          print(
              'AddListingController: Image upload error: $e, proceeding without images');
        }
      }

      // Sanitize inputs
      final sanitizedTitle = SecurityService.to.sanitizeInput(title.value);
      final sanitizedDescription = SecurityService.to.sanitizeInput(
        description.value,
      );

      print('AddListingController: Creating listing object...');

      // Əlavə məlumatları topla
      final Map<String, dynamic> additionalDetails = {
        'listingType': listingType.value,
        'propertyType': propertyType.value,
        'city': city.value,
        'district': district.value,
        'ownerName': ownerName.value,
        'ownerEmail': ownerEmail.value,
        'isOwner': isOwner.value,
      };

      // Əmlak növünə görə əlavə məlumatları daxil et
      if (requiresRoomCount()) {
        additionalDetails['roomCount'] = roomCount.value;
      }

      if (requiresFloor()) {
        additionalDetails['floor'] = floor.value;
        additionalDetails['totalFloors'] = totalFloors.value;
      }

      if (requiresBuildingType()) {
        additionalDetails['isNewBuilding'] = isNewBuilding.value;
      }

      if (requiresRepairStatus()) {
        additionalDetails['hasRepair'] = hasRepair.value;
      }

      // Sahə bütün əmlak növləri üçün
      additionalDetails['area'] = area.value;

      // Create listing data map
      final listingData = {
        'title': sanitizedTitle,
        'description': sanitizedDescription,
        'price': price.value,
        'category':
            propertyType.value, // Əmlak növünü kateqoriya kimi istifadə et
        'images': imageUrls,
        'userId': user.uid,
        'city': city.value,
        'district': district.value,
        'phone': phone.value.isEmpty ? '' : phone.value,
        'ownerName': ownerName.value,
        'ownerEmail': ownerEmail.value,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'details': additionalDetails,
        'location': {'city': city.value, 'district': district.value}
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

    // Property type validation
    if (propertyType.value.isEmpty) {
      Get.snackbar('Xəta', 'Əmlakın növünü seçin');
      return false;
    }

    // City validation
    if (city.value.isEmpty) {
      Get.snackbar('Xəta', 'Şəhər seçin');
      return false;
    }

    // District validation
    if (district.value.isEmpty) {
      Get.snackbar('Xəta', 'Rayon seçin');
      return false;
    }

    // Image validation
    if (selectedImages.length < minImages) {
      Get.snackbar('Xəta', 'Ən az $minImages şəkil əlavə edin');
      return false;
    }

    // Title validation
    if (title.value.isEmpty) {
      Get.snackbar('Xəta', 'Başlıq daxil edin');
      return false;
    }

    // Description validation
    if (description.value.isEmpty) {
      Get.snackbar('Xəta', 'Təsvir daxil edin');
      return false;
    }

    // Price validation
    if (price.value <= 0) {
      Get.snackbar('Xəta', 'Qiymət daxil edin');
      return false;
    }

    // Area validation
    if (area.value <= 0) {
      Get.snackbar('Xəta', 'Sahə daxil edin');
      return false;
    }

    // Owner name validation
    if (ownerName.value.isEmpty) {
      Get.snackbar('Xəta', 'Adınızı daxil edin');
      return false;
    }

    // Phone validation
    if (phone.value.isEmpty) {
      Get.snackbar('Xəta', 'Telefon nömrəsi daxil edin');
      return false;
    }

    // Room count validation for required property types
    if (requiresRoomCount() && roomCount.value <= 0) {
      Get.snackbar('Xəta', 'Otaq sayını daxil edin');
      return false;
    }

    // Floor validation for required property types
    if (requiresFloor() && floor.value <= 0) {
      Get.snackbar('Xəta', 'Mərtəbə daxil edin');
      return false;
    }

    return true;
  }

  void _resetForm() {
    selectedImages.clear();
    title.value = '';
    description.value = '';
    price.value = 0.0;
    propertyType.value = '';
    city.value = 'Bakı';
    district.value = '';
    roomCount.value = 0;
    area.value = 0.0;
    floor.value = 0;
    totalFloors.value = 0;
    isNewBuilding.value = true;
    hasRepair.value = true;
    phone.value = '';
    ownerName.value = '';
    ownerEmail.value = '';
    isOwner.value = true;
  }
}
