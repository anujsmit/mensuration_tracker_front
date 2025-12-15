// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mensurationhealthapp/screens/home/admin/navbar_admin.dart'; // Import the correct Admin screen
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/notification_provider.dart';
import 'package:mensurationhealthapp/screens/auth/phone_login_screen.dart'; 
import 'package:mensurationhealthapp/screens/home/homescreen.dart';

// Renamed from LoginScreen to FirebaseLoginScreen to reflect the new primary auth methods
class FirebaseLoginScreen extends StatefulWidget {
  const FirebaseLoginScreen({super.key});

  @override
  _FirebaseLoginScreenState createState() => _FirebaseLoginScreenState();
}

class _FirebaseLoginScreenState extends State<FirebaseLoginScreen> {
  bool _isLoadingGoogle = false;
  bool _isLoadingApple = false;

  String _cleanErrorMessage(String error) {
    return error
        .replaceAll('XMLHttpRequest', '')
        .replaceAll('Exception:', '')
        .replaceAll('HttpException:', '')
        .replaceAll('SocketException:', 'Network error:')
        .trim();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoadingGoogle) return;
    setState(() => _isLoadingGoogle = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<UserNotificationProvider>(context, listen: false);

      await authProvider.signInWithGoogle();

      if (mounted) {
        Fluttertoast.showToast(msg: 'Signed in with Google successfully');
        
        if (authProvider.isAuth) {
          await notificationProvider.fetchNotifications(authProvider.token);
        }

        // Redirect based on admin status, using the correct NavbarAdmin class
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return authProvider.isAdmin ? const NavbarAdmin() : const HomeScreen(); 
            },
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: _cleanErrorMessage(error.toString()),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isLoadingApple) return;
    setState(() => _isLoadingApple = true);

    try {
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // await authProvider.signInWithApple(); // Call the placeholder/actual method

      // Temporarily mock success/error since the method is a placeholder
      await Future.delayed(const Duration(milliseconds: 500)); 
      throw Exception('Apple Sign-in is currently disabled in this environment.');

    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: _cleanErrorMessage(error.toString()),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingApple = false);
    }
  }

  void _navigateToPhoneLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PhoneLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  Icons.health_and_safety,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Welcome to Menstrual Tracker',
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Sign in using your preferred method',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 48),

              // 1. Sign in with Google
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 300),
                child: _SocialAuthButton(
                  isLoading: _isLoadingGoogle,
                  text: 'Sign in with Google',
                  // Ensure this path is correct or replace with a network image/icon
                  icon: Image.asset('assets/images/google_logo.png', height: 24), 
                  onPressed: _handleGoogleSignIn,
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Sign in with Apple
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 400),
                child: _SocialAuthButton(
                  isLoading: _isLoadingApple,
                  text: 'Sign in with Apple',
                  icon: const Icon(Icons.apple, color: Colors.white, size: 28),
                  onPressed: _handleAppleSignIn,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // 3. Divider
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: textTheme.bodySmall),
                    ),
                    Expanded(
                      child: Divider(
                        color: colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Sign in with Phone
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 600),
                child: ElevatedButton.icon(
                  onPressed: _navigateToPhoneLogin,
                  icon: const Icon(Icons.phone_android, size: 24),
                  label: Text(
                    'Sign in with Phone Number',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 5. Placeholder for Forgot Password (kept for old accounts/admin password reset flow)
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 700),
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/forgotpassword', 
                  ),
                  child: Text(
                    'Using old password or need to reset?',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget for consistent social auth buttons
class _SocialAuthButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final Widget icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _SocialAuthButton({
    required this.isLoading,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: foregroundColor,
                strokeWidth: 2,
              ),
            )
          : icon,
      label: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        side: BorderSide(
          color: foregroundColor.withOpacity(0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }
}