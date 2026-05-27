import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  // ======================================================
  // SINGLETON
  // ======================================================

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  // ======================================================
  // STORAGE
  // ======================================================

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // ======================================================
  // DIO
  // ======================================================

  late Dio _dio;
  bool _isInitialized = false;

  // ======================================================
  // GETTERS
  // ======================================================

  /// Get the Dio instance (auto-initializes if needed)
  Dio get dio {
    if (!_isInitialized) {
      throw Exception('DioClient not initialized. Call initialize() first.');
    }
    return _dio;
  }

  /// Alternative getter for backward compatibility
  Dio get client => dio;

  // ======================================================
  // INITIALIZE
  // ======================================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    // UPDATE THIS URL TO YOUR CORRECT BACKEND IP
    // For Android emulator: http://10.0.2.2:5000/api
    // For physical device: http://YOUR_COMPUTER_IP:5000/api
    const String baseUrl = 'http://192.168.1.69:5000/api'; // Change this to your IP
    
    print('🌐 Initializing DioClient with baseUrl: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'access_token');

          if (token != null && token.isNotEmpty) {
            final cleanToken = token.trim();
            options.headers['Authorization'] = 'Bearer $cleanToken';
            
            // Debug token type
            final tokenType = cleanToken.contains('FUzI1Ni') ? 'Supabase (ES256)' : 'Local (HS256)';
            print('🔑 Token attached: $tokenType');
          } else {
            print('⚠️ No token found');
          }

          print('📤 REQUEST: ${options.method} ${options.path}');
          if (options.data != null) {
            print('📦 Request data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          if (response.statusCode == 200 || response.statusCode == 201) {
            print('✅ Success');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          print('❌ ERROR: ${error.message}');
          print('❌ URL: ${error.requestOptions.path}');
          
          if (error.response != null) {
            print('❌ Status: ${error.response?.statusCode}');
            print('❌ Response: ${error.response?.data}');
          }

          if (error.response?.statusCode == 401) {
            print('🔐 Unauthorized - Token may be expired');
            await storage.delete(key: 'access_token');
            print('🔐 Token cleared. Please login again.');
          }

          return handler.next(error);
        },
      ),
    );

    _isInitialized = true;
    print('✅ DioClient initialized successfully');
  }

  // ======================================================
  // CONVENIENCE METHODS
  // ======================================================

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    await initialize();
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    await initialize();
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    await initialize();
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    await initialize();
    return _dio.delete(path);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    await initialize();
    return _dio.patch(path, data: data);
  }

  // ======================================================
  // TOKEN MANAGEMENT
  // ======================================================

  Future<void> setAuthToken(String token) async {
    await storage.write(key: 'access_token', value: token);
    print('🔑 Auth token stored');
  }

  Future<String?> getAuthToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<void> clearAuthToken() async {
    await storage.delete(key: 'access_token');
    print('🔑 Auth token cleared');
  }
}