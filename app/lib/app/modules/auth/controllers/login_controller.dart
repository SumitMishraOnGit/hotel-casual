import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isOtpSent = false.obs;
  final isLoading = false.obs;
  final isFormValid = false.obs;
  final resendCountdown = 0.obs;

  Timer? _timer;
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_checkFormValidity);
    otpController.addListener(_checkFormValidity);

    final args = Get.arguments;
    if (args is Map && args['phone'] != null) {
      phoneController.text = args['phone'].toString();
      _checkFormValidity();
    }
  }

  void _checkFormValidity() {
    final phone = phoneController.text.trim();
    if (!isOtpSent.value) {
      isFormValid.value = RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
    } else {
      isFormValid.value = otpController.text.trim().length == 6;
    }
  }

  void _startCountdown() {
    resendCountdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final trimmed = value.trim();
    if (trimmed.length < 10) return 'Enter a 10-digit mobile number';
    if (!RegExp(r'^[6-9]').hasMatch(trimmed)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required';
    if (value.trim().length != 6) return 'Enter 6-digit OTP';
    return null;
  }

  void changePhoneNumber() {
    _timer?.cancel();
    resendCountdown.value = 0;
    otpController.clear();
    isOtpSent.value = false;
    _authService.resetOtpState();
    _checkFormValidity();
  }

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;

    final phone = phoneController.text.trim();
    isLoading.value = true;

    try {
      await _authService.sendOtp(
        phone: phone,
        onCodeSent: (verId) {
          isOtpSent.value = true;
          isLoading.value = false;
          _startCountdown();
          _checkFormValidity();
          Get.snackbar(
            'OTP Sent',
            'Verification code sent to +91 $phone',
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
    if (!formKey.currentState!.validate()) return;

    final smsCode = otpController.text.trim();
    final phone = phoneController.text.trim();
    isLoading.value = true;

    try {
      final user = await _authService.verifyOtp(smsCode: smsCode);

      if (user != null) {
        // Existing user profile found
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
        // New user - authenticated with Firebase Auth but no profile in RTDB
        final uid = _authService.firebaseUser.value?.uid ?? '';
        Get.offNamed(
          Routes.userTypeChooser,
          arguments: {
            'uid': uid,
            'phone': phone,
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
}

