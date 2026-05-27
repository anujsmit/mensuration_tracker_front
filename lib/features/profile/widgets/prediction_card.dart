import 'package:flutter/material.dart';

class PredictionCard
    extends StatelessWidget {

  final String title;

  final String description;

  final IconData icon;

  final Color color;

  const PredictionCard({

    super.key,

    required this.title,

    required this.description,

    required this.icon,

    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),

      child: Row(

        children: [

          CircleAvatar(

            radius: 28,

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
            width: 18,
          ),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  title,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  description,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}