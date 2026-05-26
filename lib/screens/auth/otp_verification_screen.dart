// lib/screens/auth/otp_verification_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mensurationhealthapp/providers/auth_provider.dart';

import 'package:mensurationhealthapp/screens/home/main_navigation_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();

  bool _isLoading = false;

  int _resendCooldown = 60;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ==========================================
  // TIMER
  // ==========================================

  void _startCooldown() {
    _timer?.cancel();

    setState(() {
      _resendCooldown = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_resendCooldown > 0) {
          setState(() {
            _resendCooldown--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  // ==========================================
  // VERIFY OTP
  // ==========================================

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.replaceAll(' ', '').trim();

    if (otp.isEmpty || otp.length < 6) {
      _showSnackBar(
        'Please enter valid OTP',
        Colors.red,
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      await authProvider.verifyPhoneOtp(
        phoneNumber: widget.phoneNumber,
        otp: otp,
      );

      if (!mounted) return;

      _showSnackBar(
        'Phone verified successfully',
        Colors.green,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      _showSnackBar(
        e.toString().replaceAll('Exception: ', ''),
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==========================================
  // RESEND OTP
  // ==========================================

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) {
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      await authProvider.sendPhoneOtp(
        widget.phoneNumber,
      );

      _showSnackBar(
        'OTP resent successfully',
        Colors.green,
      );

      _startCooldown();
    } catch (e) {
      _showSnackBar(
        e.toString().replaceAll('Exception: ', ''),
        Colors.red,
      );
    }
  }

  // ==========================================
  // SNACKBAR
  // ==========================================

  void _showSnackBar(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // ==================================
              // BACK BUTTON
              // ==================================

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================
              // ICON
              // ==================================

              Center(
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ==================================
              // TITLE
              // ==================================

              Text(
                'OTP Verification',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter the 6-digit OTP sent to\n${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 45),

              // ==================================
              // OTP FIELD
              // ==================================

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 10,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================
              // VERIFY BUTTON
              // ==================================

              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'VERIFY OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // ==================================
              // RESEND
              // ==================================

              Center(
                child: TextButton(
                  onPressed: _resendCooldown == 0 ? _resendOtp : null,
                  child: Text(
                    _resendCooldown > 0
                        ? 'Resend OTP in ${_resendCooldown}s'
                        : 'Resend OTP',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ==================================
              // INFO BOX
              // ==================================

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: primaryColor,
                      size: 35,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Secure Verification',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your OTP is securely verified using Supabase authentication.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
