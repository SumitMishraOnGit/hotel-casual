import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../data/models/job_model.dart';
import '../../../routes/app_routes.dart';

class MyJobsController extends GetxController {
  final isLoading = true.obs;
  final allMyJobs = <JobModel>[].obs;

  final AuthService _authService = Get.find<AuthService>();
  final JobService _jobService = Get.find<JobService>();

  String get workerUid => _authService.currentUser.value?.uid ?? '';

  /// Returns true if the job's date is today or in the future
  bool _isDateUpcoming(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;
      final jobDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      return !jobDate.isBefore(todayOnly);
    } catch (_) {
      return false;
    }
  }

  List<JobModel> get upcomingJobs {
    return allMyJobs.where((job) {
      if (job.status == 'cancelled') return false;
      if (!_isDateUpcoming(job.date)) return false;
      return job.status == 'open' || job.status == 'filled';
    }).toList();
  }

  List<JobModel> get pastJobs {
    return allMyJobs.where((job) {
      if (job.status == 'completed' || job.status == 'cancelled') return true;
      // Date has passed but status wasn't updated (open/filled)
      return !_isDateUpcoming(job.date);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    if (workerUid.isNotEmpty) {
      _jobService.streamWorkerJobs(workerUid).listen((list) {
        allMyJobs.value = list;
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }
  }

  void goToJobDetail(JobModel job) {
    Get.toNamed(Routes.jobDetail, arguments: job);
  }

  String getAppliedRole(JobModel job) {
    final app = job.applicants[workerUid];
    if (app is Map) {
      final titleIdx = app['titleIndex'];
      if (titleIdx is int && titleIdx >= 0 && titleIdx < job.titles.length) {
        return job.titles[titleIdx].title;
      }
    }
    return '';
  }
}
