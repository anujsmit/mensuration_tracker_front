// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 100,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Streamlined Sign Up',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'We now support sign-up and login exclusively through Google, Apple, and Phone Number (OTP) for enhanced security and convenience.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue to Sign In / Sign Up',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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