import 'package:get/get.dart';
import '../../screens/home_screen.dart';
import '../../screens/favorite_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/add_listing_screen.dart';
import '../../screens/listing_detail_screen.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/main', page: () => const MainScreen()),
    GetPage(name: '/home', page: () => const HomeScreen()),
    GetPage(name: '/favorites', page: () => const FavoriteScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(name: '/add-listing', page: () => const AddListingScreen()),
    GetPage(
      name: '/listing-detail',
      page: () => ListingDetailScreen(listing: Get.arguments),
    ),
  ];
}
