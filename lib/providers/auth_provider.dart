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
  bool _isAdmin = false;
  bool _isLoading = false;

  // Getters
  bool get isAuth => _token != null;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get username => _username;

  // Constants
  static const String _baseUrl = Config.apiAuthBaseUrl;
  static const String _userDataKey = 'userData';
  static const Duration _timeout = Duration(seconds: 30);

  // ======================================================
  // Helper function to normalize email (Facebook-style)
  // ======================================================
  String normalizeEmail(String email) {
    String normalized = email.toLowerCase().trim();
    
    // Handle Gmail: remove dots before @gmail.com
    if (normalized.contains('@gmail.com')) {
      final parts = normalized.split('@');
      final localPart = parts[0].replaceAll('.', '');
      normalized = '$localPart@gmail.com';
    }
    
    // Handle Googlemail (sometimes used instead of gmail.com)
    if (normalized.contains('@googlemail.com')) {
      final parts = normalized.split('@');
      final localPart = parts[0].replaceAll('.', '');
      normalized = '$localPart@gmail.com';
    }
    
    return normalized;
  }

  // ======================================================
  // 1️⃣ EMAIL & PASSWORD SIGN UP (with email normalization)
Future<void> signUpWithEmail(
  String email, 
  String password, {
  String? fullName,
  String? phoneNumber,
}) async {
  try {
    _isLoading = true;
    notifyListeners();

    final normalizedEmail = normalizeEmail(email);

    final Map<String, dynamic> requestBody = {
      'email': normalizedEmail,
      'password': password,
      'fullName': fullName ?? normalizedEmail.split('@')[0],
    };
    
    // Add phone number if provided
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
    _username = data['user']['username']; // This will be the email
    _isAdmin = data['user']['isAdmin'] ?? false;

    await _saveUserData();

  } catch (e) {
    debugPrint("Email Sign Up Error: $e");
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  // ======================================================
  // 2️⃣ EMAIL & PASSWORD SIGN IN (with email normalization)
  // ======================================================
  Future<void> signInWithEmail(String email, String password, {bool rememberMe = false}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Normalize email before sending
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

      // Save user data
      _token = data['token'];
      _userId = data['user']['id'].toString();
      _email = data['user']['email'];
      _username = data['user']['username'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();

    } catch (e) {
      debugPrint("Email Sign In Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 3️⃣ FORGOT PASSWORD - SEND OTP
  // ======================================================
  Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

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

      return data;
    } catch (e) {
      debugPrint("Send Password Reset OTP Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 4️⃣ FORGOT PASSWORD - VERIFY OTP
  // ======================================================
  Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp) async {
    try {
      _isLoading = true;
      notifyListeners();

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

      return data;
    } catch (e) {
      debugPrint("Verify Password Reset OTP Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 5️⃣ FORGOT PASSWORD - RESEND OTP
  // ======================================================
  Future<Map<String, dynamic>> resendPasswordResetOTP(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

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

      return data;
    } catch (e) {
      debugPrint("Resend Password Reset OTP Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 6️⃣ FORGOT PASSWORD - RESET WITH TOKEN
  // ======================================================
  Future<void> resetPasswordWithToken(String resetToken, String newPassword, String confirmPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

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

    } catch (e) {
      debugPrint("Reset Password With Token Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 7️⃣ PHONE & PASSWORD SIGN UP
  // ======================================================
  Future<void> signUpWithPhone({
    required String phoneNumber,
    required String password,
    required String username,
    String? fullName,
    String? countryCode,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$_baseUrl/phone/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
          'username': username,
          'fullName': fullName ?? username,
          'countryCode': countryCode,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? 'Phone signup failed');
      }

      // Save user data
      _token = data['token'];
      _userId = data['user']['id'].toString();
      _username = data['user']['username'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();

    } catch (e) {
      debugPrint("Phone Sign Up Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 8️⃣ PHONE & PASSWORD SIGN IN
  // ======================================================
  Future<void> signInWithPhone({
    required String phoneNumber,
    required String password,
    String? countryCode,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$_baseUrl/phone/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
          'countryCode': countryCode,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Phone login failed');
      }

      // Save user data
      _token = data['token'];
      _userId = data['user']['id'].toString();
      _username = data['user']['username'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();

    } catch (e) {
      debugPrint("Phone Sign In Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 9️⃣ GOOGLE SIGN-IN
  // ======================================================
  Future<void> signInWithGoogle({
    required String? idToken,
    required String? accessToken,
    required Map<String, dynamic> userInfo,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

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

      // Save user data
      _token = data['token'];
      _userId = data['user']['id'].toString();
      _email = data['user']['email'];
      _username = data['user']['username'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();

    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 🔟 PHONE OTP - SEND OTP
  // ======================================================
  Future<void> sendPhoneOtp(String phoneNumber, {String countryCode = '+91'}) async {
    try {
      _isLoading = true;
      notifyListeners();

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

    } catch (e) {
      debugPrint("Send OTP Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 1️⃣1️⃣ PHONE OTP - VERIFY OTP
  // ======================================================
  Future<void> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
    String? username,
    String countryCode = '+91',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

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

      // Save user data
      _token = data['token'];
      _userId = data['user']['id'].toString();
      _username = data['user']['username'];
      _isAdmin = data['user']['isAdmin'] ?? false;

      await _saveUserData();

    } catch (e) {
      debugPrint("Verify OTP Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 1️⃣2️⃣ CHANGE PASSWORD (when logged in)
  // ======================================================
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$_baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Password change failed');
      }

    } catch (e) {
      debugPrint("Change Password Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // 1️⃣3️⃣ AUTO LOGIN
  // ======================================================
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userDataKey)) return false;

    try {
      final data = jsonDecode(prefs.getString(_userDataKey)!);

      _token = data['token'];
      _userId = data['userId'];
      _email = data['email'];
      _username = data['username'];
      _isAdmin = data['isAdmin'] ?? false;

      // Validate token by making a test request
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

      // Token is invalid
      await signOut();
      return false;

    } catch (e) {
      debugPrint("Auto login error: $e");
      await signOut();
      return false;
    }
  }

  // ======================================================
  // 1️⃣4️⃣ SIGN OUT
  // ======================================================
  Future<void> signOut() async {
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
  // 1️⃣5️⃣ GET USER PROFILE
  // ======================================================
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to get profile');
      }

      return data;
    } catch (e) {
      debugPrint("Get profile error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 1️⃣6️⃣ UPDATE USER PROFILE
  // ======================================================
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(profileData),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }

      // Update local data if username changed
      if (profileData.containsKey('username')) {
        _username = profileData['username'];
        await _saveUserData();
      }

    } catch (e) {
      debugPrint("Update profile error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 1️⃣7️⃣ UPDATE USERNAME
  // ======================================================
  Future<void> updateUsername(String username) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile/username'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'username': username}),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to update username');
      }

      _username = username;
      await _saveUserData();

    } catch (e) {
      debugPrint("Update username error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 1️⃣8️⃣ GET USER BY ID (Admin only)
  // ======================================================
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to get user');
      }

      return data;
    } catch (e) {
      debugPrint("Get user by id error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 1️⃣9️⃣ GET ALL USERS (Admin only)
  // ======================================================
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to get users');
      }

      return data;
    } catch (e) {
      debugPrint("Get all users error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 2️⃣0️⃣ UPDATE USER (Admin only)
  // ======================================================
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(userData),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to update user');
      }

    } catch (e) {
      debugPrint("Update user error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 2️⃣1️⃣ DELETE USER (Admin only)
  // ======================================================
  Future<void> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to delete user');
      }

    } catch (e) {
      debugPrint("Delete user error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 2️⃣2️⃣ MAKE USER ADMIN (Admin only)
  // ======================================================
  Future<void> makeUserAdmin(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/$userId/make-admin'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to make user admin');
      }

    } catch (e) {
      debugPrint("Make user admin error: $e");
      rethrow;
    }
  }

  // ======================================================
  // 2️⃣3️⃣ REMOVE ADMIN (Admin only)
  // ======================================================
  Future<void> removeAdmin(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/$userId/remove-admin'),
        headers: {'Authorization': 'Bearer $_token'},
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to remove admin');
      }

    } catch (e) {
      debugPrint("Remove admin error: $e");
      rethrow;
    }
  }

  // ======================================================
  // LOCAL STORAGE
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

