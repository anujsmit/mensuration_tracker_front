import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:mensurationhealthapp/config/config.dart';

class ReportProvider with ChangeNotifier {
  // Cached reports with timestamps
  Map<String, dynamic>? _summaryReport;
  Map<String, dynamic>? _periodStats;
  Map<String, dynamic>? _periodsReport;
  Map<String, dynamic>? _cyclesReport;
  Map<String, dynamic>? _symptomsReport;
  Map<String, dynamic>? _monthlyReport;
  Map<String, dynamic>? _customReport;
  
  DateTime? _summaryReportTimestamp;
  DateTime? _periodStatsTimestamp;
  DateTime? _periodsReportTimestamp;
  DateTime? _cyclesReportTimestamp;
  DateTime? _symptomsReportTimestamp;
  DateTime? _monthlyReportTimestamp;
  DateTime? _customReportTimestamp;
  
  String _error = '';
  bool _isLoading = false;
  bool _isDownloading = false;

  // Cache duration - 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Use the centralized API base URL
  final String baseUrl = Config.apiAuthBaseUrl;

  // Getters
  Map<String, dynamic>? get summaryReport => _summaryReport;
  Map<String, dynamic>? get periodStats => _periodStats;
  Map<String, dynamic>? get periodsReport => _periodsReport;
  Map<String, dynamic>? get cyclesReport => _cyclesReport;
  Map<String, dynamic>? get symptomsReport => _symptomsReport;
  Map<String, dynamic>? get monthlyReport => _monthlyReport;
  Map<String, dynamic>? get customReport => _customReport;
  String get error => _error;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;

  // Clear all reports and cache
  void clearReports() {
    _summaryReport = null;
    _periodStats = null;
    _periodsReport = null;
    _cyclesReport = null;
    _symptomsReport = null;
    _monthlyReport = null;
    _customReport = null;
    
    _summaryReportTimestamp = null;
    _periodStatsTimestamp = null;
    _periodsReportTimestamp = null;
    _cyclesReportTimestamp = null;
    _symptomsReportTimestamp = null;
    _monthlyReportTimestamp = null;
    _customReportTimestamp = null;
    
    _error = '';
    notifyListeners();
  }

  // Clear specific cache
  void clearCache({bool summary = false, bool periodStats = false}) {
    if (summary) {
      _summaryReport = null;
      _summaryReportTimestamp = null;
    }
    if (periodStats) {
      _periodStats = null;
      _periodStatsTimestamp = null;
    }
    notifyListeners();
  }

  // Check if cache is valid
  bool _isCacheValid(DateTime? timestamp) {
    return timestamp != null && 
           DateTime.now().difference(timestamp) < _cacheDuration;
  }

