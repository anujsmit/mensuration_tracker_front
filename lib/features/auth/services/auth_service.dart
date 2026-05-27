import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  // ======================================================
  // SUPABASE
  // ======================================================

  final SupabaseClient supabase =
      Supabase.instance.client;

  // ======================================================
  // STORAGE
  // ======================================================

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  // ======================================================
  // LOGIN
  // ======================================================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {

    final response =
        await supabase.auth.signInWithPassword(

      email: email,

      password: password,

    );

    // ======================================================
    // SAVE ACCESS TOKEN
    // ======================================================

    final token =
        response.session?.accessToken;

    if (token != null) {

      await storage.write(
        key: 'access_token',
        value: token,
      );

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

    final response =
        await supabase.auth.signUp(

      email: email,

      password: password,

      data: {
        'full_name': fullName,
      },

    );

    // ======================================================
    // SAVE ACCESS TOKEN
    // ======================================================

    final token =
        response.session?.accessToken;

    if (token != null) {

      await storage.write(
        key: 'access_token',
        value: token,
      );

    }

    return response;

  }

  // ======================================================
  // GOOGLE SIGN IN
  // ======================================================

  Future<bool> signInWithGoogle() async {

    return await supabase.auth.signInWithOAuth(

      OAuthProvider.google,

      redirectTo:
          'io.supabase.flutter://login-callback',

    );

  }

  // ======================================================
  // LOGOUT
  // ======================================================

  Future<void> logout() async {

    await supabase.auth.signOut();

    await storage.delete(
      key: 'access_token',
    );

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

    return supabase.auth.currentUser !=
        null;

  }

  // ======================================================
  // RESET PASSWORD
  // ======================================================

  Future<void> resetPassword({
    required String email,
  }) async {

    await supabase.auth.resetPasswordForEmail(
      email,
    );

  }

  // ======================================================
  // UPDATE PASSWORD
  // ======================================================

  Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {

    return await supabase.auth.updateUser(

      UserAttributes(
        password: newPassword,
      ),

    );

  }

  // ======================================================
  // REFRESH SESSION
  // ======================================================

  Future<AuthResponse> refreshSession()
      async {

    return await supabase.auth.refreshSession();

  }

  // ======================================================
  // GET ACCESS TOKEN
  // ======================================================

  Future<String?> getAccessToken()
      async {

    return await storage.read(
      key: 'access_token',
    );

  }

  // ======================================================
  // SAVE TOKEN MANUALLY
  // ======================================================

  Future<void> saveToken(
    String token,
  ) async {

    await storage.write(
      key: 'access_token',
      value: token,
    );

  }

  // ======================================================
  // DELETE TOKEN
  // ======================================================

  Future<void> deleteToken() async {

    await storage.delete(
      key: 'access_token',
    );

  }

}