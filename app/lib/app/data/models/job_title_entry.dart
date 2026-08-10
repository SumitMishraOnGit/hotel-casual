class JobTitleEntry {
  final String title;
  final String role;
  final int wage;
  final int slotsTotal;
  final int slotsFilled;

  JobTitleEntry({
    required this.title,
    required this.role,
    this.wage = 0,
    required this.slotsTotal,
    this.slotsFilled = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'role': role,
        'wage': wage,
        'slotsTotal': slotsTotal,
        'slotsFilled': slotsFilled,
      };

  factory JobTitleEntry.fromJson(Map<dynamic, dynamic> json) => JobTitleEntry(
        title: json['title'] ?? '',
        role: json['role'] ?? '',
        wage: _toInt(json['wage']),
        slotsTotal: _toInt(json['slotsTotal']),
        slotsFilled: _toInt(json['slotsFilled']),
      );

  static int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
