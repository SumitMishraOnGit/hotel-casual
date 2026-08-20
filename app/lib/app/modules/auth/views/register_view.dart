import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Obx(() {
        if (controller.isOtpSent.value) {
          return _OtpScreen(controller: controller);
        }
        return _PhoneScreen(controller: controller);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Screen 1 : "What's your number?"
// ─────────────────────────────────────────────────────────────
class _PhoneScreen extends StatelessWidget {
  final RegisterController controller;
  const _PhoneScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 64, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo icon (briefcase)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.work_outline_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 28),

            // Title
            const Text(
              "What's your number?",
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF14181F),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We'll text you a code to verify it's you.",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0x8C14181F),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 34),

            // Phone Number label
            const Text(
              'Phone Number',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF14181F),
              ),
            ),
            const SizedBox(height: 8),

            // Phone input field
            Obx(() {
              final errorText = controller.phoneError.value;
              final hasError = errorText != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasError ? Colors.redAccent : AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Row(
                      children: [
                        const Text(
                          '+91',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF14181F),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 18, color: const Color(0x2614181F)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (_) {
                              controller.hasPhoneInteracted.value = true;
                            },
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF14181F),
                            ),
                            decoration: const InputDecoration(
                              hintText: '98765 43210',
                              hintStyle: TextStyle(color: Color(0x5514181F)),
                              counterText: '',
                              filled: false,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        errorText,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),

            const Spacer(),

            // Send OTP Button
            Obx(() {
              final enabled = controller.isPhoneValid.value && !controller.isLoading.value;
              return GestureDetector(
                onTap: enabled ? controller.sendOtp : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Screen 2 : "Enter the code"
// ─────────────────────────────────────────────────────────────
class _OtpScreen extends StatelessWidget {
  final RegisterController controller;
  const _OtpScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 64, 28, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back arrow
            GestureDetector(
              onTap: controller.goBackToPhone,
              child: const Text(
                '←',
                style: TextStyle(fontSize: 22, color: Color(0xFF14181F)),
              ),
            ),
            const SizedBox(height: 22),

            // Title
            const Text(
              'Enter the code',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF14181F),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0x8C14181F),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Sent to '),
                  TextSpan(
                    text: '+91 ${controller.phoneController.text.trim()}',
                    style: const TextStyle(
                      color: Color(0xFF14181F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),

            // 6-box OTP
            _RegisterOtpBoxRow(controller: controller),
            const SizedBox(height: 20),

            // Resend countdown
            Obx(() {
              final secs = controller.resendCountdown.value;
              if (secs > 0) {
                final mins = secs ~/ 60;
                final remaining = secs % 60;
                final label = mins > 0
                    ? '$mins:${remaining.toString().padLeft(2, '0')}'
                    : '0:${remaining.toString().padLeft(2, '0')}';
                return RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0x8C14181F),
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: "Didn't get a code? "),
                      TextSpan(
                        text: 'Resend in $label',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return GestureDetector(
                onTap: controller.isLoading.value ? null : controller.sendOtp,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0x8C14181F),
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: "Didn't get a code? "),
                      TextSpan(
                        text: 'Resend',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Spacer(),

            // Verify Button
            Obx(() {
              final enabled = controller.isOtpValid.value && !controller.isLoading.value;
              return GestureDetector(
                onTap: enabled ? controller.verifyOtp : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 6-box OTP widget used in the Register OTP screen
// ─────────────────────────────────────────────────────────────
class _RegisterOtpBoxRow extends StatefulWidget {
  final RegisterController controller;
  const _RegisterOtpBoxRow({required this.controller});

  @override
  State<_RegisterOtpBoxRow> createState() => _RegisterOtpBoxRowState();
}

class _RegisterOtpBoxRowState extends State<_RegisterOtpBoxRow> {
  final List<TextEditingController> _boxes =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _boxes[i].addListener(_sync);
      _nodes[i].addListener(() => setState(() {}));
    }
  }

  void _sync() {
    final combined = _boxes.map((c) => c.text).join();
    widget.controller.otpController.text = combined;
  }

  @override
  void dispose() {
    for (final c in _boxes) { c.dispose(); }
    for (final f in _nodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(6, (i) {
        final isFilled = _boxes[i].text.isNotEmpty;
        final isFocused = _nodes[i].hasFocus;
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
                    color: isActive ? AppColors.primary : const Color(0x2614181F),
                    width: isActive ? 1.8 : 1.5,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _boxes[i],
                    focusNode: _nodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    cursorColor: AppColors.primary,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
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
                      _sync();
                      if (val.isNotEmpty && i < 5) {
                        _nodes[i + 1].requestFocus();
                      } else if (val.isEmpty && i > 0) {
                        _nodes[i - 1].requestFocus();
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

