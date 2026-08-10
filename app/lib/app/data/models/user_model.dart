class UserModel {
  final String uid;
  final String phone;
  final String name;
  final String role; // 'driver', 'steward', 'chef', 'admin'
  final String city;
  final bool available;
  final String createdAt;

  UserModel({
    required this.uid,
    required this.phone,
    required this.name,
    required this.role,
    required this.city,
    this.available = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phone': phone,
      'name': name,
      'role': role,
      'city': city,
      'available': available,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'steward',
      city: json['city'] ?? '',
      available: json['available'] ?? true,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
