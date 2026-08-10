import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/create_job_controller.dart';

class CreateJobView extends GetView<CreateJobController> {
  const CreateJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Post New Job'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Venue Details ──────────────────────────────────────
              _sectionLabel(context, 'Venue Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.venueNameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => controller.validateRequired(v, 'Venue name'),
                decoration: const InputDecoration(hintText: 'e.g. Taj Palace Hotel'),
              ),
              const SizedBox(height: 20),

              _sectionLabel(context, 'Venue Address'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.venueAddressController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) =>
                    controller.validateRequired(v, 'Venue address'),
                decoration: const InputDecoration(
                    hintText: 'e.g. Sardar Patel Marg, Chanakyapuri'),
              ),
              const SizedBox(height: 20),

              _sectionLabel(context, 'City'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.cityController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => controller.validateRequired(v, 'City'),
                decoration: const InputDecoration(hintText: 'e.g. Delhi'),
              ),
              const SizedBox(height: 20),

              // ── Contact Details ────────────────────────────────────
              _sectionLabel(context, 'Contact Person Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.contactPersonNameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => controller.validateRequired(v, 'Contact Person'),
                decoration: const InputDecoration(hintText: 'e.g. HR Team / Rajesh Kumar'),
              ),
              const SizedBox(height: 20),

              _sectionLabel(context, 'Contact Person Phone'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.contactPersonPhoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: controller.validatePhone,
                decoration: const InputDecoration(
                  hintText: '9876543210',
                  prefixText: '+91 ',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 20),

              // ── Job Description ────────────────────────────────────
              _sectionLabel(context, 'Job Description (Optional, max 1000 chars)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.descriptionController,
                maxLength: 1000,
                maxLines: 4,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  hintText: 'Describe job requirements, duties, dress code, etc.',
                ),
              ),
              const SizedBox(height: 20),

              // ── Date Picker ────────────────────────────────────────
              _sectionLabel(context, 'Job Date'),
              const SizedBox(height: 8),
              Obx(() {
                final date = controller.selectedDate.value;
                final label = date == null
                    ? 'Select date'
                    : '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
                return GestureDetector(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: date == null
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // ── Job Titles Section ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel(context, 'Job Titles & Slots'),
                  TextButton.icon(
                    onPressed: controller.addTitleRow,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Title'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dynamic title rows
              Obx(() => Column(
                    children: List.generate(controller.titleRows.length,
                        (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TitleRow(
                          index: index,
                          controller: controller,
                        ),
                      );
                    }),
                  )),

              const SizedBox(height: 16),

              // ── Submit ─────────────────────────────────────────────
              Obx(() {
                final isLoading = controller.isLoading.value;
                return ElevatedButton(
                  onPressed: isLoading ? null : controller.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Post Job'),
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

// ── Individual Title Row Widget ─────────────────────────────────────────────

class _TitleRow extends StatelessWidget {
  final int index;
  final CreateJobController controller;

  const _TitleRow({required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final row = controller.titleRows[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Title #N" + remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Title ${index + 1}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Obx(() => controller.titleRows.length > 1
                  ? GestureDetector(
                      onTap: () => controller.removeTitleRow(index),
                      child: const Icon(Icons.close,
                          size: 18, color: Colors.redAccent),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 12),

          // Role chips
          Obx(() => Wrap(
                spacing: 6,
                runSpacing: 4,
                children: controller.roles.map((role) {
                  final isSelected =
                      row.role.value == role.toLowerCase();
                  return GestureDetector(
                    onTap: () =>
                        controller.setRowRole(index, role),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 12),

          // Wage & Slots inputs side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wage input for this title card
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wage per Job (₹)',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.wageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                      validator: controller.validateWage,
                      decoration: const InputDecoration(
                        hintText: '1200',
                        prefixText: '₹ ',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Slots count field
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Slots',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: row.slotsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      autovalidateMode:
                          AutovalidateMode.onUserInteraction,
                      validator: controller.validateSlots,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '0',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
