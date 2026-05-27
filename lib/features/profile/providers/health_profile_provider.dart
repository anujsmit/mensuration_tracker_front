import 'package:flutter/material.dart';

import '../models/health_profile_model.dart';
import '../services/health_profile_service.dart';

class HealthProfileProvider with ChangeNotifier {
  // ======================================================
  // SERVICE
  // ======================================================

  final HealthProfileService _service = HealthProfileService();

  // ======================================================
  // VARIABLES
  // ======================================================

  HealthProfileModel? _healthProfile;
  bool _isLoading = false;
  String? _error;

  // ======================================================
  // GETTERS
  // ======================================================

  HealthProfileModel? get healthProfile => _healthProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ======================================================
  // FETCH HEALTH PROFILE
  // ======================================================

  Future<void> fetchHealthProfile() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _healthProfile = await _service.getHealthProfile();
    } catch (e) {
      debugPrint('HEALTH PROFILE ERROR => $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // SAVE HEALTH PROFILE (UPDATED WITH NULLABLE PARAMETERS)
  // ======================================================

  Future<bool> saveHealthProfile({
    int? age,
    required int cycleLength,
    required DateTime lastPeriodDate,
    int? bleedingDuration,
    required String flowRegularity,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final current = _healthProfile;

      // If we have an existing profile, update it
      if (current != null) {
        final updated = HealthProfileModel(
          id: current.id,
          userId: current.userId,
          age: age ?? current.age,
          cycleLength: cycleLength,
          lastPeriodDate: lastPeriodDate,
          bleedingDuration: bleedingDuration ?? current.bleedingDuration,
          flowRegularity: flowRegularity,
        );

        await _service.saveHealthProfile(updated);
        _healthProfile = updated;
      } else {
        // Create new profile
        final newProfile = HealthProfileModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user_id', // Replace with actual user ID
          age: age,
          cycleLength: cycleLength,
          lastPeriodDate: lastPeriodDate,
          bleedingDuration: bleedingDuration,
          flowRegularity: flowRegularity,
        );

        await _service.saveHealthProfile(newProfile);
        _healthProfile = newProfile;
      }

      return true;
    } catch (e) {
      debugPrint('SAVE HEALTH PROFILE ERROR => $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================
  // UPDATE HEALTH PROFILE (PARTIAL UPDATE)
  // ======================================================

// Add this method to HealthProfileProvider class
Future<bool> updateHealthProfile({
  int? cycleLength,
  DateTime? lastPeriodDate,
  int? bleedingDuration,
  String? flowRegularity,
}) async {
  if (_healthProfile == null) return false;
  
  try {
    _isLoading = true;
    notifyListeners();
    
    final updated = HealthProfileModel(
      id: _healthProfile!.id,
      userId: _healthProfile!.userId,
      age: _healthProfile!.age,
      cycleLength: cycleLength ?? _healthProfile!.cycleLength,
      lastPeriodDate: lastPeriodDate ?? _healthProfile!.lastPeriodDate,
      bleedingDuration: bleedingDuration ?? _healthProfile!.bleedingDuration,
      flowRegularity: flowRegularity ?? _healthProfile!.flowRegularity,
    );
    
    await _service.saveHealthProfile(updated);
    _healthProfile = updated;
    
    return true;
  } catch (e) {
    print('Update health profile error: $e');
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  // ======================================================
  // PREDICTION
  // ======================================================

  DateTime? get nextPredictedPeriod {
    final profile = _healthProfile;
    if (profile == null) return null;
    if (profile.lastPeriodDate == null) return null;

    return profile.lastPeriodDate!.add(
      Duration(days: profile.cycleLength ?? 28),
    );
  }

  // ======================================================
  // OVULATION
  // ======================================================

  DateTime? get predictedOvulation {
    final profile = _healthProfile;
    if (profile == null) return null;
    if (profile.lastPeriodDate == null) return null;

    final ovulationDay = (profile.cycleLength ?? 28) - 14;
    return profile.lastPeriodDate!.add(Duration(days: ovulationDay));
  }

  // ======================================================
  // FERTILE WINDOW
  // ======================================================

  DateTime? get fertileWindowStart {
    final ovulation = predictedOvulation;
    if (ovulation == null) return null;
    
    // Fertile window is typically 5 days before ovulation
    return ovulation.subtract(const Duration(days: 5));
  }

  DateTime? get fertileWindowEnd {
    final ovulation = predictedOvulation;
    if (ovulation == null) return null;
    
    // Fertile window ends on ovulation day
    return ovulation;
  }

  // ======================================================
  // PMS WINDOW
  // ======================================================

  DateTime? get pmsStart {
    final nextPeriod = nextPredictedPeriod;
    if (nextPeriod == null) return null;
    
    // PMS typically starts 5-7 days before period
    return nextPeriod.subtract(const Duration(days: 7));
  }

  // ======================================================
  // CLEAR
  // ======================================================

  void clearHealthProfile() {
    _healthProfile = null;
    notifyListeners();
  }
}