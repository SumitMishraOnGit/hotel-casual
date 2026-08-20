import 'package:get/get.dart';
import '../controllers/hotel_onboarding_controller.dart';

class HotelOnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HotelOnboardingController>(() => HotelOnboardingController());
  }
}
