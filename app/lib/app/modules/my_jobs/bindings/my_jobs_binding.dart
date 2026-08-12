import 'package:get/get.dart';
import '../controllers/my_jobs_controller.dart';

class MyJobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyJobsController>(() => MyJobsController());
  }
}
