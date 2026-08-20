import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  String _formatRole(String role, String userType) {
    if (userType == 'hotel' || role == 'admin' || role == 'superadmin') {
      return 'Hotel Admin';
    }
    if (role == 'casual_banquet') return 'Casual — Banquet';
    if (role == 'cook_banquet') return 'Cook — Banquet';
    if (role == 'driver') return 'Driver';
    return role
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Obx(() {
        final user = controller.authService.currentUser.value;
        if (user == null) {
          return const Center(child: Text('No user data'));
        }

        final expYears = user.experienceYears;
        final experienceString = '$expYears yr${expYears != 1 ? 's' : ''}';
        final isHotel = user.userType == 'hotel' || user.role == 'admin';

        final displayName = isHotel
            ? (user.hotelName != null && user.hotelName!.isNotEmpty ? user.hotelName! : user.name)
            : user.name;
        final roleLabel = _formatRole(user.role, user.userType);

        return SingleChildScrollView(
          child: Column(
            children: [
              // ── Top Teal Header Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 54, 18, 60),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: Get.back,
                      child: const Text(
                        '←',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Profile Body ──
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                child: Column(
                  children: [
                    // ── Overlapping Profile Avatar ──
                    Transform.translate(
                      offset: const Offset(0, -42),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: controller.reuploadProfilePhoto,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF14181F).withValues(alpha: 0.12),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                        ? Image.network(
                                            user.photoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.person, size: 48, color: AppColors.primary),
                                          )
                                        : const Icon(Icons.person, size: 48, color: AppColors.primary),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 2,
                                child: GestureDetector(
                                  onTap: controller.reuploadProfilePhoto,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFF6F7F9), width: 3),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '✎',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Name
                          Text(
                            displayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Role Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: isHotel
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.14)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              roleLabel,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isHotel ? const Color(0xFFB45309) : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Details Cards ──
                    Transform.translate(
                      offset: const Offset(0, -22),
                      child: Column(
                        children: [
                          if (isHotel) ...[
                            // Hotel Name
                            _buildCard(
                              icon: '🏢',
                              label: 'Hotel Name',
                              value: user.hotelName != null && user.hotelName!.isNotEmpty
                                  ? user.hotelName!
                                  : user.name,
                              onEdit: controller.showEditHotelNameDialog,
                            ),
                            const SizedBox(height: 12),

                            // Phone Number
                            _buildCard(
                              icon: '📞',
                              label: 'Phone Number',
                              value: user.phone,
                            ),
                            const SizedBox(height: 12),

                            // City
                            _buildCard(
                              icon: '📍',
                              label: 'City',
                              value: user.city.isNotEmpty ? user.city : 'Not set',
                              onEdit: controller.showEditCityDialog,
                            ),
                            const SizedBox(height: 22),

                            // ── Hotel Verification Section ──
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Hotel Verification',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // GST Number (Locked / Read-Only preview)
                            _buildDocCard(
                              icon: '✅',
                              iconBg: const Color(0xFF16A34A).withValues(alpha: 0.1),
                              title: 'GST Number',
                              subtitle: user.gstNumber != null && user.gstNumber!.isNotEmpty
                                  ? user.gstNumber!
                                  : 'Not provided',
                              onPreview: (user.gstCertUrl != null && user.gstCertUrl!.isNotEmpty)
                                  ? () => controller.showDocumentPreview(
                                        'GST Certificate',
                                        user.gstCertUrl!,
                                      )
                                  : null,
                            ),
                            const SizedBox(height: 10),

                            // GST Certificate (Locked / Read-Only preview)
                            _buildDocCard(
                              icon: '📄',
                              title: 'GST Certificate',
                              subtitle: 'Submitted with sign-up',
                              onPreview: (user.gstCertUrl != null && user.gstCertUrl!.isNotEmpty)
                                  ? () => controller.showDocumentPreview(
                                        'GST Certificate',
                                        user.gstCertUrl!,
                                      )
                                  : null,
                            ),
                          ] else ...[
                            // Worker Full Name
                            _buildCard(
                              icon: '👤',
                              label: 'Full Name',
                              value: user.name,
                              onEdit: controller.showEditNameDialog,
                            ),
                            const SizedBox(height: 12),

                            // Phone Number
                            _buildCard(
                              icon: '📞',
                              label: 'Phone Number',
                              value: user.phone,
                            ),
                            const SizedBox(height: 12),

                            // City
                            _buildCard(
                              icon: '🏢',
                              label: 'City',
                              value: user.city.isNotEmpty ? user.city : 'Not set',
                              onEdit: controller.showEditCityDialog,
                            ),
                            const SizedBox(height: 12),

                            // Experience
                            _buildCard(
                              icon: '💼',
                              iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                              label: 'Experience',
                              value: experienceString.trim(),
                              onEdit: controller.showEditExperienceDialog,
                            ),
                            const SizedBox(height: 22),

                            // ── Verification Documents Section ──
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Verification Documents',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Worker Document (License / Aadhaar) - Editable number, Reupload, and Preview
                            _buildDocCard(
                              icon: '📄',
                              title: user.docType == 'license' ? 'Driving License' : 'Aadhaar Card',
                              subtitle: user.docNumber != null && user.docNumber!.isNotEmpty
                                  ? user.docNumber!
                                  : 'Tap to add document number',
                              onEdit: controller.showEditDocNumberDialog,
                              onReupload: controller.reuploadDocPhoto,
                              onPreview: (user.docImageUrl != null && user.docImageUrl!.isNotEmpty)
                                  ? () => controller.showDocumentPreview(
                                        user.docType == 'license' ? 'Driving License' : 'Aadhaar Card',
                                        user.docImageUrl!,
                                      )
                                  : null,
                            ),
                            const SizedBox(height: 10),

                            // Profile Photo Verification - Reupload & Preview
                            _buildDocCard(
                              icon: '📷',
                              title: 'Profile Photo',
                              subtitle: 'Submitted with sign-up',
                              onReupload: controller.reuploadProfilePhoto,
                              onPreview: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                                  ? () => controller.showDocumentPreview(
                                        'Profile Photo',
                                        user.photoUrl!,
                                      )
                                  : null,
                            ),
                          ],

                          const SizedBox(height: 22),

                          // ── Log Out Button ──
                          GestureDetector(
                            onTap: controller.confirmLogout,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFDC2626).withValues(alpha: 0.28),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '↪',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCard({
    required String icon,
    Color? iconBg,
    required String label,
    required String value,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14181F).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg ?? AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0x8014181F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  '✎',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocCard({
    required String icon,
    Color? iconBg,
    required String title,
    required String subtitle,
    VoidCallback? onEdit,
    VoidCallback? onReupload,
    VoidCallback? onPreview,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14181F).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg ?? AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onEdit,
                        behavior: HitTestBehavior.opaque,
                        child: const Text(
                          '✎',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0x8014181F),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onReupload != null) ...[
            GestureDetector(
              onTap: onReupload,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Upload',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ),
          ],
          if (onPreview != null)
            GestureDetector(
              onTap: onPreview,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Preview',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
