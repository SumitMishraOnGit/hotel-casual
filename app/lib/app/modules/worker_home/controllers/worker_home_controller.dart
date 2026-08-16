import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../core/services/notification_service.dart';
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
          job.city.toLowerCase().contains(q) ||
          job.formattedJobNumber.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    Get.find<NotificationService>().requestPermission();
    _jobService.streamOpenJobs().listen((list) {
      final role = _authService.currentUser.value?.role ?? '';
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      jobs.value = list.where((job) {
        // Filter out jobs whose date has already passed
        try {
          final parts = job.date.split('-');
          if (parts.length == 3) {
            final jobDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            if (jobDate.isBefore(todayOnly)) return false;
          }
        } catch (_) {}
        // Filter by role
        if (role.isEmpty) return true;
        return job.titles.any(
          (t) => t.role.toLowerCase() == role.toLowerCase(),
        );
      }).toList();
      isLoading.value = false;
    });
  }

  void goToJobDetail(JobModel job) {
    Get.toNamed(Routes.jobDetail, arguments: job);
  }

  void goToProfile() {
    Get.toNamed(Routes.profile);
  }

  void goToMyJobs() {
    Get.toNamed(Routes.myJobs);
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
