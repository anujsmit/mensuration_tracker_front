// ======================================================
// FILE:
// lib/features/notifications/services/notification_service.dart
// ======================================================

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class NotificationService {

  // ======================================================
  // DIO
  // ======================================================

  final Dio dio =
      DioClient().dio;

  // ======================================================
  // GET NOTIFICATIONS
  // ======================================================

  Future<Response> getNotifications()
      async {

    return await dio.get(
      '/notifications',
    );

  }

  // ======================================================
  // MARK AS READ
  // ======================================================

  Future<Response> markAsRead(
    String id,
  ) async {

    return await dio.put(
      '/notifications/$id/read',
    );

  }

  // ======================================================
  // MARK ALL READ
  // ======================================================

  Future<Response> markAllRead()
      async {

    return await dio.put(
      '/notifications/mark-all-read',
    );

  }

  // ======================================================
  // DELETE NOTIFICATION
  // ======================================================

  Future<Response> deleteNotification(
    String id,
  ) async {

    return await dio.delete(
      '/notifications/$id',
    );

  }

  // ======================================================
  // SAVE FCM TOKEN
  // ======================================================

  Future<Response> saveFcmToken(
    String token,
  ) async {

    return await dio.post(

      '/notifications/save-token',

      data: {
        'fcm_token': token,
      },

    );

  }

}