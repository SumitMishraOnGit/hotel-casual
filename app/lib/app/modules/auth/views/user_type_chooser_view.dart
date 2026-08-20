import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/user_type_chooser_controller.dart';

class UserTypeChooserView extends GetView<UserTypeChooserController> {
  const UserTypeChooserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 64, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'What brings you here?',
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
                'Choose how you want to use Hotel Casual.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0x8C14181F),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // I want to WORK card (teal - selected/primary)
              GestureDetector(
                onTap: controller.chooseWorker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon box
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Center(
                                child: Text('💼', style: TextStyle(fontSize: 21)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'I want to work',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Find daily-wage shifts at hotels and venues near you.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xCCFFFFFF),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Arrow button bottom-right
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '→',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // I want to HIRE card (white)
              GestureDetector(
                onTap: controller.chooseHotel,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x1F14181F), width: 1.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon box
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Center(
                                child: Text('🏢', style: TextStyle(fontSize: 21)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'I want to hire',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF14181F),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Post shifts and find staff for your hotel or venue.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0x8C14181F),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Arrow button bottom-right
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0x1414181F),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '→',
                            style: TextStyle(color: Color(0xFF14181F), fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Terms footer
              const Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0x7314181F),
                    height: 1.4,
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

