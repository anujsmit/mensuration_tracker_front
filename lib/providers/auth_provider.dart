import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mensurationhealthapp/config/config.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _email;
  String? _username;
  String? _phoneNumber;
  bool _isAdmin = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isAuth => _token != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get username => _username;
  String? get phoneNumber => _phoneNumber;

  static const String _baseUrl = Config.apiAuthBaseUrl;
  static const String _userDataKey = 'userData';
  static const Duration _timeout = Duration(seconds: 30);

  String normalizeEmail(String email) {
    String normalized = email.toLowerCase().trim();
    
    if (normalized.contains('@gmail.com')) {
      final parts = normalized.split('@');
      final localPart = parts[0].replaceAll('.', '');
      normalized = '$localPart@gmail.com';
    }
    
    if (normalized.contains('@googlemail.com')) {
      final parts = normalized.split('@');
      final localPart = parts[0].replaceAll('.', '');
      normalized = '$localPart@gmail.com';
    }
    
    return normalized;
  }

  // EMAIL SIGNUP (FIXED)
  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final normalizedEmail = normalizeEmail(email);

      final Map<String, dynamic> requestBody = {
        'email': normalizedEmail,
        'password': password,
        'fullName': fullName ?? normalizedEmail.split('@')[0],
      };
      
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestBody['phoneNumber'] = phoneNumber;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? 'Signup failed');
      }

      // Save user data
      _token = data['token'];
      _userId = data['user']['id'].toString();
      _email = data['user']['email'];
      _username = data['user']['username'] ?? data['user']['fullName'];
      _phoneNumber = data['user']['phoneNumber'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();
      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // EMAIL SIGNIN (FIXED)
  Future<void> signInWithEmail(String email, String password, {bool rememberMe = false}) async {
    _setLoading(true);
    _clearError();

    try {
      final normalizedEmail = normalizeEmail(email);

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': normalizedEmail,
          'password': password,
          'rememberMe': rememberMe,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Login failed');
      }

      _token = data['token'];
      _userId = data['user']['id'].toString();
      _email = data['user']['email'];
      _username = data['user']['username'] ?? data['user']['fullName'];
      _phoneNumber = data['user']['phoneNumber'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();
      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // PHONE SIGNUP (FIXED - Added missing endpoint)
  Future<void> signUpWithPhone({
    required String phoneNumber,
    required String password,
    required String username,
    String? fullName,
    String? countryCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/phone/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
          'username': username,
          'fullName': fullName ?? username,
          'countryCode': countryCode ?? '+1',
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? 'Phone signup failed');
      }

      _token = data['token'];
      _userId = data['user']['id'].toString();
      _username = data['user']['username'];
      _phoneNumber = data['user']['phoneNumber'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();
      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // PHONE SIGNIN (FIXED)
  Future<void> signInWithPhone({
    required String phoneNumber,
    required String password,
    String? countryCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/phone/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
          'countryCode': countryCode ?? '+1',
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Phone login failed');
      }

      _token = data['token'];
      _userId = data['user']['id'].toString();
      _username = data['user']['username'];
      _phoneNumber = data['user']['phoneNumber'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();
      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // SEND PHONE OTP (FIXED)
  Future<void> sendPhoneOtp(String phoneNumber, {String countryCode = '+1'}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/phone/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'countryCode': countryCode,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to send OTP');
      }

      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // VERIFY PHONE OTP (FIXED)
  Future<void> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
    String? username,
    String countryCode = '+1',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/phone/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
          'username': username,
          'countryCode': countryCode,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'OTP verification failed');
      }

      _token = data['token'];
      _userId = data['user']['id'].toString();
      _username = data['user']['username'];
      _phoneNumber = data['user']['phoneNumber'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();
      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // GOOGLE SIGNIN (FIXED - Complete implementation)
  Future<void> signInWithGoogle({
    required String idToken,
    required String accessToken,
    required Map<String, dynamic> userInfo,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'accessToken': accessToken,
          'userInfo': userInfo,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Google sign-in failed');
      }

      _token = data['token'];
      _userId = data['user']['id'].toString();
      _email = data['user']['email'];
      _username = data['user']['username'] ?? data['user']['fullName'];
      _phoneNumber = data['user']['phoneNumber'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();
      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // FORGOT PASSWORD - SEND OTP (FIXED)
  Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final normalizedEmail = normalizeEmail(email);

      final response = await http.post(
        Uri.parse('$_baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': normalizedEmail}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to send OTP');
      }

      _setLoading(false);
      return data;

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // VERIFY PASSWORD RESET OTP (FIXED)
  Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['valid'] != true) {
        throw Exception(data['message'] ?? 'Invalid OTP');
      }

      _setLoading(false);
      return data;

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // RESEND PASSWORD RESET OTP (FIXED)
  Future<Map<String, dynamic>> resendPasswordResetOTP(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final normalizedEmail = normalizeEmail(email);

      final response = await http.post(
        Uri.parse('$_baseUrl/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': normalizedEmail}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to resend OTP');
      }

      _setLoading(false);
      return data;

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // RESET PASSWORD WITH TOKEN (FIXED)
  Future<void> resetPasswordWithToken(String resetToken, String newPassword, String confirmPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'resetToken': resetToken,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Password reset failed');
      }

      _setLoading(false);

    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      rethrow;
    }
  }

  // AUTO LOGIN (FIXED)
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userDataKey)) return false;

    try {
      final data = jsonDecode(prefs.getString(_userDataKey)!);

      _token = data['token'];
      _userId = data['userId'];
      _email = data['email'];
      _username = data['username'];
      _phoneNumber = data['phoneNumber'];
      _isAdmin = data['isAdmin'] ?? false;

      // Validate token
      if (_token != null) {
        final response = await http.get(
          Uri.parse('$_baseUrl/profile'),
          headers: {'Authorization': 'Bearer $_token'},
        ).timeout(_timeout);

        if (response.statusCode == 200) {
          notifyListeners();
          return true;
        }
      }

      await signOut();
      return false;

    } catch (e) {
      debugPrint("Auto login error: $e");
      await signOut();
      return false;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    _token = null;
    _userId = null;
    _email = null;
    _username = null;
    _phoneNumber = null;
    _isAdmin = false;
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);

    notifyListeners();
  }

  // HELPERS
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userDataKey,
      jsonEncode({
        'token': _token,
        'userId': _userId,
        'email': _email,
        'username': _username,
        'phoneNumber': _phoneNumber,
        'isAdmin': _isAdmin,
      }),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}