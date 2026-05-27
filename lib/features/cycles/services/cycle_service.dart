import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class CycleService {
  // ======================================================
  // DIO
  // ======================================================

  late final Dio _dio;
  
  CycleService() {
    _dio = DioClient().dio;
  }

  Dio get dio => _dio;

  // ======================================================
  // CREATE CYCLE
  // ======================================================

  Future<Response> createCycle({
    required String startDate,
    String? endDate,
    int? cycleLength,
    int? periodLength,
    String? notes,
  }) async {
    try {
      return await dio.post(
        '/cycles',
        data: {
          'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          if (cycleLength != null) 'cycle_length': cycleLength,
          if (periodLength != null) 'period_length': periodLength,
          if (notes != null) 'notes': notes,
        },
      );
    } catch (e) {
      print('Error in createCycle: $e');
      rethrow;
    }
  }

  // ======================================================
  // GET CYCLES
  // ======================================================

  Future<Response> getCycles() async {
    try {
      return await dio.get('/cycles');
    } catch (e) {
      print('Error in getCycles: $e');
      rethrow;
    }
  }

  // ======================================================
  // GET SINGLE CYCLE
  // ======================================================

  Future<Response> getCycle(String id) async {
    try {
      return await dio.get('/cycles/$id');
    } catch (e) {
      print('Error in getCycle: $e');
      rethrow;
    }
  }

  // ======================================================
  // UPDATE CYCLE
  // ======================================================

  Future<Response> updateCycle({
    required String id,
    String? startDate,
    String? endDate,
    int? cycleLength,
    int? periodLength,
    String? notes,
  }) async {
    try {
      return await dio.put(
        '/cycles/$id',
        data: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          if (cycleLength != null) 'cycle_length': cycleLength,
          if (periodLength != null) 'period_length': periodLength,
          if (notes != null) 'notes': notes,
        },
      );
    } catch (e) {
      print('Error in updateCycle: $e');
      rethrow;
    }
  }

  // ======================================================
  // DELETE CYCLE
  // ======================================================

  Future<Response> deleteCycle(String id) async {
    try {
      return await dio.delete('/cycles/$id');
    } catch (e) {
      print('Error in deleteCycle: $e');
      rethrow;
    }
  }
}