import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../routes/app_routes.dart';

class AdminDashboardController extends GetxController {
  final jobs = <JobModel>[].obs;
  final isLoading = true.obs;

  final searchQuery = ''.obs;
  final selectedRole = 'All roles'.obs;
  final roles = const ['All roles', 'Steward', 'Driver', 'Chef'];

  final notifications = <NotificationModel>[].obs;

  late final JobService _jobService;
  late final AuthService _authService;
  late final NotificationService _notifService;

  String get adminId => _authService.currentUser.value?.uid ?? '';

  int get unreadNotifCount => notifications.where((n) => !n.isRead).length;

  List<JobModel> get filteredJobs {
    return jobs.where((job) {
      final q = searchQuery.value.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          job.venueName.toLowerCase().contains(q) ||
          job.venueAddress.toLowerCase().contains(q) ||
          job.city.toLowerCase().contains(q) ||
          job.formattedJobNumber.toLowerCase().contains(q);

      final role = selectedRole.value;
      final matchesRole = role == 'All roles' ||
          job.titles.any((t) => t.role.toLowerCase() == role.toLowerCase());

      return matchesQuery && matchesRole;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _jobService = Get.find<JobService>();
    _authService = Get.find<AuthService>();
    _notifService = Get.find<NotificationService>();

    if (adminId.isNotEmpty) {
      _jobService.streamAdminJobs(adminId).listen((list) {
        jobs.value = list;
        isLoading.value = false;
      });

      _notifService.streamNotifications(adminId).listen((list) {
        notifications.value = list;
      });
    } else {
      isLoading.value = false;
    }
  }

  void onNotificationTap(NotificationModel notification) async {
    Get.back(); // close bottom sheet
    if (!notification.isRead && adminId.isNotEmpty) {
      await _notifService.markAsRead(adminId, notification.id);
    }
    if (notification.jobId.isNotEmpty) {
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref('jobs/${notification.jobId}')
            .get();
        if (snapshot.exists && snapshot.value != null) {
          final jobMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
          final job = JobModel.fromJson(jobMap);
          if (notification.type == 'new_applicant') {
            Get.toNamed(Routes.applicants, arguments: job);
          } else {
            Get.toNamed(Routes.jobDetail, arguments: job);
          }
        }
      } catch (_) {}
    }
  }

  void openNotificationsSheet() {
    if (adminId.isNotEmpty && unreadNotifCount > 0) {
      _notifService.markAllAsRead(adminId);
    }

    Get.bottomSheet(
      Container(
        height: Get.height * 0.65,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_active_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Admin Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No admin alerts yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You will receive alerts here when workers apply to your jobs.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _buildAdminNotifCard(notif);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAdminNotifCard(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'new_applicant':
        iconData = Icons.person_add_rounded;
        iconColor = AppColors.primary;
        break;
      case 'job_cancelled':
        iconData = Icons.cancel_rounded;
        iconColor = Colors.red.shade600;
        break;
      case 'application_accepted':
        iconData = Icons.task_alt_rounded;
        iconColor = const Color(0xFF059669);
        break;
      case 'new_job':
        iconData = Icons.work_rounded;
        iconColor = const Color(0xFF2563EB);
        break;
      default:
        iconData = Icons.notifications_rounded;
        iconColor = AppColors.primary;
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead
              ? Colors.grey.shade200
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      color: notification.isRead
          ? Colors.white
          : AppColors.primary.withValues(alpha: 0.04),
      child: InkWell(
        onTap: () => onNotificationTap(notification),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inHours < 24) {
        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        return '${diff.inHours}h ago';
      }

      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = dt.day;
      final month = monthNames[dt.month - 1];
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';

      return '$day $month, $hour:$minute $period';
    } catch (_) {
      return '';
    }
  }

  void goToCreateJob() {
    Get.toNamed(Routes.createJob);
  }

  void goToProfile() {
    Get.toNamed(Routes.profile);
  }

  Future<void> cancelJob(String jobId) async {
    await _jobService.cancelJob(jobId);
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
