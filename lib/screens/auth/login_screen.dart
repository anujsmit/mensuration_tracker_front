// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mensurationhealthapp/screens/auth/forgetpassword.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart' as app_auth;
import 'package:mensurationhealthapp/providers/notification_provider.dart';
import 'package:mensurationhealthapp/screens/home/admin/navbar_admin.dart';
import 'package:mensurationhealthapp/screens/home/homescreen.dart';
import 'package:mensurationhealthapp/screens/auth/signup_screen.dart';
import 'package:mensurationhealthapp/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _useEmailLogin = true; // true = email, false = phone
  String _fullPhoneNumber = '';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);
      final notificationProvider =
          Provider.of<UserNotificationProvider>(context, listen: false);

      if (_useEmailLogin) {
        await authProvider.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          rememberMe: _rememberMe,
        );
      } else {
        await authProvider.signInWithPhone(
          phoneNumber: _fullPhoneNumber.isNotEmpty
              ? _fullPhoneNumber
              : _phoneController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Login successful',
        backgroundColor: Theme.of(context).colorScheme.primary,
        textColor: Colors.white,
      );

      if (authProvider.isAuth) {
        await notificationProvider.fetchNotifications(authProvider.token);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              authProvider.isAdmin ? const NavbarAdmin() : const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      String message = error.toString().replaceAll('Exception: ', '');

      if (message.contains('Invalid')) {
        message = 'Invalid email/phone or password';
      } else if (message.contains('not found')) {
        message = 'No account found with this email/phone';
      } else if (message.contains('network')) {
        message = 'Network error. Please check your connection.';
      }

      Fluttertoast.showToast(
        msg: message,
        backgroundColor: Theme.of(context).colorScheme.error,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor =
        isDark ? theme.scaffoldBackgroundColor : Colors.white;
    final surfaceColor = theme.colorScheme.surface;
    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Animated Logo
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      height: 100,
                      width: 100,
                      alignment: Alignment.center,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: theme.colorScheme.onPrimary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App name
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Mensuration Health',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Track • Predict • Thrive',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Login method toggle
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? surfaceColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _useEmailLogin = true;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _useEmailLogin
                                      ? (isDark ? cardColor : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: _useEmailLogin
                                      ? [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black26
                                                : Colors.grey.shade300,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      color: _useEmailLogin
                                          ? primaryColor
                                          : secondaryTextColor,
                                      fontWeight: _useEmailLogin
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _useEmailLogin = false;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_useEmailLogin
                                      ? (isDark ? cardColor : Colors.white)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: !_useEmailLogin
                                      ? [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black26
                                                : Colors.grey.shade300,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'Phone',
                                    style: TextStyle(
                                      color: !_useEmailLogin
                                          ? primaryColor
                                          : secondaryTextColor,
                                      fontWeight: !_useEmailLogin
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email or Phone field based on selection
                  if (_useEmailLogin)
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: secondaryTextColor),
                          filled: true,
                          fillColor:
                              isDark ? surfaceColor : Colors.grey.shade50,
                        ).applyDefaults(theme.inputDecorationTheme),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                    )
                  else
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 300),
                      child: IntlPhoneField(
                        controller: _phoneController,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: theme.textTheme.bodyMedium,
                          filled: true,
                          fillColor:
                              isDark ? surfaceColor : Colors.grey.shade50,
                        ).applyDefaults(theme.inputDecorationTheme),
                        initialCountryCode: 'US',
                        onChanged: (phone) {
                          _fullPhoneNumber = phone.completeNumber;
                        },
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (phone.number.length < 10) {
                            return 'Invalid phone number';
                          }
                          return null;
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Password field
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: theme.textTheme.bodyMedium,
                        prefixIcon:
                            Icon(Icons.lock_outline, color: secondaryTextColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: secondaryTextColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: isDark ? surfaceColor : Colors.grey.shade50,
                      ).applyDefaults(theme.inputDecorationTheme),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Remember me and forgot password row
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: primaryColor,
                              checkColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Text(
                              'Remember me',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        // In your login screen, add this button to navigate to forgot password
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login button
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 600),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        minimumSize: const WidgetStatePropertyAll(
                            Size(double.infinity, 50)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _useEmailLogin
                                  ? 'Log In with Email'
                                  : 'Log In with Phone',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OR divider
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 700),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: secondaryTextColor?.withOpacity(0.3))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                                color: secondaryTextColor?.withOpacity(0.3))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Google sign in button
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 800),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: 'Google Sign-In coming soon',
                          backgroundColor: theme.colorScheme.secondary,
                          textColor: theme.colorScheme.onSecondary,
                        );
                      },
                      icon: Icon(Icons.g_mobiledata,
                          color: Colors.red.shade400, size: 24),
                      label: Text(
                        'Continue with Google',
                        style: theme.textTheme.bodyLarge,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: secondaryTextColor?.withOpacity(0.3) ??
                              Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Sign up link
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 900),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: _navigateToSignup,
                          child: Text(
                            'Sign up',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
