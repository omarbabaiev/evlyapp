import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_constants.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final RxList<ListingModel> listings = <ListingModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Hamısı'.obs;
  final RxBool isLoading = false.obs;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Hamısı', 'icon': Icons.apps},
    {'name': 'Ev', 'icon': Icons.home},
    {'name': 'Torpaq', 'icon': Icons.landscape},
    {'name': 'Mənzil', 'icon': Icons.apartment},
    {'name': 'Ofis', 'icon': Icons.business},
    {'name': 'Mağaza', 'icon': Icons.store},
  ];

  final List<String> bannerImages = [
    'https://via.placeholder.com/400x200/1E88E5/ffffff?text=Banner+1',
    'https://via.placeholder.com/400x200/43A047/ffffff?text=Banner+2',
    'https://via.placeholder.com/400x200/E53935/ffffff?text=Banner+3',
  ];

  @override
  void onInit() {
    super.onInit();
    loadListings();

    // Kategori dəyişiklikləri üçün dinləyici
    ever(selectedCategory, (_) => loadListings());
  }

  Future<void> loadListings() async {
    try {
      isLoading.value = true;
      print('HomeController: Loading listings...');

      List<ListingModel> loadedListings;

      // Kateqoriyaya görə yüklə
      if (selectedCategory.value == 'Hamısı') {
        loadedListings = await FirestoreService.to.getAllListings();
      } else {
        loadedListings = await FirestoreService.to.getListingsByCategory(
          selectedCategory.value,
        );
      }

      print('HomeController: Loaded ${loadedListings.length} listings');
      listings.value = loadedListings;
    } catch (e) {
      print('HomeController: Error loading listings: $e');
      Get.snackbar(
        'Xəta',
        'Elanlar yüklənə bilmədi: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Axtarış funksiyası
  Future<void> searchListings(String query) async {
    if (query.isEmpty) {
      loadListings();
      return;
    }

    try {
      isLoading.value = true;
      final results = await FirestoreService.to.searchListings(query);
      listings.value = results;
    } catch (e) {
      print('HomeController: Error searching listings: $e');
      Get.snackbar('Xəta', 'Axtarış zamanı xəta baş verdi');
    } finally {
      isLoading.value = false;
    }
  }

  // Data yeniləmə funksiyası
  Future<void> refreshData() async {
    await loadListings();
    return;
  }

  // Offline/online vəziyyəti
  bool get isOffline => FirestoreService.to.isOffline.value;

  // UI ilə əlaqəli metodlar
  void onSearchChanged(String query) {
    searchQuery.value = query;
    searchListings(query);
  }

  void onCategorySelected(String category) {
    selectedCategory.value = category;
  }
}
