class UserModel {
  final String uid;
  final String phone;
  final String name;
  final String userType; // 'worker' | 'hotel' | 'superadmin'
  final String role; // 'cook_banquet' | 'casual_banquet' | 'driver'
  final String city;
  final int experienceYears;
  final bool available;
  final String createdAt;
  final String? fcmToken;
  final String? photoUrl;
  final String? docType; // 'license' | 'aadhaar'
  final String? docNumber;
  final String? docImageUrl;
  final String? gstNumber;
  final String? gstCertUrl;
  final String? hotelName;

  UserModel({
    required this.uid,
    required this.phone,
    required this.name,
    this.userType = 'worker',
    required this.role,
    required this.city,
    this.experienceYears = 0,
    this.available = true,
    required this.createdAt,
    this.fcmToken,
    this.photoUrl,
    this.docType,
    this.docNumber,
    this.docImageUrl,
    this.gstNumber,
    this.gstCertUrl,
    this.hotelName,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'phone': phone,
      'name': name,
      'userType': userType,
      'role': role,
      'city': city,
      'experienceYears': experienceYears,
      'available': available,
      'createdAt': createdAt,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (docType != null) 'docType': docType,
      if (docNumber != null) 'docNumber': docNumber,
      if (docImageUrl != null) 'docImageUrl': docImageUrl,
      if (gstNumber != null) 'gstNumber': gstNumber,
      if (gstCertUrl != null) 'gstCertUrl': gstCertUrl,
      if (hotelName != null) 'hotelName': hotelName,
    };
  }

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    String rawRole = (json['role'] ?? '').toString().toLowerCase();
    String mappedRole = rawRole;
    if (rawRole == 'steward') {
      mappedRole = 'casual_banquet';
    } else if (rawRole == 'chef') {
      mappedRole = 'cook_banquet';
    } else if (rawRole.isEmpty) {
      mappedRole = 'casual_banquet';
    }

    String userType = json['userType']?.toString() ?? '';
    if (userType.isEmpty) {
      if (rawRole == 'admin') {
        userType = 'superadmin';
      } else {
        userType = 'worker';
      }
    }

    return UserModel(
      uid: json['uid'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      userType: userType,
      role: mappedRole,
      city: json['city'] ?? '',
      experienceYears: json['experienceYears'] is int
          ? json['experienceYears']
          : int.tryParse(json['experienceYears']?.toString() ?? '0') ?? 0,
      available: json['available'] ?? true,
      createdAt: json['createdAt'] ?? '',
      fcmToken: json['fcmToken']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      docType: json['docType']?.toString(),
      docNumber: json['docNumber']?.toString(),
      docImageUrl: json['docImageUrl']?.toString(),
      gstNumber: json['gstNumber']?.toString(),
      gstCertUrl: json['gstCertUrl']?.toString(),
      hotelName: json['hotelName']?.toString(),
    );
  }
}


