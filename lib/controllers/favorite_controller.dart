import 'package:get/get.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class FavoriteController extends GetxController {
  static FavoriteController get to => Get.find();

  final RxList<ListingModel> favoriteListings = <ListingModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    print('FavoriteController: onInit called');
    loadFavoriteListings();

    // İstifadəçi məlumatları dəyişəndə favorit siyahısını yenilə
    ever(AuthService.to.currentUser, (_) {
      print(
        'FavoriteController: AuthService.currentUser dəyişdi, favorilər yenilənir',
      );
      loadFavoriteListings();
    });
  }

  Future<void> loadFavoriteListings() async {
    try {
      isLoading.value = true;
      final user = AuthService.to.currentUser.value;
      if (user != null) {
        print('FavoriteController: Loading favorites for user: ${user.uid}');
        print(
          'FavoriteController: User has ${user.favoriteListings.length} favorite ids: ${user.favoriteListings}',
        );

        if (user.favoriteListings.isEmpty) {
          print('FavoriteController: User has no favorites');
          favoriteListings.value = [];
          return;
        }

        final favorites = await FirestoreService.to.getFavoriteListings(
          user.uid,
        );

        print(
          'FavoriteController: Loaded ${favorites.length} favorite listings',
        );
        favoriteListings.value = favorites;
      } else {
        print('FavoriteController: No current user found');
        favoriteListings.value = [];
      }
    } catch (e) {
      print('FavoriteController: Error loading favorites: $e');
      favoriteListings.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(String listingId) async {
    final user = AuthService.to.currentUser.value;
    if (user != null) {
      // Optimistic update - dərhal UI'ı yenilə
      List<String> currentFavorites = List<String>.from(user.favoriteListings);
      bool willBeFavorite = !currentFavorites.contains(listingId);

      if (willBeFavorite) {
        currentFavorites.add(listingId);
      } else {
        currentFavorites.remove(listingId);
      }

      // UI'ı dərhal yenilə
      final updatedUser = user.copyWith(favoriteListings: currentFavorites);
      AuthService.to.currentUser.value = updatedUser;

      // Backend'ə göndər
      final success = await FirestoreService.to.toggleFavorite(
        user.uid,
        listingId,
      );

      if (success) {
        await loadFavoriteListings();
        Get.snackbar(
          'Uğur',
          willBeFavorite
              ? 'Sevimlilərə əlavə edildi'
              : 'Sevimlilərdən çıxarıldı',
          duration: const Duration(seconds: 2),
        );
      } else {
        // Əgər backend uğursuz olsa, əvvəlki vəziyyətə qaytar
        AuthService.to.currentUser.value = user;
        Get.snackbar('Xəta', 'Əməliyyat uğursuz oldu');
      }
    }
  }

  Future<void> refreshFavorites() async {
    await loadFavoriteListings();
  }
}
