import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/job_service.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/job_title_entry.dart';

/// Holds the state for a single title row in the form
class TitleRowState {
  TextEditingController? _titleController;
  TextEditingController? _wageController;
  TextEditingController? _slotsController;
  final RxString role;

  TextEditingController get titleController =>
      _titleController ??= TextEditingController();
  TextEditingController get wageController =>
      _wageController ??= TextEditingController();
  TextEditingController get slotsController =>
      _slotsController ??= TextEditingController();

  TitleRowState() : role = 'steward'.obs {
    _titleController = TextEditingController();
    _wageController = TextEditingController();
    _slotsController = TextEditingController();
  }

  void dispose() {
    _titleController?.dispose();
    _wageController?.dispose();
    _slotsController?.dispose();
  }

  bool get isValid {
    final wage = int.tryParse(wageController.text.trim()) ?? 0;
    final slots = int.tryParse(slotsController.text.trim()) ?? 0;
    return wage > 0 && slots > 0 && slots <= 50;
  }
}

class CreateJobController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Venue / common fields
  final venueNameController = TextEditingController();
  final venueAddressController = TextEditingController();
  final cityController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactPersonNameController = TextEditingController();
  final contactPersonPhoneController = TextEditingController();

  // Title rows — starts with one empty row
  final titleRows = <TitleRowState>[].obs;

  final selectedDate = Rxn<DateTime>();
  final isLoading = false.obs;
  final isFormValid = false.obs;

  final roles = ['Steward', 'Driver', 'Chef'];

  final JobService _jobService = Get.find<JobService>();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    addTitleRow(); // start with one row

    // Auto-fill logged-in admin's contact details (editable)
    final user = _authService.currentUser.value;
    if (user != null) {
      if (user.name.isNotEmpty) {
        contactPersonNameController.text = user.name;
      }
      if (user.phone.isNotEmpty) {
        contactPersonPhoneController.text = user.phone;
      }
    }

    venueNameController.addListener(_checkValidity);
    venueAddressController.addListener(_checkValidity);
    cityController.addListener(_checkValidity);
    descriptionController.addListener(_checkValidity);
    contactPersonNameController.addListener(_checkValidity);
    contactPersonPhoneController.addListener(_checkValidity);

    _checkValidity();
  }

  // ── Title Row Management ─────────────────────────────────

  void addTitleRow() {
    final row = TitleRowState();
    row.wageController.addListener(_checkValidity);
    row.slotsController.addListener(_checkValidity);
    titleRows.add(row);
    _checkValidity();
  }

  void removeTitleRow(int index) {
    if (titleRows.length <= 1) return; // keep at least one
    titleRows[index].dispose();
    titleRows.removeAt(index);
    _checkValidity();
  }

  void setRowRole(int index, String role) {
    titleRows[index].role.value = role.toLowerCase();
  }

  // ── Form Validity ────────────────────────────────────────

  void _checkValidity() {
    final venueOk = venueNameController.text.trim().isNotEmpty &&
        venueAddressController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty;
    final contactOk = contactPersonNameController.text.trim().isNotEmpty &&
        contactPersonPhoneController.text.trim().length >= 10;
    final dateOk = selectedDate.value != null;
    final titlesOk =
        titleRows.isNotEmpty && titleRows.every((r) => r.isValid);
    isFormValid.value = venueOk && contactOk && dateOk && titlesOk;
  }

  // ── Date Picker ──────────────────────────────────────────

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00897B),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      selectedDate.value = picked;
      _checkValidity();
    }
  }

  // ── Validators ───────────────────────────────────────────

  String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number required';
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) return 'Enter a 10-digit mobile number';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid mobile number starting with 6-9';
    }
    return null;
  }

  String? validateWage(String? value) {
    if (value == null || value.trim().isEmpty) return 'Wage is required';
    final n = int.tryParse(value.trim());
    if (n == null || n <= 0) return 'Enter a valid wage';
    return null;
  }

  String? validateSlots(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = int.tryParse(value.trim());
    if (n == null || n <= 0) return 'Min 1';
    if (n > 50) return 'Max 50';
    return null;
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Title required';
    return null;
  }

  // ── Submit ───────────────────────────────────────────────

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDate.value == null) {
      Get.snackbar('Date Required', 'Please select a job date',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final adminId = _authService.currentUser.value!.uid;
      final d = selectedDate.value!;
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final entries = titleRows.map((r) {
        final roleName = r.role.value.capitalizeFirst ?? r.role.value;
        return JobTitleEntry(
          title: roleName,
          role: r.role.value,
          wage: int.parse(r.wageController.text.trim()),
          slotsTotal: int.parse(r.slotsController.text.trim()),
          slotsFilled: 0,
        );
      }).toList();

      final primaryWage = entries.isNotEmpty ? entries.first.wage : 0;

      final job = JobModel(
        jobId: '',
        adminId: adminId,
        venueName: venueNameController.text.trim(),
        venueAddress: venueAddressController.text.trim(),
        city: cityController.text.trim(),
        date: dateStr,
        wage: primaryWage,
        description: descriptionController.text.trim(),
        contactPersonName: contactPersonNameController.text.trim(),
        contactPersonPhone: contactPersonPhoneController.text.trim(),
        titles: entries,
        status: 'open',
        createdAt: DateTime.now().toIso8601String(),
      );

      await _jobService.createJob(job);
      Get.back();
      Get.snackbar(
        'Job Posted!',
        '${job.venueName} — ${entries.length} role(s) posted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Failed', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    venueNameController.dispose();
    venueAddressController.dispose();
    cityController.dispose();
    descriptionController.dispose();
    contactPersonNameController.dispose();
    contactPersonPhoneController.dispose();
    for (final row in titleRows) {
      row.dispose();
    }
    super.onClose();
  }
}
