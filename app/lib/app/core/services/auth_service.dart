import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import 'notification_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final RxString verificationId = ''.obs;
  final RxBool isOtpSent = false.obs;
  int? _resendToken;
  StreamSubscription<DatabaseEvent>? _userProfileSubscription;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    _userProfileSubscription?.cancel();
    if (user != null) {
      await fetchUserProfile(user.uid);
      _userProfileSubscription = _db.child('users').child(user.uid).onValue.listen((event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
          currentUser.value = UserModel.fromJson(data);
        }
      });
    } else {
      currentUser.value = null;
    }
  }

  /// Step 1: Send OTP to phone number (+91XXXXXXXXXX)
  Future<void> sendOtp({
    required String phone,
    Function(String verificationId)? onCodeSent,
    Function(String error)? onError,
    Function(UserCredential credential)? onAutoVerified,
  }) async {
    final completer = Completer<void>();

    // Standardize phone format (ensure +91)
    String formattedPhone = phone.trim();
    if (!formattedPhone.startsWith('+')) {
      final digits = formattedPhone.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 10) {
        formattedPhone = '+91$digits';
      } else {
        formattedPhone = '+$digits';
      }
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCred = await _auth.signInWithCredential(credential);
          if (onAutoVerified != null) {
            onAutoVerified(userCred);
          }
        } catch (e) {
          if (onError != null) onError(e.toString());
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        isOtpSent.value = false;
        String message = e.message ?? 'Verification failed';
        if (e.code == 'invalid-phone-number') {
          message = 'Invalid phone number format.';
        } else if (e.code == 'too-many-requests') {
          message = 'Too many attempts. Please try again later.';
        } else if (e.code == 'app-not-authorized') {
          message = 'App not authorized. Check SHA fingerprints in Firebase Console.';
        }
        if (onError != null) onError(message);
        if (!completer.isCompleted) completer.completeError(Exception(message));
      },
      codeSent: (String verId, int? resendToken) {
        verificationId.value = verId;
        _resendToken = resendToken;
        isOtpSent.value = true;
        if (onCodeSent != null) onCodeSent(verId);
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId.value = verId;
      },
    );

    return completer.future;
  }

  /// Step 2: Verify the 6-digit OTP code.
  /// Returns UserModel if existing user profile found, null if new user.
  Future<UserModel?> verifyOtp({
    required String smsCode,
    String? customVerificationId,
  }) async {
    final verId = customVerificationId ?? verificationId.value;
    if (verId.isEmpty) {
      throw Exception('Verification ID not found. Please request OTP again.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verId,
      smsCode: smsCode.trim(),
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw Exception('Sign in failed. Could not authenticate.');
    }

    final userProfile = await fetchUserProfile(user.uid);
    return userProfile;
  }

  /// Create a new user profile after OTP verification (for new users)
  Future<UserModel> createUserProfile({
    required String uid,
    required String phone,
    required String name,
    required String userType, // 'worker' | 'hotel' | 'superadmin'
    required String role, // 'cook_banquet' | 'casual_banquet' | 'driver'
    required String city,
    int experienceYears = 0,
    String? photoUrl,
    String? docType,
    String? docNumber,
    String? docImageUrl,
    String? gstNumber,
    String? gstCertUrl,
    String? hotelName,
  }) async {
    final user = UserModel(
      uid: uid,
      phone: phone,
      name: name,
      userType: userType,
      role: role.toLowerCase(),
      city: city,
      experienceYears: experienceYears,
      available: true,
      createdAt: DateTime.now().toIso8601String(),
      photoUrl: photoUrl,
      docType: docType,
      docNumber: docNumber,
      docImageUrl: docImageUrl,
      gstNumber: gstNumber,
      gstCertUrl: gstCertUrl,
      hotelName: hotelName,
    );

    await _db.child('users').child(uid).set(user.toJson());
    currentUser.value = user;
    return user;
  }

  /// Fetch User Profile from Realtime Database
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

  /// Check if a user with the given phone number already exists
  Future<UserModel?> getUserByPhone(String phone) async {
    try {
      final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
      final last10Digits = cleanDigits.length >= 10
          ? cleanDigits.substring(cleanDigits.length - 10)
          : cleanDigits;

      final snapshot = await _db.child('users').get();
      if (!snapshot.exists || snapshot.value == null) return null;

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      for (final entry in data.entries) {
        if (entry.value is Map) {
          final userData = Map<dynamic, dynamic>.from(entry.value as Map);
          final userPhone = (userData['phone'] as String? ?? '').replaceAll(RegExp(r'\D'), '');
          if (userPhone.isNotEmpty && userPhone.endsWith(last10Digits)) {
            return UserModel.fromJson(userData);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Reset OTP state
  void resetOtpState() {
    verificationId.value = '';
    isOtpSent.value = false;
    _resendToken = null;
  }

  /// Deletes incomplete user account from Firebase Auth and cleans up session
  Future<void> cleanupIncompleteSession() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.delete();
      } catch (_) {
        try {
          await _auth.signOut();
        } catch (_) {}
      }
    }
    currentUser.value = null;
    resetOtpState();
  }

  /// Sign out
  Future<void> logout() async {
    final uid = currentUser.value?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        if (Get.isRegistered<NotificationService>()) {
          await Get.find<NotificationService>().clearFcmToken(uid);
        }
      } catch (_) {}
    }
    resetOtpState();
    await _auth.signOut();
    currentUser.value = null;
  }
}

