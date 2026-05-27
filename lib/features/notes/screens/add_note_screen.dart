// ======================================================
// FILE:
// lib/features/notes/screens/add_note_screen.dart
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/note_provider.dart';

import '../widgets/mood_selector.dart';

class AddNoteScreen
    extends StatefulWidget {

  const AddNoteScreen({
    super.key,
  });

  @override
  State<AddNoteScreen>
      createState() =>
          _AddNoteScreenState();

}

class _AddNoteScreenState
    extends State<AddNoteScreen> {

  final _noteController =
      TextEditingController();

  String _selectedMood =
      'Happy';

  bool _isPeriodDay = false;

  int _padsUsed = 0;

  String _periodIntensity =
      'Medium';

  @override
  void dispose() {

    _noteController.dispose();

    super.dispose();

  }

  // ======================================================
  // SAVE NOTE
  // ======================================================

  Future<void> _saveNote()
      async {

    final provider =
        Provider.of<NoteProvider>(
      context,
      listen: false,
    );

    final success =
        await provider.createNote(

      noteDate:
          DateTime.now()
              .toIso8601String(),

      content:
          _noteController.text,

      mood:
          _selectedMood,

      isPeriodDay:
          _isPeriodDay,

      padsUsed:
          _padsUsed,

      periodIntensity:
          _periodIntensity,

    );

    if (!mounted) return;

    if (success) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(
          content:
              Text('Note saved'),
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
        Provider.of<NoteProvider>(
      context,
    );

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        title:
            const Text('Daily Note'),
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
            // MOOD
            // ==================================

            const Text(

              'How are you feeling today?',

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),

            ),

            const SizedBox(
              height: 18,
            ),

            MoodSelector(

              selectedMood:
                  _selectedMood,

              onSelected: (mood) {

                setState(() {

                  _selectedMood =
                      mood;

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

              'Write your thoughts',

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),

            ),

            const SizedBox(
              height: 12,
            ),

            TextField(

              controller:
                  _noteController,

              maxLines: 6,

              decoration:
                  InputDecoration(

                hintText:
                    'Write here...',

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),

                  borderSide:
                      BorderSide.none,

                ),

              ),

            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================
            // PERIOD DAY
            // ==================================

            SwitchListTile(

              value:
                  _isPeriodDay,

              onChanged: (value) {

                setState(() {

                  _isPeriodDay =
                      value;

                });

              },

              title:
                  const Text(
                'Is this a period day?',
              ),

            ),

            // ==================================
            // PADS USED
            // ==================================

            if (_isPeriodDay)

              Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'Pads Used',
                  ),

                  Slider(

                    value:
                        _padsUsed
                            .toDouble(),

                    min: 0,

                    max: 15,

                    divisions: 15,

                    label:
                        _padsUsed
                            .toString(),

                    onChanged: (
                      value,
                    ) {

                      setState(() {

                        _padsUsed =
                            value
                                .toInt();

                      });

                    },

                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // ==========================
                  // INTENSITY
                  // ==========================

                  DropdownButtonFormField(

                    value:
                        _periodIntensity,

                    items: const [

                      DropdownMenuItem(
                        value: 'Light',
                        child:
                            Text(
                          'Light',
                        ),
                      ),

                      DropdownMenuItem(
                        value: 'Medium',
                        child:
                            Text(
                          'Medium',
                        ),
                      ),

                      DropdownMenuItem(
                        value: 'Heavy',
                        child:
                            Text(
                          'Heavy',
                        ),
                      ),

                    ],

                    onChanged: (
                      value,
                    ) {

                      setState(() {

                        _periodIntensity =
                            value!;

                      });

                    },

                  ),

                ],

              ),

            const SizedBox(
              height: 35,
            ),

            // ==================================
            // BUTTON
            // ==================================

            SizedBox(

              width: double.infinity,

              height: 58,

              child: ElevatedButton(

                onPressed:
                    provider.isLoading
                        ? null
                        : _saveNote,

                child:
                    provider.isLoading

                        ? const CircularProgressIndicator(
                            color:
                                Colors
                                    .white,
                          )

                        : const Text(
                            'SAVE NOTE',
                          ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}