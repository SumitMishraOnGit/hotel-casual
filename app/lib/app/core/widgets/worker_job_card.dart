import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../../data/models/job_model.dart';

class WorkerJobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final String? appliedRole;
  final String? customStatusLabel;
  final Color? customStatusColor;

  const WorkerJobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.appliedRole,
    this.customStatusLabel,
    this.customStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = job.status == 'cancelled';
    final roleToDisplay = appliedRole ??
        (job.titles.isNotEmpty ? job.titles.first.role : 'Staff');
    final openSlots = job.totalSlots - job.filledSlots;

    return GestureDetector(
      onTap: onTap,
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
              // Venue name & status badge / Job ID
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.jobNumber > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                job.formattedJobNumber,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ),
                        Text(
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
                      ],
                    ),
                  ),
                  if (customStatusLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (customStatusColor ?? const Color(0xFF059669))
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        customStatusLabel!,
                        style: TextStyle(
                          color: customStatusColor ?? const Color(0xFF059669),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isCancelled)
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
                  roleToDisplay.capitalizeFirst ?? roleToDisplay,
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
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
