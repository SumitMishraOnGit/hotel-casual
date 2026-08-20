import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class RegisterController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isOtpSent = false.obs;
  final isLoading = false.obs;
  final isPhoneValid = false.obs;
  final isOtpValid = false.obs;
  final resendCountdown = 0.obs;

  final phoneError = RxnString();
  final hasPhoneInteracted = false.obs;

  // These are still needed by routes that navigate to register with profile data
  // (kept for backward-compat if userTypeChooser still passes them)
  String uid = '';
  String phone = '';
  String userType = 'worker';

  // Role options kept for profile form (used after userTypeChooser)
  final selectedRole = 'casual_banquet'.obs;
  final List<Map<String, String>> roleOptions = [
    {'code': 'casual_banquet', 'label': 'Casual Banquet'},
    {'code': 'cook_banquet', 'label': 'Cook Banquet'},
    {'code': 'driver', 'label': 'Driver'},
  ];

  Timer? _timer;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_checkPhoneValidity);
    otpController.addListener(_checkOtpValidity);

    // If navigated with arguments (e.g. from userTypeChooser → profile form)
    final args = Get.arguments;
    if (args is Map) {
      uid = args['uid']?.toString() ?? _authService.firebaseUser.value?.uid ?? '';
      phone = args['phone']?.toString() ?? '';
      userType = args['userType']?.toString() ?? 'worker';
    }
  }

  void _checkPhoneValidity() {
    final text = phoneController.text.trim();
    isPhoneValid.value = RegExp(r'^[6-9]\d{9}$').hasMatch(text);
    if (hasPhoneInteracted.value || text.length >= 10) {
      phoneError.value = validatePhone(text);
    } else {
      phoneError.value = null;
    }
  }

  void _checkOtpValidity() {
    isOtpValid.value = otpController.text.trim().length == 6;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 10) {
      return 'Enter a 10-digit mobile number';
    }
    if (!RegExp(r'^[6-9]').hasMatch(trimmed)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  void _startCountdown() {
    resendCountdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        t.cancel();
      }
    });
  }

  void goBackToPhone() {
    _timer?.cancel();
    resendCountdown.value = 0;
    otpController.clear();
    isOtpSent.value = false;
    isOtpValid.value = false;
    phoneError.value = null;
    _authService.resetOtpState();
  }

  void _showExistingAccountDialog(String phoneNum) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 10),
            Text(
              'Account Exists',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'An account is already registered with +91 $phoneNum. Would you like to log in instead?',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offNamed(Routes.login, arguments: {'phone': phoneNum});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log In Instead'),
          ),
        ],
      ),
    );
  }

  Future<void> sendOtp() async {
    hasPhoneInteracted.value = true;
    final phoneNum = phoneController.text.trim();
    final err = validatePhone(phoneNum);
    phoneError.value = err;
    if (err != null) return;

    isLoading.value = true;

    try {
      // Check if user already exists
      final existingUser = await _authService.getUserByPhone(phoneNum);
      if (existingUser != null) {
        isLoading.value = false;
        _showExistingAccountDialog(phoneNum);
        return;
      }

      await _authService.sendOtp(
        phone: phoneNum,
        onCodeSent: (verId) {
          isOtpSent.value = true;
          isLoading.value = false;
          _startCountdown();
          Get.snackbar(
            'OTP Sent',
            'Verification code sent to +91 $phoneNum',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        onError: (error) {
          isLoading.value = false;
          Get.snackbar(
            'Failed to Send OTP',
            error,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> verifyOtp() async {
    final smsCode = otpController.text.trim();
    final phoneNum = phoneController.text.trim();
    isLoading.value = true;

    try {
      final user = await _authService.verifyOtp(smsCode: smsCode);

      if (user != null) {
        // Existing user — go to their dashboard
        Get.snackbar(
          'Welcome Back',
          'Logged in as ${user.name}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (user.userType == 'hotel' || user.userType == 'superadmin' || user.role == 'admin') {
          Get.offAllNamed(Routes.adminDashboard);
        } else {
          Get.offAllNamed(Routes.workerHome);
        }
      } else {
        // New user — go to work/hire chooser
        final firebaseUid = _authService.firebaseUser.value?.uid ?? '';
        Get.offNamed(
          Routes.userTypeChooser,
          arguments: {
            'uid': firebaseUid,
            'phone': phoneNum,
          },
        );
      }
    } catch (e) {
      String message = e.toString().replaceAll('Exception: ', '');
      if (message.contains('invalid-verification-code')) {
        message = 'Invalid OTP. Please check and try again.';
      } else if (message.contains('session-expired')) {
        message = 'OTP expired. Please request a new code.';
      }
      Get.snackbar(
        'Verification Failed',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── kept for profile form (post-chooser step) ──────────────
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final experienceController = TextEditingController();
  final isFormValid = false.obs;

  void setRole(String roleCode) => selectedRole.value = roleCode;

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) return 'City is required';
    return null;
  }

  String? validateExperience(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) return 'Enter a valid number of years';
    return null;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final city = cityController.text.trim();
    final expYears = int.tryParse(experienceController.text.trim()) ?? 0;

    isLoading.value = true;

    try {
      final user = await _authService.createUserProfile(
        uid: uid,
        phone: phone,
        name: name,
        userType: 'worker',
        role: selectedRole.value,
        city: city,
        experienceYears: expYears,
      );

      Get.snackbar(
        'Account Created!',
        'Welcome, ${user.name}!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(Routes.workerHome);
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    otpController.dispose();
    nameController.dispose();
    cityController.dispose();
    experienceController.dispose();
    super.onClose();
  }
}

