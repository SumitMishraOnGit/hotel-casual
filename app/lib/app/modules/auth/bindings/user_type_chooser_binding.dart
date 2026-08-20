import 'package:get/get.dart';
import '../controllers/user_type_chooser_controller.dart';

class UserTypeChooserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserTypeChooserController>(
      () => UserTypeChooserController(),
    );
  }
}
