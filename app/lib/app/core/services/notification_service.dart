import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/notification_model.dart';
import 'auth_service.dart';

class NotificationService extends GetxService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  StreamSubscription? _tokenRefreshSubscription;

  @override
  void onInit() {
    super.onInit();
    _initLocalNotifications();
    _initFCM();

    // Listen to current user changes
    final authService = Get.find<AuthService>();

    // Handle user already logged in at startup
    if (authService.currentUser.value != null) {
      saveFcmToken(authService.currentUser.value!.uid);
    }

    ever(authService.currentUser, (user) {
      if (user != null) {
        saveFcmToken(user.uid);
      }
    });
  }

  // ── FCM Initialization ──────────────────────────────────────────────
  Future<void> _initFCM() async {
    // Request FCM permission (Android 13+ requires runtime permission)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Handle foreground FCM messages — show local notification
    FirebaseMessaging.onMessage.listen(_onForegroundFCMMessage);

    // Handle notification tap when app was in background (not killed)
    FirebaseMessaging.onMessageOpenedApp.listen(_onFCMMessageTap);

    // Check if app was opened from a terminated state via notification tap
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      // Delay slightly to ensure navigation stack is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        _onFCMMessageTap(initialMessage);
      });
    }
  }

  void _onForegroundFCMMessage(RemoteMessage message) {
    // Show a local notification so the user sees it while app is in foreground
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotificationFromFCM(
        title: notification.title ?? '',
        body: notification.body ?? '',
        data: message.data,
      );
    }
  }

  void _onFCMMessageTap(RemoteMessage message) {
    // Navigate to job detail if jobId is in the data payload
    final jobId = message.data['jobId'];
    final notifId = message.data['notifId'];
    final userId = message.data['userId'];

    // Mark as read if we have the info
    if (notifId != null && userId != null) {
      markAsRead(userId, notifId);
    }

    if (jobId != null && jobId.toString().isNotEmpty) {
      _navigateToJobDetail(jobId.toString());
    }
  }

  void _navigateToJobDetail(String jobId) async {
    try {
      final snapshot = await _db.child('jobs').child(jobId).get();
      if (snapshot.exists && snapshot.value != null) {
        // Navigate using route name; the job detail page will fetch
        // the job from the argument
        Get.toNamed('/job-detail', arguments: {'jobId': jobId});
      }
    } catch (_) {}
  }

  // ── FCM Token Management ────────────────────────────────────────────
  Future<void> saveFcmToken(String uid) async {
    try {
      final token = await _fcm.getToken();
      if (token != null && uid.isNotEmpty) {
        await _db.child('users').child(uid).update({'fcmToken': token});
      }

      // Listen for token refresh
      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription =
          _fcm.onTokenRefresh.listen((newToken) async {
        if (uid.isNotEmpty) {
          await _db.child('users').child(uid).update({'fcmToken': newToken});
        }
      });
    } catch (_) {}
  }

  /// Clear FCM token from RTDB on logout so user stops receiving pushes
  Future<void> clearFcmToken(String uid) async {
    try {
      _tokenRefreshSubscription?.cancel();
      if (uid.isNotEmpty) {
        await _db.child('users').child(uid).child('fcmToken').remove();
      }
      await _fcm.deleteToken();
    } catch (_) {}
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

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    // The payload contains the jobId for navigation
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _navigateToJobDetail(payload);
    }
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



  Future<void> _showLocalNotificationFromFCM({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
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

    final jobId = data?['jobId'] ?? '';

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: jobId,
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
    _tokenRefreshSubscription?.cancel();
    super.onClose();
  }
}

