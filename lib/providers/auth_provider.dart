import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mensurationhealthapp/config/config.dart';

class AuthProvider with ChangeNotifier {

  // =========================
  // STATE
  // =========================
  String? _token;
  String? _userId;
  String? _email;
  String? _username;
  bool _isAdmin = false;
  bool _isLoading = false;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // =========================
  // GETTERS
  // =========================
  bool get isAuth => _token != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;

  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get username => _username;
  User? get firebaseUser => _firebaseAuth.currentUser;

  // =========================
  // CONSTANTS
  // =========================
  static const String _baseUrl = Config.apiAuthBaseUrl;
  static const String _userDataKey = 'userData';
  static const Duration _timeout = Duration(seconds: 30);

  // ======================================================
  // 1️⃣ GOOGLE SIGN-IN (FIXED FOR google_sign_in 7.x)
  // ======================================================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.authenticate();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception("Google ID Token missing");
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) throw Exception("Firebase user null");

      _email = user.email;
      _username = user.displayName ?? user.email?.split('@')[0];

      await _syncFirebaseUserWithBackend(user);

      return userCredential;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 2️⃣ SEND FIREBASE TOKEN TO BACKEND
  // ======================================================
  Future<void> _syncFirebaseUserWithBackend(User user) async {
    try {
      final idToken = await user.getIdToken(true);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Backend authentication failed');
      }

      final data = jsonDecode(response.body);

      _token = data['token'];
      _userId = data['user_id']?.toString();
      _isAdmin = data['isAdmin'] ?? false;

      await _saveUserData();
    } catch (e) {
      debugPrint("Backend Sync Error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 3️⃣ AUTO LOGIN
  // ======================================================
  Future<bool> tryAutoLogin() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      try {
        _email = firebaseUser.email;
        _username =
            firebaseUser.displayName ?? firebaseUser.email?.split('@')[0];
        await _syncFirebaseUserWithBackend(firebaseUser);
        notifyListeners();
        return true;
      } catch (_) {
        await signOut();
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userDataKey)) return false;

    final data = jsonDecode(prefs.getString(_userDataKey)!);

    _token = data['token'];
    _userId = data['userId'];
    _email = data['email'];
    _username = data['username'];
    _isAdmin = data['isAdmin'] ?? false;

    if (_token == null || _userId == null) {
      await signOut();
      return false;
    }

    notifyListeners();
    return true;
  }

  // ======================================================
  // 4️⃣ SIGN OUT
  // ======================================================
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();

    _token = null;
    _userId = null;
    _email = null;
    _username = null;
    _isAdmin = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);

    notifyListeners();
  }

  // ======================================================
  // 5️⃣ PHONE OTP
  // ======================================================
  Future<Map<String, dynamic>> requestPhoneOtp(String phone) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/phone/request-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phoneNumber': phone}),
        )
        .timeout(_timeout);

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'OTP request failed');
    }
    return data;
  }

  Future<Map<String, dynamic>> verifyPhoneOtp(
      String phone, String otp) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/phone/verify-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'phoneNumber': phone, 'otp': otp}),
        )
        .timeout(_timeout);

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'OTP verification failed');
    }

    _token = data['token'];
    _userId = data['user_id']?.toString();
    _email = data['email'];
    _username = data['username'];
    _isAdmin = data['isAdmin'] ?? false;

    await _saveUserData();
    notifyListeners();
    return data;
  }

  // ======================================================
  // 6️⃣ EMAIL OTP
  // ======================================================
  Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/verify-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otp': otp}),
        )
        .timeout(_timeout);

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data['message'] ?? 'OTP failed');
    }
    return data;
  }

  Future<void> resendOtp(String email) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/resend-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Failed to resend OTP');
    }
  }

  // ======================================================
  // 7️⃣ LOCAL STORAGE
  // ======================================================
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userDataKey,
      jsonEncode({
        'token': _token,
        'userId': _userId,
        'email': _email,
        'username': _username,
        'isAdmin': _isAdmin,
      }),
    );
  }
}
