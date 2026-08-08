import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Simulate loading/initialization time
    await Future.delayed(const Duration(seconds: 2));
    
    // Navigate to login
    Get.offAllNamed(Routes.login);
  }
}
