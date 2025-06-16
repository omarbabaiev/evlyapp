import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/listing_model.dart';
import '../controllers/favorite_controller.dart';
import '../services/auth_service.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/date_utils.dart' as AppDateUtils;
import '../controllers/listing_controller.dart';
import '../core/constants/app_images.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onTap;

  const ListingCard({super.key, required this.listing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: .1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ??
              () {
                // Navigate to listing detail
                try {
                  if (listing.id.isEmpty) {
                    print('ListingCard: Cannot navigate - listing ID is empty');
                    Get.snackbar(
                      'Xəta',
                      'Elan məlumatları tapılmadı',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                    return;
                  }

                  Get.toNamed(
                    '/listing-detail',
                    arguments: listing,
                    preventDuplicates: true,
                  );
                } catch (e) {
                  print('Navigation error: $e');
                  Get.snackbar(
                    'Xəta',
                    'Elan məlumatlarına keçid zamanı xəta baş verdi',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'listing_detail_${listing.id}_0',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: listing.images.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: listing.images.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) =>
                                    AppImages.cachedNetworkImagePlaceholder(
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) =>
                                    AppImages.cachedNetworkImageError(
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                color: AppColors.gray100,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: AppColors.gray400,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // Image indicator

                    // Kateqoriya göstəricisi

                    // Favorite button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Obx(() {
                        final favoriteController =
                            Get.find<FavoriteController>();
                        final user = AuthService.to.currentUser.value;
                        final isFavorite =
                            user?.favoriteListings.contains(listing.id) ??
                                false;

                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                            ),
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  isFavorite ? Colors.red : AppColors.gray500,
                              size: 16,
                            ),
                            onPressed: () {
                              if (user != null) {
                                favoriteController.toggleFavorite(listing.id);
                              } else {
                                Get.snackbar('Xəta', 'Giriş etməlisiniz');
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        listing.title,
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Price
                      Text(
                        '${listing.price.toStringAsFixed(0)} AZN',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(.03),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${listing.city} • ${AppDateUtils.DateUtils.formatDateTime(listing.updatedAt ?? DateTime.now())}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.gray400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
