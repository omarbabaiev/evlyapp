import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'firestore_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GetStorage _storage = GetStorage();

  // Navigasyon kontrolü için yeni değişkenler
  final bool _disableInitialNavigation;
  bool _navigationEnabled = false;

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  AuthService({bool disableInitialNavigation = false})
      : _disableInitialNavigation = disableInitialNavigation;

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
    super.onInit();

    // Eğer başlangıçta navigasyon devre dışı değilse, hemen etkinleştir
    if (!_disableInitialNavigation) {
      _navigationEnabled = true;
    }
  }

  // Navigasyonu etkinleştiren metot
  void enableNavigation() {
    _navigationEnabled = true;
    _setInitialScreen(firebaseUser.value);
  }

  void _setInitialScreen(User? user) async {
    try {
      // Eğer GetMaterialApp hazır değilse veya navigasyon devre dışıysa, navigasyon yapmaya çalışmayın
      if ((!Get.isRegistered<GetMaterialApp>() && Get.key == null) ||
          !_navigationEnabled) {
        print(
            'AuthService: Navigasyon ertelendi (${_navigationEnabled ? "GetMaterialApp hazır değil" : "Navigasyon devre dışı"})');
        return;
      }

      if (user == null) {
        currentUser.value = null;
        _storage.remove(AppConstants.keyIsLoggedIn);

        // GetMaterialApp hazır olduğunda navigasyon yap
        if (Get.key != null && Get.currentRoute != '/login') {
          try {
            await Future.delayed(const Duration(milliseconds: 500));
            Get.offAllNamed('/login');
          } catch (e) {
            print('AuthService: Login navigasyon hatası: $e');
          }
        }
      } else {
        await _loadUserData(user);
        _storage.write(AppConstants.keyIsLoggedIn, true);

        // GetMaterialApp hazır olduğunda navigasyon yap
        if (Get.key != null && Get.currentRoute != '/main') {
          try {
            await Future.delayed(const Duration(milliseconds: 500));
            Get.offAllNamed('/main');
          } catch (e) {
            print('AuthService: Main navigasyon hatası: $e');
          }
        }
      }
    } catch (e) {
      print('AuthService: Error in _setInitialScreen: $e');
    }
  }

  Future<void> _loadUserData(User user) async {
    try {
      print('AuthService: Loading user data for ${user.uid}');
      final userData = await FirestoreService.to.getUserData(user.uid);
      if (userData != null) {
        print('AuthService: User data loaded successfully');
        print(
          'AuthService: User has ${userData.favoriteListings.length} favorite listings',
        );
        currentUser.value = userData;
      } else {
        print('AuthService: No existing user data found, creating new user');
        // İlk dəfə giriş edən istifadəçi üçün yeni profil yarat
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
          favoriteListings: [],
        );
        final success = await FirestoreService.to.createUser(newUser);
        if (success) {
          print('AuthService: New user created successfully');
          currentUser.value = newUser;
        } else {
          print('AuthService: Failed to create new user');
        }
      }
    } catch (e) {
      print('AuthService: Error loading user data: $e');
      Get.snackbar('Xəta', 'İstifadəçi məlumatları yüklənə bilmədi');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      Get.snackbar('Xəta', 'Google ilə giriş uğursuz oldu');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      currentUser.value = null;
      _storage.remove(AppConstants.keyIsLoggedIn);
    } catch (e) {
      Get.snackbar('Xəta', 'Çıxış zamanı xəta baş verdi');
    }
  }

  bool get isLoggedIn => firebaseUser.value != null;

  Future<void> refreshUserData() async {
    final user = firebaseUser.value;
    if (user != null) {
      await _loadUserData(user);
    }
  }
}
