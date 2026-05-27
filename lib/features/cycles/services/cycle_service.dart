// lib/services/cycle_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mensurationhealthapp/core/network/dio_client.dart';

class CycleService {
  late final Dio _dio;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final dioClient = DioClient();
      await dioClient.initialize();
      _dio = dioClient.client;
      _isInitialized = true;
    }
  }

  Future<Response> createCycle({
    required String startDate,
    String? endDate,
    int? cycleLength,
    int? periodLength,
    String? notes,
  }) async {
    await _ensureInitialized();
    
    try {
      final data = {
        'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (cycleLength != null) 'cycle_length': cycleLength,
        if (periodLength != null) 'period_length': periodLength,
        if (notes != null) 'notes': notes,
      };
      
      debugPrint('📝 Creating cycle with data: $data');
      
      final response = await _dio.post('/cycles', data: data);
      return response;
    } catch (e) {
      debugPrint('❌ Error in createCycle: $e');
      rethrow;
    }
  }

  Future<Response> getCycles() async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get('/cycles');
      return response;
    } catch (e) {
      debugPrint('❌ Error in getCycles: $e');
      rethrow;
    }
  }

  Future<Response> getCycle(String id) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.get('/cycles/$id');
      return response;
    } catch (e) {
      debugPrint('❌ Error in getCycle: $e');
      rethrow;
    }
  }

  Future<Response> updateCycle({
    required String id,
    String? startDate,
    String? endDate,
    int? cycleLength,
    int? periodLength,
    String? notes,
  }) async {
    await _ensureInitialized();
    
    try {
      final data = {
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (cycleLength != null) 'cycle_length': cycleLength,
        if (periodLength != null) 'period_length': periodLength,
        if (notes != null) 'notes': notes,
      };
      
      final response = await _dio.put('/cycles/$id', data: data);
      return response;
    } catch (e) {
      debugPrint('❌ Error in updateCycle: $e');
      rethrow;
    }
  }

  Future<Response> deleteCycle(String id) async {
    await _ensureInitialized();
    
    try {
      final response = await _dio.delete('/cycles/$id');
      return response;
    } catch (e) {
      debugPrint('❌ Error in deleteCycle: $e');
      rethrow;
    }
  }
}