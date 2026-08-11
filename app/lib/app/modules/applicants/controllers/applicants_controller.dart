import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/job_service.dart';
import '../../../data/models/job_applicant.dart';
import '../../../data/models/job_model.dart';

class ApplicantsController extends GetxController {
  final applicants = <JobApplicant>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  late final JobModel job;
  late final JobService _jobService;

  @override
  void onInit() {
    super.onInit();
    _jobService = Get.find<JobService>();

    final args = Get.arguments;
    if (args is JobModel) {
      job = args;
      _fetchApplicants();
    } else {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  Future<void> _fetchApplicants() async {
    try {
      isLoading.value = true;
      final result = await _jobService.fetchJobApplicants(job);
      applicants.assignAll(result);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
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
}
