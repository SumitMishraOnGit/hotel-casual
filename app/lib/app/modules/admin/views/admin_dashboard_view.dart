import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthService>().currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 88,
        titleSpacing: 20,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Namaste 👋',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              (user?.name.split(' ').first) ?? 'Admin',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                tooltip: 'Logout',
                onPressed: controller.logout,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToCreateJob,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
      ),
      body: CustomScrollView(
        slivers: [
          // Search Bar & Filter Chips Header
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      decoration: InputDecoration(
                        hintText: 'Search hotel, city...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.grey.shade400, size: 22),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                // Filter Chips
                Obx(
                  () {
                    final selectedRole = controller.selectedRole.value;
                    return SizedBox(
                      height: 38,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.roles.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final role = controller.roles[index];
                          final isSelected = selectedRole == role;
                          return GestureDetector(
                            onTap: () => controller.selectedRole.value = role,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0F766E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  if (!isSelected)
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF14181F),
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                // Available Jobs Section Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Text(
                    'AVAILABLE JOBS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Jobs List or Empty View
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF0F766E))),
                );
              }

              final filtered = controller.filteredJobs;

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline_rounded,
                            size: 64, color: AppColors.border),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs found',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _JobCard(job: filtered[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final isCancelled = job.status == 'cancelled';
    final isOpen = job.status == 'open';
    final primaryRole =
        job.titles.isNotEmpty ? job.titles.first.role : 'Staff';
    final openSlots = job.totalSlots - job.filledSlots;

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.jobDetail, arguments: job),
      child: Opacity(
        opacity: isCancelled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isCancelled
                ? Border.all(color: const Color(0xFF14181F).withValues(alpha: 0.12))
                : null,
            boxShadow: isCancelled
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF14181F).withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: const Color(0xFF14181F).withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Venue name & status/action
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      job.venueName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        height: 1.2,
                        color: isCancelled
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF14181F),
                      ),
                    ),
                  ),
                  if (isCancelled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Cancelled',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isOpen)
                    GestureDetector(
                      onTap: () => _confirmCancel(context),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.redAccent.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Role chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? const Color(0xFF6B7280).withValues(alpha: 0.1)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  primaryRole.capitalizeFirst ?? primaryRole,
                  style: TextStyle(
                    color: isCancelled
                        ? const Color(0xFF6B7280)
                        : const Color(0xFFB45309),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Two stat boxes
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Wage / job',
                      value: '₹${job.wage}',
                      bg: isCancelled
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.10),
                      labelColor: isCancelled
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF92600A),
                      valueColor: isCancelled
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: 'Open slots',
                      value: '$openSlots',
                      bg: isCancelled
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFF0F766E).withValues(alpha: 0.08),
                      labelColor: isCancelled
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF0F766E),
                      valueColor: isCancelled
                          ? const Color(0xFF4B5563)
                          : const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Divider
              Container(
                height: 1,
                color: const Color(0xFF14181F).withValues(alpha: 0.08),
              ),
              const SizedBox(height: 14),

              // Footer: location + date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '📍 ${job.venueAddress}, ${job.city}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: const Color(0xFF14181F).withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '📅 ${job.date}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: const Color(0xFF14181F).withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Job?'),
        content: Text(
            'Are you sure you want to cancel the job at ${job.venueName}?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('No')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<AdminDashboardController>().cancelJob(job.jobId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  final Color labelColor;
  final Color valueColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.bg,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

