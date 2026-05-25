// lib/utils/error_handler.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ErrorHandler {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static void initialize() {
    // Initialize error handling for Flutter framework
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      // Optionally send to analytics
      debugPrint('Flutter Error: ${details.exception}');
    };
    
    // Handle async errors - Fixed for web compatibility
    // For Flutter web, we need a different approach
    if (ui.PlatformDispatcher.instance != null) {
      ui.PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Async Error: $error');
        return true;
      };
    }
  }
  
  static void showErrorSnackBar(String message, {Duration? duration}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: duration ?? const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
  
  static void showSuccessSnackBar(String message) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}