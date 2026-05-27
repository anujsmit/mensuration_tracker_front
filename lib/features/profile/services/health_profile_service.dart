import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/health_profile_model.dart';

class HealthProfileService {

  final supabase =
      Supabase.instance.client;

  // ======================================================
  // GET HEALTH PROFILE
  // ======================================================

  Future<HealthProfileModel?>
      getHealthProfile()
      async {

    try {

      final user =
          supabase.auth.currentUser;

      if (user == null) {
        return null;
      }

      final response =
          await supabase
              .from('user_profiles')
              .select()
              .eq(
                'user_id',
                user.id,
              )
              .maybeSingle();

      // ==========================================
      // CREATE EMPTY PROFILE
      // ==========================================

      if (response == null) {

        final emptyProfile = {

          'user_id': user.id,
        };

        final inserted =
            await supabase
                .from(
                  'user_profiles',
                )
                .insert(
                  emptyProfile,
                )
                .select()
                .single();

        return HealthProfileModel
            .fromJson(
          inserted,
        );
      }

      return HealthProfileModel
          .fromJson(response);

    } catch (e) {

      debugPrint(
        'GET HEALTH PROFILE ERROR => $e',
      );

      return null;
    }
  }

  // ======================================================
  // SAVE HEALTH PROFILE
  // ======================================================

  Future<void> saveHealthProfile(
    HealthProfileModel profile,
  ) async {

    try {

      await supabase
          .from('user_profiles')
          .upsert(
            profile.toJson(),
          );

    } catch (e) {

      debugPrint(
        'SAVE HEALTH PROFILE ERROR => $e',
      );

      rethrow;
    }
  }

  // ======================================================
  // DELETE HEALTH PROFILE
  // ======================================================

  Future<void>
      deleteHealthProfile()
      async {

    try {

      final user =
          supabase.auth.currentUser;

      if (user == null) return;

      await supabase
          .from('user_profiles')
          .delete()
          .eq(
            'user_id',
            user.id,
          );

    } catch (e) {

      debugPrint(
        'DELETE HEALTH PROFILE ERROR => $e',
      );

      rethrow;
    }
  }

  // ======================================================
  // NEXT PERIOD PREDICTION
  // ======================================================

  DateTime? predictNextPeriod(
    HealthProfileModel profile,
  ) {

    if (profile.lastPeriodDate ==
        null) {

      return null;
    }

    return profile.lastPeriodDate!
        .add(

      Duration(
        days:
            profile.cycleLength ??
                28,
      ),
    );
  }

  // ======================================================
  // OVULATION PREDICTION
  // ======================================================

  DateTime? predictOvulation(
    HealthProfileModel profile,
  ) {

    if (profile.lastPeriodDate ==
        null) {

      return null;
    }

    final ovulationDay =
        (profile.cycleLength ??
                28) -
            14;

    return profile.lastPeriodDate!
        .add(

      Duration(
        days:
            ovulationDay,
      ),
    );
  }

  // ======================================================
  // FERTILITY WINDOW
  // ======================================================

  List<DateTime>
      predictFertilityWindow(
    HealthProfileModel profile,
  ) {

    final ovulation =
        predictOvulation(profile);

    if (ovulation == null) {
      return [];
    }

    return [

      ovulation.subtract(
        const Duration(
          days: 5,
        ),
      ),

      ovulation,
    ];
  }
}