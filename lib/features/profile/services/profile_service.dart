// ======================================================
// FILE:
// lib/features/profile/services/profile_service.dart
// ======================================================

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class ProfileService {

  // ======================================================
  // DIO
  // ======================================================

  final Dio dio =
      DioClient().dio;

  // ======================================================
  // GET PROFILE
  // ======================================================

  Future<Response> getProfile()
      async {

    return await dio.get(
      '/profile',
    );

  }

  // ======================================================
  // UPDATE PROFILE
  // ======================================================

  Future<Response> updateProfile({

    required String fullName,

    required String username,

    String? phoneNumber,

    String? bio,

    int? age,

    double? weight,

    double? height,

  }) async {

    return await dio.put(

      '/profile',

      data: {

        'full_name':
            fullName,

        'username':
            username,

        'phone_number':
            phoneNumber,

        'bio':
            bio,

        'age':
            age,

        'weight':
            weight,

        'height':
            height,

      },

    );

  }

  // ======================================================
  // DELETE ACCOUNT
  // ======================================================

  Future<Response> deleteAccount()
      async {

    return await dio.delete(
      '/profile',
    );

  }

}