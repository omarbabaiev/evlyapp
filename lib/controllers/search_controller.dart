import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class AppSearchController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final GetStorage _storage = GetStorage();

  final RxString searchQuery = ''.obs;
  final RxList<ListingModel> searchResults = <ListingModel>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  // Axtarış sahəsindəki dəyişiklik üçün (sadəcə dəyər saxlayır)
  void onSearchInputChanged(String query) {
    searchQuery.value = query;
  }

  // Manual axtarış funksiyası (düymə və ya Enter düyməsi üçün)
  Future<void> performSearch([String? customQuery]) async {
    final query = customQuery ?? searchQuery.value;

    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;

    try {
      final currentUser = AuthService.to.currentUser.value;

      final results = await _firestoreService.searchListings(
        query,
        userId: currentUser?.uid,
      );
      searchResults.value = results;

      // Axtarış uğurlu olubsa tarixçəyə əlavə et
      _addToRecentSearches(query.trim());
    } catch (e) {
      print('Search error: $e');
      searchResults.clear();
      Get.snackbar(
        'Xəta',
        'Axtarış zamanı xəta baş verdi',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Son axtarışlardan seçim
  void selectRecentSearch(String search) {
    searchQuery.value = search;
    performSearch(search);
  }

  // Keyboard-da Enter düyməsi üçün
  void onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      performSearch(query.trim());
    }
  }

  // İstifadəçi davranış izləmə
  Future<void> trackListingView(ListingModel listing) async {
    try {
      final currentUser = AuthService.to.currentUser.value;
      if (currentUser != null) {
        await _firestoreService.trackUserView(
          currentUser.uid,
          listing.id,
          listing.category,
        );
      }
    } catch (e) {
      print('AppSearchController: Error tracking listing view: $e');
    }
  }

  void _addToRecentSearches(String search) {
    if (search.isEmpty) return;

    // Əgər artıq varsa, çıxar
    recentSearches.remove(search);

    // Əvvələ əlavə et
    recentSearches.insert(0, search);

    // Yalnız son 10 axtarışı saxla
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }

    _saveRecentSearches();
  }

  void removeRecentSearch(String search) {
    recentSearches.remove(search);
    _saveRecentSearches();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();
  }

  void clearSearchResults() {
    searchResults.clear();
    searchQuery.value = '';
  }

  void _loadRecentSearches() {
    final saved = _storage.read<List>('recent_searches');
    if (saved != null) {
      recentSearches.value = saved.cast<String>();
    }
  }

  void _saveRecentSearches() {
    _storage.write('recent_searches', recentSearches.toList());
  }
}
