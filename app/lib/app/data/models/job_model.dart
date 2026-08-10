import 'job_title_entry.dart';

class JobModel {
  final String jobId;
  final String adminId;
  final String venueName;
  final String venueAddress;
  final String city;
  final String date;
  final int wage;
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
    return JobModel(
      jobId: json['jobId'] ?? '',
      adminId: json['adminId'] ?? '',
      venueName: json['venueName'] ?? '',
      venueAddress: json['venueAddress'] ?? '',
      city: json['city'] ?? '',
      date: json['date'] ?? '',
      wage: _toInt(json['wage']),
      titles: titleList,
      status: json['status'] ?? 'open',
      createdAt: json['createdAt'] ?? '',
    );
  }

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
