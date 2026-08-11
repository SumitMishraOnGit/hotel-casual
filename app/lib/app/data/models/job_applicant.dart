class JobApplicant {
  final String uid;
  final String name;
  final String phone;
  final String role;
  final String city;
  final int titleIndex;
  final String titleName; // resolved from job.titles[titleIndex].title
  final String appliedAt;

  JobApplicant({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.city,
    required this.titleIndex,
    required this.titleName,
    required this.appliedAt,
  });
}
