import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/job_model.dart';

class JobDetailController extends GetxController {
  final job = Rxn<JobModel>();
  final isAdmin = false.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is JobModel) {
      job.value = args;
    } else {
      hasError.value = true;
    }
    final currentUser = Get.find<AuthService>().currentUser.value;
    isAdmin.value = currentUser?.role == 'admin';
  }

  Future<void> launchCaller(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.isEmpty) return;
    final Uri url = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      Get.snackbar('Error', 'Could not launch dialer');
    }
  }

  void cancelJob() {
    Get.back();
    Get.snackbar('Cancel Job', 'Cancel functionality is managed on the dashboard');
  }

  void applyNow() {
    Get.snackbar('Coming Soon', 'Apply logic will be enabled in Day 3 worker flow');
  }
}
