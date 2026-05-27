// ======================================================
// FILE:
// lib/features/notifications/models/notification_model.dart
// ======================================================

class NotificationModel {

  final String id;

  final String userId;

  final String title;

  final String message;

  final bool isRead;

  final String? type;

  final DateTime createdAt;

  NotificationModel({

    required this.id,

    required this.userId,

    required this.title,

    required this.message,

    required this.isRead,

    this.type,

    required this.createdAt,

  });

  // ======================================================
  // FROM JSON
  // ======================================================

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return NotificationModel(

      id: json['id'] ?? '',

      userId:
          json['user_id'] ?? '',

      title:
          json['title'] ?? '',

      message:
          json['message'] ?? '',

      isRead:
          json['is_read'] ?? false,

      type:
          json['type'],

      createdAt: DateTime.parse(
        json['created_at'],
      ),

    );

  }

  // ======================================================
  // TO JSON
  // ======================================================

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'user_id': userId,

      'title': title,

      'message': message,

      'is_read': isRead,

      'type': type,

      'created_at':
          createdAt.toIso8601String(),

    };

  }

}