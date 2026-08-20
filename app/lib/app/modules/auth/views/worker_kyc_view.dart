import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/worker_kyc_controller.dart';

class WorkerKycView extends GetView<WorkerKycController> {
  const WorkerKycView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 64, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              GestureDetector(
                onTap: Get.back,
                child: const Text(
                  '\u2190',
                  style: TextStyle(fontSize: 22, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 22),

              // Title
              const Text(
                'Verify your identity',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle adapts by role
              Text(
                controller.isDriver
                    ? 'Required for all drivers to accept jobs on Hotel Casual.'
                    : 'Required for all workers to accept jobs on Hotel Casual.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0x8C14181F),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 26),

              // ── Full Name ──────────────────────────────────────
              _FieldLabel(label: 'Full Name', required: true),
              const SizedBox(height: 8),
              _TextInput(
                controller: controller.nameController,
                hint: 'e.g. Rahul Sharma',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),

              // ── City ─────────────────────────────────────────
              _FieldLabel(label: 'City', required: true),
              const SizedBox(height: 8),
              _TextInput(
                controller: controller.cityController,
                hint: 'e.g. Mumbai',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),

              // ── Profile Photo ─────────────────────────────────
              _FieldLabel(label: 'Profile Photo', required: true),
              const SizedBox(height: 8),
              Obx(() => _UploadBox(
                    imagePath: controller.profileImagePath.value,
                    icon: '📷',
                    hint: 'Tap to upload a clear selfie',
                    formatHint: 'Supports: JPG, PNG · Max 5MB',
                    onTap: controller.pickProfilePhoto,
                  )),
              const SizedBox(height: 18),

              // ── Doc Number (adapts by role) ───────────────────
              _FieldLabel(
                label: controller.docNumberLabel,
                required: true,
              ),
              const SizedBox(height: 8),
              _TextInput(
                controller: controller.docNumberController,
                hint: controller.docNumberHint,
                keyboardType: controller.isDriver
                    ? TextInputType.text
                    : TextInputType.number,
                textCapitalization: controller.isDriver
                    ? TextCapitalization.characters
                    : TextCapitalization.none,
                inputFormatters: controller.isDriver
                    ? [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
                        LengthLimitingTextInputFormatter(20),
                      ]
                    : [
                        FilteringTextInputFormatter.digitsOnly,
                        const AadhaarInputFormatter(),
                      ],
              ),
              const SizedBox(height: 18),

              // ── Doc Photo (adapts by role) ────────────────────
              _FieldLabel(
                label: controller.docPhotoLabel,
                required: true,
              ),
              const SizedBox(height: 8),
              Obx(() => _UploadBox(
                    imagePath: controller.docImagePath.value,
                    icon: '📄',
                    hint: controller.isDriver
                        ? 'Tap to upload front of license'
                        : 'Tap to upload your Aadhaar card',
                    formatHint: 'Supports: JPG, PNG, WEBP · Max 5MB',
                    onTap: controller.pickDocPhoto,
                  )),
              const SizedBox(height: 18),

              // ── Experience (optional) ─────────────────────────
              const _FieldLabel(label: 'Experience', required: false),
              const SizedBox(height: 8),
              _TextInput(
                controller: controller.experienceController,
                hint: 'e.g. 3 years',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              const SizedBox(height: 30),

              // ── Submit button ─────────────────────────────────
              Obx(() {
                final loading = controller.isLoading.value;
                return GestureDetector(
                  onTap: loading ? null : controller.submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: loading
                          ? AppColors.primary.withValues(alpha: 0.55)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: loading
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    alignment: Alignment.center,
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit for review',
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

              const SizedBox(height: 10),

              // Footnote
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Non-driver roles upload Aadhaar number + photo instead of a license.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0x7314181F),
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared small widgets ────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.danger,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ] else ...[
          const SizedBox(width: 6),
          const Text(
            '(optional)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0x6614181F),
            ),
          ),
        ],
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _TextInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x2614181F), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: Color(0x6614181F),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String? imagePath;
  final String icon;
  final String hint;
  final String formatHint;
  final VoidCallback onTap;

  const _UploadBox({
    required this.imagePath,
    required this.icon,
    required this.hint,
    required this.formatHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: imagePath != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(imagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Change',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0x4014181F),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xCC14181F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatHint,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0x6614181F),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class AadhaarInputFormatter extends TextInputFormatter {
  const AadhaarInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 12) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

