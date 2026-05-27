// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late Dio dio;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // CHANGE THIS TO YOUR IP ADDRESS
    const String baseUrl = 'http://192.168.1.69:5000/api';
    
    debugPrint('🌐 Connecting to: $baseUrl');

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'access_token');
          
          if (token != null && token.isNotEmpty) {
            // IMPORTANT: Remove any whitespace and ensure proper format
            final cleanToken = token.trim();
            // Set the header correctly - no line breaks or extra spaces
            options.headers['Authorization'] = 'Bearer $cleanToken';
            
            // Debug log
            final tokenPreview = cleanToken.length > 30 
                ? '${cleanToken.substring(0, 30)}...' 
                : cleanToken;
            debugPrint('🔑 Token attached (${cleanToken.length} chars): $tokenPreview');
          } else {
            debugPrint('⚠️ No token found');
          }
          
          debugPrint('📤 ${options.method} ${options.path}');
          if (options.data != null) {
            debugPrint('📦 Request data: ${options.data}');
          }
          
          // Validate header before sending
          final authHeader = options.headers['Authorization'];
          if (authHeader != null && authHeader.toString().contains('\n')) {
            debugPrint('❌ ERROR: Authorization header contains line break!');
            // Fix it
            options.headers['Authorization'] = authHeader.toString().replaceAll('\n', '').replaceAll(' ', ' ');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('📥 ${response.statusCode} ${response.requestOptions.path}');
          if (response.statusCode == 200 || response.statusCode == 201) {
            debugPrint('✅ Success');
          } else {
            debugPrint('⚠️ Status: ${response.statusCode}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          debugPrint('❌ Error: ${error.message}');
          debugPrint('❌ URL: ${error.requestOptions.path}');
          
          if (error.response != null) {
            debugPrint('❌ Status: ${error.response?.statusCode}');
            debugPrint('❌ Response: ${error.response?.data}');
            
            if (error.response?.statusCode == 401) {
              debugPrint('🔐 Unauthorized - Invalid token');
              await storage.delete(key: 'access_token');
              await storage.delete(key: 'refresh_token');
            }
          }
          
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    _isInitialized = true;
    debugPrint('✅ DioClient initialized');
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> setAuthToken(String token) async {
    // Clean the token before storing
    final cleanToken = token.trim();
    await storage.write(key: 'access_token', value: cleanToken);
    debugPrint('🔑 Auth token stored (${cleanToken.length} chars)');
  }

  Future<String?> getAuthToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<void> clearAuthToken() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    debugPrint('🔑 Auth tokens cleared');
  }

  Dio get client {
    if (!_isInitialized) {
      throw Exception('DioClient not initialized. Call initialize() first.');
    }
    return dio;
  }
}