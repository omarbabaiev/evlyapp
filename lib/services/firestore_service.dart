import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/listing_model.dart';
import '../core/constants/app_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FirestoreService extends GetxService {
  static FirestoreService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxBool isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFirestore();
    _monitorConnectivity();
  }

  void _initializeFirestore() {
    // Offline dəstəyi aktiv et
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    print('FirestoreService: Offline persistence enabled');
  }

  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      isOffline.value = result == ConnectivityResult.none;
      print(
        'FirestoreService: Connection status changed, offline: ${isOffline.value}',
      );
    });
  }

  // İki mərhələli sorğu (cache-first sonra server)
  Future<List<T>> getWithCacheFirst<T>({
    required Future<List<T>> Function(Source source) query,
  }) async {
    try {
      // Əvvəlcə cache-dən məlumatları al
      final cachedData = await query(Source.cache);

      // Əgər keşdə məlumatlar varsa, onları göstər
      if (cachedData.isNotEmpty) {
        print(
          'FirestoreService: Returning ${cachedData.length} items from cache',
        );
      }

      // İnternet varsa, serverdən yenilə
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        print('FirestoreService: Fetching fresh data from server');
        return await query(Source.server);
      }

      return cachedData;
    } catch (e) {
      print('FirestoreService: Error in cache-first query: $e');
      // Cache-də xəta olsa, serverdən cəhd et
      try {
        return await query(Source.server);
      } catch (e) {
        print('FirestoreService: Error in server query: $e');
        return [];
      }
    }
  }

  // User operations
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('FirestoreService: Error getting user data: $e');
      Get.snackbar('Xəta', 'İstifadəçi məlumatları alına bilmədi');
      return null;
    }
  }

  Future<bool> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .set(user.toMap());
      return true;
    } catch (e) {
      print('FirestoreService: Error creating user: $e');
      Get.snackbar('Xəta', 'İstifadəçi yaradıla bilmədi');
      return false;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.collectionUsers)
          .doc(user.uid)
          .update(user.toMap());
      return true;
    } catch (e) {
      print('FirestoreService: Error updating user: $e');
      Get.snackbar('Xəta', 'İstifadəçi məlumatları yenilənə bilmədi');
      return false;
    }
  }

  // İstifadəçi davranış izləmə
  Future<void> trackUserView(
      String userId, String listingId, String category) async {
    try {
      await _firestore.collection('user_behaviors').add({
        'userId': userId,
        'listingId': listingId,
        'category': category,
        'action': 'view',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking user view: $e');
    }
  }

  Future<void> trackSearchQuery(String userId, String query) async {
    try {
      await _firestore.collection('user_behaviors').add({
        'userId': userId,
        'searchQuery': query,
        'action': 'search',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking search: $e');
    }
  }

  // İstifadəçi üçün tövsiyə alqoritmi
  Future<Map<String, double>> getUserPreferences(String userId) async {
    try {
      final behaviors = await _firestore
          .collection('user_behaviors')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      Map<String, double> preferences = {};

      for (var doc in behaviors.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          String category = data['category'];
          preferences[category] = (preferences[category] ?? 0) + 1;
        }
      }

      // Normallaşdır (0-1 arası)
      if (preferences.isNotEmpty) {
        double maxValue = preferences.values.reduce((a, b) => a > b ? a : b);
        preferences.updateAll((key, value) => value / maxValue);
      }

      return preferences;
    } catch (e) {
      print('Error getting user preferences: $e');
      return {};
    }
  }

  // Freshness factor hesablama
  double _calculateFreshnessScore(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours <= 24) {
      return 1.0; // Son 24 saat - maksimum skor
    } else if (difference.inDays <= 7) {
      return 0.7; // Son həftə - yüksək skor
    } else if (difference.inDays <= 30) {
      return 0.4; // Son ay - orta skor
    } else {
      return 0.1; // Köhnə elanlar - aşağı skor
    }
  }

  // Keyfiyyət skoru hesablama
  double _calculateQualityScore(ListingModel listing) {
    double score = 0.0;

    // Şəkil sayı (max 0.3)
    double imageScore = (listing.images.length / 10).clamp(0.0, 0.3);
    score += imageScore;

    // Təsvir uzunluğu (max 0.2)
    double descriptionScore =
        (listing.description.length / 500).clamp(0.0, 0.2);
    score += descriptionScore;

    // Əlavə məlumatlar (max 0.3)
    double detailsScore = 0.0;
    if (listing.district != null && listing.district!.isNotEmpty)
      detailsScore += 0.1;
    if (listing.ownerName != null && listing.ownerName!.isNotEmpty)
      detailsScore += 0.1;
    if (listing.details != null && listing.details!.isNotEmpty)
      detailsScore += 0.1;
    score += detailsScore;

    // Qiymət məntiqiliyi (max 0.2)
    if (listing.price > 100 && listing.price < 1000000) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  // Smart listing alqoritmi
  Future<List<ListingModel>> getSmartListings({
    String? userId,
    int limit = 20,
  }) async {
    try {
      // Bütün elanları al
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionListings)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      List<ListingModel> listings = querySnapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();

      // İstifadəçi preferences al
      Map<String, double> userPreferences = {};
      if (userId != null) {
        userPreferences = await getUserPreferences(userId);
      }

      // Hər elan üçün smart skor hesabla
      List<MapEntry<ListingModel, double>> scoredListings =
          listings.map((listing) {
        double score = _calculateSmartScore(listing, userPreferences);
        return MapEntry(listing, score);
      }).toList();

      // Skora görə sırala
      scoredListings.sort((a, b) => b.value.compareTo(a.value));

      return scoredListings.map((entry) => entry.key).take(limit).toList();
    } catch (e) {
      print('Error in getSmartListings: $e');
      return await getAllListings(limit: limit);
    }
  }

  double _calculateSmartScore(
      ListingModel listing, Map<String, double> userPreferences) {
    // Freshness factor (40% çəki)
    double freshnessScore = _calculateFreshnessScore(listing.createdAt) * 0.4;

    // Keyfiyyət skoru (30% çəki)
    double qualityScore = _calculateQualityScore(listing) * 0.3;

    // İstifadəçi davranış skoru (30% çəki)
    double userScore = 0.0;
    if (userPreferences.isNotEmpty) {
      userScore = (userPreferences[listing.category] ?? 0.0) * 0.3;
    }

    return freshnessScore + qualityScore + userScore;
  }

  // Listing operations - smart alqoritm ilə
  Future<List<ListingModel>> getAllListings(
      {int limit = 20, String? userId}) async {
    return getWithCacheFirst<ListingModel>(
      query: (Source source) async {
        try {
          print(
              'FirestoreService: Getting smart listings from ${source.name}...');

          // Smart alqoritm istifadə et
          if (userId != null) {
            return await getSmartListings(userId: userId, limit: limit);
          }

          // Default sıralama
          final querySnapshot = await _firestore
              .collection(AppConstants.collectionListings)
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get(GetOptions(source: source));

          final listings = querySnapshot.docs
              .map((doc) => ListingModel.fromFirestore(doc))
              .toList();

          return listings;
        } catch (e) {
          print(
              'FirestoreService: Error getting listings from ${source.name}: $e');
          if (source == Source.cache) {
            throw e;
          }
          return [];
        }
      },
    );
  }

  Future<List<ListingModel>> getListingsByCategory(
    String category, {
    int limit = 20,
  }) async {
    return getWithCacheFirst<ListingModel>(
      query: (Source source) async {
        try {
          final querySnapshot = await _firestore
              .collection(AppConstants.collectionListings)
              .where('category', isEqualTo: category)
              .limit(limit)
              .get(GetOptions(source: source));

          return querySnapshot.docs
              .map((doc) => ListingModel.fromFirestore(doc))
              .toList();
        } catch (e) {
          print('FirestoreService: Error in getListingsByCategory: $e');
          if (source == Source.cache) {
            throw e;
          }
          Get.snackbar('Xəta', 'Kategoriya elanları yüklənə bilmədi');
          return [];
        }
      },
    );
  }

  Future<List<ListingModel>> searchListings(
    String query, {
    int limit = 20,
    String? userId,
  }) async {
    try {
      // Axtarış tarixçəsini qeyd et
      if (userId != null) {
        await trackSearchQuery(userId, query);
      }

      // Get all listings first
      final querySnapshot = await _firestore
          .collection(AppConstants.collectionListings)
          .orderBy('createdAt', descending: true)
          .limit(100) // Get more to filter locally
          .get();

      final allListings = querySnapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();

      // Filter locally for better search results
      final searchQuery = query.toLowerCase();
      final filteredListings = allListings.where((listing) {
        return listing.title.toLowerCase().contains(searchQuery) ||
            listing.description.toLowerCase().contains(searchQuery) ||
            listing.city.toLowerCase().contains(searchQuery) ||
            listing.category.toLowerCase().contains(searchQuery);
      }).toList();

      // Smart sıralama tətbiq et
      if (userId != null) {
        final userPreferences = await getUserPreferences(userId);
        filteredListings.sort((a, b) {
          double scoreA = _calculateSmartScore(a, userPreferences);
          double scoreB = _calculateSmartScore(b, userPreferences);
          return scoreB.compareTo(scoreA);
        });
      }

      return filteredListings.take(limit).toList();
    } catch (e) {
      print('FirestoreService: Error in searchListings: $e');
      Get.snackbar('Xəta', 'Axtarış nəticələri yüklənə bilmədi');
      return [];
    }
  }

  Future<List<ListingModel>> getFilteredListings(
    Map<String, dynamic> filters, {
    int limit = 20,
  }) async {
    try {
      // Get all listings first for better filtering
      Query query = _firestore.collection(AppConstants.collectionListings);

      // Only apply category filter in Firestore if specified
      if (filters['propertyType'] != null &&
          filters['propertyType'].isNotEmpty) {
        // Map filter property types to actual categories
        String category = _mapPropertyTypeToCategory(filters['propertyType']);
        query = query.where('category', isEqualTo: category);
      }

      query = query.orderBy('createdAt', descending: true).limit(100);

      final querySnapshot = await query.get();
      List<ListingModel> results = querySnapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();

      // Apply all filters locally for better control
      results = _applyAllFilters(results, filters);

      return results.take(limit).toList();
    } catch (e) {
      print('FirestoreService: Error in getFilteredListings: $e');
      Get.snackbar('Xəta', 'Filter nəticələri yüklənə bilmədi');
      return [];
    }
  }

  String _mapPropertyTypeToCategory(String propertyType) {
    switch (propertyType) {
      case 'house':
        return 'Ev';
      case 'apartment':
        return 'Mənzil';
      case 'land':
        return 'Torpaq';
      case 'commercial':
        return 'Mağaza';
      default:
        return propertyType;
    }
  }

  List<ListingModel> _applyAllFilters(
    List<ListingModel> listings,
    Map<String, dynamic> filters,
  ) {
    return listings.where((listing) {
      // Price range filter
      if (filters['minPrice'] != null && filters['minPrice'] > 0) {
        if (listing.price < filters['minPrice']) return false;
      }
      if (filters['maxPrice'] != null && filters['maxPrice'] < 1000000) {
        if (listing.price > filters['maxPrice']) return false;
      }

      // Category filter (already applied in query, but double-check)
      if (filters['propertyType'] != null &&
          filters['propertyType'].isNotEmpty) {
        String expectedCategory =
            _mapPropertyTypeToCategory(filters['propertyType']);
        if (listing.category != expectedCategory) return false;
      }

      return true;
    }).toList();
  }

  Future<List<ListingModel>> getUserListings(
    String userId, {
    int limit = 20,
  }) async {
    return getWithCacheFirst<ListingModel>(
      query: (Source source) async {
        try {
          print(
            'FirestoreService: Getting user listings for userId: $userId from ${source.name}',
          );
          final querySnapshot = await _firestore
              .collection(AppConstants.collectionListings)
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get(GetOptions(source: source));

          print(
            'FirestoreService: Found ${querySnapshot.docs.length} user listings from ${source.name}',
          );

          final listings = querySnapshot.docs
              .map((doc) {
                try {
                  return ListingModel.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing user listing ${doc.id}: $e');
                  return null;
                }
              })
              .where((listing) => listing != null)
              .cast<ListingModel>()
              .toList();

          print(
            'FirestoreService: Successfully parsed ${listings.length} user listings from ${source.name}',
          );
          return listings;
        } catch (e) {
          print(
            'FirestoreService: Error getting user listings from ${source.name}: $e',
          );
          if (source == Source.cache) {
            throw e;
          }
          Get.snackbar('Xəta', 'İstifadəçi elanları yüklənə bilmədi: $e');
          return [];
        }
      },
    );
  }

  // Elan yükləmədən öncə doğrulama
  bool validateListing(ListingModel listing) {
    // Şəkil yoxlama
    if (listing.images.isEmpty) {
      Get.snackbar('Xəta', 'Ən azı bir şəkil əlavə edin');
      return false;
    }

    // Qiymət yoxlama
    if (listing.price <= 0) {
      Get.snackbar('Xəta', 'Qiymət müsbət ədəd olmalıdır');
      return false;
    }

    // Başlıq yoxlama
    if (listing.title.trim().isEmpty) {
      Get.snackbar('Xəta', 'Başlıq boş ola bilməz');
      return false;
    }

    // Təsvir yoxlama
    if (listing.description.trim().isEmpty) {
      Get.snackbar('Xəta', 'Təsvir boş ola bilməz');
      return false;
    }

    return true;
  }

  Future<bool> createListing(ListingModel listing) async {
    // Göndərməzdən əvvəl doğrulama
    if (!validateListing(listing)) {
      return false;
    }

    try {
      await _firestore
          .collection(AppConstants.collectionListings)
          .add(listing.toFirestore());
      return true;
    } catch (e) {
      print('FirestoreService: Error creating listing: $e');
      Get.snackbar('Xəta', 'Elan yaradıla bilmədi');
      return false;
    }
  }

  Future<bool> createListingFromData(Map<String, dynamic> listingData) async {
    try {
      print('FirestoreService: Creating listing from data...');
      await _firestore
          .collection(AppConstants.collectionListings)
          .add(listingData);
      print('FirestoreService: Listing created successfully');
      return true;
    } catch (e) {
      print('FirestoreService: Error creating listing from data: $e');
      Get.snackbar('Xəta', 'Elan yaradıla bilmədi: $e');
      return false;
    }
  }

  Future<bool> deleteListing(String listingId, String userId) async {
    try {
      print('FirestoreService: Deleting listing $listingId by user $userId');

      // First verify the listing exists and belongs to the user
      final doc = await _firestore
          .collection(AppConstants.collectionListings)
          .doc(listingId)
          .get();

      if (!doc.exists) {
        print('FirestoreService: Listing not found');
        Get.snackbar('Xəta', 'Elan tapılmadı');
        return false;
      }

      final listingData = doc.data() as Map<String, dynamic>;
      final listingUserId = listingData['userId'] ?? '';

      if (listingUserId != userId) {
        print('FirestoreService: User not authorized to delete this listing');
        Get.snackbar('Xəta', 'Bu elanı silmək üçün icazəniz yoxdur');
        return false;
      }

      // Delete the listing
      await _firestore
          .collection(AppConstants.collectionListings)
          .doc(listingId)
          .delete();

      print('FirestoreService: Listing deleted successfully');
      return true;
    } catch (e) {
      print('FirestoreService: Error deleting listing: $e');
      Get.snackbar('Xəta', 'Elan silinə bilmədi: $e');
      return false;
    }
  }

  // Favorite operations
  Future<List<ListingModel>> getFavoriteListings(String userId) async {
    return getWithCacheFirst<ListingModel>(
      query: (Source source) async {
        try {
          print(
            'FirestoreService: Getting favorite listings for userId: $userId from ${source.name}',
          );
          final user = await getUserData(userId);
          if (user == null) {
            print('FirestoreService: User not found for favorites');
            return [];
          }

          if (user.favoriteListings.isEmpty) {
            print('FirestoreService: User has no favorite listings');
            return [];
          }

          print(
            'FirestoreService: User has ${user.favoriteListings.length} favorites to fetch from ${source.name}',
          );

          final List<ListingModel> favorites = [];
          for (String listingId in user.favoriteListings) {
            try {
              print(
                'FirestoreService: Fetching favorite listing with id: $listingId from ${source.name}',
              );
              final doc = await _firestore
                  .collection(AppConstants.collectionListings)
                  .doc(listingId)
                  .get(GetOptions(source: source));

              if (doc.exists) {
                print(
                  'FirestoreService: Found favorite listing: $listingId from ${source.name}',
                );
                favorites.add(ListingModel.fromFirestore(doc));
              } else {
                print(
                  'FirestoreService: Favorite listing not found: $listingId in ${source.name}',
                );
              }
            } catch (e) {
              print(
                'FirestoreService: Error fetching favorite listing $listingId from ${source.name}: $e',
              );
            }
          }

          print(
            'FirestoreService: Successfully fetched ${favorites.length} favorites from ${source.name}',
          );
          return favorites;
        } catch (e) {
          print(
            'FirestoreService: Error getting favorite listings from ${source.name}: $e',
          );
          if (source == Source.cache) {
            throw e;
          }
          Get.snackbar('Xəta', 'Sevimlilər yüklənə bilmədi: $e');
          return [];
        }
      },
    );
  }

  Future<bool> toggleFavorite(String userId, String listingId) async {
    try {
      final user = await getUserData(userId);
      if (user == null) return false;

      List<String> favorites = List<String>.from(user.favoriteListings);

      if (favorites.contains(listingId)) {
        favorites.remove(listingId);
      } else {
        favorites.add(listingId);
      }

      final updatedUser = user.copyWith(favoriteListings: favorites);
      return await updateUser(updatedUser);
    } catch (e) {
      print('FirestoreService: Error toggling favorite: $e');
      Get.snackbar('Xəta', 'Sevimli əməliyyatı uğursuz oldu');
      return false;
    }
  }
}
