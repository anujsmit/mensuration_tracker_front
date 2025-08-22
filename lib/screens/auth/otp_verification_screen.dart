import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mensurationhealthapp/screens/auth/login_screen.dart';
import 'package:mensurationhealthapp/screens/home/profile.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/notification_provider.dart';
import 'package:mensurationhealthapp/screens/home/homescreen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isLogin;
  final String? userId;

  const OtpVerificationScreen({
    Key? key,
    required this.email,
    required this.isLogin,
    this.userId,
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

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      Fluttertoast.showToast(msg: 'Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<UserNotificationProvider>(context, listen: false);
      final response = await authProvider.verifyOtp(widget.email, otp);

      if (!mounted) return;

      Fluttertoast.showToast(msg: 'OTP verified successfully');

      // Load notifications after successful verification
      if (authProvider.isAuth) {
        await notificationProvider.fetchNotifications(authProvider.token);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            if (widget.isLogin) {
              return const HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
        (Route<dynamic> route) => false,
      );
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resendOtp(widget.email);
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'New OTP sent to your email',
        backgroundColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onPrimary,
      );
    } catch (error) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Failed to resend OTP. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Theme.of(context).colorScheme.error,
        textColor: Theme.of(context).colorScheme.onError,
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _handleOtpInput(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (index == 5 && value.isNotEmpty) {
      FocusScope.of(context).unfocus();
      _verifyOtp();
    }
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
                  'Enter the OTP sent to ${widget.email}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
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
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
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
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                delay: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed: _isResending ? null : _resendOtp,
                  child: _isResending
                      ? SizedBox(
                          width: 24,
                          height: 24,
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: colorScheme.surface.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
          onChanged: (value) => _handleOtpInput(index, value),
        ),
      ),
    );
  }
}