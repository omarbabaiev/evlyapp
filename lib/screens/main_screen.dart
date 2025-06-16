import 'package:evlyapp/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/main_controller.dart';
import 'package:page_transition/page_transition.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';
import 'add_listing_screen.dart';
import '../core/theme/app_colors.dart';
import '../core/routes/app_pages.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({Key? key}) : super(key: key);

  Widget _buildPage(int index) {
    final List<Widget> pages = [
      const HomeScreen(),
      const FavoriteScreen(),
      Container(),
      const ProfileScreen(),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.01, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(index),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Yalnız CustomScrollView və ListView scroll-larını dinlə
            // Carousel və digər horizontal scroll-ları ignore et
            if (scrollInfo is ScrollUpdateNotification) {
              final scrollable = scrollInfo.metrics.axisDirection;
              // Yalnız vertical scroll-ları dinlə
              if (scrollable == AxisDirection.down ||
                  scrollable == AxisDirection.up) {
                controller.handleScroll(scrollInfo.scrollDelta ?? 0);
              }
            } else if (scrollInfo is ScrollEndNotification) {
              final scrollable = scrollInfo.metrics.axisDirection;
              if (scrollable == AxisDirection.down ||
                  scrollable == AxisDirection.up) {
                controller.resetAccumulatedDelta();
              }
            }
            return false;
          },
          child: pages[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.onWillPop,
      child: GetBuilder<MainController>(
        builder: (controller) => Scaffold(
          body: Obx(() => _buildPage(controller.currentIndex.value)),
          floatingActionButton: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => Get.toNamed(Routes.ADD_LISTING),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          floatingActionButtonLocation: controller.isBottomBarVisible.value
              ? FloatingActionButtonLocation.centerDocked
              : FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: controller.isBottomBarVisible.value ? 70 : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: controller.isBottomBarVisible.value ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 1,
                          offset: const Offset(0, -.2),
                        ),
                      ],
                    ),
                    child: BottomAppBar(
                      height: 70,
                      color: Colors.white,
                      notchMargin: 10,
                      shape: const CircularNotchedRectangle(),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(
                              context: context,
                              icon: Icons.home_outlined,
                              selectedIcon: Icons.home_rounded,
                              label: 'Ana Səhifə',
                              index: 0,
                              currentIndex: controller.currentIndex.value,
                              onTap: controller.changePage,
                            ),
                            _buildNavItem(
                              context: context,
                              icon: Icons.favorite_border_rounded,
                              selectedIcon: Icons.favorite_rounded,
                              label: 'Sevimlilər',
                              index: 1,
                              currentIndex: controller.currentIndex.value,
                              onTap: controller.changePage,
                            ),
                            const SizedBox(width: 60), // Space for FAB
                            _buildNavItem(
                              context: context,
                              icon: Icons.chat_bubble_outline_rounded,
                              selectedIcon: Icons.chat_bubble_rounded,
                              label: 'Mesajlar',
                              index: 2,
                              currentIndex: controller.currentIndex.value,
                              onTap: controller.changePage,
                            ),
                            _buildNavItem(
                              context: context,
                              icon: Icons.person_outline_rounded,
                              selectedIcon: Icons.person_rounded,
                              label: 'Profil',
                              index: 3,
                              currentIndex: controller.currentIndex.value,
                              onTap: controller.changePage,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int currentIndex,
    required Function(int) onTap,
  }) {
    final isSelected = index == currentIndex;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? AppColors.primary : AppColors.gray600,
                  size: 24,
                ),
              ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.poppins(
                  color: isSelected ? AppColors.primary : AppColors.gray600,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
