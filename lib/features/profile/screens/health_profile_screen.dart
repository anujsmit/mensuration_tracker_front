import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/health_profile_provider.dart';
import '../../../core/theme/app_theme.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ageController;
  late TextEditingController _cycleController;
  late TextEditingController _bleedingController;
  DateTime? _lastPeriodDate;
  String _flowRegularity = 'regular';
  
  // Additional health metrics
  String _symptomSeverity = 'moderate';
  String _activityLevel = 'moderate';
  bool _hasMedicalConditions = false;
  String _medicalConditions = '';
  bool _isOnMedication = false;
  String _medications = '';

  @override
  void initState() {
    super.initState();
    final profile = context.read<HealthProfileProvider>().healthProfile;
    
    _ageController = TextEditingController(text: profile?.age?.toString() ?? '');
    _cycleController = TextEditingController(text: profile?.cycleLength?.toString() ?? '');
    _bleedingController = TextEditingController(text: profile?.bleedingDuration?.toString() ?? '');
    _lastPeriodDate = profile?.lastPeriodDate;
    _flowRegularity = profile?.flowRegularity ?? 'regular';
  }

  @override
  void dispose() {
    _ageController.dispose();
    _cycleController.dispose();
    _bleedingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HealthProfileProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Health Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: theme.primaryColor),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Accurate health information helps us provide better predictions and insights',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Section Header
                _buildSectionHeader(
                  context: context,
                  title: 'Basic Information',
                  icon: Icons.person_outline,
                ),
                
                const SizedBox(height: 20),
                
                // Age Field
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake_outlined),
                    helperText: 'Your current age',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final age = int.tryParse(value);
                    if (age != null && (age < 12 || age > 100)) {
                      return 'Please enter a valid age (12-100)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Section Header
                _buildSectionHeader(
                  context: context,
                  title: 'Menstrual Cycle Details',
                  icon: Icons.favorite_outline,
                ),
                
                const SizedBox(height: 20),
                
                // Cycle Length Field
                TextFormField(
                  controller: _cycleController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cycle Length (days)',
                    prefixIcon: Icon(Icons.calendar_today),
                    helperText: 'Typical cycle length is between 21-35 days',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your cycle length';
                    }
                    final cycle = int.tryParse(value);
                    if (cycle == null) {
                      return 'Please enter a valid number';
                    }
                    if (cycle < 21 || cycle > 45) {
                      return 'Please enter a valid cycle length (21-45 days)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Bleeding Duration Field
                TextFormField(
                  controller: _bleedingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bleeding Duration (days)',
                    prefixIcon: Icon(Icons.water_drop_outlined),
                    helperText: 'Typical duration is between 3-7 days',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final duration = int.tryParse(value);
                    if (duration != null && (duration < 1 || duration > 14)) {
                      return 'Please enter a valid duration (1-14 days)';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Flow Regularity Dropdown
                DropdownButtonFormField<String>(
                  value: _flowRegularity,
                  decoration: const InputDecoration(
                    labelText: 'Flow Regularity',
                    prefixIcon: Icon(Icons.timeline),
                    helperText: 'How regular is your menstrual cycle?',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'regular', 
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 18, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Regular - Consistent cycle every month'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'usually_regular', 
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Usually Regular - Minor variations'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'usually_irregular', 
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, size: 18, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Usually Irregular - Noticeable variations'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'always_irregular', 
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Always Irregular - Unpredictable cycle'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _flowRegularity = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Last Period Date Picker
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.calendar_month, color: theme.primaryColor),
                    title: Text(
                      _lastPeriodDate == null
                          ? 'Select Last Period Date'
                          : 'Last Period: ${DateFormat('MMM d, yyyy').format(_lastPeriodDate!)}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: _lastPeriodDate != null
                        ? Text(
                            _getDaysSinceLastPeriod(),
                            style: theme.textTheme.bodySmall,
                          )
                        : null,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _pickDate,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Section Header
                _buildSectionHeader(
                  context: context,
                  title: 'Additional Health Information',
                  icon: Icons.health_and_safety_outlined,
                ),
                
                const SizedBox(height: 20),
                
                // Symptom Severity Dropdown
                DropdownButtonFormField<String>(
                  value: _symptomSeverity,
                  decoration: const InputDecoration(
                    labelText: 'Symptom Severity',
                    prefixIcon: Icon(Icons.medical_information),
                    helperText: 'How severe are your menstrual symptoms?',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mild', child: Text('Mild - Minor discomfort')),
                    DropdownMenuItem(value: 'moderate', child: Text('Moderate - Manageable pain')),
                    DropdownMenuItem(value: 'severe', child: Text('Severe - Debilitating pain')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _symptomSeverity = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Activity Level Dropdown
                DropdownButtonFormField<String>(
                  value: _activityLevel,
                  decoration: const InputDecoration(
                    labelText: 'Activity Level',
                    prefixIcon: Icon(Icons.directions_run),
                    helperText: 'Your regular physical activity level',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'sedentary', child: Text('Sedentary - Little to no exercise')),
                    DropdownMenuItem(value: 'light', child: Text('Light - Exercise 1-3 days/week')),
                    DropdownMenuItem(value: 'moderate', child: Text('Moderate - Exercise 3-5 days/week')),
                    DropdownMenuItem(value: 'active', child: Text('Active - Daily exercise')),
                    DropdownMenuItem(value: 'very_active', child: Text('Very Active - Intense daily exercise')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _activityLevel = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Medical Conditions Switch
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: SwitchListTile(
                    title: const Text('Have any medical conditions?'),
                    subtitle: const Text('PCOS, Endometriosis, Thyroid issues, etc.'),
                    value: _hasMedicalConditions,
                    onChanged: (value) {
                      setState(() {
                        _hasMedicalConditions = value;
                        if (!value) {
                          _medicalConditions = '';
                        }
                      });
                    },
                    activeColor: theme.primaryColor,
                  ),
                ),
                
                if (_hasMedicalConditions) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(text: _medicalConditions),
                    decoration: const InputDecoration(
                      labelText: 'Please specify medical conditions',
                      prefixIcon: Icon(Icons.medical_services),
                      helperText: 'Separate multiple conditions with commas',
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      _medicalConditions = value;
                    },
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Medication Switch
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  child: SwitchListTile(
                    title: const Text('Currently on any medication?'),
                    subtitle: const Text('Birth control, pain relievers, etc.'),
                    value: _isOnMedication,
                    onChanged: (value) {
                      setState(() {
                        _isOnMedication = value;
                        if (!value) {
                          _medications = '';
                        }
                      });
                    },
                    activeColor: theme.primaryColor,
                  ),
                ),
                
                if (_isOnMedication) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: TextEditingController(text: _medications),
                    decoration: const InputDecoration(
                      labelText: 'Please specify medications',
                      prefixIcon: Icon(Icons.medication),
                      helperText: 'Separate multiple medications with commas',
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      _medications = value;
                    },
                  ),
                ],
                
                const SizedBox(height: 40),
                
                // Save Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor.withOpacity(0.05),
                        theme.colorScheme.secondary.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save Health Profile',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your information is securely stored and used only for predictions',
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
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
    );
  }

  // ======================================================
  // HELPER METHODS
  // ======================================================

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getDaysSinceLastPeriod() {
    if (_lastPeriodDate == null) return '';
    
    final now = DateTime.now();
    final daysSince = now.difference(_lastPeriodDate!).inDays;
    
    if (daysSince == 0) return 'Started today';
    if (daysSince == 1) return 'Started yesterday';
    return '$daysSince days ago';
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

  Future<void> _showHelpDialog() async {
    final theme = Theme.of(context);
    
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline, color: theme.primaryColor),
              const SizedBox(width: 8),
              const Text('Why this information?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                'Cycle Length',
                'Helps predict your next period and fertile window accurately',
              ),
              const Divider(),
              _buildHelpItem(
                'Bleeding Duration',
                'Customizes predictions based on your typical period length',
              ),
              const Divider(),
              _buildHelpItem(
                'Flow Regularity',
                'Adjusts prediction confidence based on your cycle consistency',
              ),
              const Divider(),
              _buildHelpItem(
                'Last Period Date',
                'Starting point for all cycle predictions',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

Future<void> _save() async {
  // Validate form
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // Check for required fields
  if (_cycleController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your cycle length'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
    return;
  }

  if (_lastPeriodDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select your last period date'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
    return;
  }

  final provider = context.read<HealthProfileProvider>();
  
  // Parse values - cycleLength and lastPeriodDate are required
  final age = _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null;
  final cycleLength = int.parse(_cycleController.text);
  final bleedingDuration = _bleedingController.text.isNotEmpty ? int.parse(_bleedingController.text) : null;
  
  // Save health profile with nullable parameters
  final success = await provider.saveHealthProfile(
    age: age,                    // Can be null
    cycleLength: cycleLength,     // Required
    lastPeriodDate: _lastPeriodDate!, // Required
    bleedingDuration: bleedingDuration, // Can be null
    flowRegularity: _flowRegularity, // Required
  );

  if (!mounted) return;

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Health profile updated successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Delay navigation to show snackbar
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pop(context);
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Failed to update health profile'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}}