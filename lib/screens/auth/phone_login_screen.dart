// anujsmit/mensuration_tracker_front/mensuration_tracker_front-f791c10d8517a5f857299bbd66976c42835a8ba8a/lib/screens/auth/phone_login_screen.dart (MODIFIED)

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:animate_do/animate_do.dart';
import 'package:mensurationhealthapp/screens/auth/otp_verification_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullPhoneNumber = '';
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _verifyPhoneNumber() async { // Renamed from _requestOtp
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        // Handles OTP auto-retrieval
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This block is for auto-verification on Android; skip OTP screen.
          // In a real application, you'd complete the sign-in and then call the backend token exchange here.
          // For simplicity in this demo, we handle the manual code sent case.
        },
        // Handles failure
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            Fluttertoast.showToast(
              msg: e.message ?? 'Phone verification failed.',
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Theme.of(context).colorScheme.error,
              textColor: Theme.of(context).colorScheme.onError,
            );
            setState(() => _isLoading = false);
          }
        },
        // Handles code being sent; navigate to OTP screen
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            Fluttertoast.showToast(
              msg: 'OTP sent to $_fullPhoneNumber',
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => OtpVerificationScreen(
                  identifier: _fullPhoneNumber,
                  verificationId: verificationId,
                  resendToken: resendToken,
                ),
              ),
            );
            setState(() => _isLoading = false);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Optional: handle timeout
        },
      );
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: error.toString().replaceAll('Exception: ', ''),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
        );
      }
      if (mounted) setState(() => _isLoading = false);
    } 
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in with Phone'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    Icons.phone_android,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Phone Number Verification',
                    style: textTheme.headlineMedium?.copyWith(
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
                    'Enter your phone number to receive a one-time password (OTP)',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 48),
                FadeInLeft(
                  duration: const Duration(milliseconds: 700),
                  child: IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                      counterText: '', // Remove the character counter
                    ),
                    initialCountryCode: 'US',
                    keyboardType: TextInputType.phone,
                    onChanged: (phone) {
                      _fullPhoneNumber = phone.completeNumber;
                    },
                    validator: (value) {
                      if (value == null || value.number.isEmpty) { 
                        return 'Please enter your phone number';
                      }
                      if (_fullPhoneNumber.length < 10) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  delay: const Duration(milliseconds: 450),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'SEND OTP',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  delay: const Duration(milliseconds: 500),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Go back to other sign-in options',
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
      ),
    );
  }
}