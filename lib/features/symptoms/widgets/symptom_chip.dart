// ======================================================
// FILE:
// lib/features/symptoms/widgets/symptom_chip.dart
// ======================================================

import 'package:flutter/material.dart';

class SymptomChip
    extends StatelessWidget {

  final String label;

  final bool selected;

  final VoidCallback onTap;

  const SymptomChip({

    super.key,

    required this.label,

    required this.selected,

    required this.onTap,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return GestureDetector(

      onTap: onTap,

      child: AnimatedContainer(

        duration:
            const Duration(
          milliseconds: 200,
        ),

        padding:
            const EdgeInsets
                .symmetric(

          horizontal: 18,

          vertical: 12,

        ),

        decoration:
            BoxDecoration(

          color: selected

              ? Colors.pink

              : Colors.white,

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          border: Border.all(

            color: selected

                ? Colors.pink

                : Colors.grey
                    .shade300,

          ),

        ),

        child: Text(

          label,

          style: TextStyle(

            color: selected

                ? Colors.white

                : Colors.black87,

            fontWeight:
                FontWeight.w600,

          ),

        ),

      ),

    );

  }

}