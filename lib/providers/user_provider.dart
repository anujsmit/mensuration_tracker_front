import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mensurationhealthapp/providers/auth_provider.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String username;
  final bool verified;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.verified,
    required this.isAdmin,
    required this.createdAt,
    this.lastLogin,
  });

  // Factory constructor to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        username: json['username'],
        verified: json['verified'] == true || json['verified'] == 1,
        isAdmin: json['isAdmin'] == true || json['isAdmin'] == 1,
        createdAt: DateTime.parse(json['createdAt']),
        lastLogin: json['lastLogin'] != null
            ? DateTime.parse(json['lastLogin'])
            : null,
      );

  // **FIX: Add toJson method for serialization**
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'username': username,
        'verified': verified,
        'isAdmin': isAdmin,
      };
}

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPages => _totalPages;
  int get totalUsers => _totalUsers;
  int get currentPage => _currentPage;

  static const String _baseUrl = 'http://10.228.36.188:3000/api/auth/users';
  void reset() {
    _users = [];
    _currentPage = 1;
    _totalPages = 1;
    _totalUsers = 0;
    _error = null;
    notifyListeners();
  }

  Future<void> fetchUsers({
    required String token,
    int page = 1,
    String search = '',
    bool? verified,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    if (page == 1) _error = null; // Clear previous errors on a fresh load
    notifyListeners();

    try {
      final params = {
        'page': page.toString(),
        'limit': '10',
        if (search.isNotEmpty) 'search': search,
        if (verified != null) 'verified': verified.toString(),
      };

      final uri = Uri.parse('$_baseUrl/users').replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final fetchedUsers = List<UserModel>.from(
          responseData['data']['users'].map((u) => UserModel.fromJson(u)),
        );

        if (page == 1) {
          _users = fetchedUsers;
        } else {
          _users.addAll(fetchedUsers);
        }

        _currentPage = page;
        _totalPages = responseData['data']['pagination']['totalPages'] ?? 1;
        _totalUsers = responseData['data']['pagination']['total'] ?? 0;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load users');
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel user, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(user.toJson()), // Use the toJson method here
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 200) {
        throw Exception(responseData['message'] ?? 'Failed to update user');
      }

      // Update the user in the local list
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
        notifyListeners();
      }
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(int userId, String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          _users.removeWhere((u) => u.id == userId);
          _totalUsers--;
          notifyListeners();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to delete user');
        }
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserVerification(
      int userId, bool verified, String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.patch(
        Uri.parse('$_baseUrl/users/$userId/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'verified': verified}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            final oldUser = _users[index];
            _users[index] = UserModel(
              id: oldUser.id,
              name: oldUser.name,
              email: oldUser.email,
              username: oldUser.username,
              verified: verified,
              isAdmin: oldUser.isAdmin,
              createdAt: oldUser.createdAt,
              lastLogin: oldUser.lastLogin,
            );
            notifyListeners();
          }
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update verification');
        }
      } else {
        throw Exception(
            'Failed to update verification: ${response.statusCode}');
      }
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
