import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/ReportProvider.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic>? _summaryData;
  Map<String, dynamic>? _periodStats;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _downloadingReport = false;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    // Small delay to ensure context is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadReports();
      }
    });
  }

  Future<void> _loadReports({bool forceRefresh = false}) async {
    if (!mounted) return;

    // Don't load if already loading or refreshing
    if (_isLoading || _isRefreshing) return;

    setState(() {
      if (!forceRefresh) {
        _isLoading = !_hasLoadedOnce;
      }
      _isRefreshing = forceRefresh;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final reportProvider = context.read<ReportProvider>();

      final token = authProvider.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Load both reports in parallel
      final results = await Future.wait([
        reportProvider.getSummaryReport(token, forceRefresh: forceRefresh),
        reportProvider.getPeriodStats(token, forceRefresh: forceRefresh),
      ]);

      if (mounted) {
        setState(() {
          _summaryData = results[0];
          _periodStats = results[1];
          _hasLoadedOnce = true;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isRefreshing = false;
        });
        _showErrorSnackbar('Failed to load reports: $e');
      }
    }
  }

  Future<void> _downloadReport() async {
    final authProvider = context.read<AuthProvider>();
    final reportProvider = context.read<ReportProvider>();

    final token = authProvider.token;
    if (token == null) {
      _showErrorSnackbar('Authentication error. Please log in again.');
      return;
    }

    if (!mounted) return;
    setState(() => _downloadingReport = true);

    try {
      final result = await reportProvider.downloadHealthReport(token);

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessSnackbar('Report downloaded successfully!');

        // Refresh the data after download
        _loadReports(forceRefresh: true);
      } else {
        _showErrorSnackbar(result['message'] as String? ?? 'Download failed');
      }
    } catch (e) {
      _showErrorSnackbar('Error downloading report: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _downloadingReport = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show loading skeleton
    if (_isLoading && !_hasLoadedOnce) {
      return _buildLoadingSkeleton();
    }

    // Show error state
    if (_errorMessage != null && !_hasLoadedOnce) {
      return _buildErrorState();
    }

    // Check if we have any data
    final hasData = (_summaryData != null && _summaryData!.isNotEmpty) ||
        (_periodStats != null && _periodStats!.isNotEmpty);

    if (!hasData && _hasLoadedOnce) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Health Reports'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isRefreshing)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _loadReports(forceRefresh: true),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            RefreshIndicator(
              onRefresh: () => _loadReports(forceRefresh: true),
              backgroundColor: Colors.white,
              color: colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    _buildWelcomeHeader(colorScheme),
                    const SizedBox(height: 24),

                    // Profile Summary
                    if (_summaryData != null && _summaryData!.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildProfileSummary(_summaryData!, colorScheme),
                      ),

                    // Period Statistics
                    if (_periodStats != null && _periodStats!.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildPeriodStatsSection(
                            _periodStats!, colorScheme),
                      ),

                    const SizedBox(height: 24),

                    // Download Section
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildDownloadSection(colorScheme),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Loading overlay for refreshing
            if (_isRefreshing && _hasLoadedOnce)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: colorScheme.primary,
                  minHeight: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.15),
            colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Insights Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track patterns and monitor your menstrual health',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(
      Map<String, dynamic> data, ColorScheme colorScheme) {
    final profile = data['profile'] ?? {};
    final summary = data;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Profile Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (profile.isNotEmpty) ...[
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    if (profile['age'] != null)
                      _buildProfileItem(
                          'Age', '${profile['age']}', Icons.cake_rounded),
                    if (profile['weight'] != null)
                      _buildProfileItem('Weight', '${profile['weight']}',
                          Icons.monitor_weight_rounded),
                    if (profile['height'] != null)
                      _buildProfileItem('Height', '${profile['height']}',
                          Icons.height_rounded),
                    if (profile['cycle_length'] != null)
                      _buildProfileItem('Cycle Length',
                          '${profile['cycle_length']}', Icons.repeat_rounded),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (summary['totalCycles'] != null ||
                  summary['totalSymptoms'] != null ||
                  summary['totalNotes'] != null) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (summary['totalCycles'] != null)
                      _buildSummaryStat('Cycles', '${summary['totalCycles']}',
                          Icons.repeat_rounded),
                    if (summary['totalSymptoms'] != null)
                      _buildSummaryStat(
                          'Symptoms',
                          '${summary['totalSymptoms']}',
                          Icons.health_and_safety_rounded),
                    if (summary['totalNotes'] != null)
                      _buildSummaryStat('Notes', '${summary['totalNotes']}',
                          Icons.note_rounded),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPeriodStatsSection(
      Map<String, dynamic> periodStats, ColorScheme colorScheme) {
    final summary = periodStats['summary'] ?? {};
    final intensityDistribution = periodStats['intensityDistribution'] ?? [];
    final monthlyStats = periodStats['monthlyStats'] ?? [];

    return Column(
      children: [
        // Period Statistics Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timeline_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Period Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Last 6 Months',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildStatCard(
                    'Months Tracked',
                    _safeToString(summary['months_tracked'], '0'),
                    Icons.calendar_month_rounded,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Period Days',
                    _safeToString(summary['period_days'], '0'),
                    Icons.water_drop_rounded,
                    Colors.pink,
                  ),
                  _buildStatCard(
                    'Total Pads',
                    _safeToString(summary['total_pads_used'], '0'),
                    Icons.clean_hands_rounded,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Avg Pads/Day',
                    _formatAvgPadsPerDay(summary['avg_pads_per_day']),
                    Icons.trending_up_rounded,
                    Colors.green,
                  ),
                ],
              ),
              if (summary['first_tracked_date'] != null ||
                  summary['last_tracked_date'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (summary['first_tracked_date'] != null)
                        _buildDateItem('First Tracked',
                            summary['first_tracked_date'].toString()),
                      if (summary['last_tracked_date'] != null)
                        _buildDateItem('Last Tracked',
                            summary['last_tracked_date'].toString()),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Intensity Distribution
        if (intensityDistribution.isNotEmpty)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pie_chart_rounded,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Intensity Distribution',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: intensityDistribution.map<Widget>((item) {
                        final intensity =
                            item['period_intensity']?.toString() ?? 'Unknown';
                        final days = _parseInt(item['days_count']);
                        final totalDays = intensityDistribution.fold<int>(
                          0,
                          (int sum, item) =>
                              sum + _parseInt(item['days_count']),
                        );
                        final percentage =
                            totalDays > 0 ? (days / totalDays) * 100 : 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getIntensityColor(intensity),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        intensity.capitalize(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: totalDays > 0
                                                ? days / totalDays
                                                : 0,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation(
                                              _getIntensityColor(intensity),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            minHeight: 8,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$days days',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

        // Monthly Overview
        if (monthlyStats.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_view_month_rounded,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Monthly Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: monthlyStats.take(6).map<Widget>((month) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatMonth(
                                        month['month']?.toString() ?? ''),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    '${_parseInt(month['period_days'])} period days',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${_parseInt(month['pads_used'])}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'pads',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (monthlyStats.length > 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${monthlyStats.length - 6} more months',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.download_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Export Your Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Download your complete health history in CSV format for personal records or medical consultations.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: _downloadingReport ? null : _downloadReport,
                icon: _downloadingReport
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(
                  _downloadingReport
                      ? 'Generating Report...'
                      : 'Download Complete Report',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // UI Helper Widgets
  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(String label, String? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        Text(
          date != null ? _formatDate(date) : 'N/A',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Loading Skeleton
  Widget _buildLoadingSkeleton() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Reports'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error State
  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Reports'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 24),
              Text(
                'Failed to Load Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'An unknown error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _loadReports(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Reports'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                'No Data Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Start tracking your menstrual cycles, symptoms, and daily notes to generate detailed health reports.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _loadReports(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods to safely handle data types
  String _safeToString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  String _formatAvgPadsPerDay(dynamic value) {
    if (value == null) return '0.0';
    final doubleVal = _parseDouble(value);
    return doubleVal.toStringAsFixed(1);
  }

  // Helper Methods
  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'light':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'heavy':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatMonth(String monthString) {
    try {
      if (monthString.contains('-')) {
        final parts = monthString.split('-');
        if (parts.length == 2) {
          final year = parts[0];
          final month = int.tryParse(parts[1]);
          if (month != null) {
            final monthName = DateFormat('MMM').format(DateTime(2000, month));
            return '$monthName $year';
          }
        }
      }
      return monthString;
    } catch (e) {
      return monthString;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.tryParse(dateString);
      if (date != null) {
        return DateFormat('MMM dd, yyyy').format(date);
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}