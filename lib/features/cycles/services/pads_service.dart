// lib/services/pads_service.dart
import 'package:dio/dio.dart';
import '../models/pads_tracking.dart';
import '../../../core/network/dio_client.dart';

class PadsService {
  late final Dio _dio;
  
  PadsService() {
    _dio = DioClient().dio;
  }

  // Save pads usage
  Future<PadsTracking?> savePadsTracking(PadsTracking tracking) async {
    try {
      final response = await _dio.post(
        '/pads/track',
        data: tracking.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data['data'] != null) {
          return PadsTracking.fromJson(response.data['data']);
        }
        return tracking; // Return the tracking object even if no data returned
      }
      
      // Handle 401 gracefully
      if (response.statusCode == 401) {
        print('Authentication required for pads tracking - skipping');
        return null;
      }
      
      throw Exception('Failed to save pads tracking: ${response.statusCode}');
    } on DioException catch (e) {
      // Handle 401 specifically
      if (e.response?.statusCode == 401) {
        print('Authentication error when saving pads tracking - skipping');
        return null; // Return null instead of throwing
      }
      print('Error saving pads tracking: $e');
      return null;
    } catch (e) {
      print('Error saving pads tracking: $e');
      return null;
    }
  }

  // Get pads tracking for date range
  Future<List<PadsTracking>> getPadsTracking({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      
      final response = await _dio.get(
        '/pads/track',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PadsTracking.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('Authentication error when getting pads tracking');
        return [];
      }
      print('Error getting pads tracking: $e');
      return [];
    } catch (e) {
      print('Error getting pads tracking: $e');
      return [];
    }
  }

  // Get pads statistics
  Future<PadsStatistics> getStatistics({int days = 30}) async {
    try {
      final response = await _dio.get(
        '/pads/statistics',
        queryParameters: {'days': days},
      );
      
      if (response.statusCode == 200 && response.data != null && response.data['statistics'] != null) {
        return PadsStatistics.fromJson(response.data['statistics']);
      }
      
      // Return empty statistics if API fails
      return _getEmptyStatistics();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('Authentication error when getting pads statistics');
      } else {
        print('Error getting pads statistics: $e');
      }
      return _getEmptyStatistics();
    } catch (e) {
      print('Error getting pads statistics: $e');
      return _getEmptyStatistics();
    }
  }

  // Get single day tracking
  Future<PadsTracking?> getTrackingForDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _dio.get('/pads/track/$dateStr');
      
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        return PadsTracking.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('Authentication error when getting tracking for date');
      }
      return null;
    } catch (e) {
      print('Error getting tracking for date: $e');
      return null;
    }
  }

  // Delete pads entry
  Future<bool> deletePadsEntry(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      await _dio.delete('/pads/track/$dateStr');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('Authentication error when deleting pads entry');
      } else {
        print('Error deleting pads entry: $e');
      }
      return false;
    } catch (e) {
      print('Error deleting pads entry: $e');
      return false;
    }
  }

  // Get weekly summary
  Future<Map<String, dynamic>> getWeeklySummary(DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final tracking = await getPadsTracking(
        startDate: weekStart,
        endDate: weekEnd,
      );
      
      int totalPads = 0;
      int totalTampons = 0;
      int totalLiners = 0;
      
      for (var entry in tracking) {
        totalPads += entry.padsUsed;
        totalTampons += entry.tamponsUsed;
        totalLiners += entry.linersUsed;
      }
      
      return {
        'totalPads': totalPads,
        'totalTampons': totalTampons,
        'totalLiners': totalLiners,
        'totalProducts': totalPads + totalTampons + totalLiners,
        'daysTracked': tracking.length,
      };
    } catch (e) {
      print('Error getting weekly summary: $e');
      return {
        'totalPads': 0,
        'totalTampons': 0,
        'totalLiners': 0,
        'totalProducts': 0,
        'daysTracked': 0,
      };
    }
  }

  // Get monthly summary
  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);
      
      final tracking = await getPadsTracking(
        startDate: startDate,
        endDate: endDate,
      );
      
      int totalPads = 0;
      int totalTampons = 0;
      int totalLiners = 0;
      
      for (var entry in tracking) {
        totalPads += entry.padsUsed;
        totalTampons += entry.tamponsUsed;
        totalLiners += entry.linersUsed;
      }
      
      return {
        'totalPads': totalPads,
        'totalTampons': totalTampons,
        'totalLiners': totalLiners,
        'totalProducts': totalPads + totalTampons + totalLiners,
        'daysTracked': tracking.length,
      };
    } catch (e) {
      print('Error getting monthly summary: $e');
      return {
        'totalPads': 0,
        'totalTampons': 0,
        'totalLiners': 0,
        'totalProducts': 0,
        'daysTracked': 0,
      };
    }
  }
  
  PadsStatistics _getEmptyStatistics() {
    return PadsStatistics(
      totalPads: 0,
      totalTampons: 0,
      totalLiners: 0,
      averagePerDay: 0,
      daysTracked: 0,
      flowIntensityCount: {},
    );
  }
}