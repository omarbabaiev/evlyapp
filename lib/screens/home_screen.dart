// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/home_controller.dart';
import '../widgets/listing_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/modern_banner_card.dart';
import '../widgets/category_item.dart';
import '../core/theme/app_colors.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(() {
          return CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverToBoxAdapter(child: SizedBox(height: 20)),
              // Search Bar
              SliverAppBar(
                snap: true,
                floating: true,
                collapsedHeight: 70,
                expandedHeight: 60,
                surfaceTintColor: AppColors.background,
                backgroundColor: AppColors.background,
                title: const SearchBarWidget(),
              ),

              // Banner Carousel
              SliverToBoxAdapter(
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  child: CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 150,
                      autoPlay: false,
                      enlargeCenterPage: true,
                      viewportFraction: 0.85,
                      enableInfiniteScroll: true,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index, realIndex) {
                      switch (index) {
                        case 0:
                          return ModernBannerCard(
                            title: 'Premium Evlər',
                            subtitle: 'Ən yaxşı qiymətlərlə\nkeyfiyyətli evlər',
                            buttonText: 'İndi Bax',
                            onTap: () => controller.onCategorySelected('Ev'),
                          );
                        case 1:
                          return ModernBannerCard(
                            title: 'Mənzillər',
                            subtitle: 'Şəhərin mərkəzində\nrahat mənzillər',
                            buttonText: 'Kəşf Et',
                            gradientColors: const [
                              Color(0xFF10B981),
                              Color(0xFF34D399),
                            ],
                            onTap: () =>
                                controller.onCategorySelected('Mənzil'),
                          );
                        case 2:
                          return ModernBannerCard(
                            title: 'Yeni Tikililər',
                            subtitle: 'Son texnologiya ilə\ntikili binalar',
                            buttonText: 'Gör',
                            gradientColors: const [
                              Color(0xFFF59E0B),
                              Color(0xFFFFBF69),
                            ],
                            onTap: () {},
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),

              // Offline bildirişi
              if (FirestoreService.to.isOffline.value)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    color: Colors.amber,
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, color: Colors.black87),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Offline rejimindəsiniz. Məlumatlar lokal cache\'dən yüklənir.',
                            style: GoogleFonts.poppins(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Category Filter
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.categories.length,
                    itemBuilder: (context, index) {
                      final category = AppConstants.categories[index];
                      return Obx(
                        () => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected:
                                controller.selectedCategory.value == category,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedCategory.value = category;
                                controller.loadListings();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Section title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Populyar Elanlar',
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Hamısını gör',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Skeletonizer ile listings
              Obx(
                () => SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: controller.isLoading.value
                      ? SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Skeletonizer(
                              enabled: controller.isLoading.value,
                              enableSwitchAnimation: true,
                              child: ListingCard(
                                listing: ListingModel(
                                  userId: '1',
                                  city: 'Bakı',
                                  phone: '1234567890',
                                  description: 'Elan',
                                  category: 'Elan',
                                  images: [],
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  id: '1',
                                  title: 'Elan',
                                  price: 100000,
                                ),
                              ),
                            ),
                            childCount: 6,
                          ),
                        )
                      : controller.listings.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Heç bir elan tapılmadı',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Başqa kateqoriya seçin və ya yenidən yoxlayın',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[500]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final listing = controller.listings[index];
                                return ListingCard(listing: listing);
                              }, childCount: controller.listings.length),
                            ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Şəkil placeholder
          Container(height: 120, color: Colors.grey[300]),
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
