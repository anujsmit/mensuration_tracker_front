// anujsmit/mensuration_tracker_front/mensuration_tracker_front-f791c10d8517a5f857299bbd66976c42835a8ba8a/lib/providers/auth_provider.dart (MODIFIED)
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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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
  // 1️⃣ GOOGLE SIGN-IN 
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

      await _syncFirebaseUserWithBackend(user, '/firebase/auth/google');

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
  // 2️⃣ SEND FIREBASE TOKEN TO BACKEND (Unified Sync)
  // ======================================================
  Future<void> _syncFirebaseUserWithBackend(User user, String endpoint) async {
    try {
      final idToken = await user.getIdToken(true);

      final response = await http
          .post(
            // Corrected endpoint mapping: $_baseUrl/firebase/auth/google
            Uri.parse('$_baseUrl$endpoint'), 
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Backend authentication failed');
      }

      final data = jsonDecode(response.body);

      _token = data['token'];
      _userId = data['user_id']?.toString();
      _isAdmin = data['isAdmin'] ?? false;
      _email = data['email'] ?? user.email;
      _username = data['username'] ?? user.displayName;

      await _saveUserData();
    } catch (e) {
      debugPrint("Backend Sync Error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 3️⃣ PHONE TOKEN EXCHANGE (New: Called AFTER Firebase verifies OTP)
  // ======================================================
  Future<Map<String, dynamic>> verifyPhoneToken(String idToken) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final res = await http
        .post(
          // Matches backend /api/auth/phone/verify-token
          Uri.parse('$_baseUrl/phone/verify-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        )
        .timeout(_timeout);

      final data = jsonDecode(res.body);
      if (res.statusCode != 200) {
        throw Exception(data['message'] ?? 'Phone token verification failed');
      }

      _token = data['token'];
      _userId = data['user_id']?.toString();
      _email = data['email'];
      _username = data['username'];
      _isAdmin = data['isAdmin'] ?? false;

      await _saveUserData();
      return data;

    } catch (e) {
      debugPrint("Phone Sign-In Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // ======================================================
  // 4️⃣ AUTO LOGIN
  // ======================================================
  Future<bool> tryAutoLogin() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      try {
        _email = firebaseUser.email;
        _username =
            firebaseUser.displayName ?? firebaseUser.email?.split('@')[0];
        await _syncFirebaseUserWithBackend(firebaseUser, '/firebase/auth/google');
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
  // 5️⃣ SIGN OUT
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
  // 6️⃣ LOCAL STORAGE
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