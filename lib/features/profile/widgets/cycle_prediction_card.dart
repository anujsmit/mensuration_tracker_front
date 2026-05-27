import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CyclePredictionCard
    extends StatelessWidget {

  final DateTime? nextPeriod;

  final DateTime? ovulation;

  const CyclePredictionCard({

    super.key,

    required this.nextPeriod,

    required this.ovulation,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          28,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          const Text(

            'Cycle Predictions',

            style: TextStyle(

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          _row(

            icon:
                Icons.water_drop,

            color: Colors.pink,

            title:
                'Next Period',

            value:
                nextPeriod != null

                    ? DateFormat(
                        'MMM d',
                      ).format(
                        nextPeriod!,
                      )

                    : '--',
          ),

          const SizedBox(
            height: 20,
          ),

          _row(

            icon:
                Icons.favorite,

            color: Colors.purple,

            title:
                'Ovulation',

            value:
                ovulation != null

                    ? DateFormat(
                        'MMM d',
                      ).format(
                        ovulation!,
                      )

                    : '--',
          ),
        ],
      ),
    );
  }

  Widget _row({

    required IconData icon,

    required Color color,

    required String title,

    required String value,

  }) {

    return Row(

      children: [

        CircleAvatar(

          backgroundColor:
              color.withOpacity(
            0.1,
          ),

          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(
          width: 16,
        ),

        Expanded(
          child: Text(title),
        ),

        Text(

          value,

          style:
              const TextStyle(

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}