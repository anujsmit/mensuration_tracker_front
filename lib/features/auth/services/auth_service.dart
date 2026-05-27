// lib/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  // ======================================================
  // LOGIN
  // ======================================================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final supabaseToken = response.session?.accessToken;
    
    if (supabaseToken != null) {
      // Exchange Supabase token for local backend token
      await _exchangeAndStoreToken(supabaseToken);
    }

    return response;
  }

  // ======================================================
  // REGISTER
  // ======================================================

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );

    final supabaseToken = response.session?.accessToken;
    
    if (supabaseToken != null) {
      // Exchange Supabase token for local backend token
      await _exchangeAndStoreToken(supabaseToken);
    }

    return response;
  }

  // ======================================================
  // EXCHANGE TOKEN WITH BACKEND
  // ======================================================

  // lib/services/auth_service.dart - Add more debug logging

Future<void> _exchangeAndStoreToken(String supabaseToken) async {
  try {
    print('🔄 EXCHANGING TOKEN...');
    print('📤 Supabase token (first 50 chars): ${supabaseToken.substring(0, 50)}...');
    
    final response = await _dio.post(
      'http://192.168.1.69:5000/api/auth/exchange-token',
      data: {'supabase_token': supabaseToken},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => true, // Don't throw on any status
      ),
    );
    
    print('📥 Exchange response status: ${response.statusCode}');
    print('📥 Exchange response data: ${response.data}');
    
    if (response.statusCode == 200 && response.data['success'] == true) {
      final localToken = response.data['access_token'];
      await storage.write(key: 'access_token', value: localToken);
      print('✅ Local token stored successfully');
      print('🔑 Local token (first 50 chars): ${localToken.substring(0, 50)}...');
    } else {
      print('⚠️ Token exchange failed with status: ${response.statusCode}');
      print('⚠️ Response: ${response.data}');
      // Don't fallback to Supabase token - this is the issue!
      // Instead, throw an error so we know it failed
      throw Exception('Token exchange failed: ${response.data}');
    }
  } catch (e) {
    print('❌ Token exchange error: $e');
    // Don't store Supabase token - this will cause 401 errors
    // Instead, rethrow so login fails
    rethrow;
  }
}

  // ======================================================
  // GOOGLE SIGN IN
  // ======================================================

  Future<bool> signInWithGoogle() async {
    final response = await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
    
    // After Google sign in completes, get the token
    final session = supabase.auth.currentSession;
    if (session != null) {
      await _exchangeAndStoreToken(session.accessToken);
    }
    
    return true;
  }

  // ======================================================
  // LOGOUT
  // ======================================================

  Future<void> logout() async {
    await supabase.auth.signOut();
    await storage.delete(key: 'access_token');
  }

  // ======================================================
  // GET CURRENT USER
  // ======================================================

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // ======================================================
  // GET CURRENT SESSION
  // ======================================================

  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }

  // ======================================================
  // CHECK AUTH
  // ======================================================

  bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }

  // ======================================================
  // RESET PASSWORD
  // ======================================================

  Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  // ======================================================
  // UPDATE PASSWORD
  // ======================================================

  Future<UserResponse> updatePassword({required String newPassword}) async {
    return await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ======================================================
  // REFRESH SESSION
  // ======================================================

  Future<AuthResponse> refreshSession() async {
    return await supabase.auth.refreshSession();
  }

  // ======================================================
  // GET ACCESS TOKEN
  // ======================================================

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  // ======================================================
  // SAVE TOKEN MANUALLY
  // ======================================================

  Future<void> saveToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  // ======================================================
  // DELETE TOKEN
  // ======================================================

  Future<void> deleteToken() async {
    await storage.delete(key: 'access_token');
  }
}