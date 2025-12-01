import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _email;
  String? _username;
  bool _isAdmin = false;

  bool get isAuth => _token != null;
  bool get isAdmin => _isAdmin;
  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get username => _username; 

  // Constants
  static const String _baseUrl = 'http://10.56.42.100:3000/api/auth';
  static const String _userDataKey = 'userData';
  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<Map<String, dynamic>> _makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final headers = {'Content-Type': 'application/json'};
      final encodedBody = body != null ? json.encode(body) : null;

      late http.Response response;
      switch (method) {
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: encodedBody)
              .timeout(_requestTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode >= 400) {
        throw HttpException(
          responseData['message'] ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }

      return responseData;
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  bool get isTokenValid {
    if (_token == null) return false;
    return true;
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String username,
    String email,
    String password,
  ) async {
    return await _makeRequest(
      endpoint: 'signup',
      method: 'POST',
      body: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'timezone': DateTime.now().timeZoneName,
      },
    );
  }

Future<bool> verifyAdminStatus(String token) async {
  final response = await http.get(Uri.parse('$_baseUrl/api/verify'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['isAdmin'] == true;
  } else {
    throw Exception('Failed to verify admin status');
  }
}

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final responseData = await _makeRequest(
        endpoint: 'verify-otp',
        method: 'POST',
        body: {'email': email, 'otp': otp},
      );

      _token = responseData['token'];
      _userId = responseData['user_id']?.toString();
      _email = responseData['email'];
      _username = responseData['username'];
      _isAdmin = responseData['isAdmin'] ?? false;

      await _saveUserDataToPrefs();
      notifyListeners();

      return responseData;
    } on HttpException catch (e) {
      if (e.statusCode == 400 && e.message.contains('expired')) {
        throw Exception('OTP has expired. Please request a new one.');
      } else if (e.statusCode == 400) {
        throw Exception('Invalid OTP. Please try again.');
      }
      rethrow;
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await _makeRequest(
        endpoint: 'resend-otp',
        method: 'POST',
        body: {'email': email},
      );
    } on HttpException catch (e) {
      if (e.statusCode == 404) {
        throw Exception('Email not found. Please sign up first.');
      } else if (e.statusCode == 400) {
        throw Exception('Account already verified. Please login.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final responseData = await _makeRequest(
        endpoint: 'login',
        method: 'POST',
        body: {'email': email, 'password': password},
      );

      if (responseData['requires_otp'] == true ||
          responseData['otp_sent'] == true) {
        return {
          'requires_otp': true,
          'email': email,
          'user_id': responseData['user_id']?.toString(),
        };
      }

      _token = responseData['token'];
      _userId = responseData['user_id']?.toString();
      _email = responseData['email'];
      _username = responseData['username']; // ADDED: Store username
      _isAdmin = responseData['isAdmin'] ?? false;

      await _saveUserDataToPrefs();
      notifyListeners();

      return null;
    } on HttpException catch (e) {
      if (e.statusCode == 403 && e.message.contains('OTP')) {
        return {
          'requires_otp': true,
          'email': email,
          'message': e.message,
        };
      }
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userDataKey)) return false;

    try {
      final extractedData =
          json.decode(prefs.getString(_userDataKey)!) as Map<String, dynamic>;
      print('Stored user data: $extractedData');

      _token = extractedData['token'];
      _userId = extractedData['userId'];
      _email = extractedData['email'];
      _username = extractedData['username'];
      _isAdmin = extractedData['isAdmin'] ??
          false; // Get admin status from stored data

      // First verify token is valid
      if (_token == null || _userId == null) {
        await logout();
        return false;
      }

      // Verify with server to confirm admin status
      try {
        final serverAdminStatus = await checkAdminStatus(_token!);
        print('Server admin status: $serverAdminStatus');
        _isAdmin = serverAdminStatus;
        await _saveUserDataToPrefs(); // Update local storage with confirmed admin status
      } catch (e) {
        print('Admin verification failed, using stored status: $e');
        // If verification fails, use the stored status
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Auto-login error: $e');
      await _clearUserData();
      return false;
    }
  }

  bool _getAdminStatusFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      return payload['isAdmin'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkAdminStatus(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/check-admin'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isAdmin'] ?? false;
      }
      throw Exception('Failed to verify admin status');
    } catch (e) {
      print('Admin check error: $e');
      rethrow;
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _email = null;
    _username = null;
    _isAdmin = false;
    await _clearUserData();
    notifyListeners();
  }

  Future<void> requestPasswordReset(String email) async {
    await _makeRequest(
      endpoint: 'request-password-reset',
      method: 'POST',
      body: {'email': email},
    );
  }

  Future<void> verifyPasswordResetOtp(String email, String otp) async {
    await _makeRequest(
      endpoint: 'verify-password-reset-otp',
      method: 'POST',
      body: {'email': email, 'otp': otp},
    );
  }

  Future<void> setNewPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    await _makeRequest(
      endpoint: 'set-new-password',
      method: 'POST',
      body: {'email': email, 'otp': otp, 'new_password': newPassword},
    );
  }

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
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, {required this.statusCode});

  @override
  String toString() => 'HTTP $statusCode: $message';
}
