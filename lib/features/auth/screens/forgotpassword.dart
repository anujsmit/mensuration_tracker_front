// lib/screens/auth/forgotpassword.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ForgotPasswordScreen
    extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen>
      createState() =>
          _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<
        ForgotPasswordScreen> {
  final _emailController =
      TextEditingController();

  final _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;

  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ==========================================
  // SEND RESET EMAIL
  // ==========================================

  Future<void>
      _sendResetEmail() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider =
          Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      await authProvider
          .sendPasswordResetOTP(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _emailSent = true;
      });

      _showSnackBar(
        'Password reset email sent successfully',
        Colors.green,
      );

    } catch (e) {
      _showSnackBar(
        e
            .toString()
            .replaceAll(
                'Exception: ', ''),
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(
            () => _isLoading = false);
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
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: color,

        behavior:
            SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
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
                    height: 20),

                // ==================================
                // BACK BUTTON
                // ==================================

                Align(
                  alignment:
                      Alignment.centerLeft,

                  child: IconButton(
                    onPressed: () =>
                        Navigator.pop(
                            context),

                    icon: const Icon(
                      Icons
                          .arrow_back_ios_new_rounded,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 20),

                // ==================================
                // ICON
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
                      Icons.lock_reset,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 35),

                // ==================================
                // TITLE
                // ==================================

                Text(
                  _emailSent
                      ? 'Check Your Email'
                      : 'Forgot Password',

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

                const SizedBox(height: 12),

                Text(
                  _emailSent
                      ? 'We sent a password reset link to your email address.'
                      : 'Enter your email address and we will send you a password reset link.',

                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                    height: 45),

                // ==================================
                // SUCCESS BOX
                // ==================================

                if (_emailSent) ...[
                  Container(
                    padding:
                        const EdgeInsets
                            .all(20),

                    decoration:
                        BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                              22),

                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                                  0.03),

                          blurRadius: 10,

                          offset:
                              const Offset(
                                  0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .mark_email_read_outlined,

                          size: 70,

                          color: Colors
                              .green
                              .shade600,
                        ),

                        const SizedBox(
                            height: 20),

                        Text(
                          _emailController.text
                              .trim(),

                          textAlign:
                              TextAlign.center,

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                            height: 14),

                        Text(
                          'Open your email inbox and click the password reset link.',

                          textAlign:
                              TextAlign.center,

                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 35),

                  SizedBox(
                    height: 56,

                    child:
                        ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                            context);
                      },

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

                      child: const Text(
                        'BACK TO LOGIN',

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
                ],

                // ==================================
                // EMAIL FORM
                // ==================================

                if (!_emailSent) ...[
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
                      height: 30),

                  // ==================================
                  // SEND BUTTON
                  // ==================================

                  SizedBox(
                    height: 58,

                    child:
                        ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _sendResetEmail,

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
                                color: Colors
                                    .white,
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Text(
                              'SEND RESET LINK',

                              style:
                                  TextStyle(
                                fontSize:
                                    16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                      height: 35),

                  // ==================================
                  // INFO BOX
                  // ==================================

                  Container(
                    padding:
                        const EdgeInsets
                            .all(18),

                    decoration:
                        BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                              20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                                  0.03),

                          blurRadius: 10,

                          offset:
                              const Offset(
                                  0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .security_outlined,

                          color:
                              primaryColor,

                          size: 35,
                        ),

                        const SizedBox(
                            height: 12),

                        Text(
                          'Secure Password Reset',

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: Colors
                                .grey
                                .shade800,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        Text(
                          'Password reset is securely handled using Supabase authentication.',

                          textAlign:
                              TextAlign.center,

                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(
                    height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}