// ======================================================
// FILE:
// lib/features/notifications/providers/notification_provider.dart
// ======================================================

import 'package:flutter/material.dart';

import '../models/notification_model.dart';

import '../services/notification_service.dart';

class NotificationProvider
    with ChangeNotifier {

  // ======================================================
  // SERVICE
  // ======================================================

  final NotificationService
      _service =
      NotificationService();

  // ======================================================
  // VARIABLES
  // ======================================================

  List<NotificationModel>
      _notifications = [];

  bool _isLoading = false;

  String? _error;

  // ======================================================
  // GETTERS
  // ======================================================

  List<NotificationModel>
      get notifications =>
          _notifications;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  int get unreadCount =>

      _notifications
          .where(
            (e) => !e.isRead,
          )
          .length;

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
  // FETCH NOTIFICATIONS
  // ======================================================

  Future<void>
      fetchNotifications()
      async {

    try {

      _setLoading(true);

      final response =
          await _service
              .getNotifications();

      final List data =
          response.data['data'];

      _notifications =
          data
              .map(
                (e) =>
                    NotificationModel
                        .fromJson(e),
              )
              .toList();

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    } finally {

      _setLoading(false);

    }

  }

  // ======================================================
  // MARK AS READ
  // ======================================================

  Future<void> markAsRead(
    String id,
  ) async {

    try {

      await _service.markAsRead(
        id,
      );

      final index =
          _notifications.indexWhere(
        (e) => e.id == id,
      );

      if (index != -1) {

        _notifications[index] =
            NotificationModel(

          id:
              _notifications[index]
                  .id,

          userId:
              _notifications[index]
                  .userId,

          title:
              _notifications[index]
                  .title,

          message:
              _notifications[index]
                  .message,

          isRead: true,

          type:
              _notifications[index]
                  .type,

          createdAt:
              _notifications[index]
                  .createdAt,

        );

      }

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    }

  }

  // ======================================================
  // MARK ALL AS READ
  // ======================================================

  Future<void> markAllAsRead()
      async {

    try {

      await _service.markAllRead();

      _notifications =

          _notifications.map(
            (e) {

          return NotificationModel(

            id: e.id,

            userId: e.userId,

            title: e.title,

            message: e.message,

            isRead: true,

            type: e.type,

            createdAt:
                e.createdAt,

          );

        }).toList();

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    }

  }

  // ======================================================
  // DELETE NOTIFICATION
  // ======================================================

  Future<void> deleteNotification(
    String id,
  ) async {

    try {

      await _service
          .deleteNotification(id);

      _notifications.removeWhere(
        (e) => e.id == id,
      );

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    }

  }

}