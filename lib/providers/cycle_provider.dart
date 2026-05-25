// lib/providers/cycle_provider.dart
import 'package:flutter/material.dart';

class CycleProvider extends ChangeNotifier {
  Map<String, dynamic> _cycleData = {};
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get cycleData => _cycleData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateCycleData(Map<String, dynamic> data) {
    _cycleData = data;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}