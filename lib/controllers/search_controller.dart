import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';

class AppSearchController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final GetStorage _storage = GetStorage();

  final RxString searchQuery = ''.obs;
  final RxList<ListingModel> searchResults = <ListingModel>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxBool isLoading = false.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _loadRecentSearches();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void selectRecentSearch(String search) {
    searchQuery.value = search;
    _performSearch(search);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    isLoading.value = true;

    try {
      final results = await _firestoreService.searchListings(query);
      searchResults.value = results;

      // Add to recent searches
      _addToRecentSearches(query);
    } catch (e) {
      print('Search error: $e');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _addToRecentSearches(String search) {
    if (search.trim().isEmpty) return;

    // Remove if already exists
    recentSearches.remove(search);

    // Add to beginning
    recentSearches.insert(0, search);

    // Keep only last 10 searches
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

  void _loadRecentSearches() {
    final saved = _storage.read<List>('recent_searches');
    if (saved != null) {
      recentSearches.value = saved.cast<String>();
    }
  }

  void _saveRecentSearches() {
    _storage.write('recent_searches', recentSearches.toList());
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
