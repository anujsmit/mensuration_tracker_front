import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ======================================================
// CORE
// ======================================================

import 'core/network/dio_client.dart';

// ======================================================
// AUTH
// ======================================================

import 'features/auth/providers/auth_provider.dart';

import 'features/auth/screens/login_screen.dart';

// ======================================================
// PROFILE
// ======================================================

import 'features/profile/providers/profile_provider.dart';

// ======================================================
// CYCLES
// ======================================================

import 'features/cycles/providers/cycle_provider.dart';

// ======================================================
// NOTES
// ======================================================

import 'features/notes/providers/note_provider.dart';

// ======================================================
// SYMPTOMS
// ======================================================

import 'features/symptoms/providers/symptom_provider.dart';

// ======================================================
// NOTIFICATIONS
// ======================================================

import 'features/notifications/providers/notification_provider.dart';

// ======================================================
// REPORTS
// ======================================================

import 'features/reports/providers/report_provider.dart';

// ======================================================
// HOME
// ======================================================

import 'package:mensurationhealthapp/main_navigation_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  try {

    // ==================================================
    // LOCK ORIENTATION
    // ==================================================

    await SystemChrome
        .setPreferredOrientations([

      DeviceOrientation.portraitUp,

    ]);

    // ==================================================
    // LOAD ENV
    // ==================================================

    await dotenv.load(
      fileName: '.env',
    );

    // ==================================================
    // GET ENV VALUES
    // ==================================================

    final supabaseUrl =
        dotenv.env['SUPABASE_URL'];

    final supabaseAnonKey =
        dotenv.env['SUPABASE_ANON_KEY'];

    // ==================================================
    // VALIDATE ENV
    // ==================================================

    if (supabaseUrl == null ||
        supabaseUrl.isEmpty) {

      throw Exception(
        'SUPABASE_URL missing in .env',
      );

    }

    if (supabaseAnonKey == null ||
        supabaseAnonKey.isEmpty) {

      throw Exception(
        'SUPABASE_ANON_KEY missing in .env',
      );

    }

    // ==================================================
    // INIT SUPABASE
    // ==================================================

    await Supabase.initialize(

      url: supabaseUrl,

      anonKey: supabaseAnonKey,

    );

    // ==================================================
    // INIT DIO
    // ==================================================

    await DioClient().initialize();

    // ==================================================
    // RUN APP
    // ==================================================

    runApp(
      const MyApp(),
    );

  } catch (e) {

    runApp(
      ErrorApp(
        error: e.toString(),
      ),
    );

  }

}

// ======================================================
// MAIN APP
// ======================================================

class MyApp extends StatelessWidget {

  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return MultiProvider(

      providers: [

        // ==============================================
        // AUTH
        // ==============================================

        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(),
        ),

        // ==============================================
        // PROFILE
        // ==============================================

        ChangeNotifierProvider(
          create: (_) =>
              ProfileProvider(),
        ),

        // ==============================================
        // CYCLES
        // ==============================================

        ChangeNotifierProvider(
          create: (_) =>
              CycleProvider(),
        ),

        // ==============================================
        // NOTES
        // ==============================================

        ChangeNotifierProvider(
          create: (_) =>
              NoteProvider(),
        ),

        // ==============================================
        // SYMPTOMS
        // ==============================================

        ChangeNotifierProvider(
          create: (_) =>
              SymptomProvider(),
        ),

        // ==============================================
        // NOTIFICATIONS
        // ==============================================

        ChangeNotifierProvider(
          create: (_) =>
              NotificationProvider(),
        ),

        // ==============================================
        // REPORTS
        // ==============================================

        ChangeNotifierProvider(
          create: (_) =>
              ReportProvider(),
        ),

      ],

      child: MaterialApp(

        debugShowCheckedModeBanner:
            false,

        title:
            'Mensuration Tracker',

        // ==============================================
        // THEME
        // ==============================================

        theme: ThemeData(

          useMaterial3: true,

          colorSchemeSeed:
              Colors.pink,

          scaffoldBackgroundColor:
              const Color(0xFFF6F7FB),

          appBarTheme:
              const AppBarTheme(

            centerTitle: true,

            elevation: 0,

            backgroundColor:
                Colors.transparent,

          ),

          elevatedButtonTheme:
              ElevatedButtonThemeData(

            style:
                ElevatedButton.styleFrom(

              backgroundColor:
                  Colors.pink,

              foregroundColor:
                  Colors.white,

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),

              ),

            ),

          ),

          inputDecorationTheme:
              InputDecorationTheme(

            filled: true,

            fillColor:
                Colors.white,

            border:
                OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(
                18,
              ),

              borderSide:
                  BorderSide.none,

            ),

          ),

        ),

        // ==============================================
        // HOME
        // ==============================================

        home:
            const AuthWrapper(),

      ),

    );

  }

}

// ======================================================
// AUTH WRAPPER
// ======================================================

class AuthWrapper
    extends StatelessWidget {

  const AuthWrapper({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return Consumer<AuthProvider>(

      builder: (
        context,
        auth,
        child,
      ) {

        // ==========================================
        // LOADING
        // ==========================================

        if (auth.isLoading) {

          return const Scaffold(

            body: Center(

              child:
                  CircularProgressIndicator(),

            ),

          );

        }

        // ==========================================
        // AUTHENTICATED
        // ==========================================

        if (auth.isAuth) {

          return const MainNavigationScreen();

        }

        // ==========================================
        // LOGIN
        // ==========================================

        return const LoginScreen();

      },

    );

  }

}

// ======================================================
// ERROR APP
// ======================================================

class ErrorApp
    extends StatelessWidget {

  final String error;

  const ErrorApp({

    super.key,

    required this.error,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      home: Scaffold(

        backgroundColor:
            Colors.white,

        body: Center(

          child: Padding(

            padding:
                const EdgeInsets.all(
              24,
            ),

            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                // ==================================
                // ICON
                // ==================================

                const Icon(

                  Icons.error_outline,

                  size: 90,

                  color: Colors.red,

                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================
                // TITLE
                // ==================================

                const Text(

                  'Startup Error',

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

                const SizedBox(
                  height: 16,
                ),

                // ==================================
                // MESSAGE
                // ==================================

                Text(

                  error,

                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(

                    fontSize: 15,

                    color: Colors.black87,

                  ),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}