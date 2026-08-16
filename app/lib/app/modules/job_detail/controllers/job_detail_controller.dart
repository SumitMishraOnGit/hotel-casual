import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../data/models/job_model.dart';
import '../../../routes/app_routes.dart';

class JobDetailController extends GetxController {
  final job = Rxn<JobModel>();
  final isAdmin = false.obs;
  final hasError = false.obs;

  // Apply flow state
  final hasApplied = false.obs;
  final isApplying = false.obs;

  late final JobService _jobService;
  late final AuthService _authService;

  @override
  void onInit() {
    super.onInit();
    _jobService = Get.find<JobService>();
    _authService = Get.find<AuthService>();

    final args = Get.arguments;
    if (args is JobModel) {
      job.value = args;
    } else {
      hasError.value = true;
    }
    final currentUser = _authService.currentUser.value;
    isAdmin.value = currentUser?.role == 'admin';

    // If worker, check if they've already applied
    if (!isAdmin.value && job.value != null && currentUser != null) {
      _checkAppliedStatus();
    }
  }

  String get userCity => _authService.currentUser.value?.city ?? '';

  bool get isJobDatePast {
    final dateStr = job.value?.date ?? '';
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return false;
      final jobDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final today = DateTime.now();
      return jobDate.isBefore(DateTime(today.year, today.month, today.day));
    } catch (_) {
      return false;
    }
  }

  bool get isCityMismatch {
    if (isAdmin.value) return false;
    final currentJob = job.value;
    final uCity = userCity.trim().toLowerCase();
    final jCity = currentJob?.city.trim().toLowerCase() ?? '';
    return uCity.isNotEmpty && jCity.isNotEmpty && uCity != jCity;
  }

  Future<void> _checkAppliedStatus() async {
    final currentJob = job.value;
    final currentUser = _authService.currentUser.value;
    if (currentJob == null || currentUser == null) return;

    // First check local data (from the JobModel already loaded)
    if (currentJob.hasWorkerApplied(currentUser.uid)) {
      hasApplied.value = true;
      return;
    }

    // Fallback: check Firebase directly (in case local data is stale)
    try {
      final applied =
          await _jobService.checkIfApplied(currentJob.jobId, currentUser.uid);
      hasApplied.value = applied;
    } catch (_) {
      // Silently ignore — worst case, worker can try to apply
      // and the transaction will catch the duplicate
    }
  }

  /// Determines the current state of the Apply button
  String get applyButtonState {
    final currentJob = job.value;
    final currentUser = _authService.currentUser.value;
    if (currentJob == null || currentUser == null) return 'error';
    if (currentJob.status == 'cancelled') return 'cancelled';
    if (isJobDatePast) return 'datePassed';
    if (hasApplied.value) return 'applied';
    if (isApplying.value) return 'applying';

    // Check role match
    final hasMatchingRole = currentJob.titles
        .any((t) => t.role.toLowerCase() == currentUser.role.toLowerCase());
    if (!hasMatchingRole) return 'roleMismatch';

    // Check slot availability for this role
    if (!currentJob.hasAvailableSlotsForRole(currentUser.role)) {
      return 'jobFull';
    }

    return 'canApply';
  }

  Future<void> applyNow() async {
    if (isApplying.value || hasApplied.value) return;

    final currentJob = job.value;
    final currentUser = _authService.currentUser.value;
    if (currentJob == null || currentUser == null) return;

    isApplying.value = true;

    final result = await _jobService.applyToJob(currentJob.jobId, currentUser);

    switch (result) {
      case ApplyResult.success:
        hasApplied.value = true;
        Get.snackbar(
          'Application Successful! 🎉',
          'You have been accepted for this job.',
          backgroundColor: const Color(0xFF059669),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        break;
      case ApplyResult.alreadyApplied:
        hasApplied.value = true;
        Get.snackbar(
          'Already Applied',
          'You have already applied to this job.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        break;
      case ApplyResult.jobFull:
        _showJobFilledDialog();
        break;
      case ApplyResult.roleMismatch:
        Get.snackbar(
          'No Matching Position',
          'This job doesn\'t have openings for your role.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        break;
      case ApplyResult.error:
        Get.snackbar(
          'Error',
          'Something went wrong. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        break;
    }

    isApplying.value = false;
  }

  void _showJobFilledDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 28),
            SizedBox(width: 10),
            Text('Job Just Filled'),
          ],
        ),
        content: const Text(
          'Sorry! All slots for your role have been filled while you were viewing this job. Try applying to other available jobs.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void goToApplicants() {
    if (job.value == null) return;
    Get.toNamed(Routes.applicants, arguments: job.value);
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

  final isCancelling = false.obs;

  Future<void> cancelJob() async {
    final currentJob = job.value;
    if (currentJob == null) return;

    // Confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text('Cancel Job?'),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel ${currentJob.formattedJobNumber} at ${currentJob.venueName}?\n\nAll accepted workers will be notified.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes, Cancel Job'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    isCancelling.value = true;
    try {
      await _jobService.cancelJob(currentJob.jobId);
      // Update local state so UI reflects immediately
      job.value = JobModel(
        jobId: currentJob.jobId,
        jobNumber: currentJob.jobNumber,
        adminId: currentJob.adminId,
        venueName: currentJob.venueName,
        venueAddress: currentJob.venueAddress,
        city: currentJob.city,
        date: currentJob.date,
        wage: currentJob.wage,
        description: currentJob.description,
        contactPersonName: currentJob.contactPersonName,
        contactPersonPhone: currentJob.contactPersonPhone,
        titles: currentJob.titles,
        applicants: currentJob.applicants,
        status: 'cancelled',
        createdAt: currentJob.createdAt,
      );
      Get.snackbar(
        'Job Cancelled',
        '${currentJob.formattedJobNumber} has been cancelled and workers notified.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not cancel the job. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isCancelling.value = false;
    }
  }
}
