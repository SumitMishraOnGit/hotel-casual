import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'hotel-casual-demo.firebasestorage.app',
  );
  final ImagePicker _picker = ImagePicker();

  final isUpdating = false.obs;
  final isUploadingImage = false.obs;
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

  Future<void> updateCity(String newCity) async {
    final user = authService.currentUser.value;
    if (user == null) return;

    isUpdating.value = true;
    try {
      await _db.child('users').child(user.uid).update({
        'city': newCity,
      });
      await authService.fetchUserProfile(user.uid);
      Get.back();
      Get.snackbar(
        'Success',
        'City updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update city: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> updateDocNumber(String newDocNumber) async {
    final user = authService.currentUser.value;
    if (user == null) return;

    isUpdating.value = true;
    try {
      await _db.child('users').child(user.uid).update({
        'docNumber': newDocNumber,
      });
      await authService.fetchUserProfile(user.uid);
      Get.back();
      Get.snackbar(
        'Success',
        'Document number updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update document number: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void showEditDocNumberDialog() {
    final user = authService.currentUser.value;
    if (user == null) return;

    final docTitle = user.docType == 'license' ? 'License Number' : 'Aadhaar Number';
    final controller = TextEditingController(text: user.docNumber ?? '');

    Get.dialog(
      AlertDialog(
        title: Text('Edit $docTitle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(docTitle),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textCapitalization: user.docType == 'license'
                  ? TextCapitalization.characters
                  : TextCapitalization.none,
              keyboardType: user.docType == 'license'
                  ? TextInputType.text
                  : TextInputType.number,
              decoration: InputDecoration(
                hintText: user.docType == 'license'
                    ? 'e.g. DL-0420110012345'
                    : 'e.g. 1234 5678 9012',
                border: const OutlineInputBorder(),
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
                      final docNum = controller.text.trim();
                      if (docNum.isNotEmpty) {
                        updateDocNumber(docNum);
                      } else {
                        Get.snackbar(
                          'Invalid Input',
                          'Document number cannot be empty',
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

  void showEditCityDialog() {
    final user = authService.currentUser.value;
    if (user == null) return;

    final controller = TextEditingController(text: user.city);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit City'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('City'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Enter your city',
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
                      final city = controller.text.trim();
                      if (city.isNotEmpty) {
                        updateCity(city);
                      } else {
                        Get.snackbar(
                          'Invalid Input',
                          'City cannot be empty',
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

  Future<void> updateHotelName(String newHotelName) async {
    final user = authService.currentUser.value;
    if (user == null) return;

    isUpdating.value = true;
    try {
      await _db.child('users').child(user.uid).update({
        'hotelName': newHotelName,
      });
      await authService.fetchUserProfile(user.uid);
      Get.back();
      Get.snackbar(
        'Success',
        'Hotel name updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update hotel name: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void showEditHotelNameDialog() {
    final user = authService.currentUser.value;
    if (user == null) return;

    final controller = TextEditingController(text: user.hotelName ?? '');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Hotel / Venue Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hotel or Venue Name'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Grand Palace Hotel',
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
                      if (name.isNotEmpty) {
                        updateHotelName(name);
                      } else {
                        Get.snackbar(
                          'Invalid Input',
                          'Hotel name cannot be empty',
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

  void showDocumentPreview(String title, String imageUrl) {
    if (imageUrl.isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.8,
                      maxScale: 3.0,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Padding(
                          padding: EdgeInsets.all(30),
                          child: Text('Unable to load document image'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 24),
              onPressed: () => Get.back(),
            ),
          ],
        ),
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

  Future<Uint8List?> _compress(String path) async {
    return await FlutterImageCompress.compressWithFile(
      path,
      quality: 72,
      minWidth: 1080,
      minHeight: 1080,
    );
  }

  Future<String> _uploadBytes(Uint8List bytes, String storagePath) async {
    final ref = _storage.ref(storagePath);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  void _showSourcePicker({
    required String title,
    required Future<void> Function(ImageSource source) onSelect,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload $title',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, size: 20, color: Color(0x8014181F)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Supported formats: JPG, PNG, WEBP (Max 5MB)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  color: Color(0x8014181F),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: const Text(
                  'Take Photo (Camera)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Capture directly using device camera',
                  style: TextStyle(fontSize: 12, color: Color(0x6614181F)),
                ),
                onTap: () {
                  Get.back();
                  onSelect(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_open_outlined, color: AppColors.primary),
                ),
                title: const Text(
                  'Browse Files & Gallery',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Choose from file manager or photo albums',
                  style: TextStyle(fontSize: 12, color: Color(0x6614181F)),
                ),
                onTap: () {
                  Get.back();
                  onSelect(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> reuploadProfilePhoto() async {
    final user = authService.currentUser.value;
    if (user == null) return;

    _showSourcePicker(
      title: 'Profile Photo',
      onSelect: (source) async {
        try {
          final picked = await _picker.pickImage(source: source, imageQuality: 90);
          if (picked == null) return;

          isUploadingImage.value = true;
          Get.showSnackbar(
            const GetSnackBar(
              message: 'Uploading photo...',
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.TOP,
            ),
          );

          final compressedBytes = await _compress(picked.path);
          if (compressedBytes == null) throw Exception('Failed to compress image');

          final downloadUrl = await _uploadBytes(
            compressedBytes,
            'users/${user.uid}/profile_photo.jpg',
          );

          await _db.child('users').child(user.uid).update({
            'photoUrl': downloadUrl,
          });

          await authService.fetchUserProfile(user.uid);

          Get.snackbar(
            'Success',
            'Profile photo updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Upload Failed',
            e.toString().replaceAll('Exception: ', ''),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        } finally {
          isUploadingImage.value = false;
        }
      },
    );
  }

  Future<void> reuploadDocPhoto() async {
    final user = authService.currentUser.value;
    if (user == null) return;

    final docTitle = user.docType == 'license' ? 'Driving License' : 'Aadhaar Card';

    _showSourcePicker(
      title: docTitle,
      onSelect: (source) async {
        try {
          final picked = await _picker.pickImage(source: source, imageQuality: 90);
          if (picked == null) return;

          isUploadingImage.value = true;
          Get.showSnackbar(
            const GetSnackBar(
              message: 'Uploading document...',
              duration: Duration(seconds: 2),
              snackPosition: SnackPosition.TOP,
            ),
          );

          final compressedBytes = await _compress(picked.path);
          if (compressedBytes == null) throw Exception('Failed to compress document');

          final downloadUrl = await _uploadBytes(
            compressedBytes,
            'users/${user.uid}/doc_image.jpg',
          );

          await _db.child('users').child(user.uid).update({
            'docImageUrl': downloadUrl,
          });

          await authService.fetchUserProfile(user.uid);

          Get.snackbar(
            'Success',
            '$docTitle photo updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Upload Failed',
            e.toString().replaceAll('Exception: ', ''),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        } finally {
          isUploadingImage.value = false;
        }
      },
    );
  }

  Future<void> logout() async {
    await authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
