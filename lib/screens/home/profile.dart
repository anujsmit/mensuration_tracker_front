import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/profile_provider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure context is available before provider calls
    Future.microtask(_loadData);
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    // Only fetch if authenticated
    if (authProvider.isAuth && authProvider.token != null) {
      // The profile provider fetches all necessary profile data, including username
      profileProvider.fetchProfile(authProvider.userId!, authProvider.token!);
    }
  }

  bool _isProfileComplete(Map<String, dynamic>? profile) {
    if (profile == null) return false;
    // Check for essential health profile fields
    return profile['age'] != null &&
        profile['weight'] != null &&
        profile['height'] != null &&
        profile['cycle_length'] != null &&
        profile['last_period_date'] != null;
  }

  // MODIFIED: This widget now accepts both providers to correctly display data.
  Widget _buildProfileHeader(
    ProfileProvider profileProvider,
    AuthProvider authProvider,
  ) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.surface.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ZoomIn(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 50,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                if (!_isProfileComplete(profileProvider.profile))
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.username ?? 'user',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              authProvider.email ?? 'No email provided',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (!_isProfileComplete(profileProvider.profile))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Complete your profile for better insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon) {
    final isEmpty = value.isEmpty || value == 'Not set';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          Text(
            isEmpty ? 'Not set' : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isEmpty
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.edit, color: Colors.white),
      onPressed: () {
        final profileProvider = context.read<ProfileProvider>();
        final authProvider = context.read<AuthProvider>();

        if (authProvider.userId != null && authProvider.token != null) {
          showDialog(
            context: context,
            builder: (context) => _EditProfileDialog(
              profileData: profileProvider.profile ?? {},
              userId: authProvider.userId!,
              token: authProvider.token!,
            ),
          ).then((_) => _loadData());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (profileProvider.isLoading && profileProvider.profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isProfileComplete = _isProfileComplete(profileProvider.profile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<AuthProvider>().logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80), // Padding for FAB
          child: Column(
            children: [
              const SizedBox(height: 16),
              // MODIFIED: Pass both providers to the header widget
              _buildProfileHeader(profileProvider, authProvider),
              const SizedBox(height: 8),

              if (!isProfileComplete) _buildCompleteProfileBanner(),

              _buildProfileSection('Account Information', [
                _buildProfileItem(
                  'User ID',
                  authProvider.userId ?? 'N/A',
                  Icons.person_outline,
                ),
                _buildProfileItem(
                  'Status',
                  authProvider.isAuth ? 'Active' : 'Inactive',
                  Icons.power_settings_new,
                ),
                _buildProfileItem(
                  'Account Type',
                  authProvider.isAdmin ? 'Admin' : 'Standard User',
                  Icons.admin_panel_settings_outlined,
                ),
              ]),
              if (profileProvider.profile != null)
                _buildProfileSection('Health Information', [
                  _buildProfileItem(
                    'Age',
                    profileProvider.profile!['age']?.toString() ?? '',
                    Icons.cake_outlined,
                  ),
                  _buildProfileItem(
                    'Weight',
                    profileProvider.profile!['weight'] != null
                        ? '${profileProvider.profile!['weight']} kg'
                        : '',
                    Icons.fitness_center_outlined,
                  ),
                  _buildProfileItem(
                    'Height',
                    profileProvider.profile!['height'] != null
                        ? '${profileProvider.profile!['height']} cm'
                        : '',
                    Icons.height_outlined,
                  ),
                  _buildProfileItem(
                    'Cycle Length',
                    profileProvider.profile!['cycle_length'] != null
                        ? '${profileProvider.profile!['cycle_length']} days'
                        : '',
                    Icons.sync_outlined,
                  ),
                  _buildProfileItem(
                    'Last Period Date',
                    _formatDate(profileProvider.profile!['last_period_date']),
                    Icons.calendar_today_outlined,
                  ),
                  _buildProfileItem(
                    'Age at Menarche',
                    profileProvider.profile!['age_at_menarche'] != null
                        ? '${profileProvider.profile!['age_at_menarche']} years'
                        : '',
                    Icons.child_care_outlined,
                  ),
                  _buildProfileItem(
                    'Flow Regularity',
                    profileProvider.profile!['flow_regularity']?.toString() ??
                        '',
                    Icons.water_drop_outlined,
                  ),
                  _buildProfileItem(
                    'Bleeding Duration',
                    profileProvider.profile!['bleeding_duration'] != null
                        ? '${profileProvider.profile!['bleeding_duration']} days'
                        : '',
                    Icons.timer_outlined,
                  ),
                  _buildProfileItem(
                    'Flow Amount',
                    profileProvider.profile!['flow_amount']?.toString() ?? '',
                    Icons.opacity_outlined,
                  ),
                  _buildProfileItem(
                    'Period Interval',
                    profileProvider.profile!['period_interval'] != null
                        ? '${profileProvider.profile!['period_interval']} days'
                        : '',
                    Icons.schedule_outlined,
                  ),
                ]),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildEditButton(),
    );
  }

  Widget _buildCompleteProfileBanner() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Profile Incomplete',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your health profile to get personalized insights and predictions.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onErrorContainer.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  final profileProvider = context.read<ProfileProvider>();
                  final authProvider = context.read<AuthProvider>();

                  showDialog(
                    context: context,
                    builder: (context) => _EditProfileDialog(
                      profileData: profileProvider.profile ?? {},
                      userId: authProvider.userId!,
                      token: authProvider.token!,
                    ),
                  ).then((_) => _loadData());
                },
                child: Text(
                  'Complete Profile',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Not set';
    try {
      if (date is String) {
        final parsedDate = DateTime.tryParse(date);
        if (parsedDate != null) {
          return DateFormat('MMM dd, yyyy').format(parsedDate);
        }
      }
      return date.toString();
    } catch (e) {
      return 'Invalid date';
    }
  }
}

// The _EditProfileDialog remains unchanged as it already receives the necessary data.
class _EditProfileDialog extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final String userId;
  final String token;

  const _EditProfileDialog({
    required this.profileData,
    required this.userId,
    required this.token,
  });

  @override
  State<_EditProfileDialog> createState() => __EditProfileDialogState();
}

class __EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _cycleLengthController;
  late final TextEditingController _lastPeriodDateController;
  late final TextEditingController _ageAtMenarcheController;
  late final TextEditingController _bleedingDurationController;
  late final TextEditingController _periodIntervalController;
  late String? _flowRegularity;
  late String? _flowAmount;

  final List<String> _flowRegularityOptions = [
    'regular',
    'usually_regular',
    'usually_irregular',
    'always_irregular',
  ];
  final List<String> _flowAmountOptions = ['Light', 'Moderate', 'Heavy'];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _ageController = TextEditingController(
      text: widget.profileData['age']?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.profileData['weight']?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.profileData['height']?.toString() ?? '',
    );
    _cycleLengthController = TextEditingController(
      text: widget.profileData['cycle_length']?.toString() ?? '',
    );
    _lastPeriodDateController = TextEditingController(
      text: widget.profileData['last_period_date']?.toString() ?? '',
    );
    _ageAtMenarcheController = TextEditingController(
      text: widget.profileData['age_at_menarche']?.toString() ?? '',
    );
    _bleedingDurationController = TextEditingController(
      text: widget.profileData['bleeding_duration']?.toString() ?? '',
    );
    _periodIntervalController = TextEditingController(
      text: widget.profileData['period_interval']?.toString() ?? '28',
    );

    _flowRegularity =
        widget.profileData['flow_regularity'] != null &&
            _flowRegularityOptions.contains(
              widget.profileData['flow_regularity'],
            )
        ? widget.profileData['flow_regularity']
        : null;
    _flowAmount =
        widget.profileData['flow_amount'] != null &&
            _flowAmountOptions.contains(widget.profileData['flow_amount'])
        ? widget.profileData['flow_amount']
        : null;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _cycleLengthController.dispose();
    _lastPeriodDateController.dispose();
    _ageAtMenarcheController.dispose();
    _bleedingDurationController.dispose();
    _periodIntervalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider = context.read<ProfileProvider>();

    final profile = {
      'age': int.tryParse(_ageController.text),
      'weight': _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      'height': _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text)
          : null,
      'cycleLength': _cycleLengthController.text.isNotEmpty
          ? int.tryParse(_cycleLengthController.text)
          : null,
      'lastPeriodDate': _lastPeriodDateController.text.isNotEmpty
          ? _lastPeriodDateController.text
          : null,
      'ageAtMenarche': _ageAtMenarcheController.text.isNotEmpty
          ? int.tryParse(_ageAtMenarcheController.text)
          : null,
      'flowRegularity': _flowRegularity,
      'bleedingDuration': _bleedingDurationController.text.isNotEmpty
          ? int.tryParse(_bleedingDurationController.text)
          : null,
      'flowAmount': _flowAmount,
      'periodInterval': int.tryParse(_periodIntervalController.text) ?? 28,
    };

    try {
      final success = await profileProvider.saveProfile(profile, widget.token);
      if (success) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${profileProvider.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Age is required';
    final num = int.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > 120) return 'Age must be 0-120';
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > 500) return 'Weight must be 0-500 kg';
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) return null;
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > 300) return 'Height must be 0-300 cm';
    return null;
  }

  String? _validateCycleLength(String? value) {
    if (value == null || value.isEmpty) return null;
    final num = int.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > 365) return 'Cycle length must be 0-365 days';
    return null;
  }

  String? _validateAgeAtMenarche(String? value) {
    if (value == null || value.isEmpty) return null;
    final num = int.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > 30) return 'Age at menarche must be 0-30';
    return null;
  }

  String? _validateBleedingDuration(String? value) {
    if (value == null || value.isEmpty) return null;
    final num = int.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > 30) return 'Bleeding duration must be 0-30 days';
    return null;
  }

  String? _validatePeriodInterval(String? value) {
    if (value == null || value.isEmpty) return 'Period interval is required';
    final num = int.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > 365) return 'Period interval must be 0-365 days';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardColor,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 450,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Edit Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          child: _buildNumberField(
                            _ageController,
                            'Age',
                            Icons.cake,
                            _validateAge,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 750),
                          child: _buildNumberField(
                            _weightController,
                            'Weight (kg)',
                            Icons.fitness_center,
                            _validateWeight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: _buildNumberField(
                            _heightController,
                            'Height (cm)',
                            Icons.height,
                            _validateHeight,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 850),
                          child: _buildNumberField(
                            _cycleLengthController,
                            'Cycle Length (days)',
                            Icons.repeat,
                            _validateCycleLength,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 900),
                          child: _buildDateField(),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 950),
                          child: _buildNumberField(
                            _ageAtMenarcheController,
                            'Age at Menarche',
                            Icons.child_care,
                            _validateAgeAtMenarche,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: _buildDropdownField(
                            value: _flowRegularity,
                            options: _flowRegularityOptions,
                            label: 'Flow Regularity',
                            icon: Icons.water_drop,
                            onChanged: (value) =>
                                setState(() => _flowRegularity = value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1050),
                          child: _buildNumberField(
                            _bleedingDurationController,
                            'Bleeding Duration (days)',
                            Icons.timer,
                            _validateBleedingDuration,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1100),
                          child: _buildDropdownField(
                            value: _flowAmount,
                            options: _flowAmountOptions,
                            label: 'Flow Amount',
                            icon: Icons.opacity,
                            onChanged: (value) =>
                                setState(() => _flowAmount = value),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1150),
                          child: _buildNumberField(
                            _periodIntervalController,
                            'Period Interval (days)',
                            Icons.schedule,
                            _validatePeriodInterval,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _saveProfile,
                      child: Text(
                        'Save',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: Theme.of(context).inputDecorationTheme.border,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
      ),
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _lastPeriodDateController,
      decoration: InputDecoration(
        labelText: 'Last Period Date',
        prefixIcon: Icon(
          Icons.calendar_today,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: Theme.of(context).inputDecorationTheme.border,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          _lastPeriodDateController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(date);
        }
      },
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> options,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: Theme.of(context).inputDecorationTheme.border,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
      ),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }
}
