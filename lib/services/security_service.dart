import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SecurityService extends GetxService {
  static SecurityService get to => Get.find();

  final GetStorage _storage = GetStorage();

  // Input validation
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPrice(double price) {
    return price > 0 && price < 999999999;
  }

  bool isValidTitle(String title) {
    return title.trim().length >= 3 && title.trim().length <= 100;
  }

  bool isValidDescription(String description) {
    return description.trim().length >= 10 && description.trim().length <= 1000;
  }

  // Sanitize input
  String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(
          RegExp(r'[^\w\s\-.,!?;:()]'),
          '',
        ); // Allow only safe characters
  }

  // Rate limiting
  bool isRateLimited(String action) {
    final key = 'rate_limit_$action';
    final lastAction = _storage.read<int>(key) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 5 actions per minute
    if (now - lastAction < 12000) {
      // 12 seconds between actions
      print('SecurityService: Rate limited for action: $action');
      return true;
    }

    _storage.write(key, now);
    print('SecurityService: Rate limit check passed for action: $action');
    return false;
  }

  // Content validation
  bool containsInappropriateContent(String content) {
    final inappropriateWords = [
      'spam', 'fake', 'scam', 'fraud', 'illegal',
      // Add more inappropriate words as needed
    ];

    final lowerContent = content.toLowerCase();
    for (String word in inappropriateWords) {
      if (lowerContent.contains(word)) {
        print('SecurityService: Inappropriate content detected: $word');
        return true;
      }
    }
    print('SecurityService: Content validation passed');
    return false;
  }

  // Image validation
  bool isValidImageSize(int sizeInBytes) {
    return sizeInBytes <= 5 * 1024 * 1024; // 5MB max
  }

  // Permission checks
  bool canUserCreateListing(String userId) {
    final key = 'user_listings_count_$userId';
    final count = _storage.read<int>(key) ?? 0;

    // Max 10 listings per user
    return count < 10;
  }

  bool canUserDeleteListing(String userId, String listingOwnerId) {
    return userId == listingOwnerId;
  }

  // Update user listing count
  void incrementUserListingCount(String userId) {
    final key = 'user_listings_count_$userId';
    final count = _storage.read<int>(key) ?? 0;
    _storage.write(key, count + 1);
  }

  void decrementUserListingCount(String userId) {
    final key = 'user_listings_count_$userId';
    final count = _storage.read<int>(key) ?? 0;
    if (count > 0) {
      _storage.write(key, count - 1);
    }
  }
}
