// lib/services/chat_service.dart
import 'package:dio/dio.dart';
import 'package:mensurationhealthapp/core/network/dio_client.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  late Dio _dio;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final dioClient = DioClient();
      await dioClient.initialize();
      _dio = dioClient.dio;
      _isInitialized = true;
    }
  }

  // Send message to AI (simplified - no conversationId)
  Future<Map<String, dynamic>> sendMessage({required String message}) async {
    try {
      await _ensureInitialized();
      
      print('📤 Sending message: $message');
      
      final response = await _dio.post(
        '/chat/send',
        data: {'message': message},
      );
      
      print('✅ Response received: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Chat send error: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }
      throw Exception('Failed to send message');
    }
  }

  // Get chat suggestions
  Future<List<Map<String, dynamic>>> getSuggestions() async {
    try {
      await _ensureInitialized();
      
      final response = await _dio.get('/chat/suggestions');
      return List<Map<String, dynamic>>.from(response.data['suggestions']);
    } catch (e) {
      print('Get suggestions error: $e');
      // Return default suggestions if API fails
      return [
        {'id': 1, 'title': 'Track my cycle', 'prompt': 'How do I start tracking my menstrual cycle?'},
        {'id': 2, 'title': 'Period symptoms', 'prompt': 'What are common period symptoms?'},
        {'id': 3, 'title': 'Irregular cycles', 'prompt': 'What causes irregular periods?'},
        {'id': 4, 'title': 'PMS relief', 'prompt': 'How can I relieve PMS symptoms?'},
      ];
    }
  }

  // Get health tip
  Future<String> getHealthTip() async {
    try {
      await _ensureInitialized();
      
      final response = await _dio.get('/chat/health-tip');
      return response.data['tip'];
    } catch (e) {
      print('Get health tip error: $e');
      return 'Take time to rest and listen to your body today. 💕';
    }
  }
}