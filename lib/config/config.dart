import 'package:flutter/foundation.dart';

class Config {
  // Fixed IP for all platforms
  static const String baseUrl = 'http://192.168.56.1:3000/api';
  
  // API Endpoints
  static const String apiAuthBaseUrl = '$baseUrl/auth';
  static const String chatApiUrl = '$baseUrl/chat';
  static const String notesApiUrl = '$baseUrl/notes';
  static const String reportsApiUrl = '$baseUrl/reports';
  static const String usersApiUrl = '$baseUrl/users';
  
  // Network Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  // Helper method for headers
  static Map<String, String> getAuthHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }
  
  // Debug logging
  static void logConfig() {
    if (kDebugMode) {
      print('Base URL: $baseUrl');
      print('Auth URL: $apiAuthBaseUrl');
    }
  }
}