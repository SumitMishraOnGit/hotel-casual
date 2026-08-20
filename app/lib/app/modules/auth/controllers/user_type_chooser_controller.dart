import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class UserTypeChooserController extends GetxController {
  late final String uid;
  late final String phone;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      uid = args['uid']?.toString() ?? '';
      phone = args['phone']?.toString() ?? '';
    } else {
      uid = '';
      phone = '';
    }
  }

  void chooseWorker() {
    Get.toNamed(
      Routes.roleSelect,
      arguments: {
        'uid': uid,
        'phone': phone,
      },
    );
  }

  void chooseHotel() {
    Get.toNamed(
      Routes.hotelOnboarding,
      arguments: {
        'uid': uid,
        'phone': phone,
      },
    );
  }
}