  // Common method for API calls with caching
  Future<Map<String, dynamic>> _fetchWithCache({
    required String url,
    required String token,
    Map<String, dynamic>? cache,
    DateTime? cacheTimestamp,
    String cacheKey = '',
    bool forceRefresh = false,
    Map<String, String>? queryParams,
  }) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && cache != null && _isCacheValid(cacheTimestamp)) {
      return cache;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      Uri uri;
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = Uri.parse(url).replace(queryParameters: queryParams);
      } else {
        uri = Uri.parse(url);
      }

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          final data = responseData['data'] ?? {};
          
          // Update cache based on cacheKey
          switch (cacheKey) {
            case 'summary':
              _summaryReport = data;
              _summaryReportTimestamp = DateTime.now();
              break;
            case 'periodStats':
              _periodStats = data;
              _periodStatsTimestamp = DateTime.now();
              break;
            case 'periods':
              _periodsReport = data;
              _periodsReportTimestamp = DateTime.now();
              break;
            case 'cycles':
              _cyclesReport = data;
              _cyclesReportTimestamp = DateTime.now();
              break;
            case 'symptoms':
              _symptomsReport = data;
              _symptomsReportTimestamp = DateTime.now();
              break;
            case 'monthly':
              _monthlyReport = data;
              _monthlyReportTimestamp = DateTime.now();
              break;
            case 'custom':
              _customReport = data;
              _customReportTimestamp = DateTime.now();
              break;
          }
          
          return data;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load data');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      // Return cached data even if stale when there's an error
      if (cache != null) {
        return cache;
      }
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch period stats (from notes.js)
  Future<Map<String, dynamic>> getPeriodStats(
    String token, {
    bool forceRefresh = false,
  }) async {
    return await _fetchWithCache(
      url: '$baseUrl/notes/period-stats',
      token: token,
      cache: _periodStats,
      cacheTimestamp: _periodStatsTimestamp,
      cacheKey: 'periodStats',
      forceRefresh: forceRefresh,
    );
  }

  // Fetch summary report
  Future<Map<String, dynamic>> getSummaryReport(
    String token, {
    bool forceRefresh = false,
  }) async {
    return await _fetchWithCache(
      url: '$baseUrl/reports/summary',
      token: token,
      cache: _summaryReport,
      cacheTimestamp: _summaryReportTimestamp,
      cacheKey: 'summary',
      forceRefresh: forceRefresh,
    );
  }

  // Fetch periods report
  Future<Map<String, dynamic>> getPeriodsReport(
    String token, {
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    
    return await _fetchWithCache(
      url: '$baseUrl/reports/periods',
      token: token,
      cache: _periodsReport,
      cacheTimestamp: _periodsReportTimestamp,
      cacheKey: 'periods',
      forceRefresh: forceRefresh,
      queryParams: queryParams,
    );
  }

  // Fetch cycles report
  Future<Map<String, dynamic>> getCyclesReport(
    String token, {
    bool forceRefresh = false,
  }) async {
    return await _fetchWithCache(
      url: '$baseUrl/reports/cycles',
      token: token,
      cache: _cyclesReport,
      cacheTimestamp: _cyclesReportTimestamp,
      cacheKey: 'cycles',
      forceRefresh: forceRefresh,
    );
  }

  // Fetch symptoms analysis report
  Future<Map<String, dynamic>> getSymptomsAnalysis(
    String token, {
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    
    return await _fetchWithCache(
      url: '$baseUrl/reports/symptoms-analysis',
      token: token,
      cache: _symptomsReport,
      cacheTimestamp: _symptomsReportTimestamp,
      cacheKey: 'symptoms',
      forceRefresh: forceRefresh,
      queryParams: queryParams,
    );
  }

  // Fetch monthly report
  Future<Map<String, dynamic>> getMonthlyReport(
    String token, {
    required String year,
    required String month,
    bool forceRefresh = false,
  }) async {
    return await _fetchWithCache(
      url: '$baseUrl/reports/monthly?year=$year&month=$month',
      token: token,
      cache: _monthlyReport,
      cacheTimestamp: _monthlyReportTimestamp,
      cacheKey: 'monthly',
      forceRefresh: forceRefresh,
    );
  }

  // Fetch custom report
  Future<Map<String, dynamic>> getCustomReport(
    String token, {
    required String startDate,
    required String endDate,
    bool includeNotes = true,
    bool includeSymptoms = true,
    bool includeCycles = true,
    bool includePeriods = true,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, String>{
      'startDate': startDate,
      'endDate': endDate,
      'includeNotes': includeNotes.toString(),
      'includeSymptoms': includeSymptoms.toString(),
      'includeCycles': includeCycles.toString(),
      'includePeriods': includePeriods.toString(),
    };
    
    return await _fetchWithCache(
      url: '$baseUrl/reports/custom',
      token: token,
      cache: _customReport,
      cacheTimestamp: _customReportTimestamp,
      cacheKey: 'custom',
      forceRefresh: forceRefresh,
      queryParams: queryParams,
    );
  }

  // Download health report (CSV)
  Future<Map<String, dynamic>> downloadHealthReport(
    String token, {
    bool forceRefresh = false,
  }) async {
    // Check cache first for download URLs
    if (!forceRefresh && _summaryReport != null && _isCacheValid(_summaryReportTimestamp)) {
      return {
        'success': true,
        'message': 'Using cached report data',
        'data': _summaryReport,
      };
    }

    _isDownloading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/health'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'text/csv, application/json',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        String? contentDisposition = response.headers['content-disposition'];
        String filename = 'health_report_${DateTime.now().millisecondsSinceEpoch}.csv';
        
        if (contentDisposition != null) {
          final match = RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
          if (match != null) {
            filename = match.group(1) ?? filename;
          }
        }

        // Handle CSV response
        if (contentType.contains('csv')) {
          return {
            'success': true,
            'data': response.bodyBytes,
            'filename': filename,
            'contentType': 'csv',
            'size': response.bodyBytes.length,
            'timestamp': DateTime.now().toIso8601String(),
          };
        } else {
          // Try to parse as JSON
          try {
            final responseData = json.decode(response.body);
            if (responseData['status'] == 'error' || responseData['success'] == false) {
              return {
                'success': false,
                'message': responseData['message'] ?? 'Failed to generate report.',
              };
            }
            
            // Cache the data if it's a JSON response
            if (responseData['data'] != null) {
              _summaryReport = responseData['data'];
              _summaryReportTimestamp = DateTime.now();
            }
            
            return {
              'success': true,
              'data': Uint8List.fromList(utf8.encode(json.encode(responseData))),
              'filename': filename.replaceAll('.csv', '.json'),
              'contentType': 'json',
              'size': response.body.length,
              'timestamp': DateTime.now().toIso8601String(),
            };
          } catch (e) {
            return {
              'success': true,
              'data': response.bodyBytes,
              'filename': filename,
              'contentType': 'text',
              'size': response.bodyBytes.length,
              'timestamp': DateTime.now().toIso8601String(),
            };
          }
        }
      } else {
        final responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Server error: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error or timeout: ${e.toString()}',
      };
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  // Get period dates (from notes.js)
  Future<List<dynamic>> getPeriodDates(
    String token, {
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      String url = '$baseUrl/notes/period-dates';
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      
      final uri = Uri.parse(url).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data'] ?? [];
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load period dates');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get current period info (from notes.js)
  Future<Map<String, dynamic>> getCurrentPeriod(
    String token, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notes/current-period'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['data'] ?? {};
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load current period');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  // Get all reports at once (for dashboard)
  Future<Map<String, dynamic>> getAllReports(
    String token, {
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        getSummaryReport(token, forceRefresh: forceRefresh),
        getPeriodStats(token, forceRefresh: forceRefresh),
      ]);

      return {
        'summary': results[0],
        'periodStats': results[1],
        'success': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load all reports: ${e.toString()}',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Preload data (call this when app starts or user logs in)
  Future<void> preloadReports(String token) async {
    try {
      await Future.wait([
        getSummaryReport(token),
        getPeriodStats(token),
      ]);
    } catch (e) {
      // Silent fail for preloading
      debugPrint('Preload failed: $e');
    }
  }
}