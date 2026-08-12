import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../../routes/app_routes.dart';

class WorkerBottomNav extends StatelessWidget {
  final int currentIndex;

  const WorkerBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          onTap: (index) {
            if (index == currentIndex) return;
            switch (index) {
              case 0:
                Get.offNamed(Routes.workerHome);
                break;
              case 1:
                Get.offNamed(Routes.myJobs);
                break;
              case 2:
                Get.offNamed(Routes.notifications);
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_history_rounded),
              activeIcon: Icon(Icons.work_history_rounded),
              label: 'My Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}
