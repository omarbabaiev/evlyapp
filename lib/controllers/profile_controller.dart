import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  final RxList<ListingModel> userListings = <ListingModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    print('ProfileController: onInit called');

    // Listen to user changes to reload listings
    ever(AuthService.to.currentUser, (user) {
      print('ProfileController: User changed, reloading listings');
      if (user != null) {
        loadUserListings();
      } else {
        userListings.clear();
      }
    });

    loadUserListings();
  }

  Future<void> loadUserListings() async {
    try {
      isLoading.value = true;
      final user = AuthService.to.currentUser.value;
      if (user != null) {
        print('ProfileController: Loading listings for user: ${user.uid}');
        final listings = await FirestoreService.to.getUserListings(user.uid);
        print('ProfileController: Loaded ${listings.length} listings');
        userListings.value = listings;
      } else {
        print('ProfileController: No current user found');
      }
    } catch (e) {
      print('ProfileController: Error loading user listings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToMyListings() {
    Get.toNamed('/my-listings');
  }

  void navigateToAddListing() {
    Get.toNamed('/add-listing');
  }

  Future<void> signOut() async {
    Get.dialog(
      AlertDialog(
        title: Text('Çıxış'),
        content: Text('Çıxış etmək istədiyinizdən əminsiniz?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Xeyr')),
          TextButton(
            onPressed: () async {
              Get.back();
              await AuthService.to.signOut();
            },
            child: Text('Bəli'),
          ),
        ],
      ),
    );
  }

  Future<void> refreshProfile() async {
    await loadUserListings();
  }
}
