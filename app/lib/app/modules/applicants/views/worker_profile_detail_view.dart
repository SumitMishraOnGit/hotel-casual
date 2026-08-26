import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job_applicant.dart';

class WorkerProfileDetailView extends StatelessWidget {
  const WorkerProfileDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final applicant = Get.arguments as JobApplicant?;

    if (applicant == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          title: const Text('Worker Profile'),
        ),
        body: const Center(
          child: Text('Applicant details not found'),
        ),
      );
    }

    final isDriver = applicant.role.toLowerCase() == 'driver' ||
        applicant.docType?.toLowerCase() == 'license';
    final docTitle = isDriver ? 'Driving License' : 'Aadhaar Card';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Worker Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Profile Card ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with tap to zoom if image exists
                  GestureDetector(
                    onTap: () {
                      if (applicant.photoUrl != null &&
                          applicant.photoUrl!.isNotEmpty) {
                        _showImagePreview(
                          context,
                          'Profile Photo',
                          applicant.photoUrl!,
                        );
                      }
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: applicant.photoUrl != null &&
                                    applicant.photoUrl!.isNotEmpty
                                ? Image.network(
                                    applicant.photoUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, _, _) => Center(
                                      child: Text(
                                        _getInitials(applicant.name),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      _getInitials(applicant.name),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        if (applicant.photoUrl != null &&
                            applicant.photoUrl!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    applicant.name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Role Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatRole(applicant.role),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Call Worker Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchCaller(applicant.phone),
                      icon: const Icon(Icons.call, size: 18, color: Colors.white),
                      label: Text(
                        'Call Worker (${applicant.phone})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Shift Application Details ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined,
                          size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Application Details',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _infoRow('Applied Role', applicant.titleName),
                  const Divider(height: 20),
                  _infoRow('Applied At', _formatTimestamp(applicant.appliedAt)),
                  const Divider(height: 20),
                  _infoRow('Status', 'Accepted (Confirmed Slot)',
                      valueColor: const Color(0xFF059669), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Worker Information ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_pin_circle_outlined,
                          size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Worker Details',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _infoRow('Current City', applicant.city.isNotEmpty ? applicant.city : 'Not specified'),
                  const Divider(height: 20),
                  _infoRow(
                    'Experience',
                    applicant.experienceYears > 0
                        ? '${applicant.experienceYears} Years'
                        : 'Fresher / Optional',
                  ),
                  const Divider(height: 20),
                  _infoRow('Mobile Number', applicant.phone),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── KYC & Verification Document ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Identity & KYC Document ($docTitle)',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _infoRow(
                    '$docTitle Number',
                    (applicant.docNumber != null &&
                            applicant.docNumber!.trim().isNotEmpty)
                        ? applicant.docNumber!
                        : 'Not provided',
                    isBold: true,
                  ),
                  const SizedBox(height: 16),

                  // Document Image Card
                  const Text(
                    'Document Photo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (applicant.docImageUrl != null &&
                      applicant.docImageUrl!.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showImagePreview(
                        context,
                        '$docTitle (${applicant.name})',
                        applicant.docImageUrl!,
                      ),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          color: Colors.grey.shade100,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                applicant.docImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (_, _, _) => const Center(
                                  child: Text('Failed to load document photo'),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in,
                                        size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tap to zoom',
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
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        color: Colors.grey.shade50,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined,
                                size: 32, color: Colors.grey.shade400),
                            const SizedBox(height: 6),
                            Text(
                              'No document image uploaded',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  static void _showImagePreview(
      BuildContext context, String title, String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.8,
                        maxScale: 3.5,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (_, _, _) => const Padding(
                            padding: EdgeInsets.all(30),
                            child: Text('Unable to load document image'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.textPrimary, size: 24),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launchCaller(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.isEmpty) return;
    final Uri url = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      Get.snackbar('Error', 'Could not launch dialer');
    }
  }

  static String _formatRole(String role) {
    final lower = role.toLowerCase();
    if (lower == 'casual_banquet' || lower == 'steward') {
      return 'Casual — Banquet';
    }
    if (lower == 'cook_banquet' || lower == 'chef') {
      return 'Cook — Banquet';
    }
    if (lower == 'driver') {
      return 'Driver';
    }
    if (lower == 'staff' || lower.isEmpty) {
      return 'Staff';
    }
    return lower
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : '?';
  }

  static String _formatTimestamp(String isoString) {
    if (isoString.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inHours < 24) {
        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        return '${diff.inHours}h ago';
      }

      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = dt.day;
      final month = monthNames[dt.month - 1];
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';

      return '$day $month, $hour:$minute $period';
    } catch (_) {
      return isoString;
    }
  }
}
