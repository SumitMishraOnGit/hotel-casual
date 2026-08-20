import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class WorkerKycController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'hotel-casual-demo.firebasestorage.app',
  );
  final ImagePicker _picker = ImagePicker();

  late final String uid;
  late final String phone;
  late final String selectedRole;

  // Form controllers
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final docNumberController = TextEditingController();
  final experienceController = TextEditingController();

  // Observable state
  final profileImagePath = RxnString();
  final docImagePath = RxnString();
  final isLoading = false.obs;

  bool get isDriver => selectedRole == 'driver';

  /// Label shown for the document number field
  String get docNumberLabel => isDriver ? 'License Number' : 'Aadhaar Number';
  String get docNumberHint => isDriver ? 'e.g. DL-0420110012345' : 'e.g. 1234 5678 9012';
  String get docPhotoLabel => isDriver ? 'License Photo' : 'Aadhaar Photo';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final currentAuthUser = FirebaseAuth.instance.currentUser;
    final authUid = currentAuthUser?.uid ?? '';
    final authPhone = currentAuthUser?.phoneNumber ?? '';

    if (args is Map) {
      final argUid = args['uid']?.toString() ?? '';
      uid = argUid.isNotEmpty ? argUid : authUid;
      final argPhone = args['phone']?.toString() ?? '';
      phone = argPhone.isNotEmpty ? argPhone : authPhone;
      selectedRole = args['selectedRole']?.toString() ?? 'casual_banquet';
    } else {
      uid = authUid;
      phone = authPhone;
      selectedRole = 'casual_banquet';
    }
  }

  Future<void> pickProfilePhoto() async {
    _showSourcePicker(
      title: 'Profile Photo',
      onSelect: (source) async {
        final picked = await _picker.pickImage(source: source, imageQuality: 90);
        if (picked != null) profileImagePath.value = picked.path;
      },
    );
  }

  Future<void> pickDocPhoto() async {
    _showSourcePicker(
      title: docPhotoLabel,
      onSelect: (source) async {
        final picked = await _picker.pickImage(source: source, imageQuality: 90);
        if (picked != null) docImagePath.value = picked.path;
      },
    );
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

  bool _validate() {
    if (nameController.text.trim().isEmpty) {
      _snack('Name required', 'Please enter your full name.');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      _snack('City required', 'Please enter your city.');
      return false;
    }
    if (profileImagePath.value == null) {
      _snack('Profile photo required', 'Please upload a clear selfie.');
      return false;
    }
    final docRaw = docNumberController.text.trim();
    if (docRaw.isEmpty) {
      _snack('$docNumberLabel required', 'Please enter your $docNumberLabel.');
      return false;
    }
    if (!isDriver) {
      final cleanedAadhaar = docRaw.replaceAll(RegExp(r'\s+'), '');
      if (!RegExp(r'^\d{12}$').hasMatch(cleanedAadhaar)) {
        _snack('Invalid Aadhaar Number', 'Please enter a valid 12-digit Aadhaar number.');
        return false;
      }
    } else {
      if (docRaw.length < 8) {
        _snack('Invalid License Number', 'Please enter a valid driving license number.');
        return false;
      }
    }
    if (docImagePath.value == null) {
      _snack('$docPhotoLabel required', 'Please upload your $docPhotoLabel.');
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (!_validate()) return;
    isLoading.value = true;

    try {
      // Compress and upload profile photo
      final profileBytes = await _compress(profileImagePath.value!);
      if (profileBytes == null) throw Exception('Failed to compress profile photo.');
      final photoUrl = await _uploadBytes(profileBytes, 'users/$uid/profile_photo.jpg');

      // Compress and upload doc photo
      final docBytes = await _compress(docImagePath.value!);
      if (docBytes == null) throw Exception('Failed to compress document photo.');
      final docImageUrl = await _uploadBytes(docBytes, 'users/$uid/doc_image.jpg');

      final expYears = int.tryParse(experienceController.text.trim()) ?? 0;
      final docType = isDriver ? 'license' : 'aadhaar';
      final cleanDocNumber = isDriver
          ? docNumberController.text.trim()
          : docNumberController.text.replaceAll(RegExp(r'\s+'), '').trim();

      await _authService.createUserProfile(
        uid: uid,
        phone: phone,
        name: nameController.text.trim(),
        userType: 'worker',
        role: selectedRole,
        city: cityController.text.trim(),
        experienceYears: expYears,
        photoUrl: photoUrl,
        docType: docType,
        docNumber: cleanDocNumber,
        docImageUrl: docImageUrl,
      );

      Get.offAllNamed(Routes.workerHome);
    } catch (e) {
      _snack('Submission Failed', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void _snack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    cityController.dispose();
    docNumberController.dispose();
    experienceController.dispose();
    super.onClose();
  }
}
