import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/worker_bottom_nav.dart';
import '../../../core/widgets/worker_job_card.dart';
import '../../../data/models/job_model.dart';
import '../controllers/my_jobs_controller.dart';

class MyJobsView extends GetView<MyJobsController> {
  const MyJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const WorkerBottomNav(currentIndex: 1),
        appBar: AppBar(
          title: const Text('My Jobs'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past & Cancelled'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _buildJobList(context, controller.upcomingJobs, isUpcoming: true),
              _buildJobList(context, controller.pastJobs, isUpcoming: false),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildJobList(BuildContext context, List<JobModel> jobs, {required bool isUpcoming}) {
    if (jobs.isEmpty) {
      return Center(child: _buildEmptyState(context, isUpcoming));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = jobs[index];

        final appliedRole = controller.getAppliedRole(job);
        Color statusColor;
        String statusLabel;

        // Check if the job date has passed
        bool isDatePast = false;
        try {
          final parts = job.date.split('-');
          if (parts.length == 3) {
            final jobDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            final today = DateTime.now();
            isDatePast = jobDate
                .isBefore(DateTime(today.year, today.month, today.day));
          }
        } catch (_) {}

        if (isDatePast && job.status != 'cancelled' && job.status != 'completed') {
          statusColor = Colors.red.shade700;
          statusLabel = '📅 Date Passed';
        } else if (job.status == 'cancelled') {
          statusColor = Colors.red.shade600;
          statusLabel = 'Cancelled';
        } else if (job.status == 'completed') {
          statusColor = Colors.blue.shade600;
          statusLabel = 'Completed';
        } else if (job.status == 'filled') {
          statusColor = Colors.orange.shade700;
          statusLabel = 'Filled';
        } else {
          statusColor = const Color(0xFF059669);
          statusLabel = 'Accepted';
        }

        return WorkerJobCard(
          job: job,
          appliedRole: appliedRole.isNotEmpty ? appliedRole : null,
          customStatusLabel: statusLabel,
          customStatusColor: statusColor,
          onTap: () => controller.goToJobDetail(job),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isUpcoming) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.assignment_late_outlined : Icons.history_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'No Upcoming Jobs' : 'No Past Jobs',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isUpcoming
                ? 'Jobs you accept will appear here. Browse open jobs on the home feed to apply!'
                : 'Your completed or cancelled jobs will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
