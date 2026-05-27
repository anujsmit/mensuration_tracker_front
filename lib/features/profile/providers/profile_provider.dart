// ======================================================
// FILE:
// lib/features/profile/providers/profile_provider.dart
// ======================================================

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
  // FETCH PROFILE
  // ======================================================

  Future<void> fetchProfile()
      async {

    try {

      _setLoading(true);

      final response =
          await _service
              .getProfile();

      _profile =
          ProfileModel.fromJson(
        response.data['data'],
      );

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    } finally {

      _setLoading(false);

    }

  }

  // ======================================================
  // UPDATE PROFILE
  // ======================================================

  Future<bool> updateProfile({

    required String fullName,

    required String username,

    String? phoneNumber,

    String? bio,

    int? age,

    double? weight,

    double? height,

  }) async {

    try {

      _setLoading(true);

      _setError(null);

      final response =
          await _service
              .updateProfile(

        fullName:
            fullName,

        username:
            username,

        phoneNumber:
            phoneNumber,

        bio:
            bio,

        age:
            age,

        weight:
            weight,

        height:
            height,

      );

      _profile =
          ProfileModel.fromJson(
        response.data['data'],
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
  // DELETE ACCOUNT
  // ======================================================

  Future<bool> deleteAccount()
      async {

    try {

      _setLoading(true);

      await _service
          .deleteAccount();

      _profile = null;

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