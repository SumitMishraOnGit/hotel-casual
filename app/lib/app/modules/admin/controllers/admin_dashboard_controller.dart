import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../data/models/job_model.dart';
import '../../../routes/app_routes.dart';

class AdminDashboardController extends GetxController {
  final jobs = <JobModel>[].obs;
  final isLoading = true.obs;

  final AuthService _authService = Get.find<AuthService>();
  final JobService _jobService = Get.find<JobService>();

  @override
  void onInit() {
    super.onInit();
    final adminId = _authService.currentUser.value?.uid ?? '';
    _jobService.streamAdminJobs(adminId).listen((list) {
      jobs.value = list;
      isLoading.value = false;
    });
  }

  void goToCreateJob() {
    Get.toNamed(Routes.createJob);
  }

  Future<void> cancelJob(String jobId) async {
    await _jobService.cancelJob(jobId);
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
