// lib/screens/auth/otp_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:mensurationhealthapp/screens/home/admin/navbar_admin.dart'; 
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
// FIX: Alias to resolve the name collision with firebase_auth_platform_interface.
import 'package:mensurationhealthapp/providers/auth_provider.dart' as AppAuth; 
import 'package:mensurationhealthapp/providers/notification_provider.dart';
import 'package:mensurationhealthapp/screens/home/homescreen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String identifier; // Phone number
  final String verificationId; // Firebase verification ID
  final int? resendToken;

  const OtpVerificationScreen({
    Key? key,
    required this.identifier,
    required this.verificationId,
    this.resendToken,
  }) : super(key: key); 

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      Fluttertoast.showToast(msg: 'Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // FIX: Use the alias (AppAuth) for the custom AuthProvider
      final authProvider = Provider.of<AppAuth.AuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<UserNotificationProvider>(context, listen: false);
      
      // 1. Create a PhoneAuthCredential using the Firebase verificationId and the entered OTP
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      
      // 2. Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
          throw Exception("Firebase sign-in failed after OTP verification.");
      }

      // 3. Get the Firebase ID Token (Returns String?)
      final String? idToken = await user.getIdToken();
      
      // FIX: Null safety check added here to handle String?
      if (idToken == null) {
          throw Exception("Failed to retrieve Firebase ID Token after successful login.");
      }

      // 4. Exchange the Firebase ID Token for the custom backend JWT
      await authProvider.verifyPhoneToken(idToken);

      if (!mounted) return;

      Fluttertoast.showToast(msg: 'Sign in successful');

      // Load notifications after successful verification/login
      if (authProvider.isAuth) {
        await notificationProvider.fetchNotifications(authProvider.token);
      }

      // Navigate to home/admin
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            return authProvider.isAdmin ? const NavbarAdmin() : const HomeScreen(); 
          },
        ),
        (Route<dynamic> route) => false,
      );

    } on FirebaseAuthException catch (e) {
        if (mounted) {
            Fluttertoast.showToast(
                msg: e.code == 'invalid-verification-code' 
                    ? 'Invalid OTP. Please try again.' 
                    : e.message ?? 'Verification failed.',
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.onError,
            );
        }
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: error.toString().replaceAll('Exception: ', ''),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.identifier,
        forceResendingToken: widget.resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification on Android devices
          if (mounted) {
            _handleAutoVerification(credential);
          }
        }, 
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            Fluttertoast.showToast(
              msg: 'Resend failed: ${e.message ?? "Unknown error"}',
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Theme.of(context).colorScheme.error,
              textColor: Theme.of(context).colorScheme.onError,
            );
            setState(() => _isResending = false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            Fluttertoast.showToast(
              msg: 'New OTP sent to ${widget.identifier}',
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
            );
            
            // Update the verification ID for the new OTP
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // This would typically require updating the parent widget's state
              // For simplicity, we'll just show a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter the new OTP sent to your phone'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            });
            
            setState(() => _isResending = false);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Optional: handle timeout
          if (mounted) {
            setState(() => _isResending = false);
          }
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to resend OTP: ${error.toString()}',
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
        );
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _handleAutoVerification(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null && mounted) {
        final authProvider = Provider.of<AppAuth.AuthProvider>(context, listen: false);
        final notificationProvider = Provider.of<UserNotificationProvider>(context, listen: false);
        
        final String? idToken = await user.getIdToken();
        if (idToken != null) {
          await authProvider.verifyPhoneToken(idToken);
          
          if (authProvider.isAuth) {
            await notificationProvider.fetchNotifications(authProvider.token);
          }
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) {
                return authProvider.isAdmin ? const NavbarAdmin() : const HomeScreen(); 
              },
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Auto-verification failed: ${error.toString()}',
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
        );
      }
    }
  }

  void _handleOtpInput(int index, String value) {
    // Only allow digits
    if (value.isNotEmpty && !RegExp(r'^\d$').hasMatch(value)) {
      _otpControllers[index].clear();
      return;
    }
    
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when last digit is entered
    if (index == 5 && value.isNotEmpty) {
      FocusScope.of(context).unfocus();
      
      // Wait a moment for the UI to update, then verify
      Future.delayed(const Duration(milliseconds: 300), () {
        _verifyOtp();
      });
    }
  }

  void _clearOtpFields() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  void initState() {
    super.initState();
    
    // Auto-focus the first OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes[0].canRequestFocus) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: FadeInLeft(
          duration: const Duration(milliseconds: 500),
          child: const Text('OTP Verification'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearOtpFields,
            tooltip: 'Clear all fields',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Icon(
                  Icons.verified_user,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'OTP Verification',
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Enter the 6-digit code sent to your phone number',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: Text(
                  widget.identifier,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, _buildOtpField),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 100),
                child: TextButton(
                  onPressed: _clearOtpFields,
                  child: Text(
                    'Clear OTP',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
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
                            'VERIFY OTP',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive the code? ',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: _isResending ? null : _resendOtp,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: _isResending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 400),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Change Phone Number',
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

  Widget _buildOtpField(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ElasticIn(
      duration: Duration(milliseconds: 500 + (index * 100)),
      child: SizedBox(
        width: 48,
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          maxLength: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) => _handleOtpInput(index, value),
          onTap: () {
            // Clear the field when tapped (for easier editing)
            if (_otpControllers[index].text.isNotEmpty) {
              _otpControllers[index].clear();
            }
          },
        ),
      ),
    );
  }
}