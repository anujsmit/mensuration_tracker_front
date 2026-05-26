// lib/providers/profile_provider.dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider with ChangeNotifier {
  // ==========================================
  // SUPABASE
  // ==========================================

  final supabase =
      Supabase.instance.client;

  // ==========================================
  // STATE
  // ==========================================

  Map<String, dynamic>? _profile;

  List<dynamic> _cycles = [];

  List<dynamic> _symptoms = [];

  bool _isVerified = false;

  String? _username;

  String? _email;

  String _error = '';

  bool _isLoading = false;

  // ==========================================
  // GETTERS
  // ==========================================

  Map<String, dynamic>? get profile =>
      _profile;

  List<dynamic> get cycles =>
      _cycles;

  List<dynamic> get symptoms =>
      _symptoms;

  bool get isVerified =>
      _isVerified;

  String? get username =>
      _username;

  String? get email =>
      _email;

  String get error =>
      _error;

  bool get isLoading =>
      _isLoading;

  // ==========================================
  // CLEAR DATA
  // ==========================================

  void clearData() {
    _profile = null;

    _cycles = [];

    _symptoms = [];

    _isVerified = false;

    _username = null;

    _email = null;

    _error = '';

    _isLoading = false;

    notifyListeners();
  }

  // ==========================================
  // FETCH PROFILE
  // ==========================================

  Future<void> fetchProfile(
    String userId,
    String token,
  ) async {
    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      final response =
          await supabase
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      _profile = response;

      _username =
          response?['full_name'];

      _email =
          supabase.auth.currentUser
              ?.email;

      _isVerified =
          supabase.auth.currentUser
                  ?.emailConfirmedAt !=
              null;

      _error = '';

    } catch (e) {
      _error = e.toString();

      debugPrint(
        'Fetch profile error: $e',
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // UPDATE USERNAME
  // ==========================================

  Future<bool> updateUsername(
    String userId,
    String username,
    String token,
  ) async {
    if (username.trim().isEmpty) {
      _error =
          'Username cannot be empty';

      notifyListeners();

      return false;
    }

    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      await supabase
          .from('profiles')
          .update({
        'full_name':
            username.trim(),
      }).eq('id', userId);

      _username =
          username.trim();

      _error = '';

      return true;

    } catch (e) {
      _error = e.toString();

      return false;

    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // SAVE PROFILE
  // ==========================================

  Future<bool> saveProfile(
    Map<String, dynamic> profileData,
    String token,
  ) async {
    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      final userId =
          supabase
              .auth.currentUser!.id;

      await supabase
          .from('profiles')
          .upsert({
        'id': userId,

        'full_name':
            profileData[
                    'full_name'] ??
                _username,

        'age':
            profileData['age'],

        'weight':
            profileData['weight'],

        'height':
            profileData['height'],

        'cycle_length':
            profileData[
                'cycleLength'],

        'last_period_date':
            profileData[
                'lastPeriodDate'],

        'age_at_menarche':
            profileData[
                'ageAtMenarche'],

        'flow_regularity':
            profileData[
                'flowRegularity'],

        'bleeding_duration':
            profileData[
                'bleedingDuration'],

        'flow_amount':
            profileData[
                'flowAmount'],

        'period_interval':
            profileData[
                'periodInterval'],

        'updated_at':
            DateTime.now()
                .toIso8601String(),
      });

      await fetchProfile(
        userId,
        '',
      );

      _error = '';

      return true;

    } catch (e) {
      _error = e.toString();

      debugPrint(
        'Save profile error: $e',
      );

      return false;

    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // FETCH CYCLES
  // ==========================================

  Future<void> fetchCycles(
    String userId,
    String token,
  ) async {
    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      final response =
          await supabase
              .from('cycles')
              .select()
              .eq('user_id', userId)
              .order(
                'start_date',
                ascending: false,
              );

      _cycles = response;

      _error = '';

    } catch (e) {
      _error = e.toString();

      _cycles = [];
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // RECORD CYCLE
  // ==========================================

  Future<bool> recordCycle(
    Map<String, dynamic> cycleData,
    String token,
  ) async {
    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      final userId =
          supabase
              .auth.currentUser!.id;

      await supabase
          .from('cycles')
          .insert({
        'user_id': userId,

        'start_date':
            cycleData['startDate'],

        'end_date':
            cycleData['endDate'],

        'notes':
            cycleData['notes'] ??
                '',
      });

      await fetchCycles(
        userId,
        '',
      );

      _error = '';

      return true;

    } catch (e) {
      _error = e.toString();

      return false;

    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // FETCH SYMPTOMS
  // ==========================================

  Future<void> fetchSymptoms(
    String userId,
    String token, {
    String? startDate,
    String? endDate,
    String? symptomType,
  }) async {
    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      dynamic query = supabase
          .from('symptoms')
          .select()
          .eq('user_id', userId);

      if (symptomType != null &&
          symptomType.isNotEmpty) {
        query = query.eq(
          'symptom_type',
          symptomType,
        );
      }

      final response =
          await query.order(
        'date',
        ascending: false,
      );

      _symptoms = response;

      _error = '';

    } catch (e) {
      _error = e.toString();

      _symptoms = [];
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // RECORD SYMPTOM
  // ==========================================

  Future<bool> recordSymptom(
    Map<String, dynamic> symptomData,
    String token,
  ) async {
    _isLoading = true;

    _error = '';

    notifyListeners();

    try {
      final userId =
          supabase
              .auth.currentUser!.id;

      await supabase
          .from('symptoms')
          .insert({
        'user_id': userId,

        'date':
            symptomData['date'],

        'symptom_type':
            symptomData[
                'symptomType'],

        'severity':
            symptomData[
                'severity'],

        'notes':
            symptomData['notes'] ??
                '',
      });

      await fetchSymptoms(
        userId,
        '',
      );

      _error = '';

      return true;

    } catch (e) {
      _error = e.toString();

      return false;

    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ==========================================
  // SUMMARY REPORT
  // ==========================================

  Future<Map<String, dynamic>?>
      getSummaryReport(
    String token,
  ) async {
    try {
      return {
        'profile': _profile,
        'cycles_count':
            _cycles.length,
        'symptoms_count':
            _symptoms.length,
      };

    } catch (e) {
      debugPrint(
        'Summary report error: $e',
      );

      return null;
    }
  }

  // ==========================================
  // DOWNLOAD HEALTH REPORT
  // ==========================================

  Future<Map<String, dynamic>>
      downloadHealthReport(
    String token,
  ) async {
    try {
      final report = '''
Health Report

User: ${_username ?? 'Unknown'}

Email: ${_email ?? 'Unknown'}

Cycles Recorded: ${_cycles.length}

Symptoms Recorded: ${_symptoms.length}

Generated At:
${DateTime.now()}
''';

      return {
        'success': true,

        'data':
            Uint8List.fromList(
          report.codeUnits,
        ),

        'filename':
            'health_report.txt',

        'contentType': 'text',
      };

    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}