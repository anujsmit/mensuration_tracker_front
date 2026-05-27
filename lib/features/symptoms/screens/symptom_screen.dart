// ======================================================
// FILE:
// lib/features/symptoms/screens/symptom_screen.dart
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/symptom_provider.dart';

import '../widgets/symptom_chip.dart';

class SymptomScreen
    extends StatefulWidget {

  const SymptomScreen({
    super.key,
  });

  @override
  State<SymptomScreen>
      createState() =>
          _SymptomScreenState();

}

class _SymptomScreenState
    extends State<SymptomScreen> {

  final TextEditingController
      _notesController =
      TextEditingController();

  String _selectedSymptom =
      'Cramps';

  String _severity =
      'Medium';

  final List<String> symptoms = [

    'Cramps',

    'Headache',

    'Back Pain',

    'Mood Swings',

    'Acne',

    'Fatigue',

    'Bloating',

    'Nausea',

  ];

  @override
  void dispose() {

    _notesController.dispose();

    super.dispose();

  }

  // ======================================================
  // SAVE
  // ======================================================

  Future<void> _saveSymptom()
      async {

    final provider =
        Provider.of<SymptomProvider>(
      context,
      listen: false,
    );

    final success =
        await provider.addSymptom(

      symptomType:
          _selectedSymptom,

      severity:
          _severity,

      symptomDate:
          DateTime.now()
              .toIso8601String(),

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
              Text(
            'Symptom added',
          ),
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
        Provider.of<SymptomProvider>(
      context,
    );

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        title:
            const Text(
          'Track Symptoms',
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            // ==================================
            // TITLE
            // ==================================

            const Text(

              'Select Symptoms',

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(
              height: 18,
            ),

            // ==================================
            // SYMPTOMS
            // ==================================

            Wrap(

              spacing: 12,

              runSpacing: 12,

              children:
                  symptoms.map(
                (symptom) {

                  return SymptomChip(

                    label:
                        symptom,

                    selected:
                        _selectedSymptom ==
                            symptom,

                    onTap: () {

                      setState(() {

                        _selectedSymptom =
                            symptom;

                      });

                    },

                  );

                },
              ).toList(),

            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================
            // SEVERITY
            // ==================================

            const Text(

              'Severity',

              style: TextStyle(

                fontSize: 18,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(
              height: 14,
            ),

            DropdownButtonFormField(

              value:
                  _severity,

              items: const [

                DropdownMenuItem(
                  value: 'Low',
                  child:
                      Text('Low'),
                ),

                DropdownMenuItem(
                  value: 'Medium',
                  child:
                      Text('Medium'),
                ),

                DropdownMenuItem(
                  value: 'High',
                  child:
                      Text('High'),
                ),

              ],

              onChanged: (value) {

                setState(() {

                  _severity =
                      value!;

                });

              },

            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================
            // NOTES
            // ==================================

            const Text(

              'Notes',

              style: TextStyle(

                fontSize: 18,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(
              height: 14,
            ),

            TextField(

              controller:
                  _notesController,

              maxLines: 5,

              decoration:
                  InputDecoration(

                hintText:
                    'Write your notes...',

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),

                  borderSide:
                      BorderSide.none,

                ),

              ),

            ),

            const SizedBox(
              height: 40,
            ),

            // ==================================
            // BUTTON
            // ==================================

            SizedBox(

              width:
                  double.infinity,

              height: 58,

              child: ElevatedButton(

                onPressed:
                    provider.isLoading

                        ? null

                        : _saveSymptom,

                child:
                    provider.isLoading

                        ? const CircularProgressIndicator(
                            color:
                                Colors
                                    .white,
                          )

                        : const Text(
                            'SAVE SYMPTOM',
                          ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}