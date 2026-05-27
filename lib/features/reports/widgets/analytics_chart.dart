// ======================================================
// FILE:
// lib/features/reports/widgets/analytics_chart.dart
// ======================================================

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsChart
    extends StatelessWidget {

  final List<double> values;

  const AnalyticsChart({

    super.key,

    required this.values,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return SizedBox(

      height: 220,

      child: LineChart(

        LineChartData(

          gridData:
              const FlGridData(
            show: true,
          ),

          borderData:
              FlBorderData(
            show: false,
          ),

          titlesData:
              const FlTitlesData(
            show: false,
          ),

          lineBarsData: [

            LineChartBarData(

              spots:

                  values
                      .asMap()
                      .entries
                      .map(
                        (e) {

                  return FlSpot(

                    e.key.toDouble(),

                    e.value,

                  );

                }).toList(),

              isCurved: true,

              dotData:
                  const FlDotData(
                show: true,
              ),

              belowBarData:
                  BarAreaData(
                show: true,
              ),

            ),

          ],

        ),

      ),

    );

  }

}