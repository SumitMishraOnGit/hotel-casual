import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class HotelOnboardingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'hotel-casual-demo.firebasestorage.app',
  );
  final ImagePicker _picker = ImagePicker();

  late final String uid;
  late final String phone;

  // Form controllers
  final nameController = TextEditingController();
  final hotelNameController = TextEditingController();
  final gstController = TextEditingController();

  // Observable state
  final venueImagePath = RxnString();
  final gstCertPath = RxnString();
  final isLoading = false.obs;
  final gstIsValid = false.obs;

  /// Standard 15-char GSTIN pattern
  static final _gstRegex = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );

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
    } else {
      uid = authUid;
      phone = authPhone;
    }
    gstController.addListener(_validateGst);
  }

  void _validateGst() {
    gstIsValid.value = _gstRegex.hasMatch(gstController.text.trim().toUpperCase());
  }

  Future<void> pickVenuePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) venueImagePath.value = picked.path;
  }

  Future<void> pickGstCert() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked != null) gstCertPath.value = picked.path;
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
    if (hotelNameController.text.trim().isEmpty) {
      _snack('Hotel name required', 'Please enter your hotel or venue name.');
      return false;
    }
    if (venueImagePath.value == null) {
      _snack('Venue photo required', 'Please upload a photo of your property.');
      return false;
    }
    if (!gstIsValid.value) {
      _snack('Invalid GST', 'Please enter a valid 15-character GST number.');
      return false;
    }
    if (gstCertPath.value == null) {
      _snack('GST Certificate required', 'Please upload your GST certificate.');
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (!_validate()) return;
    isLoading.value = true;

    try {
      // Compress and upload venue photo
      final venueBytes = await _compress(venueImagePath.value!);
      if (venueBytes == null) throw Exception('Failed to compress venue photo.');
      final photoUrl = await _uploadBytes(venueBytes, 'hotels/$uid/venue_photo.jpg');

      // Compress and upload GST cert
      final certBytes = await _compress(gstCertPath.value!);
      if (certBytes == null) throw Exception('Failed to compress GST certificate.');
      final gstCertUrl = await _uploadBytes(certBytes, 'hotels/$uid/gst_cert.jpg');

      await _authService.createUserProfile(
        uid: uid,
        phone: phone,
        name: nameController.text.trim(),
        userType: 'hotel',
        role: 'hotel',
        city: '',
        photoUrl: photoUrl,
        gstNumber: gstController.text.trim().toUpperCase(),
        gstCertUrl: gstCertUrl,
        hotelName: hotelNameController.text.trim(),
      );

      Get.offAllNamed(Routes.adminDashboard);
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
    hotelNameController.dispose();
    gstController.dispose();
    super.onClose();
  }
}
