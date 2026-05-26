// lib/screens/home/reports.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/ReportProvider.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() =>
      _ReportsState();
}

class _ReportsState
    extends State<Reports>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic>? _summaryData;

  Map<String, dynamic>? _periodStats;

  bool _isLoading = false;

  bool _downloadingReport =
      false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadReports();
    });
  }

  // ==========================================
  // LOAD REPORTS
  // ==========================================

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider =
          context.read<
              AuthProvider>();

      final reportProvider =
          context.read<
              ReportProvider>();

      final token =
          authProvider.token ?? '';

      if (token.isEmpty) {
        throw Exception(
          'User not authenticated',
        );
      }

      final summary =
          await reportProvider
              .getSummaryReport(
        token,
      );

      final periodStats =
          await reportProvider
              .getPeriodStats(
        token,
      );

      if (!mounted) return;

      setState(() {
        _summaryData = summary;
        _periodStats =
            periodStats;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString();
      });

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================
  // DOWNLOAD REPORT
  // ==========================================

  Future<void>
      _downloadReport() async {
    final authProvider =
        context.read<AuthProvider>();

    final reportProvider =
        context.read<
            ReportProvider>();

    final token =
        authProvider.token ?? '';

    if (token.isEmpty) {
      _showSnackbar(
        'Please login again',
        Colors.red,
      );

      return;
    }

    setState(() {
      _downloadingReport = true;
    });

    try {
      final result =
          await reportProvider
              .downloadHealthReport(
        token,
      );

      if (!mounted) return;

      if (result['success'] ==
          true) {
        _showSnackbar(
          'Report downloaded successfully',
          Colors.green,
        );
      } else {
        _showSnackbar(
          result['message'] ??
              'Download failed',
          Colors.red,
        );
      }

    } catch (e) {
      _showSnackbar(
        e.toString(),
        Colors.red,
      );

    } finally {
      if (mounted) {
        setState(() {
          _downloadingReport =
              false;
        });
      }
    }
  }

  // ==========================================
  // SNACKBAR
  // ==========================================

  void _showSnackbar(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor:
            color,

        behavior:
            SnackBarBehavior
                .floating,
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    super.build(context);

    final theme =
        Theme.of(context);

    final primaryColor =
        theme.colorScheme.primary;

    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        title:
            const Text('Reports'),

        centerTitle: true,

        elevation: 0,

        backgroundColor:
            Colors.transparent,

        actions: [
          IconButton(
            onPressed:
                _loadReports,

            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh:
            _loadReports,

        child:
            SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.all(
                  20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              // ==========================
              // HEADER
              // ==========================

              FadeInDown(
                child: Container(
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
                        primaryColor,
                        primaryColor
                            .withOpacity(
                                0.7),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(
                            28),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      const Icon(
                        Icons
                            .analytics_rounded,

                        color: Colors
                            .white,

                        size: 42,
                      ),

                      const SizedBox(
                          height:
                              16),

                      const Text(
                        'Health Insights',

                        style:
                            TextStyle(
                          color: Colors
                              .white,

                          fontSize:
                              28,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                          height:
                              8),

                      Text(
                        'Your menstrual health overview and statistics.',

                        style:
                            TextStyle(
                          color: Colors
                              .white
                              .withOpacity(
                                  0.9),

                          fontSize:
                              15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                  height: 24),

              // ==========================
              // PROFILE SUMMARY
              // ==========================

              FadeInUp(
                delay:
                    const Duration(
                  milliseconds:
                      100,
                ),

                child:
                    _buildSummaryCard(),
              ),

              const SizedBox(
                  height: 20),

              // ==========================
              // PERIOD STATS
              // ==========================

              FadeInUp(
                delay:
                    const Duration(
                  milliseconds:
                      200,
                ),

                child:
                    _buildStatsCard(),
              ),

              const SizedBox(
                  height: 24),

              // ==========================
              // DOWNLOAD BUTTON
              // ==========================

              FadeInUp(
                delay:
                    const Duration(
                  milliseconds:
                      300,
                ),

                child: SizedBox(
                  width:
                      double.infinity,

                  height: 58,

                  child:
                      ElevatedButton.icon(
                    onPressed:
                        _downloadingReport
                            ? null
                            : _downloadReport,

                    icon: _downloadingReport
                        ? const SizedBox(
                            width:
                                22,
                            height:
                                22,
                            child:
                                CircularProgressIndicator(
                              color: Colors
                                  .white,
                              strokeWidth:
                                  2,
                            ),
                          )
                        : const Icon(
                            Icons
                                .download_rounded,
                          ),

                    label: Text(
                      _downloadingReport
                          ? 'Generating Report...'
                          : 'Download Health Report',
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          primaryColor,

                      foregroundColor:
                          Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                18),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SUMMARY CARD
  // ==========================================

  Widget _buildSummaryCard() {
    final profile =
        _summaryData?['profile'] ??
            {};

    return Container(
      padding:
          const EdgeInsets.all(
              22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                24),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),

            blurRadius: 10,

            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          const Text(
            'Profile Summary',

            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 20),

          _buildRow(
            'Age',
            '${profile['age'] ?? '--'}',
          ),

          _buildRow(
            'Weight',
            '${profile['weight'] ?? '--'} kg',
          ),

          _buildRow(
            'Height',
            '${profile['height'] ?? '--'} cm',
          ),

          _buildRow(
            'Cycle Length',
            '${profile['cycle_length'] ?? '--'} days',
          ),

          _buildRow(
            'Flow Amount',
            '${profile['flow_amount'] ?? '--'}',
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STATS CARD
  // ==========================================

  Widget _buildStatsCard() {
    final summary =
        _periodStats?['summary'] ??
            {};

    return Container(
      padding:
          const EdgeInsets.all(
              22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                24),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.04),

            blurRadius: 10,

            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          const Text(
            'Period Statistics',

            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 20),

          Row(
            children: [
              Expanded(
                child:
                    _buildStatBox(
                  'Tracked Months',
                  '${summary['months_tracked'] ?? 0}',
                  Icons
                      .calendar_month,
                  Colors.blue,
                ),
              ),

              const SizedBox(
                  width: 14),

              Expanded(
                child:
                    _buildStatBox(
                  'Period Days',
                  '${summary['period_days'] ?? 0}',
                  Icons
                      .water_drop,
                  Colors.pink,
                ),
              ),
            ],
          ),

          const SizedBox(
              height: 14),

          Row(
            children: [
              Expanded(
                child:
                    _buildStatBox(
                  'Pads Used',
                  '${summary['total_pads_used'] ?? 0}',
                  Icons.spa,
                  Colors.orange,
                ),
              ),

              const SizedBox(
                  width: 14),

              Expanded(
                child:
                    _buildStatBox(
                  'Avg/Day',
                  '${summary['avg_pads_per_day'] ?? 0}',
                  Icons
                      .analytics,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ROW
  // ==========================================

  Widget _buildRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [
          Text(
            title,

            style: TextStyle(
              color:
                  Colors.grey.shade700,
            ),
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
      ),
    );
  }

  // ==========================================
  // STAT BOX
  // ==========================================

  Widget _buildStatBox(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
              16),

      decoration: BoxDecoration(
        color:
            color.withOpacity(0.08),

        borderRadius:
            BorderRadius.circular(
                18),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),

          const SizedBox(
              height: 12),

          Text(
            value,

            style:
                TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(
              height: 6),

          Text(
            title,

            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 12,
              color:
                  Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LOADING
  // ==========================================

  Widget _buildLoading() {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Reports'),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(
                20),

        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor:
                  Colors.grey[300]!,

              highlightColor:
                  Colors.grey[100]!,

              child: Container(
                height: 180,

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                          24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ERROR
  // ==========================================

  Widget _buildError() {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Reports'),
      ),

      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
                  24),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            children: [
              Icon(
                Icons.error_outline,

                size: 80,

                color:
                    Colors.red[300],
              ),

              const SizedBox(
                  height: 20),

              Text(
                _errorMessage ??
                    'Something went wrong',

                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(
                  height: 24),

              ElevatedButton(
                onPressed:
                    _loadReports,

                child:
                    const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}