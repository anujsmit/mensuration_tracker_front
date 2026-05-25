import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart'; // ← Add this import
import 'package:mensurationhealthapp/screens/auth/otp_verification_screen.dart';
import 'package:mensurationhealthapp/screens/auth/phone_login_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:mensurationhealthapp/providers/admin_notification_provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/notification_provider.dart';
import 'package:mensurationhealthapp/providers/profile_provider.dart';
import 'package:mensurationhealthapp/providers/user_provider.dart';
import 'package:mensurationhealthapp/providers/ReportProvider.dart';

import 'package:mensurationhealthapp/screens/home/admin/navbar_admin.dart';
import 'package:mensurationhealthapp/screens/auth/login_screen.dart';
import 'package:mensurationhealthapp/screens/auth/signup_screen.dart';
import 'package:mensurationhealthapp/screens/home/HomeScreen.dart';
import 'package:mensurationhealthapp/screens/home/profile.dart';
import 'package:mensurationhealthapp/screens/splash_screen.dart';

import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation (good practice — keep it)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 1. Initialize Firebase (you already have this)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize Google Sign-In — REQUIRED in v7.0.0+
  //    Call this exactly once, early in app startup
  try {
    await GoogleSignIn.instance.initialize(
      // clientId: kIsWeb || Platform.isIOS ? 'your-ios-or-web-client-id' : null,
      // serverClientId: 'your-backend-server-client-id-if-using-offline-access',
      // scopes: ['email', 'profile'],   // ← usually not needed here anymore
    );
    debugPrint('Google Sign-In initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Google Sign-In: $e');
    // Optionally: show error to user or fallback to email login only
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => UserNotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminNotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'Menstrual Health App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfilePage(),
          '/admin': (context) => const NavbarAdmin(),
          '/phone': (context) => const PhoneLoginScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    );
  }
}