// lib/utils/logger.dart
import 'package:flutter/foundation.dart';

class AppLogger {
  static const bool isDebugMode = kDebugMode;
  
  static void info(String message) {
    if (isDebugMode) {
      debugPrint('📘 INFO: $message');
    }
  }
  
  static void warning(String message) {
    if (isDebugMode) {
      debugPrint('⚠️ WARNING: $message');
    }
  }
  
  static void error(String message, [dynamic error]) {
    if (isDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('   Details: $error');
      }
    }
  }
  
  static void success(String message) {
    if (isDebugMode) {
      debugPrint('✅ SUCCESS: $message');
    }
  }
}