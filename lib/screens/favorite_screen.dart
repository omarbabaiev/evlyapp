import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/favorite_controller.dart';
import '../widgets/listing_card.dart';
import '../core/constants/app_constants.dart';

class FavoriteScreen extends GetView<FavoriteController> {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Əgər controller əvvəlcədən mövcuddursa, istifadə et, əks halda yarat
    final controller = Get.isRegistered<FavoriteController>()
        ? Get.find<FavoriteController>()
        : Get.put(FavoriteController(), permanent: true);

    // Hər dəfə ekran açılanda yenilə
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFavoriteListings();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        title: Text(
          'Sevimlilər',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshFavorites,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Skeletonizer(
              enableSwitchAnimation: true,
              enabled: controller.isLoading.value,
              child: controller.favoriteListings.isEmpty &&
                      !controller.isLoading.value
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/empty_favorites.png',
                            height: 120,
                            width: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.favorite_border,
                                size: 80,
                                color: Colors.grey[400],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Heç bir sevimli elan yoxdur',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ana səhifədən elanları sevimlilərə əlavə edin',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppConstants.defaultPadding,
                        mainAxisSpacing: AppConstants.defaultPadding,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: controller.isLoading.value &&
                              controller.favoriteListings.isEmpty
                          ? 6
                          : controller.favoriteListings.length,
                      itemBuilder: (context, index) {
                        if (controller.isLoading.value &&
                            controller.favoriteListings.isEmpty) {
                          // Placeholder cards for skeleton loading
                          return _buildPlaceholderCard();
                        }

                        final listing = controller.favoriteListings[index];
                        return ListingCard(listing: listing);
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Şəkil placeholder
          Container(
            height: 120,
            color: Colors.grey[300],
            child: Center(
              child: Icon(Icons.image, color: Colors.grey[400], size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Qiymət
                Container(height: 24, width: 100, color: Colors.grey[300]),
                const SizedBox(height: 8),
                // Başlıq
                Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Container(height: 16, width: 120, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
