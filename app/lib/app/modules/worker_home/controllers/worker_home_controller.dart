import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../data/models/job_model.dart';
import '../../../routes/app_routes.dart';

class WorkerHomeController extends GetxController {
  final jobs = <JobModel>[].obs;
  final isLoading = true.obs;

  final searchQuery = ''.obs;

  final AuthService _authService = Get.find<AuthService>();
  final JobService _jobService = Get.find<JobService>();

  List<JobModel> get filteredJobs {
    return jobs.where((job) {
      final q = searchQuery.value.toLowerCase().trim();
      if (q.isEmpty) return true;
      return job.venueName.toLowerCase().contains(q) ||
          job.venueAddress.toLowerCase().contains(q) ||
          job.city.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _jobService.streamOpenJobs().listen((list) {
      jobs.value = list;
      isLoading.value = false;
    });
  }

  void goToJobDetail(JobModel job) {
    Get.toNamed(Routes.jobDetail, arguments: job);
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
