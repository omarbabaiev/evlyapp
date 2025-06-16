import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/listing_model.dart';
import '../controllers/favorite_controller.dart';
import '../services/auth_service.dart';

import '../core/theme/app_colors.dart';
import '../screens/image_view_screen.dart';
import '../models/listing_stats.dart';
import '../services/listing_stats_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/listing_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../core/utils/date_utils.dart' as AppDateUtils;
import '../core/constants/app_images.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required ListingModel listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  final listingController = Get.find<ListingController>();
  final statsService = Get.find<ListingStatsService>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    if (Get.arguments == null) {
      print('ListingDetailScreen: No arguments provided');
      Get.back();
      return;
    }

    if (Get.arguments is! ListingModel) {
      print('ListingDetailScreen: Invalid arguments type');
      Get.back();
      return;
    }

    final listing = Get.arguments as ListingModel;
    if (listing.id.isEmpty) {
      print('ListingDetailScreen: Listing ID is empty');
      Get.back();
      return;
    }

    listingController.setListing(listing);
    statsService.addView(
      listing.id,
      Get.find<AuthService>().currentUser.value?.uid ?? '',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = listingController.listing;
    if (listing == null) return const SizedBox();

    final favoriteController = Get.find<FavoriteController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.cardBackground,
            surfaceTintColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() {
                  final user = AuthService.to.currentUser.value;
                  final isFavorite =
                      user?.favoriteListings.contains(listing.id) ?? false;

                  return IconButton(
                    onPressed: () {
                      if (user != null) {
                        favoriteController.toggleFavorite(listing.id);
                      } else {
                        Get.snackbar('Xəta', 'Giriş etməlisiniz');
                      }
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppColors.textPrimary,
                      size: 20,
                    ),
                  );
                }),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    // Share functionality
                    Get.snackbar(
                      'Bildiriş',
                      'Paylaşma funksiyası hazırlanır',
                      backgroundColor: Colors.white,
                      colorText: Colors.black,
                    );
                  },
                  icon: Icon(
                    Icons.share_outlined,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image slider
                  listing.images.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: listing.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => ImageViewScreen(
                                    images: listing.images,
                                    initialIndex: index,
                                    listing: listing,
                                  ),
                                  preventDuplicates: true,
                                );
                              },
                              child: Hero(
                                tag: 'listing_detail_${listing.id}_$index',
                                child: CachedNetworkImage(
                                  imageUrl: listing.images[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) =>
                                      AppImages.cachedNetworkImagePlaceholder(
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, error, stackTrace) =>
                                      AppImages.cachedNetworkImageError(
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.gray100,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: AppColors.gray400,
                            ),
                          ),
                        ),

                  // Image indicator
                  if (listing.images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          listing.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? AppColors.primary
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Image counter
                  if (listing.images.length > 1)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${listing.images.length}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.cardBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'By ',
                              style: GoogleFonts.poppins(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(listing.userId.isNotEmpty
                                      ? listing.userId
                                      : 'dummy')
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final userData = snapshot.data!.data()
                                      as Map<String, dynamic>?;
                                  final displayName =
                                      userData?['displayName'] ?? 'Elan';
                                  return Text(
                                    displayName,
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }
                                return Text(
                                  'Elan',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            Icon(Icons.star, color: AppColors.accent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '4.9 (2.2k)',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '${listing.price.toStringAsFixed(0)} ₼',
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(listing.price * 1.2).toStringAsFixed(0)} ₼',
                              style: GoogleFonts.poppins(
                                color: AppColors.textMuted,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Listing Info
                        _buildListingInfo(listing),
                      ],
                    ),
                  ),

                  // Category
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kateqoriya',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            listing.category,
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

                  const SizedBox(height: 32),

                  // Features Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xüsusiyyətlər',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureItem(
                          icon: Icons.location_on_outlined,
                          title: 'Ünvan',
                          value: 'Bakı şəhəri, Yasamal rayonu',
                        ),
                        _buildFeatureItem(
                          icon: Icons.square_foot_outlined,
                          title: 'Sahə',
                          value: '120 m²',
                        ),
                        _buildFeatureItem(
                          icon: Icons.bed_outlined,
                          title: 'Otaq sayı',
                          value: '3 otaq',
                        ),
                        _buildFeatureItem(
                          icon: Icons.wifi,
                          title: 'WiFi',
                          value: 'Mövcuddur',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Təsvir',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          listing.description,
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Statistika bölməsi
          SliverToBoxAdapter(
            child: StreamBuilder<ListingStats>(
              stream: statsService.getStats(listing.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }

                final stats = snapshot.data!;
                final isOwner = listingController.isOwner;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistika',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.visibility,
                              value: stats.viewCount.toString(),
                              label: 'Baxış',
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatItem(
                                icon: Icons.favorite,
                                value: stats.favoriteCount.toString(),
                                label: 'Favorit',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Əlaqə düyməsi
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(listing.phone),
                icon: Icon(Icons.phone),
                label: Text('Zəng et'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _makePhoneCall(listing.phone),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Zəng et',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _startChat(listing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Mesaj göndər',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingInfo(ListingModel listing) {
    final currentUser = AuthService.to.currentUser.value;
    final isOwner = currentUser?.uid == listing.userId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Elan Məlumatları',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Elan ID:', listing.id),
          _buildInfoRow('Yaradılma tarixi:',
              AppDateUtils.DateUtils.formatDateTime(listing.createdAt)),
          _buildInfoRow('Telefon:', listing.phone),
          if (isOwner) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(listing),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: Text(
                  'Elanı Sil',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ListingModel listing) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Elanı Sil',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Bu elanı silmək istədiyinizdən əminsiniz? Bu əməliyyat geri alına bilməz.',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Ləğv et',
              style: GoogleFonts.poppins(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _deleteListing(listing),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Sil',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteListing(ListingModel listing) async {
    final currentUser = AuthService.to.currentUser.value;
    if (currentUser == null) {
      Get.back();
      Get.snackbar('Xəta', 'İstifadəçi məlumatları tapılmadı');
      return;
    }

    Get.back(); // Close dialog

    // Show loading
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      final success = await FirestoreService.to.deleteListing(
        listing.id,
        currentUser.uid,
      );

      Get.back(); // Close loading

      if (success) {
        Get.back(); // Go back to previous screen
        Get.snackbar(
          'Uğur',
          'Elan uğurla silindi',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Xəta',
        'Elan silinərkən xəta baş verdi: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      Get.snackbar(
        'Xəta',
        'Zəng etmək mümkün olmadı',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _startChat(ListingModel listing) async {
    // Chat functionality removed
    Get.snackbar('Məlumat', 'Mesajlaşma funksiyası deaktiv edilib');
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
