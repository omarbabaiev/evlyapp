import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/profile_controller.dart';
import '../widgets/listing_card.dart';
import '../core/theme/app_colors.dart';
import '../models/listing_model.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mənim Elanlarım'),
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/add-listing'),
            icon: Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.userListings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.post_add_outlined,
                            size: 80,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Heç bir elanınız yoxdur',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'İlk elanınızı yaradın',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Get.toNamed('/add-listing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Elan Əlavə Et',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Skeletonizer(
                        enabled: controller.isLoading.value,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: controller.isLoading.value
                              ? 4 // Show 4 skeleton items during loading
                              : controller.userListings.length,
                          itemBuilder: (context, index) {
                            if (controller.isLoading.value) {
                              // Skeleton placeholder data
                              final skeletonListing = ListingModel(
                                id: 'skeleton_$index',
                                title: 'Loading title placeholder text',
                                description:
                                    'Loading description placeholder text for skeleton',
                                price: 150000,
                                category: 'Ev',
                                images: ['https://via.placeholder.com/400x300'],
                                userId: 'skeleton',
                                city: 'Loading...',
                                phone: 'Loading...',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              return ListingCard(
                                listing: skeletonListing,
                                onTap: () {}, // Disable tap during loading
                              );
                            } else {
                              final listing = controller.userListings[index];
                              return ListingCard(
                                listing: listing,
                                onTap: () => Get.toNamed(
                                  '/listing-detail',
                                  arguments: listing,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
