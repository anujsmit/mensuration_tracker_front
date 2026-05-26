// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/screens/auth/login_screen.dart';
import 'package:mensurationhealthapp/screens/auth/verify_email_screen.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();

    _emailController.dispose();

    _passwordController.dispose();

    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ==========================================
  // SIGNUP
  // ==========================================

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar(
        'Please accept terms & conditions',
        Colors.orange,
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
      );

      if (!mounted) return;

      _showSnackBar(
        'Account created successfully',
        Colors.green,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(
            email: _emailController.text.trim(),
          ),
        ),
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
          child: Form(
            key: _formKey,
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

                const SizedBox(height: 10),

                // ==================================
                // LOGO
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
                      Icons.favorite,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================
                // TITLE
                // ==================================

                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Start tracking your health journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 40),

                // ==================================
                // FULL NAME
                // ==================================

                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter full name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================
                // EMAIL
                // ==================================

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================
                // PASSWORD
                // ==================================

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }

                    if (value.length < 6) {
                      return 'Minimum 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================
                // CONFIRM PASSWORD
                // ==================================

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }

                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ==================================
                // TERMS
                // ==================================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(
                                text: 'I agree to the ',
                              ),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: ' and ',
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ==================================
                // SIGNUP BUTTON
                // ==================================

                SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
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
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================
                // LOGIN LINK
                // ==================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 6,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
