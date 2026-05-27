import 'package:flutter/material.dart';

class PeriodStatsCard
    extends StatelessWidget {

  final int cycleLength;

  final int bleedingDuration;

  const PeriodStatsCard({

    super.key,

    required this.cycleLength,

    required this.bleedingDuration,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        Expanded(

          child: _card(

            title:
                'Cycle Length',

            value:
                '$cycleLength d',

            color:
                Colors.pink,
          ),
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(

          child: _card(

            title:
                'Bleeding',

            value:
                '$bleedingDuration d',

            color:
                Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _card({

    required String title,

    required String value,

    required Color color,

  }) {

    return Container(

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),

      child: Column(

        children: [

          Text(

            value,

            style: TextStyle(

              color: color,

              fontSize: 24,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(title),
        ],
      ),
    );
  }
}