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
bool _isLoading = false;

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
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

// Add this debug method to AuthProvider class
Future<void> _debugNetworkRequest(Uri uri, String body) async {
debugPrint('=== NETWORK REQUEST DEBUG ===');
debugPrint('URL: ${uri.toString()}');
debugPrint('Full URL: ${uri.scheme}://${uri.host}:${uri.port}${uri.path}');
debugPrint('Body: $body');

try {
// Try a simple HTTP GET to check connectivity
final testResponse = await http.get(
Uri.parse('http://${uri.host}:${uri.port}/'),
headers: {'Content-Type': 'application/json'},
).timeout(Duration(seconds: 5));

debugPrint(
'Connectivity test: SUCCESS (Status: ${testResponse.statusCode})');
} catch (e) {
debugPrint('Connectivity test: FAILED - $e');
}

debugPrint('=== END DEBUG ===');
}

// ======================================================
// 2️⃣ SEND FIREBASE TOKEN TO BACKEND (Unified Sync)
// ======================================================
Future<void> _syncFirebaseUserWithBackend(User user, String endpoint) async {
try {
final idToken = await user.getIdToken(true);

final response = await http
.post(
Uri.parse('$_baseUrl$endpoint'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({'idToken': idToken}),
)
.timeout(_timeout);

if (response.statusCode != 200) {
final errorData = jsonDecode(response.body);
throw Exception(
errorData['message'] ?? 'Backend authentication failed');
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
// 3️⃣ PHONE TOKEN EXCHANGE (Called AFTER Firebase verifies OTP)
// ======================================================
Future<void> verifyPhoneToken(String idToken) async {
try {
_isLoading = true;
notifyListeners();

final uri = Uri.parse('$_baseUrl/phone/verify-token');
final body = jsonEncode({'idToken': idToken});

// Debug the request
await _debugNetworkRequest(uri, body.substring(0, 50) + '...');

final response = await http
.post(
uri,
headers: {'Content-Type': 'application/json'},
body: body,
)
.timeout(_timeout);

debugPrint('Response status: ${response.statusCode}');
debugPrint('Response body: ${response.body}');

if (response.statusCode != 200) {
final errorData = jsonDecode(response.body);
throw Exception(
errorData['message'] ?? 'Phone token verification failed');
}

final data = jsonDecode(response.body);

_token = data['token'];
_userId = data['user_id']?.toString();
_isAdmin = data['isAdmin'] ?? false;
_email = data['email'];
_username = data['username'];

await _saveUserData();
} catch (e) {
debugPrint("Phone Token Exchange Error: $e");
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

// Try Firebase auto-login first
if (firebaseUser != null) {
try {
_email = firebaseUser.email;
_username =
firebaseUser.displayName ?? firebaseUser.email?.split('@')[0];

// Determine which endpoint to use based on provider
if (firebaseUser.providerData
.any((userInfo) => userInfo.providerId == 'google.com')) {
await _syncFirebaseUserWithBackend(
firebaseUser, '/firebase/auth/google');
} else if (firebaseUser.providerData
.any((userInfo) => userInfo.providerId == 'phone')) {
// For phone auth, get the token and verify with backend
final idToken = await firebaseUser.getIdToken(true);
if (idToken != null) {
await verifyPhoneToken(idToken);
} else {
throw Exception("Failed to get ID token for phone user");
}
}

notifyListeners();
return true;
} catch (e) {
debugPrint("Auto login error: $e");
await signOut();
return false;
}
}

// Fall back to local storage
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
