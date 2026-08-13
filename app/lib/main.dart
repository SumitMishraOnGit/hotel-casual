import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/core/services/auth_service.dart';
import 'app/core/services/job_service.dart';
import 'app/core/services/notification_service.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Register global singletons
  Get.put(AuthService(), permanent: true);
  Get.put(JobService(), permanent: true);
  Get.put(NotificationService(), permanent: true);

  runApp(const HotelCasualApp());
}

class HotelCasualApp extends StatelessWidget {
  const HotelCasualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hotel Casual',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
