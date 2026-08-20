import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/hotel_onboarding_controller.dart';

class HotelOnboardingView extends GetView<HotelOnboardingController> {
  const HotelOnboardingView({super.key});

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
                'Tell us about your hotel',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We verify every venue before it can post shifts.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0x8C14181F),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 26),

              // ── Full Name ──────────────────────────────────────
              const _FieldLabel(label: 'Your Full Name', required: true),
              const SizedBox(height: 8),
              _TextInput(
                controller: controller.nameController,
                hint: 'e.g. Priya Mehta',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),

              // ── Hotel Name ────────────────────────────────────
              const _FieldLabel(label: 'Hotel / Venue Name', required: true),
              const SizedBox(height: 8),
              _TextInput(
                controller: controller.hotelNameController,
                hint: 'e.g. The Grand Hyatt',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),

              // ── Venue Photo ───────────────────────────────────
              const _FieldLabel(label: 'Hotel / Venue Profile Photo', required: true),
              const SizedBox(height: 8),
              Obx(() => _UploadBox(
                    imagePath: controller.venueImagePath.value,
                    icon: '\ud83c\udfe8',
                    hint: 'Tap to upload a photo of your property',
                    onTap: controller.pickVenuePhoto,
                  )),
              const SizedBox(height: 18),

              // ── GST Number ────────────────────────────────────
              const _FieldLabel(label: 'GST Number', required: true),
              const SizedBox(height: 8),
              Obx(() {
                final isValid = controller.gstIsValid.value;
                final hasText = controller.gstController.text.isNotEmpty;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isValid
                          ? AppColors.success
                          : const Color(0x2614181F),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.gstController,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 15,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: isValid
                                ? AppColors.textPrimary
                                : AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'e.g. 07ABCDE1234F1Z5',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0x6614181F),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (isValid)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 8),
                            Text(
                              '\u2713 Valid',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        )
                      else if (hasText)
                        const SizedBox(width: 8),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 18),

              // ── GST Certificate ───────────────────────────────
              const _FieldLabel(label: 'GST Certificate', required: true),
              const SizedBox(height: 8),
              Obx(() => _UploadBox(
                    imagePath: controller.gstCertPath.value,
                    icon: '\ud83d\udcc4',
                    hint: 'Tap to upload PDF or photo',
                    onTap: controller.pickGstCert,
                  )),

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

  const _TextInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
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
  final VoidCallback onTap;

  const _UploadBox({
    required this.imagePath,
    required this.icon,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(imagePath!),
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
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
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0x8014181F),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

