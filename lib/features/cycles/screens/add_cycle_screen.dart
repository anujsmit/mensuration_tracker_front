import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/pads_service.dart';
import '../models/pads_tracking.dart';
import '../providers/cycle_provider.dart';
import '../../profile/providers/health_profile_provider.dart';

class AddCycleScreen extends StatefulWidget {
  const AddCycleScreen({super.key});

  @override
  State<AddCycleScreen> createState() => _AddCycleScreenState();
}

class _AddCycleScreenState extends State<AddCycleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Cycle Information
  DateTime? _selectedDate;
  int _cycleLength = 28;
  int _bleedingDuration = 5;
  String _flowRegularity = 'regular';
  final TextEditingController _notesController = TextEditingController();
  
  // Product Usage (Optional)
  int _padsUsed = 0;
  int _tamponsUsed = 0;
  int _linersUsed = 0;
  String? _flowIntensity;
  bool _trackProducts = false; // Make product tracking optional
  
  bool _isLoading = false;
  
  final PadsService _padsService = PadsService();
  
  final List<String> _flowOptions = ['light', 'medium', 'heavy', 'very_heavy'];
  final Map<String, String> _flowLabels = {
    'light': '🟢 Light',
    'medium': '🟡 Medium',
    'heavy': '🟠 Heavy',
    'very_heavy': '🔴 Very Heavy',
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCycle() async {
    if (_selectedDate == null) {
      _showSnackBar('Please select a date', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Save cycle data to CycleProvider
      final cycleProvider = context.read<CycleProvider>();
      
      // Calculate end date based on bleeding duration
      final endDate = _selectedDate!.add(Duration(days: _bleedingDuration - 1));
      
      final success = await cycleProvider.createCycle(
        startDate: _selectedDate!.toIso8601String().split('T')[0],
        endDate: endDate.toIso8601String().split('T')[0],
        cycleLength: _cycleLength,
        periodLength: _bleedingDuration,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (!success) {
        throw Exception(cycleProvider.error ?? 'Failed to save cycle');
      }

      _showSnackBar('✅ Cycle tracked successfully!', Colors.green);

      // 2. Save product usage (optional - don't fail if this fails)
      if (_trackProducts && (_padsUsed > 0 || _tamponsUsed > 0 || _linersUsed > 0 || _flowIntensity != null)) {
        try {
          final padsTracking = PadsTracking(
            date: _selectedDate!,
            padsUsed: _padsUsed,
            tamponsUsed: _tamponsUsed,
            linersUsed: _linersUsed,
            flowIntensity: _flowIntensity,
          );
          await _padsService.savePadsTracking(padsTracking);
          _showSnackBar('📊 Product usage saved!', Colors.green);
        } catch (e) {
          // Don't fail the whole operation - cycle was saved successfully
          print('Pads tracking error (non-critical): $e');
          _showSnackBar(
            '⚠️ Cycle saved! But product usage will sync later.',
            Colors.orange,
            duration: const Duration(seconds: 3),
          );
        }
      }

      // 3. Save health profile data (optional - don't fail if this fails)
      try {
        final healthProvider = context.read<HealthProfileProvider>();
        final existingProfile = healthProvider.healthProfile;
        
        if (existingProfile == null) {
          await healthProvider.saveHealthProfile(
            age: null,
            cycleLength: _cycleLength,
            lastPeriodDate: _selectedDate!,
            bleedingDuration: _bleedingDuration,
            flowRegularity: _flowRegularity,
          );
        } else {
          await healthProvider.updateHealthProfile(
            cycleLength: _cycleLength,
            lastPeriodDate: _selectedDate,
            bleedingDuration: _bleedingDuration,
            flowRegularity: _flowRegularity,
          );
        }
      } catch (e) {
        print('Health profile error (non-critical): $e');
      }

      if (mounted) {
        Navigator.pop(context);
      }
      
    } catch (e) {
      print('Error saving cycle: $e');
      _showSnackBar('❌ Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _showSnackBar(String message, Color color, {Duration duration = const Duration(seconds: 2)}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Track Cycle'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selection
                    _buildSectionHeader('Period Start Date', Icons.calendar_today),
                    const SizedBox(height: 12),
                    _buildDatePicker(),
                    
                    const SizedBox(height: 24),
                    
                    // Cycle Details
                    _buildSectionHeader('Cycle Details', Icons.favorite),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            title: 'Cycle Length',
                            value: _cycleLength,
                            unit: 'days',
                            minValue: 21,
                            maxValue: 45,
                            onChanged: (value) => setState(() => _cycleLength = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            title: 'Bleeding Duration',
                            value: _bleedingDuration,
                            unit: 'days',
                            minValue: 1,
                            maxValue: 10,
                            onChanged: (value) => setState(() => _bleedingDuration = value),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Flow Regularity
                    DropdownButtonFormField<String>(
                      value: _flowRegularity,
                      decoration: const InputDecoration(
                        labelText: 'Flow Regularity',
                        prefixIcon: Icon(Icons.timeline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'regular', child: Text('Regular')),
                        DropdownMenuItem(value: 'usually_regular', child: Text('Usually Regular')),
                        DropdownMenuItem(value: 'usually_irregular', child: Text('Usually Irregular')),
                        DropdownMenuItem(value: 'always_irregular', child: Text('Always Irregular')),
                      ],
                      onChanged: (value) => setState(() => _flowRegularity = value!),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Product Usage Section (Optional)
                    _buildSectionHeader('Product Usage (Optional)', Icons.inventory),
                    const SizedBox(height: 8),
                    
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: SwitchListTile(
                        title: const Text('Track product usage'),
                        subtitle: const Text('Add details about pads, tampons, and liners'),
                        value: _trackProducts,
                        onChanged: (value) {
                          setState(() => _trackProducts = value);
                        },
                        activeColor: const Color(0xFF6C63FF),
                      ),
                    ),
                    
                    if (_trackProducts) ...[
                      const SizedBox(height: 16),
                      
                      _buildCounterCard(
                        title: 'Pads Used',
                        icon: Icons.water_drop,
                        color: Colors.pink,
                        value: _padsUsed,
                        onIncrement: () => setState(() => _padsUsed++),
                        onDecrement: () {
                          if (_padsUsed > 0) setState(() => _padsUsed--);
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildCounterCard(
                        title: 'Tampons Used',
                        icon: Icons.water,
                        color: Colors.purple,
                        value: _tamponsUsed,
                        onIncrement: () => setState(() => _tamponsUsed++),
                        onDecrement: () {
                          if (_tamponsUsed > 0) setState(() => _tamponsUsed--);
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildCounterCard(
                        title: 'Liners Used',
                        icon: Icons.water_drop_outlined,
                        color: Colors.teal,
                        value: _linersUsed,
                        onIncrement: () => setState(() => _linersUsed++),
                        onDecrement: () {
                          if (_linersUsed > 0) setState(() => _linersUsed--);
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Flow Intensity
                      Text(
                        'Flow Intensity',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: _flowOptions.map((intensity) {
                          final isSelected = _flowIntensity == intensity;
                          return FilterChip(
                            label: Text(_flowLabels[intensity]!),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _flowIntensity = selected ? intensity : null;
                              });
                            },
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF6C63FF),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveCycle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Save Cycle Data',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_month, color: Color(0xFF6C63FF)),
        title: Text(
          _selectedDate != null
              ? DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!)
              : 'Select Date',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            initialDate: _selectedDate ?? DateTime.now(),
          );
          if (date != null && mounted) {
            setState(() => _selectedDate = date);
          }
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String title,
    required int value,
    required String unit,
    required int minValue,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: () => onChanged(value > minValue ? value - 1 : minValue),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                '$value $unit',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => onChanged(value < maxValue ? value + 1 : maxValue),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterCard({
    required String title,
    required IconData icon,
    required Color color,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 24),
                onPressed: onDecrement,
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 30,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 24),
                onPressed: onIncrement,
                color: Colors.green,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}