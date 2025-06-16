class AppConstants {
  // App Info
  static const String appName = 'Evly';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Real Estate Marketplace';

  // Firebase Collections
  static const String collectionUsers = 'users';
  static const String collectionListings = 'listings';

  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserData = 'user_data';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxListingsPerUser = 10;

  // Image Constants
  static const double maxImageSizeMB = 5.0;
  static const int maxImagesPerListing = 5;

  // Validation Constants
  static const int minTitleLength = 3;
  static const int maxTitleLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 1000;
  static const double minPrice = 1000;
  static const double maxPrice = 10000000;

  // Rate Limiting
  static const Duration rateLimitDuration = Duration(seconds: 12);

  // Categories
  static const List<String> categories = [
    'Hamısı',
    'Ev',
    'Torpaq',
    'Mənzil',
    'Ofis',
    'Mağaza',
  ];

  // Placeholder Images
  static const String placeholderImage =
      'https://via.placeholder.com/400x300/4F7BF7/ffffff?text=Image';
  static const String bannerPlaceholder1 =
      'https://via.placeholder.com/400x200/1E88E5/ffffff?text=Banner+1';
  static const String bannerPlaceholder2 =
      'https://via.placeholder.com/400x200/43A047/ffffff?text=Banner+2';
  static const String bannerPlaceholder3 =
      'https://via.placeholder.com/400x200/E53935/ffffff?text=Banner+3';
}
