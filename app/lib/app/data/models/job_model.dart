import 'job_title_entry.dart';

class JobModel {
  final String jobId;
  final String adminId;
  final String venueName;
  final String venueAddress;
  final String city;
  final String date;
  final int wage;
  final String description;
  final String contactPersonName;
  final String contactPersonPhone;
  final List<JobTitleEntry> titles; // multiple role/title entries
  final String status; // open / filled / cancelled
  final String createdAt;

  JobModel({
    required this.jobId,
    required this.adminId,
    required this.venueName,
    required this.venueAddress,
    required this.city,
    required this.date,
    required this.wage,
    this.description = '',
    this.contactPersonName = '',
    this.contactPersonPhone = '',
    required this.titles,
    required this.status,
    required this.createdAt,
  });

  /// Total slots across all title entries
  int get totalSlots => titles.fold(0, (sum, t) => sum + t.slotsTotal);

  /// Filled slots across all title entries
  int get filledSlots => titles.fold(0, (sum, t) => sum + t.slotsFilled);

  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'adminId': adminId,
    'venueName': venueName,
    'venueAddress': venueAddress,
    'city': city,
    'date': date,
    'wage': wage,
    'description': description,
    'contactPersonName': contactPersonName,
    'contactPersonPhone': contactPersonPhone,
    'titles': titles.map((t) => t.toJson()).toList(),
    'status': status,
    'createdAt': createdAt,
  };

  factory JobModel.fromJson(Map<dynamic, dynamic> json) {
    List<JobTitleEntry> titleList = [];
    if (json['titles'] != null) {
      final raw = json['titles'];
      if (raw is List) {
        titleList = raw
            .whereType<Map>()
            .map((e) => JobTitleEntry.fromJson(Map<dynamic, dynamic>.from(e)))
            .toList();
      } else if (raw is Map) {
        // RTDB sometimes returns List as Map with integer keys
        titleList = raw.values
            .whereType<Map>()
            .map((e) => JobTitleEntry.fromJson(Map<dynamic, dynamic>.from(e)))
            .toList();
      }
    }
    final parsedWage = _toInt(json['wage']);
    final fallbackWage = parsedWage > 0
        ? parsedWage
        : (titleList.isNotEmpty ? titleList.first.wage : 0);

    if (fallbackWage > 0) {
      titleList = titleList
          .map((t) => t.wage <= 0
              ? JobTitleEntry(
                  title: t.title,
                  role: t.role,
                  wage: fallbackWage,
                  slotsTotal: t.slotsTotal,
                  slotsFilled: t.slotsFilled,
                )
              : t)
          .toList();
    }

    return JobModel(
      jobId: json['jobId'] ?? '',
      adminId: json['adminId'] ?? '',
      venueName: json['venueName'] ?? '',
      venueAddress: json['venueAddress'] ?? '',
      city: json['city'] ?? '',
      date: json['date'] ?? '',
      wage: fallbackWage,
      description: json['description'] ?? '',
      contactPersonName: json['contactPersonName'] ?? '',
      contactPersonPhone: json['contactPersonPhone'] ?? '',
      titles: titleList,
      status: json['status'] ?? 'open',
      createdAt: json['createdAt'] ?? '',
    );
  }

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
