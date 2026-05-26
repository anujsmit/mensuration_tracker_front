// lib/screens/home/profile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/profile_provider.dart';

import 'package:mensurationhealthapp/screens/auth/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  final supabase =
      Supabase.instance.client;

  final _formKey =
      GlobalKey<FormState>();

  final _fullNameController =
      TextEditingController();

  final _ageController =
      TextEditingController();

  final _weightController =
      TextEditingController();

  final _heightController =
      TextEditingController();

  final _cycleLengthController =
      TextEditingController();

  final _flowAmountController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();

    _ageController.dispose();

    _weightController.dispose();

    _heightController.dispose();

    _cycleLengthController.dispose();

    _flowAmountController.dispose();

    super.dispose();
  }

  // ==========================================
  // LOAD PROFILE
  // ==========================================

  Future<void> _loadProfile() async {
    try {
      final profileProvider =
          Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      final user =
          supabase.auth.currentUser;

      if (user == null) return;

      await profileProvider
          .fetchProfile(
        user.id,
        '',
      );

      final profile =
          profileProvider.profile;

      if (profile != null) {
        _fullNameController.text =
            profile['full_name'] ??
                '';

        _ageController.text =
            profile['age']
                    ?.toString() ??
                '';

        _weightController.text =
            profile['weight']
                    ?.toString() ??
                '';

        _heightController.text =
            profile['height']
                    ?.toString() ??
                '';

        _cycleLengthController
            .text = profile[
                    'cycle_length']
                ?.toString() ??
            '';

        _flowAmountController.text =
            profile['flow_amount'] ??
                '';
      }

      setState(() {});

    } catch (e) {
      debugPrint(
        'Profile load error: $e',
      );
    }
  }

  // ==========================================
  // SAVE PROFILE
  // ==========================================

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileProvider =
          Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      final success =
          await profileProvider
              .saveProfile({
        'full_name':
            _fullNameController.text
                .trim(),

        'age': int.tryParse(
          _ageController.text,
        ),

        'weight':
            double.tryParse(
          _weightController.text,
        ),

        'height':
            double.tryParse(
          _heightController.text,
        ),

        'cycleLength':
            int.tryParse(
          _cycleLengthController
              .text,
        ),

        'flowAmount':
            _flowAmountController
                .text
                .trim(),
      }, '');

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: const Text(
              'Profile updated successfully',
            ),

            backgroundColor:
                Colors.green,

            behavior:
                SnackBarBehavior
                    .floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              profileProvider.error,
            ),

            backgroundColor:
                Colors.red,

            behavior:
                SnackBarBehavior
                    .floating,
          ),
        );
      }

    } catch (e) {
      debugPrint(
        'Save profile error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> _logout() async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await authProvider.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryColor =
        theme.colorScheme.primary;

    final user =
        supabase.auth.currentUser;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        elevation: 0,

        backgroundColor:
            Colors.transparent,

        title: const Text(
          'Profile',
        ),

        actions: [
          IconButton(
            onPressed: _logout,

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              // ==========================
              // PROFILE HEADER
              // ==========================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(
                        28),

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

                  borderRadius:
                      BorderRadius.circular(
                          28),
                ),

                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,

                      backgroundColor:
                          Colors.white,

                      child: Text(
                        (_fullNameController
                                    .text
                                    .isNotEmpty
                                ? _fullNameController
                                    .text[0]
                                : 'U')
                            .toUpperCase(),

                        style:
                            TextStyle(
                          fontSize: 36,
                          fontWeight:
                              FontWeight
                                  .bold,

                          color:
                              primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 18),

                    Text(
                      _fullNameController
                              .text
                              .isNotEmpty
                          ? _fullNameController
                              .text
                          : 'User',

                      style:
                          const TextStyle(
                        color:
                            Colors.white,

                        fontSize: 26,

                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                        height: 8),

                    Text(
                      user?.email ??
                          '',

                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 28),

              // ==========================
              // FORM CARD
              // ==========================

              Container(
                padding:
                    const EdgeInsets.all(
                        24),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                          28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                              0.04),

                      blurRadius: 10,

                      offset:
                          const Offset(
                              0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    _buildTextField(
                      controller:
                          _fullNameController,

                      label:
                          'Full Name',

                      icon:
                          Icons.person,
                    ),

                    _buildTextField(
                      controller:
                          _ageController,

                      label: 'Age',

                      icon:
                          Icons.cake,

                      keyboardType:
                          TextInputType
                              .number,
                    ),

                    _buildTextField(
                      controller:
                          _weightController,

                      label:
                          'Weight (kg)',

                      icon:
                          Icons.monitor_weight,

                      keyboardType:
                          TextInputType
                              .number,
                    ),

                    _buildTextField(
                      controller:
                          _heightController,

                      label:
                          'Height (cm)',

                      icon:
                          Icons.height,

                      keyboardType:
                          TextInputType
                              .number,
                    ),

                    _buildTextField(
                      controller:
                          _cycleLengthController,

                      label:
                          'Cycle Length',

                      icon:
                          Icons.calendar_month,

                      keyboardType:
                          TextInputType
                              .number,
                    ),

                    _buildTextField(
                      controller:
                          _flowAmountController,

                      label:
                          'Flow Amount',

                      icon:
                          Icons.water_drop,
                    ),

                    const SizedBox(
                        height: 30),

                    SizedBox(
                      width:
                          double.infinity,

                      height: 58,

                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _saveProfile,

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
                                width:
                                    24,
                                height:
                                    24,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Text(
                                'SAVE PROFILE',

                                style:
                                    TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
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
    );
  }

  // ==========================================
  // TEXT FIELD
  // ==========================================

  Widget _buildTextField({
    required TextEditingController
        controller,

    required String label,

    required IconData icon,

    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),

      child: TextFormField(
        controller: controller,

        keyboardType:
            keyboardType,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon:
              Icon(icon),

          filled: true,

          fillColor:
              const Color(
                  0xFFF7F8FA),

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
          if (value == null ||
              value.isEmpty) {
            return 'Please enter $label';
          }

          return null;
        },
      ),
    );
  }
}