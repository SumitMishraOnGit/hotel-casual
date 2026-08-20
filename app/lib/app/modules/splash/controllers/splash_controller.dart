import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final userProfile = await _authService.fetchUserProfile(firebaseUser.uid);
        if (userProfile != null) {
          if (userProfile.userType == 'hotel' ||
              userProfile.userType == 'superadmin' ||
              userProfile.role == 'admin') {
            Get.offAllNamed(Routes.adminDashboard);
            return;
          } else {
            Get.offAllNamed(Routes.workerHome);
            return;
          }
        } else {
          // Logged in via Firebase Auth, but hasn't completed profile -> clean up session
          await _authService.cleanupIncompleteSession();
        }
      } catch (_) {
        // If error fetching profile, clean up session
        await _authService.cleanupIncompleteSession();
      }
    }

    Get.offAllNamed(Routes.login);
  }
}

