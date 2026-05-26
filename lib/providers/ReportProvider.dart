// lib/providers/ReportProvider.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportProvider with ChangeNotifier {
  // ==========================================
  // SUPABASE
  // ==========================================

  final supabase =
      Supabase.instance.client;

  // ==========================================
  // STATE
  // ==========================================

  Map<String, dynamic>? _summaryReport;

  Map<String, dynamic>? _periodStats;

  String _error = '';

  bool _isLoading = false;

  bool _isDownloading = false;

  // ==========================================
  // GETTERS
  // ==========================================

  Map<String, dynamic>?
      get summaryReport =>
          _summaryReport;

  Map<String, dynamic>?
      get periodStats =>
          _periodStats;

  String get error => _error;

  bool get isLoading =>
      _isLoading;

  bool get isDownloading =>
      _isDownloading;

  // ==========================================
  // CLEAR REPORTS
  // ==========================================

  void clearReports() {
    _summaryReport = null;

    _periodStats = null;

    _error = '';

    notifyListeners();
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = '';

    notifyListeners();
  }

  // ==========================================
  // GET SUMMARY REPORT
  // ==========================================

  Future<Map<String, dynamic>>
      getSummaryReport(
    String token, {
    bool forceRefresh = false,
  }) async {
    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      final userId =
          supabase
              .auth.currentUser!.id;

      final profile =
          await supabase
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      final cycles =
          await supabase
              .from('cycles')
              .select()
              .eq('user_id', userId);

      final symptoms =
          await supabase
              .from('symptoms')
              .select()
              .eq('user_id', userId);

      final data = {
        'profile': profile ?? {},

        'totalCycles':
            cycles.length,

        'totalSymptoms':
            symptoms.length,

        'totalNotes': 0,

        'generatedAt':
            DateTime.now()
                .toIso8601String(),
      };

      _summaryReport = data;

      return data;

    } catch (e) {
      _error = e.toString();

      return {};

    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // GET PERIOD STATS
  // ==========================================

  Future<Map<String, dynamic>>
      getPeriodStats(
    String token, {
    bool forceRefresh = false,
  }) async {
    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      final userId =
          supabase
              .auth.currentUser!.id;

      final cycles =
          await supabase
              .from('cycles')
              .select()
              .eq('user_id', userId)
              .order(
                'start_date',
                ascending: false,
              );

      int averageCycle = 28;

      if (cycles.isNotEmpty) {
        int total = 0;

        for (var cycle in cycles) {
          total +=
              (cycle[
                          'cycle_length'] ??
                      28)
                  as int;
        }

        averageCycle =
            (total / cycles.length)
                .round();
      }

      final data = {
        'summary': {
          'months_tracked':
              cycles.length,

          'period_days': 0,

          'total_pads_used':
              0,

          'avg_pads_per_day':
              0,

          'average_cycle':
              averageCycle,
        },

        'monthlyStats': [],

        'intensityDistribution':
            [],
      };

      _periodStats = data;

      return data;

    } catch (e) {
      _error = e.toString();

      return {};

    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // DOWNLOAD REPORT
  // ==========================================

  Future<Map<String, dynamic>>
      downloadHealthReport(
    String token, {
    bool forceRefresh = false,
  }) async {
    _isDownloading = true;

    notifyListeners();

    try {
      final summary =
          await getSummaryReport(
        token,
      );

      final stats =
          await getPeriodStats(
        token,
      );

      final profile =
          summary['profile'] ??
              {};

      final report = '''
========================================
MENSTRUAL HEALTH REPORT
========================================

Generated:
${DateTime.now()}

========================================
PROFILE
========================================

Name:
${profile['full_name'] ?? 'Unknown'}

Age:
${profile['age'] ?? '--'}

Weight:
${profile['weight'] ?? '--'} kg

Height:
${profile['height'] ?? '--'} cm

Cycle Length:
${profile['cycle_length'] ?? '--'} days

Flow Amount:
${profile['flow_amount'] ?? '--'}

========================================
STATISTICS
========================================

Total Cycles:
${summary['totalCycles']}

Total Symptoms:
${summary['totalSymptoms']}

Months Tracked:
${stats['summary']['months_tracked']}

Average Cycle:
${stats['summary']['average_cycle']} days

========================================
END OF REPORT
========================================
''';

      return {
        'success': true,

        'data':
            Uint8List.fromList(
          report.codeUnits,
        ),

        'filename':
            'health_report.txt',

        'contentType':
            'text/plain',

        'size':
            report.length,
      };

    } catch (e) {
      return {
        'success': false,

        'message':
            e.toString(),
      };

    } finally {
      _isDownloading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // GET ALL REPORTS
  // ==========================================

  Future<Map<String, dynamic>>
      getAllReports(
    String token, {
    bool forceRefresh = false,
  }) async {
    _isLoading = true;

    notifyListeners();

    try {
      final summary =
          await getSummaryReport(
        token,
      );

      final stats =
          await getPeriodStats(
        token,
      );

      return {
        'success': true,

        'summary': summary,

        'periodStats':
            stats,

        'generatedAt':
            DateTime.now()
                .toIso8601String(),
      };

    } catch (e) {
      return {
        'success': false,

        'message':
            e.toString(),
      };

    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // PRELOAD REPORTS
  // ==========================================

  Future<void> preloadReports(
    String token,
  ) async {
    try {
      await Future.wait([
        getSummaryReport(token),

        getPeriodStats(token),
      ]);

    } catch (e) {
      debugPrint(
        'Preload error: $e',
      );
    }
  }
}