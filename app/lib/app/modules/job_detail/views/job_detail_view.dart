import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job_model.dart';
import '../controllers/job_detail_controller.dart';

class JobDetailView extends GetView<JobDetailController> {
  const JobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasError.value || controller.job.value == null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: const Text('Job Details'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 60, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'Job details unavailable',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        );
      }

      final job = controller.job.value!;
      final primaryTitle = job.titles.isNotEmpty ? job.titles.first : null;
      final roleHeading =
          primaryTitle != null ? primaryTitle.title : job.venueName;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: const Text(
            'Job Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Job Number Badge ──────────────────────────────────
              if (job.jobNumber > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.formattedJobNumber,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              // ── Role & Company Header ───────────────────────────────
              Text(
                roleHeading,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                job.venueName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 12),

              // ── Location & Salary Summary ───────────────────────────
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${job.venueAddress}, ${job.city}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 20,
                    color: Color(0xFFB45309),
                  ),
                  const SizedBox(width: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '₹${job.wage}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                        const TextSpan(
                          text: ' / job',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92600A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Chips Row ───────────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip('New Job',
                      color: Colors.purple.shade50, textColor: Colors.purple),
                  _buildChip('${job.totalSlots} Vacancies',
                      color: Colors.blue.shade50,
                      textColor: Colors.blue.shade800),
                  _buildChip('Date: ${job.date}',
                      color: Colors.grey.shade100,
                      textColor: AppColors.textPrimary),
                ],
              ),
              const SizedBox(height: 24),

              // ── Job Highlights / Summary Card ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Highlights',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildHighlightItem(Icons.check_circle_outline,
                        'Role required: ${primaryTitle?.role.toUpperCase() ?? "STAFF"}'),
                    const SizedBox(height: 8),
                    _buildHighlightItem(Icons.calendar_today_outlined,
                        'Job Date: ${job.date}'),
                    const SizedBox(height: 8),
                    _buildHighlightItem(Icons.payments_outlined,
                        'Daily Wage: ₹${primaryTitle?.wage != null && primaryTitle!.wage > 0 ? primaryTitle.wage : job.wage} (Paid on completion)'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Job Description Section ─────────────────────────────
              if (job.description.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Description',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Roles & Wages Card ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roles & Wages',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (job.titles.isEmpty)
                      Text(
                        '₹ ${job.wage} per job',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      )
                    else
                      ...job.titles.map((t) {
                        final itemWage = t.wage > 0 ? t.wage : job.wage;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  t.role.capitalizeFirst ?? t.role,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  t.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹$itemWage / job',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Contact & Address Section ───────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (job.contactPersonName.isNotEmpty) ...[
                      Text(
                        'Contact Person',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.contactPersonName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Venue Address',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.venueName}\n${job.venueAddress}, ${job.city}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: controller.isAdmin.value
                ? _buildAdminBottomBar(job)
                : _buildWorkerBottomBar(),
          ),
        ),
      );
    });
  }

  Widget _buildChip(String label,
      {required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHighlightItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Admin Bottom Bar ─────────────────────────────────────────────────
  Widget _buildAdminBottomBar(JobModel job) {
    final applicantCount = job.applicants.length;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.goToApplicants,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.people_outline_rounded, size: 20),
            label: Text(
              'Applicants ($applicantCount)',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        if (job.status == 'open') ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: controller.cancelJob,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Cancel Job',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Worker Bottom Bar ────────────────────────────────────────────────
  Widget _buildWorkerBottomBar() {
    final job = controller.job.value!;
    final state = controller.applyButtonState;

    String label;
    Color bgColor;
    Color fgColor;
    Color borderColor;
    bool enabled;

    switch (state) {
      case 'canApply':
        label = 'Apply Now';
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        borderColor = AppColors.primary;
        enabled = true;
        break;
      case 'applying':
        label = 'Applying...';
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        fgColor = AppColors.primary;
        borderColor = AppColors.primary;
        enabled = false;
        break;
      case 'applied':
        label = 'Applied ✓';
        bgColor = const Color(0xFFE0F2F1);
        fgColor = const Color(0xFF00796B);
        borderColor = const Color(0xFF00796B);
        enabled = false;
        break;
      case 'jobFull':
        label = 'Job Full';
        bgColor = Colors.grey.shade100;
        fgColor = Colors.grey.shade500;
        borderColor = Colors.grey.shade300;
        enabled = false;
        break;
      case 'roleMismatch':
        label = 'No Matching Role';
        bgColor = Colors.grey.shade100;
        fgColor = Colors.grey.shade500;
        borderColor = Colors.grey.shade300;
        enabled = false;
        break;
      case 'cancelled':
        label = 'Cancelled';
        bgColor = Colors.red.shade50;
        fgColor = Colors.redAccent;
        borderColor = Colors.redAccent.withValues(alpha: 0.3);
        enabled = false;
        break;
      default:
        label = 'Unavailable';
        bgColor = Colors.grey.shade100;
        fgColor = Colors.grey.shade500;
        borderColor = Colors.grey.shade300;
        enabled = false;
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: enabled ? controller.applyNow : null,
            style: OutlinedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              disabledForegroundColor: fgColor,
              disabledBackgroundColor: bgColor,
              side: BorderSide(color: borderColor, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: state == 'applying'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: fgColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () =>
                controller.launchCaller(job.contactPersonPhone),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.call, size: 18),
            label: const Text(
              'Call HR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
