// ======================================================
// FILE:
// lib/features/symptoms/providers/symptom_provider.dart
// ======================================================

import 'package:flutter/material.dart';

import '../models/symptom_model.dart';

import '../services/symptom_service.dart';

class SymptomProvider
    with ChangeNotifier {

  // ======================================================
  // SERVICE
  // ======================================================

  final SymptomService _service =
      SymptomService();

  // ======================================================
  // VARIABLES
  // ======================================================

  List<SymptomModel>
      _symptoms = [];

  bool _isLoading = false;

  String? _error;

  Map<String, dynamic>
      _analytics = {};

  // ======================================================
  // GETTERS
  // ======================================================

  List<SymptomModel>
      get symptoms =>
          _symptoms;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  Map<String, dynamic>
      get analytics =>
          _analytics;

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
  // FETCH SYMPTOMS
  // ======================================================

  Future<void> fetchSymptoms()
      async {

    try {

      _setLoading(true);

      final response =
          await _service
              .getSymptoms();

      final List data =
          response.data['data'];

      _symptoms =
          data
              .map(
                (e) =>
                    SymptomModel
                        .fromJson(e),
              )
              .toList();

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    } finally {

      _setLoading(false);

    }

  }

  // ======================================================
  // ADD SYMPTOM
  // ======================================================

  Future<bool> addSymptom({

    required String symptomType,

    required String severity,

    required String symptomDate,

    String? notes,

  }) async {

    try {

      _setLoading(true);

      final response =
          await _service
              .addSymptom(

        symptomType:
            symptomType,

        severity:
            severity,

        symptomDate:
            symptomDate,

        notes:
            notes,

      );

      final symptom =
          SymptomModel.fromJson(
        response.data['data'],
      );

      _symptoms.insert(
        0,
        symptom,
      );

      notifyListeners();

      return true;

    } catch (e) {

      _setError(e.toString());

      return false;

    } finally {

      _setLoading(false);

    }

  }

  // ======================================================
  // DELETE SYMPTOM
  // ======================================================

  Future<void> deleteSymptom(
    String id,
  ) async {

    try {

      await _service
          .deleteSymptom(id);

      _symptoms.removeWhere(
        (e) => e.id == id,
      );

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    }

  }

  // ======================================================
  // FETCH ANALYTICS
  // ======================================================

  Future<void> fetchAnalytics()
      async {

    try {

      final response =
          await _service
              .getAnalytics();

      _analytics =
          response.data['data'];

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    }

  }

}