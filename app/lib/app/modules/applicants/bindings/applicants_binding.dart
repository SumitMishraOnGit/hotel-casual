import 'package:get/get.dart';
import '../controllers/applicants_controller.dart';

class ApplicantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicantsController>(() => ApplicantsController());
  }
}
