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
    Future.microtask(_loadData);
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (authProvider.isAuth && authProvider.token != null) {
      profileProvider.fetchProfile(authProvider.userId!, authProvider.token!);
    }
  }

  bool _isProfileComplete(Map<String, dynamic>? profile) {
    if (profile == null) return false;

    final requiredFields = [
      'age',
      'weight',
      'height',
      'cycle_length',
      'last_period_date'
    ];
    final optionalFields = [
      'age_at_menarche',
      'flow_regularity',
      'bleeding_duration',
      'flow_amount'
    ];

    for (var field in requiredFields) {
      if (profile[field] == null) return false;
    }

    final filledOptional =
        optionalFields.where((field) => profile[field] != null).length;

    return filledOptional >= 2;
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (profileProvider.isLoading && profileProvider.profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Loading your profile...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final isProfileComplete = _isProfileComplete(profileProvider.profile);
    final displayUsername =
        authProvider.username ?? profileProvider.username ?? 'User';
    final displayEmail =
        authProvider.email ?? profileProvider.email ?? 'user@example.com';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (!isProfileComplete)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayUsername,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!isProfileComplete)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Profile Incomplete',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content Area
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Complete Profile Banner (if incomplete)
                if (!isProfileComplete)
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.health_and_safety_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Complete Your Health Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your health information to get personalized menstrual cycle insights and predictions.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                final profileProvider =
                                    context.read<ProfileProvider>();
                                final authProvider =
                                    context.read<AuthProvider>();

                                showDialog(
                                  context: context,
                                  builder: (context) => _EditProfileDialog(
                                    profileData:
                                        profileProvider.profile ?? {},
                                    userId: authProvider.userId!,
                                    token: authProvider.token!,
                                  ),
                                ).then((_) => _loadData());
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.edit_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Complete Now',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Health Information Section
                if (profileProvider.profile != null)
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.medical_services_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Health Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Health Info Cards
                          ..._buildHealthInfoCards(profileProvider.profile!),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // Edit Profile Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
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
      ),

      // Logout Button in Bottom Navigation
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
            foregroundColor: Theme.of(context).colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
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
                      context.read<AuthProvider>().signOut();
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildHealthInfoCards(Map<String, dynamic> profile) {
    final healthInfo = [
      _buildHealthCard(
        title: 'Age',
        value: profile['age']?.toString() ?? 'Not set',
        icon: Icons.cake_rounded,
        color: Colors.blue,
      ),
      _buildHealthCard(
        title: 'Weight & Height',
        value:
            '${profile['weight'] != null ? '${profile['weight']} kg' : 'Not set'} • ${profile['height'] != null ? '${profile['height']} cm' : 'Not set'}',
        icon: Icons.monitor_weight_rounded,
        color: Colors.green,
      ),
      _buildHealthCard(
        title: 'Cycle Information',
        value: profile['cycle_length'] != null
            ? '${profile['cycle_length']} days'
            : 'Not set',
        icon: Icons.repeat_rounded,
        color: Colors.purple,
      ),
      _buildHealthCard(
        title: 'Last Period',
        value: _formatDate(profile['last_period_date']),
        icon: Icons.calendar_month_rounded,
        color: Colors.orange,
      ),
      _buildHealthCard(
        title: 'Age at Menarche',
        value: profile['age_at_menarche'] != null
            ? '${profile['age_at_menarche']} years'
            : 'Not set',
        icon: Icons.child_friendly_rounded,
        color: Colors.pink,
      ),
      _buildHealthCard(
        title: 'Flow Details',
        value: '${profile['flow_amount'] ?? 'Not set'} • ${profile['flow_regularity']?.toString().replaceAll('_', ' ') ?? 'Not set'}',
        icon: Icons.water_drop_rounded,
        color: Colors.teal,
      ),
      _buildHealthCard(
        title: 'Bleeding Duration',
        value: profile['bleeding_duration'] != null
            ? '${profile['bleeding_duration']} days'
            : 'Not set',
        icon: Icons.timer_rounded,
        color: Colors.red,
      ),
      _buildHealthCard(
        title: 'Period Interval',
        value: profile['period_interval'] != null
            ? '${profile['period_interval']} days'
            : 'Not set',
        icon: Icons.schedule_rounded,
        color: Colors.indigo,
      ),
    ];

    return List.generate(
      healthInfo.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: healthInfo[index],
      ),
    );
  }

  Widget _buildHealthCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: value == 'Not set'
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
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

    _flowRegularity = widget.profileData['flow_regularity'] != null &&
            _flowRegularityOptions.contains(
              widget.profileData['flow_regularity'],
            )
        ? widget.profileData['flow_regularity']
        : null;
    _flowAmount = widget.profileData['flow_amount'] != null &&
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
            backgroundColor: Colors.green,
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
                Text(
                  'Edit Health Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your health information',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildNumberField(
                          _ageController,
                          'Age',
                          Icons.cake_rounded,
                          _validateAge,
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          _weightController,
                          'Weight (kg)',
                          Icons.monitor_weight_rounded,
                          _validateWeight,
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          _heightController,
                          'Height (cm)',
                          Icons.height_rounded,
                          _validateHeight,
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          _cycleLengthController,
                          'Cycle Length (days)',
                          Icons.repeat_rounded,
                          _validateCycleLength,
                        ),
                        const SizedBox(height: 12),
                        _buildDateField(),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          _ageAtMenarcheController,
                          'Age at Menarche',
                          Icons.child_friendly_rounded,
                          _validateAgeAtMenarche,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          value: _flowRegularity,
                          options: _flowRegularityOptions,
                          label: 'Flow Regularity',
                          icon: Icons.water_drop_rounded,
                          onChanged: (value) =>
                              setState(() => _flowRegularity = value),
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          _bleedingDurationController,
                          'Bleeding Duration (days)',
                          Icons.timer_rounded,
                          _validateBleedingDuration,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          value: _flowAmount,
                          options: _flowAmountOptions,
                          label: 'Flow Amount',
                          icon: Icons.opacity_rounded,
                          onChanged: (value) =>
                              setState(() => _flowAmount = value),
                        ),
                        const SizedBox(height: 12),
                        _buildNumberField(
                          _periodIntervalController,
                          'Period Interval (days)',
                          Icons.schedule_rounded,
                          _validatePeriodInterval,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saveProfile,
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
          Icons.calendar_month_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          _lastPeriodDateController.text = DateFormat('yyyy-MM-dd').format(date);
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(
                option.replaceAll('_', ' '),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }
}