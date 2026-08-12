import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  final isUpdating = false.obs;
  final totalJobsPosted = 0.obs;
  final activeJobsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initAdminStats();
  }

  void _initAdminStats() {
    final user = authService.currentUser.value;
    if (user != null && user.role == 'admin') {
      final jobService = Get.find<JobService>();
      jobService.streamAdminJobs(user.uid).listen((jobs) {
        totalJobsPosted.value = jobs.length;
        activeJobsCount.value = jobs.where((j) => j.status == 'open').length;
      });
    }
  }

  Future<void> updateName(String newName) async {
    final user = authService.currentUser.value;
    if (user == null) return;

    isUpdating.value = true;
    try {
      await _db.child('users').child(user.uid).update({
        'name': newName,
      });
      // Refresh user data locally
      await authService.fetchUserProfile(user.uid);
      Get.back(); // close dialog
      Get.snackbar(
        'Success',
        'Name updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update name: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void showEditNameDialog() {
    final user = authService.currentUser.value;
    if (user == null) return;

    final controller = TextEditingController(text: user.name);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Full Name'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isUpdating.value
                  ? null
                  : () {
                      final name = controller.text.trim();
                      if (name.length >= 2) {
                        updateName(name);
                      } else {
                        Get.snackbar(
                          'Invalid Input',
                          'Name must be at least 2 characters',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
              child: isUpdating.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateExperience(int years) async {
    final user = authService.currentUser.value;
    if (user == null) return;

    isUpdating.value = true;
    try {
      await _db.child('users').child(user.uid).update({
        'experienceYears': years,
      });
      // Refresh user data locally
      await authService.fetchUserProfile(user.uid);
      Get.back(); // close dialog
      Get.snackbar(
        'Success',
        'Experience updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update experience: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void showEditExperienceDialog() {
    final user = authService.currentUser.value;
    if (user == null) return;

    final controller = TextEditingController(text: user.experienceYears > 0 ? user.experienceYears.toString() : '');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Experience'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total experience (in years)'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 2',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: isUpdating.value
                  ? null
                  : () {
                      final years = int.tryParse(controller.text.trim());
                      if (years != null && years >= 0) {
                        updateExperience(years);
                      } else {
                        Get.snackbar(
                          'Invalid Input',
                          'Please enter a valid number of years',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
              child: isUpdating.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
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
    await authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
