import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/login_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/bindings/register_binding.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/worker_home/views/worker_home_view.dart';
import '../modules/admin/bindings/admin_dashboard_binding.dart';
import '../modules/admin/bindings/create_job_binding.dart';
import '../modules/admin/views/admin_dashboard_view.dart';
import '../modules/admin/views/create_job_view.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.workerHome,
      page: () => const WorkerHomeView(),
    ),
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: Routes.createJob,
      page: () => const CreateJobView(),
      binding: CreateJobBinding(),
    ),
  ];
}
