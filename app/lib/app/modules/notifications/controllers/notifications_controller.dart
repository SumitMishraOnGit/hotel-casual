import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../routes/app_routes.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = true.obs;

  final AuthService _authService = Get.find<AuthService>();
  final NotificationService _notifService = Get.find<NotificationService>();

  String get userId => _authService.currentUser.value?.uid ?? '';

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    if (userId.isNotEmpty) {
      _notifService.streamNotifications(userId).listen((list) {
        notifications.value = list;
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }
  }

  void onNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      await _notifService.markAsRead(userId, notification.id);
    }
    if (notification.jobId.isNotEmpty) {
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref('jobs/${notification.jobId}')
            .get();
        if (snapshot.exists && snapshot.value != null) {
          final jobMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
          final job = JobModel.fromJson(jobMap);
          Get.toNamed(Routes.jobDetail, arguments: job);
        }
      } catch (_) {}
    }
  }

  void markAllAsRead() {
    if (userId.isNotEmpty) {
      _notifService.markAllAsRead(userId);
    }
  }
}
