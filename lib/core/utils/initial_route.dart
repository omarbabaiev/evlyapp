import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';

String getInitialRoute() {
  // Check if intro has been shown
  final storage = GetStorage();
  final introShown = storage.read('intro_shown') ?? false;

  if (!introShown) {
    return '/intro';
  }

  // Check if user is already logged in
  try {
    final authService = Get.find<AuthService>();
    if (authService.firebaseUser.value != null) {
      return '/main';
    }
  } catch (e) {
    print('Error getting auth service: $e');
  }
  return '/login';
}
