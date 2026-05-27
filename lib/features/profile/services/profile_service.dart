import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

class ProfileService {

  final supabase =
      Supabase.instance.client;

  // ======================================================
  // GET PROFILE
  // ======================================================

  Future<ProfileModel?> getProfile()
      async {

    try {

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        return null;
      }

      final response =
          await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      // ==========================================
      // CREATE PROFILE IF NOT EXISTS
      // ==========================================

      if (response == null) {

        final newProfile = {

          'id': user.id,

          'full_name':
              user.email
                  ?.split('@')
                  .first,

          'photo_url': null,
        };

        await supabase
            .from('profiles')
            .insert(
              newProfile,
            );

        return ProfileModel
            .fromJson(
          newProfile,
        );
      }

      return ProfileModel
          .fromJson(response);

    } catch (e) {

      debugPrint(
        'GET PROFILE ERROR => $e',
      );

      return null;
    }
  }

  // ======================================================
  // UPDATE PROFILE
  // ======================================================

  Future<void> updateProfile(
    ProfileModel profile,
  ) async {

    try {

      await supabase
          .from('profiles')
          .upsert(
            profile.toJson(),
          );

    } catch (e) {

      debugPrint(
        'UPDATE PROFILE ERROR => $e',
      );

      rethrow;
    }
  }

  // ======================================================
  // DELETE PROFILE
  // ======================================================

  Future<void> deleteProfile()
      async {

    try {

      final user =
          supabase.auth.currentUser;

      if (user == null) return;

      await supabase
          .from('profiles')
          .delete()
          .eq('id', user.id);

    } catch (e) {

      debugPrint(
        'DELETE PROFILE ERROR => $e',
      );

      rethrow;
    }
  }

  // ======================================================
  // LOGOUT
  // ======================================================

  Future<void> logout() async {

    try {

      await supabase.auth
          .signOut();

    } catch (e) {

      debugPrint(
        'LOGOUT ERROR => $e',
      );

      rethrow;
    }
  }
}