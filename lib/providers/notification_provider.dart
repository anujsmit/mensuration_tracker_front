import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Helper to parse color from a hex string (e.g., "#RRGGBB")
Color _colorFromHex(String hexColor) {
  try {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  } catch (e) {
    return Colors.grey; // Fallback color
  }
}

// Helper to map icon names from the backend to Flutter's IconData
IconData _getIconData(String? iconName) {
  switch (iconName) {
    case 'warning':
      return Icons.warning_amber_rounded;
    case 'health_and_safety':
      return Icons.health_and_safety_outlined;
    case 'admin_panel_settings':
      return Icons.admin_panel_settings_outlined;
    case 'notifications_active':
      return Icons.notifications_active_outlined;
    default:
      return Icons.notifications_outlined;
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String typeName;
  final DateTime createdAt;
  bool isRead;
  final String? senderName;
  final IconData iconData;
  final Color color;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.typeName,
    required this.createdAt,
    required this.isRead,
    this.senderName,
    required this.iconData,
    required this.color,
  });

  // Factory constructor to create a NotificationItem from JSON
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'].toString(),
      title: json['title'] ?? 'No Title',
      message: json['message'] ?? 'No message content.',
      typeName: json['type_name'] ?? 'General',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      senderName: json['sender_name'],
      iconData: _getIconData(json['icon_name']),
      color: _colorFromHex(json['color_code'] ?? '#808080'),
    );
  }

  // Formats the time difference for display
  String formatTimeAgo() {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d, y').format(createdAt);
  }
}

class UserNotificationProvider with ChangeNotifier {
  // Correct base URL for the notification routes inside the auth module
  static const String _baseUrl = 'http://10.228.36.188:3000/api/auth/notification';

  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String _error = '';
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 15;
  int _unreadCount = 0;

  // Public getters
  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;
  int get unreadCount => _unreadCount;

  // Fetches notifications from the backend
  Future<void> fetchNotifications(String? token, {bool refresh = false}) async {
    if (token == null) {
      _error = "Authentication token not found. Please log in.";
      notifyListeners();
      return;
    }

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notifications = [];
      _unreadCount = 0;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    if (refresh) _error = '';
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl?page=$_currentPage&limit=$_perPage');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> notificationData = responseData['data']['notifications'];
        _unreadCount = responseData['data']['unread_count'] ?? 0;

        final newNotifications = notificationData
            .map((data) => NotificationItem.fromJson(data))
            .toList();

        if (newNotifications.isEmpty) {
          _hasMore = false;
        } else {
          _notifications.addAll(newNotifications);
          _currentPage++;
        }
      } else {
        _error = json.decode(response.body)['message'] ?? 'Failed to load notifications.';
      }
    } catch (e) {
      _error = 'Network error. Please check your connection and try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Private helper to send "mark as read" requests to the backend
  Future<void> _markReadRequest(String token, List<String> ids) async {
    final uri = Uri.parse('$_baseUrl/mark-read');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'notificationIds': ids}),
    );

    if (response.statusCode != 200) {
      throw Exception('Server failed to mark notification(s) as read.');
    }
  }

  // Marks a single notification as read
  Future<void> markAsRead(String notificationId, String token) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) return;

    // Optimistic UI update
    _notifications[index].isRead = true;
    _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
    notifyListeners();

    try {
      await _markReadRequest(token, [notificationId]);
    } catch (e) {
      // Revert on failure
      _notifications[index].isRead = false;
      _unreadCount++;
      _error = 'Failed to sync read status. Please try again.';
      notifyListeners();
    }
  }

  // Marks all notifications as read
  Future<void> markAllAsRead(String token) async {
    final unreadIds = _notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    final originalStates = { for (var n in _notifications) n.id : n.isRead };

    // Optimistic UI update
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    _unreadCount = 0;
    notifyListeners();

    try {
      // Backend expects an empty array to mark all as read
      await _markReadRequest(token, []);
    } catch (e) {
      // Revert on failure
      for (var n in _notifications) {
        n.isRead = originalStates[n.id]!;
      }
      _unreadCount = unreadIds.length;
      _error = 'Failed to mark all as read. Please try again.';
      notifyListeners();
      rethrow;
    }
  }
}
