import 'dart:async'; // Required for tracking StreamSubscription
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/scheduler.dart';

class AuthProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Track the auth stream to prevent memory leaks and ghost notifications
  StreamSubscription<AuthState>? _authStreamSubscription;
  
  // Track disposal state to prevent "notified after dispose" runtime crashes
  bool _isDisposed = false;

  // ==========================================
  // GETTERS
  // ==========================================

  User? get user => _user;

  bool get isAuth => _user != null;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get token => supabase.auth.currentSession?.accessToken;

  String? get userId => supabase.auth.currentUser?.id;

  String? get username => supabase.auth.currentUser?.userMetadata?['full_name'];

  bool get isAdmin => false;

  AuthProvider() {
    _user = supabase.auth.currentUser;

    // Assign the stream to our subscription handler
    _authStreamSubscription = supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      _safeNotifyListeners();
    });
  }

/// Safely triggers UI updates without crashing during layout/initial build phases
  void _safeNotifyListeners() {
    if (_isDisposed) return;
    
    Future.microtask(() {
      if (!_isDisposed) notifyListeners();
    });
  }
  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    _safeNotifyListeners();
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  /// Clean up persistent streaming references when provider leaves the widget tree
  @override
  void dispose() {
    _isDisposed = true;
    _authStreamSubscription?.cancel();
    super.dispose();
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

      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName ?? '',
        },
      );

      _user = response.user;
      _safeNotifyListeners();
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

      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      _user = response.user;
      _safeNotifyListeners();
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

  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      // TODO: Replace with your actual Web Client ID from your Google Cloud Console
      const webClientId = 'YOUR_WEB_CLIENT_ID';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return; // User aborted sign-in process
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw Exception('Missing Google tokens');
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      _user = supabase.auth.currentUser;
      _safeNotifyListeners();
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

  Future<void> sendPhoneOtp(String phoneNumber) async {
    try {
      _setLoading(true);
      _setError(null);
      await supabase.auth.signInWithOtp(
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
      _setError(null);

      final response = await supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );

      _user = response.user;
      _safeNotifyListeners();
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

  Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await supabase.auth.resetPasswordForEmail(email);

      return {
        'success': true,
        'message': 'Password reset email sent',
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
    try {
      _setLoading(true);
      await supabase.auth.signOut();
      _user = null;
      _safeNotifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // AUTO LOGIN
  // ==========================================

  Future<bool> tryAutoLogin() async {
    _user = supabase.auth.currentUser;
    _safeNotifyListeners();
    return _user != null;
  }
}