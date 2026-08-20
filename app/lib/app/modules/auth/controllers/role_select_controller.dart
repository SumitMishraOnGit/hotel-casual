import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class RoleSelectController extends GetxController {
  late final String uid;
  late final String phone;

  /// null means user hasn't picked yet; Continue button stays disabled
  final selectedRole = RxnString();

  final List<Map<String, String>> roleOptions = [
    {'code': 'cook_banquet', 'label': 'Cook — Banquet', 'emoji': '🍱'},
    {'code': 'casual_banquet', 'label': 'Casual — Banquet', 'emoji': '💬'},
    {'code': 'driver', 'label': 'Driver', 'emoji': '🚗'},
  ];

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

  void selectRole(String code) => selectedRole.value = code;

  void onContinue() {
    final role = selectedRole.value;
    if (role == null) return;
    Get.toNamed(
      Routes.workerKyc,
      arguments: {
        'uid': uid,
        'phone': phone,
        'selectedRole': role,
      },
    );
  }
}
