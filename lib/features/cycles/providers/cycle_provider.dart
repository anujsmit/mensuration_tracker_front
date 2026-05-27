import 'package:flutter/material.dart';
import '../models/cycle_model.dart';
import '../services/cycle_service.dart';

class CycleProvider with ChangeNotifier {
  // ======================================================
  // SERVICE
  // ======================================================

  final CycleService _service = CycleService();

  // ======================================================
  // VARIABLES
  // ======================================================

  List<CycleModel> _cycles = [];
  bool _isLoading = false;
  String? _error;

  // ======================================================
  // GETTERS
  // ======================================================

  List<CycleModel> get cycles => _cycles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get most recent cycle
  CycleModel? get mostRecentCycle {
    if (_cycles.isEmpty) return null;
    return _cycles.reduce((a, b) => a.startDate.isAfter(b.startDate) ? a : b);
  }
  
  // Get cycles in date range
  List<CycleModel> getCyclesInRange(DateTime start, DateTime end) {
    return _cycles.where((cycle) {
      return cycle.startDate.isAfter(start) && cycle.startDate.isBefore(end);
    }).toList();
  }

  // ======================================================
  // SET LOADING
  // ======================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ======================================================
  // SET ERROR
  // ======================================================

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ======================================================
  // CLEAR ERROR
  // ======================================================
  
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ======================================================
  // GET ALL CYCLES
  // ======================================================

  Future<void> fetchCycles() async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _service.getCycles();
      
      if (response.data != null && response.data['data'] != null) {
        final List data = response.data['data'];
        _cycles = data
            .map((e) => CycleModel.fromJson(e))
            .toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate));
      } else {
        _cycles = [];
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      print('Error fetching cycles: $e');
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

    final response = await _service.createCycle(
      startDate: startDate,
      endDate: endDate,
      cycleLength: cycleLength,
      periodLength: periodLength,
      notes: notes,
    );

    debugPrint('📥 Response status: ${response.statusCode}');
    debugPrint('📥 Response data: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data != null && response.data['data'] != null) {
        final cycle = CycleModel.fromJson(response.data['data']);
        _cycles.insert(0, cycle);
        notifyListeners();
        return true;
      } else if (response.data != null && response.data['cycle'] != null) {
        // Handle different response structure
        final cycle = CycleModel.fromJson(response.data['cycle']);
        _cycles.insert(0, cycle);
        notifyListeners();
        return true;
      }
    }
    
    // Handle error response
    final errorMsg = response.data?['message'] ?? 'Failed to create cycle';
    _setError(errorMsg);
    return false;
    
  } catch (e) {
    _setError(e.toString());
    debugPrint('Error creating cycle: $e');
    return false;
  } finally {
    _setLoading(false);
  }
}
  // ======================================================
  // UPDATE CYCLE
  // ======================================================

  Future<bool> updateCycle({
    required String id,
    String? startDate,
    String? endDate,
    int? cycleLength,
    int? periodLength,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _service.updateCycle(
        id: id,
        startDate: startDate,
        endDate: endDate,
        cycleLength: cycleLength,
        periodLength: periodLength,
        notes: notes,
      );

      if (response.data != null && response.data['data'] != null) {
        final updatedCycle = CycleModel.fromJson(response.data['data']);
        final index = _cycles.indexWhere((cycle) => cycle.id == id);
        if (index != -1) {
          _cycles[index] = updatedCycle;
          notifyListeners();
        }
        return true;
      }
      
      return false;
    } catch (e) {
      _setError(e.toString());
      print('Error updating cycle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ======================================================
  // DELETE CYCLE
  // ======================================================

  Future<bool> deleteCycle(String id) async {
    try {
      _setLoading(true);
      _setError(null);

      await _service.deleteCycle(id);

      _cycles.removeWhere((element) => element.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      print('Error deleting cycle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}