import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/role_select_controller.dart';

class RoleSelectView extends GetView<RoleSelectController> {
  const RoleSelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 64, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              GestureDetector(
                onTap: Get.back,
                child: const Text(
                  '←',
                  style: TextStyle(fontSize: 19, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 22),

              // Title
              const Text(
                'What kind of work?',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pick the role you'll be applying for shifts as.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0x8C14181F),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Role cards
              Obx(() {
                return Column(
                  children: controller.roleOptions.map((option) {
                    final code = option['code']!;
                    final label = option['label']!;
                    final emoji = option['emoji']!;
                    final isSelected = controller.selectedRole.value == code;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoleCard(
                        label: label,
                        emoji: emoji,
                        isSelected: isSelected,
                        onTap: () => controller.selectRole(code),
                      ),
                    );
                  }).toList(),
                );
              }),

              const Spacer(),

              // Continue button
              Obx(() {
                final canContinue = controller.selectedRole.value != null;
                return GestureDetector(
                  onTap: canContinue ? controller.onContinue : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: canContinue
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: canContinue
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
                    child: const Text(
                      'Continue',
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
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: const Color(0x2614181F), width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Emoji icon box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.16)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 17)),
              ),
            ),
            const SizedBox(width: 14),

            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),

            // Check mark (only when selected)
            if (isSelected)
              const Text(
                '✓',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
