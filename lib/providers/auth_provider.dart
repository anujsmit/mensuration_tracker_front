import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final supabase =
      Supabase.instance.client;

  User? _user;

  bool _isLoading = false;

  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  User? get user => _user;

  bool get isAuth =>
      _user != null;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  // IMPORTANT FIX
  String? get token =>
      supabase
          .auth
          .currentSession
          ?.accessToken;

  String? get userId =>
      supabase
          .auth
          .currentUser
          ?.id;

  String? get username =>
      supabase
          .auth
          .currentUser
          ?.userMetadata?['full_name'];

  // Removed admin
  bool get isAdmin => false;

  AuthProvider() {
    _user =
        supabase.auth.currentUser;

    supabase
        .auth
        .onAuthStateChange
        .listen((data) {
      _user = data.session?.user;

      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;

    notifyListeners();
  }

  void clearError() {
    _error = null;

    notifyListeners();
  }

  // ==========================================
  // SIGN UP
  // ==========================================

  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
  }) async {
    try {
      _setLoading(true);

      _setError(null);

      final response =
          await supabase.auth.signUp(
        email: email.trim(),

        password: password,

        data: {
          'full_name':
              fullName ?? '',
        },
      );

      _user = response.user;

      notifyListeners();

    } catch (e) {
      _setError(e.toString());

      rethrow;

    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // LOGIN
  // ==========================================

  Future<void> signInWithEmail(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      _setLoading(true);

      _setError(null);

      final response =
          await supabase.auth
              .signInWithPassword(
        email: email.trim(),

        password: password,
      );

      _user = response.user;

      notifyListeners();

    } catch (e) {
      _setError(e.toString());

      rethrow;

    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GOOGLE LOGIN
  // ==========================================

  Future<void>
      signInWithGoogle() async {
    try {
      _setLoading(true);

      const webClientId =
          'YOUR_WEB_CLIENT_ID';

      final GoogleSignIn
          googleSignIn =
          GoogleSignIn(
        serverClientId:
            webClientId,
      );

      final googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final googleAuth =
          await googleUser
              .authentication;

      final idToken =
          googleAuth.idToken;

      final accessToken =
          googleAuth.accessToken;

      if (idToken == null ||
          accessToken == null) {
        throw Exception(
          'Missing Google tokens',
        );
      }

      await supabase.auth
          .signInWithIdToken(
        provider:
            OAuthProvider.google,

        idToken: idToken,

        accessToken:
            accessToken,
      );

      _user =
          supabase.auth.currentUser;

      notifyListeners();

    } catch (e) {
      _setError(e.toString());

      rethrow;

    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PHONE OTP
  // ==========================================

  Future<void> sendPhoneOtp(
    String phoneNumber,
  ) async {
    try {
      _setLoading(true);

      await supabase.auth
          .signInWithOtp(
        phone: phoneNumber,
      );

    } catch (e) {
      _setError(e.toString());

      rethrow;

    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // VERIFY OTP
  // ==========================================

  Future<void> verifyPhoneOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      _setLoading(true);

      final response =
          await supabase.auth
              .verifyOTP(
        phone: phoneNumber,

        token: otp,

        type: OtpType.sms,
      );

      _user = response.user;

      notifyListeners();

    } catch (e) {
      _setError(e.toString());

      rethrow;

    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // RESET PASSWORD
  // ==========================================

  Future<Map<String, dynamic>>
      sendPasswordResetOTP(
    String email,
  ) async {
    try {
      _setLoading(true);

      await supabase.auth
          .resetPasswordForEmail(
        email,
      );

      return {
        'success': true,
        'message':
            'Password reset email sent',
      };

    } catch (e) {
      _setError(e.toString());

      rethrow;

    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> signOut() async {
    await supabase.auth.signOut();

    _user = null;

    notifyListeners();
  }

  // ==========================================
  // AUTO LOGIN
  // ==========================================

  Future<bool> tryAutoLogin() async {
    _user =
        supabase.auth.currentUser;

    notifyListeners();

    return _user != null;
  }
}