import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    if (user != null) {
      await fetchUserProfile(user.uid);
    } else {
      currentUser.value = null;
    }
  }

  // Convert raw phone number to standardized email format for Firebase Auth
  String _phoneToEmail(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    return '$cleaned@hotelcasual.com';
  }

  // Register User
  Future<UserModel> signUpWithPhoneAndPassword({
    required String phone,
    required String password,
    required String name,
    required String role,
    required String city,
  }) async {
    // Check for duplicate phone number in /phone_index before hitting Firebase Auth
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    final phoneCheck = await _db.child('phone_index').child(cleaned).get();
    if (phoneCheck.exists) {
      throw Exception('An account with this phone number already exists.');
    }

    final email = _phoneToEmail(phone);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final user = UserModel(
      uid: uid,
      phone: phone,
      name: name,
      role: role.toLowerCase(),
      city: city,
      available: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    // Save user profile and phone index atomically
    await Future.wait([
      _db.child('users').child(uid).set(user.toJson()),
      _db.child('phone_index').child(cleaned).set(uid),
    ]);

    currentUser.value = user;
    return user;
  }

  // Login User
  Future<UserModel> loginWithPhoneAndPassword({
    required String phone,
    required String password,
  }) async {
    final email = _phoneToEmail(phone);
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final user = await fetchUserProfile(uid);
    if (user == null) {
      throw Exception('User profile record not found');
    }
    return user;
  }

  // Fetch User Profile from Realtime Database
  Future<UserModel?> fetchUserProfile(String uid) async {
    final snapshot = await _db.child('users').child(uid).get();
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final user = UserModel.fromJson(data);
      currentUser.value = user;
      return user;
    }
    return null;
  }

  // Sign out
  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
  }
}
