import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../providers/health_profile_provider.dart';
import 'package:mensurationhealthapp/core/theme/app_theme.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cycleController = TextEditingController();
  final _bleedingController = TextEditingController();
  DateTime? _lastPeriodDate;
  String _flowRegularity = 'regular';
  int _currentStep = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    setState(() => _isLoading = true);
    
    final profileProvider = context.read<ProfileProvider>();
    final healthProvider = context.read<HealthProfileProvider>();

    await Future.wait([
      profileProvider.fetchProfile(),
      healthProvider.fetchHealthProfile(),
    ]);

    final profile = profileProvider.profile;
    final health = healthProvider.healthProfile;

    setState(() {
      // Pre-fill name if exists
      if (profile?.fullName != null && profile!.fullName!.isNotEmpty) {
        _nameController.text = profile.fullName!;
      }

      // Pre-fill age if exists
      if (health?.age != null) {
        _ageController.text = health!.age.toString();
      }

      // Pre-fill cycle length if exists
      if (health?.cycleLength != null) {
        _cycleController.text = health!.cycleLength.toString();
      }

      // Pre-fill bleeding duration if exists
      if (health?.bleedingDuration != null) {
        _bleedingController.text = health!.bleedingDuration.toString();
      }

      // Pre-fill last period date if exists
      if (health?.lastPeriodDate != null) {
        _lastPeriodDate = health!.lastPeriodDate;
      }

      // Pre-fill flow regularity if exists
      if (health?.flowRegularity != null) {
        _flowRegularity = health!.flowRegularity!;
      }

      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cycleController.dispose();
    _bleedingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final healthProvider = context.watch<HealthProfileProvider>();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Personal', _currentStep >= 0),
                  Expanded(child: _buildStepLine(_currentStep > 0)),
                  _buildStepIndicator(1, 'Health', _currentStep >= 1),
                  Expanded(child: _buildStepLine(_currentStep > 1)),
                  _buildStepIndicator(2, 'Cycle', _currentStep >= 2),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _getStepContent(theme),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _currentStep--),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Back'),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (_currentStep < 2) 
                                  ? () => _nextStep()
                                  : (profileProvider.isLoading || healthProvider.isLoading) ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _currentStep < 2
                                  ? const Text('Continue', style: TextStyle(fontSize: 16))
                                  : (profileProvider.isLoading || healthProvider.isLoading)
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text('Complete', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? theme.primaryColor : theme.dividerColor,
            boxShadow: isActive ? [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : [],
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive ? theme.primaryColor : theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    final theme = Theme.of(context);
    return Container(
      height: 2,
      color: isActive ? theme.primaryColor : theme.dividerColor,
    );
  }

  Widget _getStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep(theme);
      case 1:
        return _buildHealthInfoStep(theme);
      default:
        return _buildCycleInfoStep(theme);
    }
  }

  Widget _buildPersonalInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.colorScheme.secondary],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Let\'s get to know you',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us your name to personalize your experience',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline, color: theme.primaryColor),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Age',
            prefixIcon: Icon(Icons.cake_outlined, color: theme.primaryColor),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            final age = int.tryParse(value);
            if (age == null || age < 12 || age > 100) {
              return 'Please enter a valid age (12-100)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildHealthInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite, size: 40, color: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Health Information',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us understand your unique health profile',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        DropdownButtonFormField<String>(
          value: _flowRegularity,
          decoration: InputDecoration(
            labelText: 'Flow Regularity',
            prefixIcon: Icon(Icons.timeline, color: theme.primaryColor),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'regular', child: Text('Regular')),
            DropdownMenuItem(value: 'usually_regular', child: Text('Usually Regular')),
            DropdownMenuItem(value: 'usually_irregular', child: Text('Usually Irregular')),
            DropdownMenuItem(value: 'always_irregular', child: Text('Always Irregular')),
          ],
          onChanged: (value) {
            setState(() {
              _flowRegularity = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _bleedingController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Bleeding Duration (days)',
            prefixIcon: Icon(Icons.water_drop_outlined, color: theme.primaryColor),
            helperText: 'How long does your period typically last?',
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter bleeding duration';
            }
            final duration = int.tryParse(value);
            if (duration == null || duration < 1 || duration > 14) {
              return 'Please enter a valid duration (1-14 days)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCycleInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_month, size: 40, color: theme.primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Cycle Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your cycle accurately for better predictions',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _cycleController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Cycle Length (days)',
            prefixIcon: Icon(Icons.calendar_today, color: theme.primaryColor),
            helperText: 'Number of days between periods',
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your cycle length';
            }
            final cycle = int.tryParse(value);
            if (cycle == null || cycle < 21 || cycle > 45) {
              return 'Please enter a valid cycle length (21-45 days)';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _lastPeriodDate == null ? theme.colorScheme.error.withOpacity(0.3) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: theme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _lastPeriodDate == null
                        ? 'Select Last Period Date'
                        : 'Last Period: ${_formatDate(_lastPeriodDate!)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ],
            ),
          ),
        ),
        if (_lastPeriodDate == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Required for accurate predictions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.isEmpty || _ageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_bleedingController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in bleeding duration')),
        );
        return;
      }
    }
    setState(() {
      _currentStep++;
    });
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.primaryColor,
              onPrimary: Colors.white,
              surface: theme.cardColor,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_lastPeriodDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your last period date')),
      );
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    final healthProvider = context.read<HealthProfileProvider>();

    // Update profile with name
    await profileProvider.updateProfile(
      fullName: _nameController.text.trim(),
    );

    // Save health profile
    await healthProvider.saveHealthProfile(
      age: int.parse(_ageController.text),
      cycleLength: int.parse(_cycleController.text),
      lastPeriodDate: _lastPeriodDate!,
      bleedingDuration: int.parse(_bleedingController.text),
      flowRegularity: _flowRegularity,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile completed successfully! 🎉'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}