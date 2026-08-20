import 'package:get/get.dart';
import '../controllers/worker_kyc_controller.dart';

class WorkerKycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkerKycController>(() => WorkerKycController());
  }
}
