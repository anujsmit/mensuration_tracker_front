// ======================================================
// FILE:
// lib/features/reports/providers/report_provider.dart
// ======================================================

import 'package:flutter/material.dart';

import '../models/report_model.dart';

import '../services/report_service.dart';

class ReportProvider
    with ChangeNotifier {

  // ======================================================
  // SERVICE
  // ======================================================

  final ReportService _service =
      ReportService();

  // ======================================================
  // VARIABLES
  // ======================================================

  ReportModel? _report;

  bool _isLoading = false;

  String? _error;

  // ======================================================
  // GETTERS
  // ======================================================

  ReportModel? get report =>
      _report;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  // ======================================================
  // SET LOADING
  // ======================================================

  void _setLoading(
    bool value,
  ) {

    _isLoading = value;

    notifyListeners();

  }

  // ======================================================
  // SET ERROR
  // ======================================================

  void _setError(
    String? value,
  ) {

    _error = value;

    notifyListeners();

  }

  // ======================================================
  // FETCH REPORT
  // ======================================================

  Future<void> fetchReport()
      async {

    try {

      _setLoading(true);

      final response =
          await _service.getReport();

      _report =
          ReportModel.fromJson(
        response.data['data'],
      );

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    } finally {

      _setLoading(false);

    }

  }

}