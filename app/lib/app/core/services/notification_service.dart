import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/notification_model.dart';
import 'auth_service.dart';

class NotificationService extends GetxService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription? _rtdbSubscription;
  final Set<String> _notifiedIds = {};

  @override
  void onInit() {
    super.onInit();
    _initLocalNotifications();
    
    // Listen to current user changes
    final authService = Get.find<AuthService>();

    // Handle user already logged in at startup
    if (authService.currentUser.value != null) {
      _listenToUserNotifications(authService.currentUser.value!.uid);
    }

    ever(authService.currentUser, (user) {
      if (user != null) {
        _listenToUserNotifications(user.uid);
      } else {
        _rtdbSubscription?.cancel();
        _notifiedIds.clear();
      }
    });
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
  }

  /// Request runtime notification permission on Android / iOS
  Future<void> requestPermission() async {
    try {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } catch (_) {}
  }

  void _listenToUserNotifications(String uid) {
    _rtdbSubscription?.cancel();
    final ref = _db.child('notifications').child(uid);

    _rtdbSubscription = ref.onChildAdded.listen((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return;

      try {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        final notif = NotificationModel.fromJson(data);

        // Only trigger local popup with sound for unread notifications we haven't popped yet
        if (!notif.isRead && !_notifiedIds.contains(notif.id)) {
          _notifiedIds.add(notif.id);
          _showLocalNotification(notif);
        }
      } catch (_) {}
    });
  }

  Future<void> _showLocalNotification(NotificationModel notif) async {
    const androidDetails = AndroidNotificationDetails(
      'hotel_casual_channel',
      'Hotel Casual Notifications',
      channelDescription: 'Notifications for job updates and applications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@drawable/ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notif.id.hashCode,
      notif.title,
      notif.body,
      details,
    );
  }

  // ── Send Notification to a Target User ────────────────────────────────
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    required String jobId,
  }) async {
    if (userId.isEmpty) return;

    final ref = _db.child('notifications').child(userId).push();
    final notifId = ref.key!;

    final notification = NotificationModel(
      id: notifId,
      userId: userId,
      title: title,
      body: body,
      type: type,
      jobId: jobId,
      timestamp: DateTime.now().toIso8601String(),
      isRead: false,
    );

    await ref.set(notification.toJson());
  }

  // ── Stream Notifications for User ────────────────────────────────────
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _db.child('notifications').child(userId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final raw = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      final list = raw.values
          .map((v) => NotificationModel.fromJson(Map<dynamic, dynamic>.from(v as Map)))
          .toList();
      // Sort newest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  // ── Mark Notification as Read ────────────────────────────────────────
  Future<void> markAsRead(String userId, String notifId) async {
    await _db
        .child('notifications')
        .child(userId)
        .child(notifId)
        .update({'isRead': true});
  }

  // ── Mark All Notifications as Read ───────────────────────────────────
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _db.child('notifications').child(userId).get();
    if (!snapshot.exists || snapshot.value == null) return;

    final raw = Map<dynamic, dynamic>.from(snapshot.value as Map);
    final updates = <String, dynamic>{};
    for (final key in raw.keys) {
      updates['notifications/$userId/$key/isRead'] = true;
    }
    if (updates.isNotEmpty) {
      await _db.update(updates);
    }
  }

  @override
  void onClose() {
    _rtdbSubscription?.cancel();
    super.onClose();
  }
}
