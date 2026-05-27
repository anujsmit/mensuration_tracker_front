// ======================================================
// FILE:
// lib/features/cycles/providers/cycle_provider.dart
// ======================================================

import 'package:flutter/material.dart';

import '../models/cycle_model.dart';

import '../services/cycle_service.dart';

class CycleProvider
    with ChangeNotifier {

  // ======================================================
  // SERVICE
  // ======================================================

  final CycleService _service =
      CycleService();

  // ======================================================
  // VARIABLES
  // ======================================================

  List<CycleModel> _cycles = [];

  bool _isLoading = false;

  String? _error;

  // ======================================================
  // GETTERS
  // ======================================================

  List<CycleModel> get cycles =>
      _cycles;

  bool get isLoading =>
      _isLoading;

  String? get error => _error;

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
  // GET ALL CYCLES
  // ======================================================

  Future<void> fetchCycles()
      async {

    try {

      _setLoading(true);

      _setError(null);

      final response =
          await _service.getCycles();

      final List data =
          response.data['data'];

      _cycles =
          data
              .map(
                (e) =>
                    CycleModel
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
  // CREATE CYCLE
  // ======================================================

  Future<bool> createCycle({

    required String startDate,

    String? endDate,

    int? cycleLength,

    int? periodLength,

    String? notes,

  }) async {

    try {

      _setLoading(true);

      _setError(null);

      final response =
          await _service
              .createCycle(

        startDate: startDate,

        endDate: endDate,

        cycleLength:
            cycleLength,

        periodLength:
            periodLength,

        notes: notes,

      );

      final cycle =
          CycleModel.fromJson(
        response.data['data'],
      );

      _cycles.insert(0, cycle);

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
  // DELETE CYCLE
  // ======================================================

  Future<bool> deleteCycle(
    String id,
  ) async {

    try {

      _setLoading(true);

      _setError(null);

      await _service.deleteCycle(
        id,
      );

      _cycles.removeWhere(
        (element) =>
            element.id == id,
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

}