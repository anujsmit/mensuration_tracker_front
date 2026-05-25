// lib/screens/auth/forgot_password.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _resetToken;
  String? _userEmail;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  
  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.sendPasswordResetOTP(_emailController.text.trim());
      
      if (!mounted) return;
      
      setState(() {
        _otpSent = true;
        _userEmail = _emailController.text.trim();
        _isLoading = false;
      });
      
      _showSuccessSnackBar(response['message'] ?? 'OTP sent successfully');
      
      // Development mode - show OTP
      if (kDebugMode && response.containsKey('otp')) {
        _logOTPToConsole(response['otp'], _userEmail!);
        _showOTPDialog(response['otp']);
      }
      
      _startResendCooldown();
      
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(_getUserFriendlyMessage(e.toString()));
      }
    }
  }
  
  void _logOTPToConsole(String otp, String email) {
    print('═══════════════════════════════════════════════');
    print('🔐 PASSWORD RESET OTP (DEVELOPMENT MODE)');
    print('📧 Email: $email');
    print('🔢 OTP: $otp');
    print('⏰ Expires in: 10 minutes');
    print('═══════════════════════════════════════════════');
  }
  
  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      _showErrorSnackBar('Please enter OTP');
      return;
    }
    
    if (_otpController.text.length != 6) {
      _showErrorSnackBar('OTP must be 6 digits');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.verifyPasswordResetOTP(
        _userEmail!,
        _otpController.text.trim(),
      );
      
      if (!mounted) return;
      
      setState(() {
        _otpVerified = true;
        _resetToken = response['resetToken'];
        _isLoading = false;
      });
      
      _showSuccessSnackBar('OTP verified successfully');
      
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(_getUserFriendlyMessage(e.toString()));
      }
    }
  }
  
  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty) {
      _showErrorSnackBar('Please enter new password');
      return;
    }
    
    if (_newPasswordController.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPasswordWithToken(
        _resetToken!,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      _showSuccessSnackBar('Password reset successful!');
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
      
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(_getUserFriendlyMessage(e.toString()));
      }
    }
  }
  
  Future<void> _resendOTP() async {
    if (_resendCooldown > 0) {
      _showWarningSnackBar('Please wait ${_resendCooldown} seconds');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.resendPasswordResetOTP(_userEmail!);
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      _showSuccessSnackBar(response['message'] ?? 'OTP resent successfully');
      
      if (kDebugMode && response.containsKey('otp')) {
        _logOTPToConsole(response['otp'], _userEmail!);
        _showOTPDialog(response['otp']);
      }
      
      _startResendCooldown();
      
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(_getUserFriendlyMessage(e.toString()));
      }
    }
  }
  
  void _startResendCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = 60);
    
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showOTPDialog(String otp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.developer_mode, color: Colors.orange),
              SizedBox(width: 8),
              Text('Development Mode'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your OTP for testing is:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade100, Colors.blue.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  otp,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This dialog will not appear in production.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (kDebugMode) _otpController.text = otp;
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  String _getUserFriendlyMessage(String error) {
    if (error.contains('Invalid or expired OTP')) return 'Invalid or expired OTP. Please request a new one.';
    if (error.contains('Password must be at least 6 characters')) return 'Password must be at least 6 characters long.';
    if (error.contains('Passwords do not match')) return 'New password and confirmation do not match.';
    if (error.contains('network')) return 'Network error. Please check your connection.';
    if (error.contains('social login')) return 'This account uses Google/Phone sign-in. Please use that method.';
    return error;
  }
  
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts[0].length <= 3) return '***@${parts[1]}';
    return '${parts[0].substring(0, 3)}***@${parts[1]}';
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, primaryColor.withOpacity(0.7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock_reset, size: 48, color: primaryColor),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reset Password',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _otpSent ? 'Enter the OTP sent to your email' : 'Enter your email to receive OTP',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Step 1: Email
                      if (!_otpSent) ...[
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your email';
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _sendOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Send OTP', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                      
                      // Step 2: OTP
                      if (_otpSent && !_otpVerified) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'OTP sent to ${_maskEmail(_userEmail!)}',
                                  style: TextStyle(color: Colors.green.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: 'Enter 6-digit OTP',
                            prefixIcon: const Icon(Icons.security),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            helperText: 'Enter the 6-digit code sent to your email',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : _resendOTP,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _resendCooldown > 0
                                    ? Text('Resend (${_resendCooldown}s)')
                                    : const Text('Resend OTP'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _verifyOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Verify OTP'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Step 3: Reset Password
                      if (_otpVerified) ...[
                        const Icon(Icons.verified, size: 60, color: Colors.green),
                        const SizedBox(height: 16),
                        const Text('OTP Verified!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            helperText: 'Minimum 6 characters',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Reset Password', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Back to Login', style: TextStyle(color: primaryColor)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}