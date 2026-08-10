class JobTitleEntry {
  final String title;
  final String role;
  final int slotsTotal;
  final int slotsFilled;

  JobTitleEntry({
    required this.title,
    required this.role,
    required this.slotsTotal,
    this.slotsFilled = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'role': role,
        'slotsTotal': slotsTotal,
        'slotsFilled': slotsFilled,
      };

  factory JobTitleEntry.fromJson(Map<dynamic, dynamic> json) => JobTitleEntry(
        title: json['title'] ?? '',
        role: json['role'] ?? '',
        slotsTotal: _toInt(json['slotsTotal']),
        slotsFilled: _toInt(json['slotsFilled']),
      );

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
