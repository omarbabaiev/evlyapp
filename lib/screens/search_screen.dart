import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/listing_card.dart';
import '../controllers/search_controller.dart' as app_search;

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(app_search.AppSearchController());

    // Check if we have filter results from FilterScreen
    final arguments = Get.arguments;
    if (arguments != null && arguments['results'] != null) {
      controller.searchResults.value = arguments['results'];
      controller.searchQuery.value = 'Filter nəticələri';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Axtarış',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              readOnly: false,
              onChanged: controller.onSearchChanged,
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return _buildRecentSearches(controller);
              } else if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (controller.searchResults.isEmpty) {
                return _buildNoResults();
              } else {
                return _buildSearchResults(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(app_search.AppSearchController controller) {
    return Obx(() {
      if (controller.recentSearches.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 80,
                color: AppColors.gray400,
              ),
              const SizedBox(height: 16),
              Text(
                'Axtarış etmək üçün yuxarıdakı sahəni istifadə edin',
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Axtarışlar',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: Text(
                    'Təmizlə',
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.recentSearches.length,
              itemBuilder: (context, index) {
                final search = controller.recentSearches[index];
                return ListTile(
                  leading: Icon(
                    Icons.history,
                    color: AppColors.gray400,
                  ),
                  title: Text(
                    search,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => controller.removeRecentSearch(search),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.gray400,
                      size: 20,
                    ),
                  ),
                  onTap: () => controller.selectRecentSearch(search),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            'Heç bir nəticə tapılmadı',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Başqa açar sözlər cəhd edin',
            style: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(app_search.AppSearchController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final listing = controller.searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ListingCard(listing: listing),
        );
      },
    );
  }
}
