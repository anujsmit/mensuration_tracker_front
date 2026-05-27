// ======================================================
// FILE:
// lib/features/reports/services/report_service.dart
// ======================================================

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class ReportService {

  // ======================================================
  // DIO
  // ======================================================

  final Dio dio =
      DioClient().dio;

  // ======================================================
  // GET REPORT
  // ======================================================

  Future<Response> getReport()
      async {

    return await dio.get(
      '/reports',
    );

  }

  // ======================================================
  // EXPORT PDF
  // ======================================================

  Future<Response> exportPdf()
      async {

    return await dio.get(
      '/reports/pdf',
    );

  }

}