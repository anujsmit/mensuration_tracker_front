import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {

  // ======================================================
  // SINGLETON
  // ======================================================

  static final DioClient _instance =
      DioClient._internal();

  factory DioClient() => _instance;

  DioClient._internal();

  // ======================================================
  // STORAGE
  // ======================================================

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  // ======================================================
  // DIO
  // ======================================================

  late final Dio dio = Dio(
    BaseOptions(

      // ======================================================
      // CHANGE THIS
      // ======================================================

      baseUrl:
          'http://192.168.1.10:5000/api',

      // Android Emulator:
      // http://10.0.2.2:5000/api

      connectTimeout:
          const Duration(seconds: 30),

      receiveTimeout:
          const Duration(seconds: 30),

      headers: {
        'Content-Type':
            'application/json',
      },
    ),
  );

  // ======================================================
  // INITIALIZE
  // ======================================================

  Future<void> initialize() async {

    dio.interceptors.add(

      InterceptorsWrapper(

        // ======================================================
        // REQUEST
        // ======================================================

        onRequest:
            (
              options,
              handler,
            ) async {

          final token =
              await storage.read(
            key: 'access_token',
          );

          // ======================================================
          // ATTACH TOKEN
          // ======================================================

          if (token != null) {

            options.headers[
                'Authorization'] =
                'Bearer $token';

          }

          print(
            'REQUEST => ${options.method} ${options.path}',
          );

          return handler.next(
            options,
          );

        },

        // ======================================================
        // RESPONSE
        // ======================================================

        onResponse:
            (
              response,
              handler,
            ) {

          print(
            'RESPONSE => ${response.statusCode}',
          );

          return handler.next(
            response,
          );

        },

        // ======================================================
        // ERROR
        // ======================================================

        onError:
            (
              DioException error,
              handler,
            ) async {

          print(
            'ERROR => ${error.response?.data}',
          );

          // ======================================================
          // UNAUTHORIZED
          // ======================================================

          if (
              error.response?.statusCode ==
                  401) {

            // Remove token if expired
            await storage.delete(
              key: 'access_token',
            );

          }

          return handler.next(
            error,
          );

        },

      ),

    );

  }

}