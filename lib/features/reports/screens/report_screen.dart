// ======================================================
// FILE:
// lib/features/reports/screens/report_screen.dart
// ======================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/report_provider.dart';

import '../widgets/analytics_chart.dart';

class ReportScreen
    extends StatefulWidget {

  const ReportScreen({
    super.key,
  });

  @override
  State<ReportScreen>
      createState() =>
          _ReportScreenState();

}

class _ReportScreenState
    extends State<ReportScreen> {

  @override
  void initState() {

    super.initState();

    Future.microtask(() {

      Provider.of<ReportProvider>(
        context,
        listen: false,
      ).fetchReport();

    });

  }

  // ======================================================
  // FORMAT DATE
  // ======================================================

  String formatDate(
    DateTime date,
  ) {

    return DateFormat(
      'MMM dd, yyyy',
    ).format(date);

  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final provider =
        Provider.of<ReportProvider>(
      context,
    );

    final report =
        provider.report;

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        title:
            const Text(
          'Health Reports',
        ),
      ),

      body:
          provider.isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : report == null

                  ? const Center(
                      child:
                          Text(
                        'No reports found',
                      ),
                    )

                  : SingleChildScrollView(

                      padding:
                          const EdgeInsets
                              .all(20),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          // ======================
                          // HEADER CARD
                          // ======================

                          Container(

                            width:
                                double.infinity,

                            padding:
                                const EdgeInsets
                                    .all(24),

                            decoration:
                                BoxDecoration(

                              gradient:
                                  LinearGradient(

                                colors: [

                                  Colors
                                      .pink
                                      .shade400,

                                  Colors
                                      .pink
                                      .shade200,

                                ],

                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                30,
                              ),

                            ),

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                const Text(

                                  'Your Health Summary',

                                  style:
                                      TextStyle(

                                    color:
                                        Colors
                                            .white,

                                    fontSize:
                                        24,

                                    fontWeight:
                                        FontWeight
                                            .bold,

                                  ),

                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(

                                  report.nextPredictedPeriod !=
                                          null

                                      ? 'Next predicted period: ${formatDate(report.nextPredictedPeriod!)}'

                                      : 'No prediction available',

                                  style:
                                      TextStyle(

                                    color:
                                        Colors
                                            .white
                                            .withOpacity(
                                      0.95,
                                    ),

                                  ),

                                ),

                              ],

                            ),

                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // ======================
                          // STATS
                          // ======================

                          Row(

                            children: [

                              Expanded(

                                child:
                                    _buildStatCard(

                                  title:
                                      'Cycles',

                                  value:
                                      report.totalCycles.toString(),

                                  icon:
                                      Icons.sync,

                                ),

                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              Expanded(

                                child:
                                    _buildStatCard(

                                  title:
                                      'Symptoms',

                                  value:
                                      report.totalSymptoms.toString(),

                                  icon:
                                      Icons.favorite,

                                ),

                              ),

                            ],

                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          Row(

                            children: [

                              Expanded(

                                child:
                                    _buildStatCard(

                                  title:
                                      'Avg Cycle',

                                  value:
                                      '${report.averageCycleLength.toStringAsFixed(1)} days',

                                  icon:
                                      Icons.calendar_month,

                                ),

                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              Expanded(

                                child:
                                    _buildStatCard(

                                  title:
                                      'Avg Period',

                                  value:
                                      '${report.averagePeriodLength.toStringAsFixed(1)} days',

                                  icon:
                                      Icons.water_drop,

                                ),

                              ),

                            ],

                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // ======================
                          // CHART
                          // ======================

                          const Text(

                            'Cycle Analytics',

                            style: TextStyle(

                              fontSize: 20,

                              fontWeight:
                                  FontWeight
                                      .bold,

                            ),

                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          Container(

                            padding:
                                const EdgeInsets
                                    .all(18),

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.white,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                24,
                              ),

                            ),

                            child:
                                const AnalyticsChart(

                              values: [

                                28,

                                29,

                                30,

                                27,

                                28,

                                29,

                              ],

                            ),

                          ),

                          const SizedBox(
                            height: 30,
                          ),

                          // ======================
                          // EXPORT
                          // ======================

                          SizedBox(

                            width:
                                double.infinity,

                            height: 58,

                            child:
                                ElevatedButton.icon(

                              onPressed: () {

                                ScaffoldMessenger
                                        .of(
                                  context,
                                ).showSnackBar(

                                  const SnackBar(

                                    content:
                                        Text(
                                      'PDF export coming soon',
                                    ),

                                  ),

                                );

                              },

                              icon: const Icon(
                                Icons.picture_as_pdf,
                              ),

                              label: const Text(
                                'EXPORT PDF REPORT',
                              ),

                            ),

                          ),

                        ],

                      ),

                    ),

    );

  }

  // ======================================================
  // STAT CARD
  // ======================================================

  Widget _buildStatCard({

    required String title,

    required String value,

    required IconData icon,

  }) {

    return Container(

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          24,
        ),

      ),

      child: Column(

        children: [

          Container(

            padding:
                const EdgeInsets
                    .all(14),

            decoration:
                BoxDecoration(

              color: Colors
                  .pink
                  .shade50,

              shape:
                  BoxShape.circle,

            ),

            child: Icon(
              icon,
              color:
                  Colors.pink,
            ),

          ),

          const SizedBox(
            height: 14,
          ),

          Text(

            value,

            style:
                const TextStyle(

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,

            ),

          ),

          const SizedBox(
            height: 6,
          ),

          Text(

            title,

            style: TextStyle(
              color:
                  Colors.grey.shade600,
            ),

          ),

        ],

      ),

    );

  }

}