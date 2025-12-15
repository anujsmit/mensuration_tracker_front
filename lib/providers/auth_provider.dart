import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mensurationhealthapp/config/config.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _email;
  String? _username;
  bool _isAdmin = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isAuth => _token != null;
  bool get isAdmin => _isAdmin;
  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get username => _username;
  User? get firebaseUser => _firebaseAuth.currentUser;

  // Constants
  static const String _baseUrl = Config.apiAuthBaseUrl;
  static const String _userDataKey = 'userData';
  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      // Get Firebase user
      final User? user = userCredential.user;
      if (user != null) {
        // Create or update user in your backend
        await _syncUserWithBackend(user);
      }

      return userCredential;
    } catch (error) {
      print('Google Sign In Error: $error');
      rethrow;
    }
  }

  Future<void> _syncUserWithBackend(User firebaseUser) async {
    try {
      final idToken = await firebaseUser.getIdToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/firebase'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'name': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoURL,
          'idToken': idToken,
        }),
      ).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Store backend token and user data
        _token = responseData['token'];
        _userId = responseData['user_id']?.toString();
        _email = firebaseUser.email;
        _username = firebaseUser.displayName ?? firebaseUser.email?.split('@')[0];
        _isAdmin = responseData['isAdmin'] ?? false;

        await _saveUserDataToPrefs();
        notifyListeners();
      } else {
        throw Exception('Failed to sync with backend');
      }
    } catch (error) {
      print('Sync with backend error: $error');
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    // First check Firebase auth state
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        // Sync with backend
        await _syncUserWithBackend(firebaseUser);
        return true;
      } catch (error) {
        print('Auto-login sync error: $error');
        await logout();
        return false;
      }
    }

    // Fallback to stored token (for backward compatibility)
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userDataKey)) return false;

    try {
      final extractedData = 
          json.decode(prefs.getString(_userDataKey)!) as Map<String, dynamic>;
      
      _token = extractedData['token'];
      _userId = extractedData['userId'];
      _email = extractedData['email'];
      _username = extractedData['username'];
      _isAdmin = extractedData['isAdmin'] ?? false;

      if (_token == null || _userId == null) {
        await logout();
        return false;
      }

      // Verify token with server
      try {
        final serverAdminStatus = await checkAdminStatus(_token!);
        _isAdmin = serverAdminStatus;
        await _saveUserDataToPrefs();
      } catch (e) {
        print('Admin verification failed: $e');
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Auto-login error: $e');
      await _clearUserData();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Firebase logout error: $e');
    }
    
    _token = null;
    _userId = null;
    _email = null;
    _username = null;
    _isAdmin = false;
    await _clearUserData();
    notifyListeners();
  }

  // Keep existing methods but remove email/password login
  // ... (other methods remain the same)

  Future<void> _saveUserDataToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userDataKey,
      json.encode({
        'token': _token,
        'userId': _userId,
        'email': _email,
        'username': _username,
        'isAdmin': _isAdmin,
      }),
    );
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }
}