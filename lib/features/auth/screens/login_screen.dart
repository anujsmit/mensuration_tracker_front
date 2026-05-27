// lib/screens/auth/login.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';


import 'package:mensurationhealthapp/features/auth/screens/signup_screen.dart';
import 'package:mensurationhealthapp/features/auth/screens/forgotpassword.dart';
import 'package:mensurationhealthapp/features/auth/screens/phone_login_screen.dart';

import 'package:mensurationhealthapp/main_navigation_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;

  bool _obscurePassword = true;

  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // EMAIL LOGIN
  // ==========================================

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider =
          Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      await authProvider
          .signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Login successful',
          ),

          backgroundColor:
              Colors.green.shade600,

          behavior:
              SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MainNavigationScreen(),
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e
                .toString()
                .replaceAll(
                    'Exception: ',
                    ''),
          ),

          backgroundColor:
              Colors.red.shade600,

          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(
            () => _isLoading = false);
      }
    }
  }

  // ==========================================
  // GOOGLE LOGIN
  // ==========================================

  Future<void>
      _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final authProvider =
          Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      await authProvider
          .signInWithGoogle();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'Google Sign-In Successful',
          ),

          backgroundColor:
              Colors.green.shade600,

          behavior:
              SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MainNavigationScreen(),
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e
                .toString()
                .replaceAll(
                    'Exception: ',
                    ''),
          ),

          backgroundColor:
              Colors.red.shade600,

          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(
            () => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryColor =
        theme.colorScheme.primary;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,

              children: [
                const SizedBox(
                    height: 40),

                // ==================================
                // LOGO
                // ==================================

                Center(
                  child: Container(
                    height: 110,
                    width: 110,

                    decoration:
                        BoxDecoration(
                      gradient:
                          LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor
                              .withOpacity(
                                  0.7),
                        ],
                      ),

                      shape:
                          BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: primaryColor
                              .withOpacity(
                                  0.3),

                          blurRadius: 20,

                          offset:
                              const Offset(
                                  0, 10),
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

                const SizedBox(
                    height: 30),

                Text(
                  "Welcome Back",

                  textAlign:
                      TextAlign.center,

                  style: theme
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Track • Predict • Thrive",

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                    height: 45),

                // ==================================
                // EMAIL
                // ==================================

                TextFormField(
                  controller:
                      _emailController,

                  keyboardType:
                      TextInputType
                          .emailAddress,

                  decoration:
                      InputDecoration(
                    hintText:
                        'Email Address',

                    prefixIcon:
                        const Icon(
                      Icons
                          .email_outlined,
                    ),

                    filled: true,

                    fillColor:
                        Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              18),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),

                  validator: (value) {
                    if (value ==
                            null ||
                        value
                            .isEmpty) {
                      return 'Please enter email';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                    height: 18),

                // ==================================
                // PASSWORD
                // ==================================

                TextFormField(
                  controller:
                      _passwordController,

                  obscureText:
                      _obscurePassword,

                  decoration:
                      InputDecoration(
                    hintText:
                        'Password',

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),
                    ),

                    filled: true,

                    fillColor:
                        Colors.white,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                              18),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),

                  validator: (value) {
                    if (value ==
                            null ||
                        value
                            .isEmpty) {
                      return 'Please enter password';
                    }

                    if (value.length <
                        6) {
                      return 'Minimum 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                    height: 12),

                // ==================================
                // REMEMBER + FORGOT
                // ==================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value:
                              _rememberMe,

                          onChanged:
                              (value) {
                            setState(() {
                              _rememberMe =
                                  value ??
                                      false;
                            });
                          },

                          activeColor:
                              primaryColor,
                        ),

                        const Text(
                            "Remember Me"),
                      ],
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ForgotPasswordScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        'Forgot Password?',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 18),

                // ==================================
                // LOGIN BUTTON
                // ==================================

                SizedBox(
                  height: 58,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleEmailLogin,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          primaryColor,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              color:
                                  Colors.white,
                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Text(
                            'LOGIN',

                            style:
                                TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                    height: 28),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors
                            .grey
                            .shade300,
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                      ),

                      child: Text(
                        'OR',

                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        color: Colors
                            .grey
                            .shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 28),

                // ==================================
                // GOOGLE BUTTON
                // ==================================

                SizedBox(
                  height: 56,

                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : _handleGoogleLogin,

                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 34,
                      color: Colors.red,
                    ),

                    label: const Text(
                      'Continue with Google',

                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    style:
                        OutlinedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.white,

                      side:
                          BorderSide(
                        color: Colors
                            .grey
                            .shade300,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 16),

                // ==================================
                // PHONE LOGIN
                // ==================================

                SizedBox(
                  height: 56,

                  child:
                      OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PhoneLoginScreen(),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.phone_android,
                    ),

                    label: const Text(
                      'Continue with Phone',
                    ),

                    style:
                        OutlinedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.white,

                      side:
                          BorderSide(
                        color: Colors
                            .grey
                            .shade300,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 35),

                // ==================================
                // SIGNUP
                // ==================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    Text(
                      "Don't have an account?",

                      style: TextStyle(
                        color: Colors
                            .grey
                            .shade700,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SignupScreen(),
                          ),
                        );
                      },

                      child: Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          left: 6,
                        ),

                        child: Text(
                          'Sign Up',

                          style:
                              TextStyle(
                            color:
                                primaryColor,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}