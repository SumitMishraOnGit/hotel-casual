import 'package:get/get.dart';
import '../controllers/role_select_controller.dart';

class RoleSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleSelectController>(() => RoleSelectController());
  }
}
