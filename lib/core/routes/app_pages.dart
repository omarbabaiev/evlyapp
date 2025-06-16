import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import '../../screens/home_screen.dart';
import '../../screens/favorite_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/intro_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/add_listing_screen.dart';
import '../../screens/listing_detail_screen.dart';

import '../../screens/my_listings_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/filter_screen.dart';

import '../../controllers/listing_controller.dart';
import '../../services/listing_stats_service.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: '/intro', page: () => const IntroScreen()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/main', page: () => const MainScreen()),
    GetPage(name: '/home', page: () => const HomeScreen()),
    GetPage(name: '/favorites', page: () => const FavoriteScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(
        name: '/add-listing',
        page: () => const AddListingScreen(),
        transition: Transition.circularReveal),
    GetPage(
      name: '/listing-detail',
      page: () => ListingDetailScreen(
        listing:
            Get.arguments is Map ? Get.arguments['listing'] : Get.arguments,
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ListingController());
        Get.lazyPut(() => ListingStatsService());
      }),
    ),
    GetPage(name: '/my-listings', page: () => const MyListingsScreen()),
    GetPage(name: '/search', page: () => const SearchScreen()),
    GetPage(name: '/filter', page: () => const FilterScreen()),
  ];
}
