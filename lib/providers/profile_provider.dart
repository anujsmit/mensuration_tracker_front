import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Added for byte data
import 'package:mensurationhealthapp/config/config.dart'; // Added Config import

class ProfileProvider with ChangeNotifier {
  Map<String, dynamic>? _profile;
  List<dynamic> _cycles = [];
  List<dynamic> _symptoms = [];
  bool _isVerified = false;
  String? _username;
  String? _email;

  String _error = '';
  bool _isLoading = false;

  // FIX: Use the centralized API base URL and append the specific path
  final String baseUrl = '${Config.apiAuthBaseUrl}/profile';

  Map<String, dynamic>? get profile => _profile;
  List<dynamic> get cycles => _cycles;
  List<dynamic> get symptoms => _symptoms;
  bool get isVerified => _isVerified;
  String? get username => _username;
  String? get email => _email;
  String get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile(String userId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _profile =
            responseData['hasProfile'] == true ? responseData['profile'] : null;
        _username = responseData['username'];
        _email = responseData['email'];
        _error = '';
      } else {
        _error =
            json.decode(response.body)['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProfile(
      Map<String, dynamic> profileData, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        'age': profileData['age'],
        'weight': profileData['weight'],
        'height': profileData['height'],
        'cycleLength': profileData['cycleLength'],
        'lastPeriodDate': profileData['lastPeriodDate'],
        'ageAtMenarche': profileData['ageAtMenarche'],
        'flowRegularity': profileData['flowRegularity'],
        'bleedingDuration': profileData['bleedingDuration'],
        'flowAmount': profileData['flowAmount'],
        'periodInterval': profileData['periodInterval'],
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Get user ID from auth provider or response
        final responseData = json.decode(response.body);
        final userId = responseData['profile']?['user_id']?.toString() ?? 
                      profileData['user_id']?.toString() ?? '';
        
        await fetchProfile(userId, token);
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error =
            json.decode(response.body)['message'] ?? 'Failed to save profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

// NEW: Method to download the health report
Future<Map<String, dynamic>> downloadHealthReport(String token) async {
  try {
    // FIX: Use the correct reports endpoint instead of profile endpoint
    final reportUrl = Uri.parse('${Config.apiAuthBaseUrl}/reports/health'); 

    final response = await http.get(
      reportUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'text/csv, application/json',
      },
    ).timeout(const Duration(seconds: 60)); 

    if (response.statusCode == 200) {
      // Check content type
      final contentType = response.headers['content-type'] ?? '';
      
      // Extract filename from the Content-Disposition header
      String? contentDisposition = response.headers['content-disposition'];
      String filename = 'health_report.csv';
      if (contentDisposition != null) {
        // Simple parsing to get the filename
        final match = RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
        if (match != null) {
          filename = match.group(1) ?? filename;
        }
      }
      
      // Handle both CSV and JSON responses
      if (contentType.contains('csv')) {
        return {
          'success': true,
          'data': response.bodyBytes, 
          'filename': filename,
          'contentType': 'csv',
        };
      } else {
        // Try to parse as JSON
        try {
          final responseData = json.decode(response.body);
          if (responseData['success'] == false) {
            return {
              'success': false,
              'message': responseData['message'] ?? 'Failed to generate report.',
            };
          }
          return {
            'success': true,
            'data': Uint8List.fromList(utf8.encode(response.body)),
            'filename': filename,
            'contentType': 'json',
          };
        } catch (e) {
          return {
            'success': true,
            'data': response.bodyBytes,
            'filename': filename,
            'contentType': 'text',
          };
        }
      }
    } else {
      try {
        final responseData = json.decode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to download report.',
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Network error or timeout: ${e.toString()}',
    };
  }
}
  Future<void> fetchCycles(String userId, String token) async {
    _isLoading = true;
    notifyListeners();  

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cycles'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _cycles = json.decode(response.body)['data'];
        _error = '';
      } else {
        _error =
            json.decode(response.body)['message'] ?? 'Failed to load cycles';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> recordCycle(Map<String, dynamic> cycleData, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        'startDate': cycleData['startDate'],
        'endDate': cycleData['endDate'],
        'notes': cycleData['notes'],
        'timezone': cycleData['timezone'] ?? 'Asia/Kolkata',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/cycles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        await fetchCycles(cycleData['userId'], token);
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error =
            json.decode(response.body)['message'] ?? 'Failed to record cycle';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchSymptoms(String userId, String token,
      {String? startDate, String? endDate, String? symptomType}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String url = '$baseUrl/symptoms';
      List<String> params = [];
      if (startDate != null) params.add('startDate=$startDate');
      if (endDate != null) params.add('endDate=$endDate');
      if (symptomType != null) params.add('symptomType=$symptomType');

      if (params.isNotEmpty) {
        url += '?' + params.join('&');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _symptoms = json.decode(response.body)['data'];
        _error = '';
      } else {
        _error =
            json.decode(response.body)['message'] ?? 'Failed to load symptoms';
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> recordSymptom(
      Map<String, dynamic> symptomData, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        'date': symptomData['date'],
        'symptomType': symptomData['symptomType'],
        'severity': symptomData['severity'],
        'notes': symptomData['notes'],
        'timezone': symptomData['timezone'] ?? 'Asia/Kolkata',
        'cycleId': symptomData['cycleId'],
      };

      final response = await http.post(
        Uri.parse('$baseUrl/symptoms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        await fetchSymptoms(symptomData['userId'], token);
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error =
            json.decode(response.body)['message'] ?? 'Failed to record symptom';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}