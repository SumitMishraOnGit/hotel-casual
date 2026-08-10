import 'package:get/get.dart';
import '../controllers/worker_home_controller.dart';

class WorkerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkerHomeController>(
      () => WorkerHomeController(),
    );
  }
}
