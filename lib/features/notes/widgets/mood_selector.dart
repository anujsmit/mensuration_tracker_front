// ======================================================
// FILE:
// lib/features/notes/widgets/mood_selector.dart
// ======================================================

import 'package:flutter/material.dart';

class MoodSelector
    extends StatelessWidget {

  final String selectedMood;

  final Function(String mood)
      onSelected;

  const MoodSelector({

    super.key,

    required this.selectedMood,

    required this.onSelected,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    final moods = [

      {
        'emoji': '😊',
        'label': 'Happy',
      },

      {
        'emoji': '😔',
        'label': 'Sad',
      },

      {
        'emoji': '😡',
        'label': 'Angry',
      },

      {
        'emoji': '😴',
        'label': 'Tired',
      },

      {
        'emoji': '😍',
        'label': 'Loved',
      },

    ];

    return Wrap(

      spacing: 12,

      runSpacing: 12,

      children:
          moods.map((mood) {

        final isSelected =
            selectedMood ==
                mood['label'];

        return GestureDetector(

          onTap: () {

            onSelected(
              mood['label']!,
            );

          },

          child: AnimatedContainer(

            duration:
                const Duration(
              milliseconds: 200,
            ),

            padding:
                const EdgeInsets
                    .symmetric(

              horizontal: 18,

              vertical: 14,

            ),

            decoration:
                BoxDecoration(

              color: isSelected

                  ? Colors.pink

                  : Colors.white,

              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),

              border: Border.all(

                color: isSelected

                    ? Colors.pink

                    : Colors.grey
                        .shade300,

              ),

            ),

            child: Row(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                Text(
                  mood['emoji']!,
                  style:
                      const TextStyle(
                    fontSize: 22,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(

                  mood['label']!,

                  style: TextStyle(

                    color: isSelected

                        ? Colors.white

                        : Colors.black87,

                    fontWeight:
                        FontWeight.w600,

                  ),

                ),

              ],

            ),

          ),

        );

      }).toList(),

    );

  }

}