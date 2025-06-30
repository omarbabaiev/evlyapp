import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/listing_card.dart';
import '../controllers/search_controller.dart' as app_search;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

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
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with Search
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildModernHeader(controller),
              ),
            ),

            // Content with animation
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return _buildRecentSearches(controller);
                  } else if (controller.isLoading.value) {
                    return _buildLoadingState();
                  } else if (controller.searchResults.isEmpty) {
                    return _buildNoResults();
                  } else {
                    return _buildSearchResults(controller);
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(app_search.AppSearchController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Axtarış',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Get.toNamed('/filter'),
                  icon: Icon(
                    Icons.tune,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Modern Search Bar
          _buildModernSearchBar(controller),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar(app_search.AppSearchController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.onSearchInputChanged,
              onSubmitted: controller.onSearchSubmitted,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Ev, mənzil, ofis axtarın...',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 24,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          // Axtarış düyməsi
          Container(
            height: 50,
            margin: const EdgeInsets.all(4),
            child: Obx(() => Material(
                  color: controller.searchQuery.value.trim().isNotEmpty
                      ? AppColors.primary
                      : AppColors.gray300,
                  borderRadius: BorderRadius.circular(14),
                  elevation:
                      controller.searchQuery.value.trim().isNotEmpty ? 2 : 0,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                  child: InkWell(
                    onTap: controller.searchQuery.value.trim().isNotEmpty
                        ? () => controller.performSearch()
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.isLoading.value)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            'Axtar',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ),
          // Clear düyməsi
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: controller.clearSearchResults,
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Axtarılır...',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearches(app_search.AppSearchController controller) {
    return Obx(() {
      if (controller.recentSearches.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
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
                TextButton.icon(
                  onPressed: controller.clearRecentSearches,
                  icon: Icon(
                    Icons.clear_all,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Təmizlə',
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
          // Recent searches list
          Expanded(
            child: ListView.builder(
              itemCount: controller.recentSearches.length,
              itemBuilder: (context, index) {
                final search = controller.recentSearches[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(50 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: _buildRecentSearchItem(search, controller),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRecentSearchItem(
      String search, app_search.AppSearchController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.history,
            color: AppColors.textMuted,
            size: 20,
          ),
        ),
        title: Text(
          search,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Təkrar axtarmaq üçün toxunun',
          style: GoogleFonts.poppins(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          onPressed: () => controller.removeRecentSearch(search),
          icon: Icon(
            Icons.close,
            color: AppColors.textMuted,
            size: 18,
          ),
        ),
        onTap: () => controller.selectRecentSearch(search),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.search,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Axtarışa başlayın',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yuxarıdakı axtarış sahəsindən\nistədiyiniz əmlakı tapın',
                    style: GoogleFonts.poppins(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 50,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Heç bir nəticə tapılmadı',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Başqa açar sözlər cəhd edin\nvə ya filtrləri dəyişin',
                    style: GoogleFonts.poppins(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(app_search.AppSearchController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final listing = controller.searchResults[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: ListingCard(listing: listing),
              ),
            );
          },
        );
      },
    );
  }
}
