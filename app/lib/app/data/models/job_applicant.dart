class JobApplicant {
  final String uid;
  final String name;
  final String phone;
  final String role;
  final String city;
  final int titleIndex;
  final String titleName; // resolved from job.titles[titleIndex].title
  final String appliedAt;
  final int experienceYears;
  final String? photoUrl;
  final String? docType; // 'license' | 'aadhaar'
  final String? docNumber;
  final String? docImageUrl;

  JobApplicant({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.city,
    required this.titleIndex,
    required this.titleName,
    required this.appliedAt,
    this.experienceYears = 0,
    this.photoUrl,
    this.docType,
    this.docNumber,
    this.docImageUrl,
  });
}
