import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job_applicant.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    // Super admin gets a 3-tab control center
    if (controller.isSuperAdmin) {
      return _buildSuperAdminScaffold(context, authService);
    }

    // Normal hotel: existing single-view dashboard
    return _buildHotelScaffold(context, authService);
  }

  Widget _buildHotelScaffold(BuildContext context, AuthService authService) {
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
        title: Obx(() {
          final user = authService.currentUser.value;
          final displayName = (user?.hotelName != null && user!.hotelName!.trim().isNotEmpty)
              ? user.hotelName!
              : ((user?.name != null && user!.name.trim().isNotEmpty) ? user.name : 'Admin');
          return Column(
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
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          );
        }),
        actions: [
          Obx(() {
            final unread = controller.unreadNotifCount;
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                    onPressed: controller.openNotificationsSheet,
                    tooltip: 'Admin Alerts',
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
                color: AppColors.cardSurface,
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) {
                  if (value == 'profile') {
                    controller.goToProfile();
                  } else if (value == 'logout') {
                    controller.confirmLogout();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        const Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 20, color: Colors.red.shade400),
                        const SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.red.shade600)),
                      ],
                    ),
                  ),
                ],
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
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        color: const Color(0xFF0F766E),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
  Widget _buildSuperAdminScaffold(BuildContext context, AuthService authService) {
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
        title: Row(
          children: [
            // ── Special Super Admin Logo Badge ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'lib/app/assets/icons/logo-mark.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: Color(0xFF0F766E),
                        size: 26,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Text(
                        '👑',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'SUPER ADMIN',
                        style: TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: Color(0xFFFDE68A),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Control Center',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            final unread = controller.unreadNotifCount;
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                    onPressed: controller.openNotificationsSheet,
                    tooltip: 'Admin Alerts',
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
                color: AppColors.cardSurface,
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) {
                  if (value == 'profile') {
                    controller.goToProfile();
                  } else if (value == 'logout') {
                    controller.confirmLogout();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        const Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, size: 20, color: Colors.red.shade400),
                        const SizedBox(width: 12),
                        Text('Logout', style: TextStyle(color: Colors.red.shade600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.selectedTabIndex.value,
        onTap: (i) => controller.selectedTabIndex.value = i,
        selectedItemColor: const Color(0xFF0F766E),
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline_rounded),
            activeIcon: Icon(Icons.work_rounded),
            label: 'All Shifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.domain_outlined),
            activeIcon: Icon(Icons.domain_rounded),
            label: 'Hotels & GST',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge_outlined),
            activeIcon: Icon(Icons.badge_rounded),
            label: 'Workers & KYC',
          ),
        ],
      )),
      body: Obx(() {
        switch (controller.selectedTabIndex.value) {
          case 1:
            return _buildHotelsTab(context);
          case 2:
            return _buildWorkersTab(context);
          default:
            return _buildGlobalShiftsTab(context);
        }
      }),
    );
  }

  // ── Tab 0: Global Shifts Feed ──────────────────────────────────────────
  Widget _buildGlobalShiftsTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      color: const Color(0xFF0F766E),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Platform Stats Row ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Obx(() => Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.work_rounded,
                      label: 'Shifts',
                      count: controller.jobs.length,
                      color: const Color(0xFF0F766E),
                    ),
                    const SizedBox(width: 10),
                    _buildStatChip(
                      icon: Icons.domain_rounded,
                      label: 'Hotels',
                      count: controller.hotels.length,
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 10),
                    _buildStatChip(
                      icon: Icons.badge_rounded,
                      label: 'Workers',
                      count: controller.workers.length,
                      color: const Color(0xFFD97706),
                    ),
                  ],
                )),
              ),
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
                      hintText: 'Search hotel, city, job number...',
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
              Obx(() {
                final selectedRole = controller.selectedRole.value;
                return SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.roles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                                  color: Colors.black.withValues(alpha: 0.03),
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
              }),
              // ── Status Filter Chips ──
              const SizedBox(height: 8),
              Obx(() {
                final selectedSt = controller.selectedStatus.value;
                return SizedBox(
                  height: 34,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.statusOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final st = controller.statusOptions[index];
                      final isSelected = selectedSt == st;
                      return GestureDetector(
                        onTap: () => controller.selectedStatus.value = st,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6D28D9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: isSelected
                                ? null
                                : Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Center(
                            child: Text(
                              st,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                                fontSize: 12,
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
              }),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Obx(() => Text(
                  'ALL PLATFORM SHIFTS (${controller.filteredJobs.length})',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Colors.grey.shade600,
                  ),
                )),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F766E))),
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
                        'No shifts found',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
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
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _JobCard(job: filtered[index], showHotelTag: true);
                },
              ),
            );
          }),
        ),
      ],
    ),
  );
}

  // ── Tab 1: Hotels & GST Directory ──────────────────────────────────────
  Widget _buildHotelsTab(BuildContext context) {
    return Column(
      children: [
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
              onChanged: (val) => controller.hotelSearchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search hotel name, city, GST...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.grey.shade400, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Obx(() => Row(
            children: [
              Text(
                'REGISTERED HOTELS (${controller.filteredHotels.length})',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          )),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.onRefreshHotels,
            color: const Color(0xFF0F766E),
            child: Obx(() {
              final hotels = controller.filteredHotels;
              if (hotels.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: Get.height * 0.15),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_outlined,
                              size: 64, color: AppColors.border),
                          const SizedBox(height: 16),
                          Text(
                            'No hotels found',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: hotels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _HotelCard(hotel: hotels[index]);
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Tab 2: Workers & KYC Directory ─────────────────────────────────────
  Widget _buildWorkersTab(BuildContext context) {
    return Column(
      children: [
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
              onChanged: (val) => controller.workerSearchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search worker name, phone, city...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.grey.shade400, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        Obx(() {
          final selectedFilter = controller.workerRoleFilter.value;
          return SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: controller.workerRoleOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final role = controller.workerRoleOptions[index];
                final isSelected = selectedFilter == role;
                return GestureDetector(
                  onTap: () => controller.workerRoleFilter.value = role,
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
                            color: Colors.black.withValues(alpha: 0.03),
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
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Obx(() => Row(
            children: [
              Text(
                'REGISTERED WORKERS (${controller.filteredWorkers.length})',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          )),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.onRefreshWorkers,
            color: const Color(0xFF0F766E),
            child: Obx(() {
              final workers = controller.filteredWorkers;
              if (workers.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: Get.height * 0.15),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 64, color: AppColors.border),
                          const SizedBox(height: 16),
                          Text(
                            'No workers found',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: workers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _WorkerDirectoryCard(worker: workers[index]);
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final bool showHotelTag;
  const _JobCard({required this.job, this.showHotelTag = false});

  @override
  Widget build(BuildContext context) {
    final isCancelled = job.status == 'cancelled';
    final isOpen = job.status == 'open';
    final primaryRole =
        job.titles.isNotEmpty ? job.titles.first.role : 'Staff';
    final openSlots = job.totalSlots - job.filledSlots;

    // Detect if job date has already passed
    bool isPast = false;
    try {
      final parts = job.date.split('-');
      if (parts.length == 3) {
        final jobDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        final today = DateTime.now();
        isPast = jobDate.isBefore(DateTime(today.year, today.month, today.day));
      }
    } catch (_) {}

    final isDimmed = isCancelled || isPast;

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.jobDetail, arguments: job),
      child: Opacity(
        opacity: isDimmed ? 0.55 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isDimmed
                ? Border.all(color: const Color(0xFF14181F).withValues(alpha: 0.12))
                : null,
            boxShadow: isDimmed
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
                        color: isDimmed
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF14181F),
                      ),
                    ),
                  ),
                  if (isCancelled)
                    _statusTag('Cancelled', const Color(0xFF6B7280), const Color(0xFF4B5563))
                  else if (isPast)
                    _statusTag('Date Passed', const Color(0xFF78716C), const Color(0xFF57534E))
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
              if (showHotelTag) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business_rounded,
                          size: 12,
                          color: const Color(0xFF0F766E).withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          job.venueName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F766E).withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Role chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDimmed
                      ? const Color(0xFF6B7280).withValues(alpha: 0.1)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _formatRole(primaryRole),
                  style: TextStyle(
                    color: isDimmed
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
                      bg: isDimmed
                          ? const Color(0xFFF3F4F6)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.10),
                      labelColor: isDimmed
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF92600A),
                      valueColor: isDimmed
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: 'Open slots',
                      value: openSlots <= 0 ? '0 (Full)' : '$openSlots',
                      bg: isDimmed
                          ? const Color(0xFFF3F4F6)
                          : (openSlots <= 0
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFF0F766E).withValues(alpha: 0.08)),
                      labelColor: isDimmed
                          ? const Color(0xFF6B7280)
                          : (openSlots <= 0
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF0F766E)),
                      valueColor: isDimmed
                          ? const Color(0xFF4B5563)
                          : (openSlots <= 0
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF0F766E)),
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

  Widget _statusTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 10),
            Text('Cancel Job?'),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel the job at ${job.venueName}? All accepted workers will be notified about this cancellation. This action cannot be undone.',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep Job'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<AdminDashboardController>().cancelJob(job.jobId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Cancel Job'),
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

// ── Hotel Directory Card ───────────────────────────────────────────────
class _HotelCard extends StatelessWidget {
  final UserModel hotel;
  const _HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final displayName = (hotel.hotelName != null && hotel.hotelName!.trim().isNotEmpty)
        ? hotel.hotelName!
        : hotel.name;
    final hasGstCert = hotel.gstCertUrl != null && hotel.gstCertUrl!.isNotEmpty;
    final gstNumber = hotel.gstNumber ?? 'Not provided';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
          // Hotel name + badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business_rounded,
                    color: Color(0xFF0F766E), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF14181F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hotel.city.isNotEmpty ? hotel.city : 'City N/A',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Contact info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hotel.name.isNotEmpty ? hotel.name : 'Contact N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hotel.phone.isNotEmpty ? hotel.phone : 'N/A',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // GST Number badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_rounded,
                    size: 14, color: Color(0xFFB45309)),
                const SizedBox(width: 6),
                Text(
                  'GST: $gstNumber',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              // Call button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchCaller(hotel.phone),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F766E),
                    side: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // View GST Certificate button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasGstCert
                      ? () => _showGstPreview(context, displayName, hotel.gstCertUrl!)
                      : null,
                  icon: Icon(hasGstCert ? Icons.verified_rounded : Icons.no_photography_outlined, size: 16),
                  label: Text(
                    hasGstCert ? 'View GST Cert' : 'No GST Cert',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showGstPreview(BuildContext context, String hotelName, String imageUrl) {
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
                children: [
                  Text(
                    'GST Certificate — $hotelName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF14181F),
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
                            child: Text('Unable to load GST certificate image'),
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
                  color: Color(0xFF14181F), size: 24),
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
}

// ── Worker Directory Card ──────────────────────────────────────────────
class _WorkerDirectoryCard extends StatelessWidget {
  final UserModel worker;
  const _WorkerDirectoryCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Convert UserModel → JobApplicant for WorkerProfileDetailView
        final applicant = JobApplicant(
          uid: worker.uid,
          name: worker.name,
          phone: worker.phone,
          role: worker.role,
          city: worker.city,
          titleIndex: -1,
          titleName: 'N/A',
          appliedAt: '',
          experienceYears: worker.experienceYears,
          photoUrl: worker.photoUrl,
          docType: worker.docType,
          docNumber: worker.docNumber,
          docImageUrl: worker.docImageUrl,
        );
        Get.toNamed(Routes.workerProfileDetail, arguments: applicant);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
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
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: (worker.photoUrl != null && worker.photoUrl!.isNotEmpty)
                    ? Image.network(
                        worker.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Text(
                            _getInitials(worker.name),
                            style: const TextStyle(
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _getInitials(worker.name),
                          style: const TextStyle(
                            color: Color(0xFF0F766E),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          worker.name.isNotEmpty ? worker.name : 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF14181F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          _formatRole(worker.role),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        worker.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          worker.city.isNotEmpty ? worker.city : 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        _docLabel(worker),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (worker.experienceYears > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.work_history_outlined,
                            size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${worker.experienceYears}y exp',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () async {
                final cleanPhone = worker.phone.replaceAll(RegExp(r'\D'), '');
                if (cleanPhone.isEmpty) return;
                final Uri url = Uri(scheme: 'tel', path: cleanPhone);
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                } catch (_) {}
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.call_rounded,
                    color: Color(0xFF0F766E), size: 18),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
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

  static String _docLabel(UserModel w) {
    final docType = w.docType?.toLowerCase() ?? '';
    if (docType == 'license') return 'License';
    if (docType == 'aadhaar') return 'Aadhaar';
    return 'No Doc';
  }
}

String _formatRole(String role) {
  final lower = role.toLowerCase();
  if (lower == 'casual_banquet' || lower == 'steward') {
    return 'Casual Banquet';
  }
  if (lower == 'cook_banquet' || lower == 'chef') {
    return 'Cook Banquet';
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
