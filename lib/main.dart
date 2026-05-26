import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mensurationhealthapp/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/ReportProvider.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/phone_login_screen.dart';
import 'screens/home/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================
  // LOCK ORIENTATION
  // ==========================================

  await SystemChrome
      .setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await dotenv.load(
    fileName: ".env",
  );

  // ==========================================
  // INIT SUPABASE
  // ==========================================

  await Supabase.initialize(
    url: dotenv.env[
            'SUPABASE_URL'] ??
        '',

    anonKey: dotenv.env[
            'SUPABASE_ANON_KEY'] ??
        '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              ProfileProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              UserNotificationProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              ReportProvider(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner:
            false,

        title:
            'Menstrual Health App',

        theme: ThemeData(
          useMaterial3: true,

          colorSchemeSeed:
              Colors.pink,
        ),

        home: const AuthWrapper(),

        routes: {
          '/login': (_) =>
              const LoginScreen(),

          '/signup': (_) =>
              const SignupScreen(),

          '/home': (_) =>
              const MainNavigationScreen(),

          '/phone': (_) =>
              const PhoneLoginScreen(),
        },
      ),
    );
  }
}

class AuthWrapper
    extends StatelessWidget {
  const AuthWrapper({
    super.key,
  });

  @override
  Widget build(
      BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (
        context,
        auth,
        child,
      ) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        if (auth.isAuth) {
          return const MainNavigationScreen();
        }

        return const LoginScreen();
      },
    );
  }
}