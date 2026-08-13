class UserModel {
  final String uid;
  final String phone;
  final String name;
  final String role; // 'driver', 'steward', 'chef', 'admin'
  final String city;
  final int experienceYears;
  final bool available;
  final String createdAt;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.phone,
    required this.name,
    required this.role,
    required this.city,
    this.experienceYears = 0,
    this.available = true,
    required this.createdAt,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phone': phone,
      'name': name,
      'role': role,
      'city': city,
      'experienceYears': experienceYears,
      'available': available,
      'createdAt': createdAt,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'steward',
      city: json['city'] ?? '',
      experienceYears: json['experienceYears'] is int 
          ? json['experienceYears'] 
          : int.tryParse(json['experienceYears']?.toString() ?? '0') ?? 0,
      available: json['available'] ?? true,
      createdAt: json['createdAt'] ?? '',
      fcmToken: json['fcmToken']?.toString(),
    );
  }
}

