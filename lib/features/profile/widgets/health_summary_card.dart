import 'package:flutter/material.dart';

import '../models/health_profile_model.dart';

class HealthSummaryCard
    extends StatelessWidget {

  final HealthProfileModel?
      profile;

  const HealthSummaryCard({

    super.key,

    required this.profile,
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

            'Health Summary',

            style: TextStyle(

              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          _item(
            'Age',
            '${profile?.age ?? '--'}',
          ),

          _item(
            'Cycle Length',
            '${profile?.cycleLength ?? '--'} days',
          ),

          _item(
            'Bleeding Duration',
            '${profile?.bleedingDuration ?? '--'} days',
          ),

          _item(
            'Flow Regularity',
            profile?.flowRegularity ??
                '--',
          ),
        ],
      ),
    );
  }

  Widget _item(
    String title,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [

          Text(title),

          Text(

            value,

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}