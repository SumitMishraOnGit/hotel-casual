import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final cityController = TextEditingController();
  final experienceController = TextEditingController();

  final selectedRole = 'steward'.obs;
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final isFormValid = false.obs;

  final AuthService _authService = Get.find<AuthService>();
  final roles = ['Steward', 'Driver', 'Chef', 'Admin'];

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_checkFormValidity);
    phoneController.addListener(_checkFormValidity);
    passwordController.addListener(_checkFormValidity);
    cityController.addListener(_checkFormValidity);
    experienceController.addListener(_checkFormValidity);
  }

  void _checkFormValidity() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final city = cityController.text.trim();
    final isWorker = selectedRole.value != 'admin';
    final expStr = experienceController.text.trim();
    final expValid = !isWorker || (expStr.isNotEmpty && int.tryParse(expStr) != null);

    isFormValid.value = name.length >= 2 &&
        RegExp(r'^[6-9]\d{9}$').hasMatch(phone) &&
        password.length >= 6 &&
        city.isNotEmpty &&
        expValid;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    cityController.dispose();
    experienceController.dispose();
    super.onClose();
  }

  void setRole(String role) {
    selectedRole.value = role.toLowerCase();
    _checkFormValidity();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (value.trim().length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) return 'City is required';
    return null;
  }

  String? validateExperience(String? value) {
    if (selectedRole.value == 'admin') return null;
    if (value == null || value.trim().isEmpty) return 'Experience is required';
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) return 'Enter a valid number of years';
    return null;
  }

  void register() async {
    if (!formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final city = cityController.text.trim();
    final expStr = experienceController.text.trim();
    final expYears = int.tryParse(expStr) ?? 0;

    isLoading.value = true;

    try {
      final user = await _authService.signUpWithPhoneAndPassword(
        phone: phone,
        password: password,
        name: name,
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

      if (user.role == 'admin') {
        Get.offAllNamed(Routes.adminDashboard);
      } else {
        Get.offAllNamed(Routes.workerHome);
      }
    } catch (e) {
      String message = e.toString();
      if (message.contains('email-already-in-use')) {
        message = 'An account with this phone number already exists.';
      } else {
        message = message.replaceAll('Exception: ', '');
      }
      Get.snackbar(
        'Registration Failed',
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
