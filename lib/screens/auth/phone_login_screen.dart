// lib/screens/auth/phone_login_screen.dart

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/screens/auth/otp_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() =>
      _PhoneLoginScreenState();
}

class _PhoneLoginScreenState
    extends State<PhoneLoginScreen> {
  final _formKey =
      GlobalKey<FormState>();

  String _phoneNumber = '';

  bool _isLoading = false;

  // ==========================================
  // SEND OTP
  // ==========================================

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_phoneNumber.isEmpty) {
      _showSnackBar(
        'Please enter phone number',
        Colors.red,
      );

      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider =
          Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      await authProvider.sendPhoneOtp(
        _phoneNumber,
      );

      if (!mounted) return;

      _showSnackBar(
        'OTP sent successfully',
        Colors.green,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpVerificationScreen(
            phoneNumber:
                _phoneNumber,
          ),
        ),
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
                      Icons.phone_android,
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
                  'Phone Login',

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

                const SizedBox(height: 10),

                Text(
                  'Enter your phone number to receive OTP',

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
                // PHONE FIELD
                // ==================================

                IntlPhoneField(
                  decoration:
                      InputDecoration(
                    hintText:
                        'Phone Number',

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

                  initialCountryCode:
                      'NP',

                  disableLengthCheck:
                      false,

                  dropdownIconPosition:
                      IconPosition.trailing,

                  onChanged: (phone) {
                    _phoneNumber =
                        phone.completeNumber;
                  },

                  validator: (value) {
                    if (value == null ||
                        value.number
                            .isEmpty) {
                      return 'Please enter phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                    height: 30),

                // ==================================
                // SEND OTP BUTTON
                // ==================================

                SizedBox(
                  height: 58,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _sendOtp,

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
                            'SEND OTP',

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
                    height: 35),

                // ==================================
                // INFO BOX
                // ==================================

                Container(
                  padding:
                      const EdgeInsets.all(
                          18),

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
                            .verified_user_outlined,

                        color:
                            primaryColor,

                        size: 35,
                      ),

                      const SizedBox(
                          height: 12),

                      Text(
                        'Secure Authentication',

                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.grey
                                  .shade800,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                          height: 8),

                      Text(
                        'We use secure OTP verification powered by Supabase authentication.',

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
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
                    height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}