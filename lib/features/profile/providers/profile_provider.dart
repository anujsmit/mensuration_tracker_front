import 'package:flutter/material.dart';

import '../models/profile_model.dart';

import '../services/profile_service.dart';

class ProfileProvider
    with ChangeNotifier {

  // ======================================================
  // SERVICE
  // ======================================================

  final ProfileService _service =
      ProfileService();

  // ======================================================
  // VARIABLES
  // ======================================================

  ProfileModel? _profile;

  bool _isLoading = false;

  String? _error;

  // ======================================================
  // GETTERS
  // ======================================================

  ProfileModel? get profile =>
      _profile;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  // ======================================================
  // FETCH PROFILE
  // ======================================================

  Future<void> fetchProfile()
      async {

    if (_isLoading) return;

    try {

      _isLoading = true;

      _error = null;

      notifyListeners();

      _profile =
          await _service
              .getProfile();

    } catch (e) {

      debugPrint(
        'PROFILE FETCH ERROR => $e',
      );

      _error = e.toString();

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }

  // ======================================================
  // UPDATE PROFILE
  // ======================================================

  Future<bool> updateProfile({

    required String fullName,

    String? avatarUrl,

  }) async {

    try {

      _isLoading = true;

      _error = null;

      notifyListeners();

      final updated =
          _profile?.copyWith(

        fullName:
            fullName,

        avatarUrl:
            avatarUrl,
      );

      if (updated == null) {
        return false;
      }

      await _service
          .updateProfile(
        updated,
      );

      _profile = updated;

      return true;

    } catch (e) {

      debugPrint(
        'PROFILE UPDATE ERROR => $e',
      );

      _error = e.toString();

      return false;

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }

  // ======================================================
  // CLEAR
  // ======================================================

  void clearProfile() {

    _profile = null;

    notifyListeners();
  }
}