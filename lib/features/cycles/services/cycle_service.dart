import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class CycleService {

  // ======================================================
  // DIO
  // ======================================================

  final Dio dio =
      DioClient().dio;

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

    return await dio.post(

      '/cycles',

      data: {

        'start_date':
            startDate,

        'end_date':
            endDate,

        'cycle_length':
            cycleLength,

        'period_length':
            periodLength,

        'notes': notes,

      },

    );

  }

  // ======================================================
  // GET CYCLES
  // ======================================================

  Future<Response> getCycles()
      async {

    return await dio.get(
      '/cycles',
    );

  }

  // ======================================================
  // GET SINGLE CYCLE
  // ======================================================

  Future<Response> getCycle(
    String id,
  ) async {

    return await dio.get(
      '/cycles/$id',
    );

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

    return await dio.put(

      '/cycles/$id',

      data: {

        'start_date':
            startDate,

        'end_date':
            endDate,

        'cycle_length':
            cycleLength,

        'period_length':
            periodLength,

        'notes': notes,

      },

    );

  }

  // ======================================================
  // DELETE CYCLE
  // ======================================================

  Future<Response> deleteCycle(
    String id,
  ) async {

    return await dio.delete(
      '/cycles/$id',
    );

  }

}