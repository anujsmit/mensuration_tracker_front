// ======================================================
// FILE:
// lib/features/symptoms/services/symptom_service.dart
// ======================================================

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class SymptomService {

  // ======================================================
  // DIO
  // ======================================================

  final Dio dio =
      DioClient().dio;

  // ======================================================
  // ADD SYMPTOM
  // ======================================================

  Future<Response> addSymptom({

    required String symptomType,

    required String severity,

    required String symptomDate,

    String? notes,

  }) async {

    return await dio.post(

      '/symptoms',

      data: {

        'symptom_type':
            symptomType,

        'severity':
            severity,

        'symptom_date':
            symptomDate,

        'notes':
            notes,

      },

    );

  }

  // ======================================================
  // GET SYMPTOMS
  // ======================================================

  Future<Response> getSymptoms()
      async {

    return await dio.get(
      '/symptoms',
    );

  }

  // ======================================================
  // DELETE SYMPTOM
  // ======================================================

  Future<Response> deleteSymptom(
    String id,
  ) async {

    return await dio.delete(
      '/symptoms/$id',
    );

  }

  // ======================================================
  // ANALYTICS
  // ======================================================

  Future<Response> getAnalytics()
      async {

    return await dio.get(
      '/symptoms/analytics',
    );

  }

}