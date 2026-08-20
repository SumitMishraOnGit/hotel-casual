import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/login_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/bindings/user_type_chooser_binding.dart';
import '../modules/auth/views/user_type_chooser_view.dart';
import '../modules/auth/bindings/register_binding.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/bindings/role_select_binding.dart';
import '../modules/auth/views/role_select_view.dart';
import '../modules/auth/bindings/worker_kyc_binding.dart';
import '../modules/auth/views/worker_kyc_view.dart';
import '../modules/auth/bindings/hotel_onboarding_binding.dart';
import '../modules/auth/views/hotel_onboarding_view.dart';
import '../modules/worker_home/bindings/worker_home_binding.dart';
import '../modules/worker_home/views/worker_home_view.dart';
import '../modules/admin/bindings/admin_dashboard_binding.dart';
import '../modules/admin/bindings/create_job_binding.dart';
import '../modules/admin/views/admin_dashboard_view.dart';
import '../modules/admin/views/create_job_view.dart';

import '../modules/job_detail/bindings/job_detail_binding.dart';
import '../modules/job_detail/views/job_detail_view.dart';
import '../modules/applicants/bindings/applicants_binding.dart';
import '../modules/applicants/views/applicants_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/my_jobs/bindings/my_jobs_binding.dart';
import '../modules/my_jobs/views/my_jobs_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';


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
      name: Routes.userTypeChooser,
      page: () => const UserTypeChooserView(),
      binding: UserTypeChooserBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.roleSelect,
      page: () => const RoleSelectView(),
      binding: RoleSelectBinding(),
    ),
    GetPage(
      name: Routes.workerKyc,
      page: () => const WorkerKycView(),
      binding: WorkerKycBinding(),
    ),
    GetPage(
      name: Routes.hotelOnboarding,
      page: () => const HotelOnboardingView(),
      binding: HotelOnboardingBinding(),
    ),
    GetPage(
      name: Routes.workerHome,
      page: () => const WorkerHomeView(),
      binding: WorkerHomeBinding(),
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
    GetPage(
      name: Routes.jobDetail,
      page: () => const JobDetailView(),
      binding: JobDetailBinding(),
    ),
    GetPage(
      name: Routes.applicants,
      page: () => const ApplicantsView(),
      binding: ApplicantsBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.myJobs,
      page: () => const MyJobsView(),
      binding: MyJobsBinding(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
  ];
}

