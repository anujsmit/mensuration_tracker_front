import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mensurationhealthapp/config/config.dart';

class AdminNotificationProvider with ChangeNotifier {
  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  Future<Map<String, dynamic>> sendNotificationToAll({
    required String token,
    required String title,
    required String message,
    required int typeId,
  }) async {
    try {
      _validateInput(title, message);
      _setLoading(true);

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/admin/send-to-all'),
        headers: _buildHeaders(token),
        body: json.encode({
          'title': title,
          'message': message,
          'typeId': typeId,
        }),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError('Failed to send notification to all: ${e.toString()}');
      return {
        'success': false,
        'message': 'Failed to send notification: ${e.toString()}',
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> sendNotification({
    required String token,
    required String title,
    required String message,
    required int typeId,
    required List<String> userIds,
  }) async {
    try {
      if (userIds.isEmpty) {
        throw const FormatException('At least one recipient required');
      }
      _validateInput(title, message);
      _setLoading(true);

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/admin/send'),
        headers: _buildHeaders(token),
        body: json.encode({
          'title': title,
          'message': message,
          'typeId': typeId,
          'userIds': userIds,
        }),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      _handleError('Failed to send notification: ${e.toString()}');
      return {
        'success': false,
        'message': 'Failed to send notification: ${e.toString()}',
      };
    } finally {
      _setLoading(false);
    }
  }

  void _validateInput(String title, String message) {
    if (title.isEmpty || message.isEmpty) {
      throw const FormatException('Title and message are required');
    }
    if (title.length > 100) {
      throw const FormatException('Title too long (max 100 characters)');
    }
    if (message.length > 500) {
      throw const FormatException('Message too long (max 500 characters)');
    }
  }

  Map<String, String> _buildHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    final responseData = json.decode(response.body);
    if (response.statusCode == 201) {
      return {
        'success': true,
        'message': responseData['message'] ?? 'Notification sent successfully',
        'notification_id': responseData['notification_id'],
      };
    }
    throw Exception(responseData['message'] ?? 'Failed to save notification');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _handleError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}