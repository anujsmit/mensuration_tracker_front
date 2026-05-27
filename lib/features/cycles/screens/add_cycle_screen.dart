// ======================================================
// FILE:
// lib/features/cycles/screens/add_cycle_screen.dart
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cycle_provider.dart';

class AddCycleScreen
    extends StatefulWidget {

  const AddCycleScreen({
    super.key,
  });

  @override
  State<AddCycleScreen>
      createState() =>
          _AddCycleScreenState();

}

class _AddCycleScreenState
    extends State<AddCycleScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _notesController =
      TextEditingController();

  DateTime? _startDate;

  DateTime? _endDate;

  @override
  void dispose() {

    _notesController.dispose();

    super.dispose();

  }

  // ======================================================
  // PICK DATE
  // ======================================================

  Future<void> _pickDate({
    required bool isStart,
  }) async {

    final picked =
        await showDatePicker(

      context: context,

      initialDate:
          DateTime.now(),

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime(2100),

    );

    if (picked != null) {

      setState(() {

        if (isStart) {

          _startDate = picked;

        } else {

          _endDate = picked;

        }

      });

    }

  }

  // ======================================================
  // SAVE
  // ======================================================

  Future<void> _saveCycle()
      async {

    if (_startDate == null) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content:
              Text('Select start date'),
        ),

      );

      return;

    }

    final provider =
        Provider.of<CycleProvider>(
      context,
      listen: false,
    );

    final success =
        await provider.createCycle(

      startDate:
          _startDate!
              .toIso8601String(),

      endDate:
          _endDate
              ?.toIso8601String(),

      notes:
          _notesController.text,

    );

    if (!mounted) return;

    if (success) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content:
              Text('Cycle added'),
        ),

      );

      Navigator.pop(context);

    }

  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final provider =
        Provider.of<CycleProvider>(
      context,
    );

    return Scaffold(

      appBar: AppBar(
        title:
            const Text('Add Cycle'),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              // ==================================
              // START DATE
              // ==================================

              ListTile(

                title: Text(

                  _startDate == null
                      ? 'Select Start Date'
                      : _startDate!
                          .toString(),

                ),

                trailing:
                    const Icon(
                  Icons.calendar_month,
                ),

                onTap: () =>
                    _pickDate(
                  isStart: true,
                ),

              ),

              // ==================================
              // END DATE
              // ==================================

              ListTile(

                title: Text(

                  _endDate == null
                      ? 'Select End Date'
                      : _endDate!
                          .toString(),

                ),

                trailing:
                    const Icon(
                  Icons.calendar_today,
                ),

                onTap: () =>
                    _pickDate(
                  isStart: false,
                ),

              ),

              // ==================================
              // NOTES
              // ==================================

              TextFormField(

                controller:
                    _notesController,

                maxLines: 4,

                decoration:
                    const InputDecoration(
                  hintText: 'Notes',
                ),

              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================
              // BUTTON
              // ==================================

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  onPressed:
                      provider.isLoading
                          ? null
                          : _saveCycle,

                  child:
                      provider.isLoading

                          ? const CircularProgressIndicator()

                          : const Text(
                              'SAVE',
                            ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}