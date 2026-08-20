import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: Get.height,
          child: Stack(
            children: [
              // Top Background with Curve
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: Get.height * 0.42,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/app/assets/images/logo-selection.png',
                          height: 60,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kaam milega, aasaan tarike se',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              // Login Form Card
              Positioned(
                top: Get.height * 0.32,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Obx(() {
                      final isOtp = controller.isOtpSent.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isOtp ? 'Verify OTP' : 'Log in',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isOtp
                                ? 'Enter the 6-digit code sent to +91 ${controller.phoneController.text.trim()}'
                                : 'Enter your mobile number to get started',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 24),

                          if (!isOtp) ...[
                            // Phone Input
                            Text(
                              'Phone number',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: controller.validatePhone,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: '98765 43210',
                                counterText: '',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '+91',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(width: 1, height: 24, color: AppColors.border),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Send OTP Button
                            Obx(() {
                              final enabled = controller.isFormValid.value && !controller.isLoading.value;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: enabled ? controller.sendOtp : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: enabled ? AppColors.primary : AppColors.border,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Send OTP',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),

                            // Redirection to Sign up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(Routes.register),
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // 6-box OTP Input
                            Text(
                              'Enter 6-digit OTP',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _OtpBoxRow(controller: controller),
                            const SizedBox(height: 16),

                            // Resend and Change Number Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: controller.changePhoneNumber,
                                  child: const Text(
                                    'Change Number',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Obx(() {
                                  if (controller.resendCountdown.value > 0) {
                                    return Text(
                                      'Resend in ${controller.resendCountdown.value}s',
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    );
                                  }
                                  return GestureDetector(
                                    onTap: controller.isLoading.value ? null : controller.sendOtp,
                                    child: const Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Verify OTP Button
                            Obx(() {
                              final enabled = controller.isFormValid.value && !controller.isLoading.value;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: enabled ? controller.verifyOtp : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: enabled ? AppColors.primary : AppColors.border,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Verify & Continue',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                ),
                              );
                            }),
                          ],

                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              'Driver · Cook Banquet · Casual Banquet',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 6 individual OTP digit boxes for the Login screen
class _OtpBoxRow extends StatefulWidget {
  final LoginController controller;
  const _OtpBoxRow({required this.controller});

  @override
  State<_OtpBoxRow> createState() => _OtpBoxRowState();
}

class _OtpBoxRowState extends State<_OtpBoxRow> {
  final List<TextEditingController> _boxControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _boxControllers[i].addListener(_syncToParent);
      _focusNodes[i].addListener(() => setState(() {}));
    }
    // Pre-fill if controller already has value (e.g. after resend)
    final existing = widget.controller.otpController.text;
    for (int i = 0; i < existing.length && i < 6; i++) {
      _boxControllers[i].text = existing[i];
    }
  }

  void _syncToParent() {
    final combined = _boxControllers.map((c) => c.text).join();
    widget.controller.otpController.text = combined;
  }

  @override
  void dispose() {
    for (final c in _boxControllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(6, (i) {
        final isFilled = _boxControllers[i].text.isNotEmpty;
        final isFocused = _focusNodes[i].hasFocus;
        final isActive = isFocused || isFilled;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 5 ? 8 : 0),
            child: AspectRatio(
              aspectRatio: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: isActive ? 1.8 : 1.5,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _boxControllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    cursorColor: AppColors.primary,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14181F),
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() {});
                      _syncToParent();
                      if (val.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      } else if (val.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
