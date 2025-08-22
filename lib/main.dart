import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mensurationhealthapp/providers/admin_notification_provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/screens/auth/password_reset_otp_screen.dart';
import 'package:mensurationhealthapp/screens/home/admin/navbar_admin.dart';
import 'package:mensurationhealthapp/providers/notification_provider.dart';
import 'package:mensurationhealthapp/providers/profile_provider.dart';
import 'package:mensurationhealthapp/screens/auth/login_screen.dart';
import 'package:mensurationhealthapp/screens/auth/signup_screen.dart';
import 'package:mensurationhealthapp/screens/home/HomeScreen.dart';
import 'package:mensurationhealthapp/screens/home/profile.dart';
import 'package:mensurationhealthapp/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'package:mensurationhealthapp/providers/user_provider.dart';
import 'package:mensurationhealthapp/screens/auth/otp_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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