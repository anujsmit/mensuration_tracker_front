class Config {

  /* =========================================
     OneSignal Configuration
  ========================================= */

  static const String oneSignalAppId =
      'e54e63b8-38c5-4270-b161-2cb0770d0fa2';

  static const String oneSignalRestApiKey =
      'os_v2_app_4vhghobyyvbhbmlbfsyhodipujuma4g6w26udafxy6kq57lih7zihg2b2ujw3snr3gazagyqwefj6xmuy74u62bhcfc2dxgr4hcytzy';

  // Main Backend URL
  static const String baseUrl =
      'http://192.168.56.1:3000/api';

  // Auth APIs
  static const String apiAuthBaseUrl =
      '$baseUrl/auth';

  // Chatbot AI API
  static const String chatApiUrl =
      '$baseUrl/chat';

  // Notes API
  static const String notesApiUrl =
      '$baseUrl/notes';

  // Reports API
  static const String reportsApiUrl =
      '$baseUrl/reports';

  // Users API
  static const String usersApiUrl =
      '$baseUrl/users';


  /* =========================================
     Notification Configuration
  ========================================= */

  static const String androidChannelId =
      'mensuration-tracker';

  static const String androidChannelName =
      'mensuration-tracker';

  static const String notificationIcon =
      'ic_stat_onesignal_default';

  static const String notificationSound =
      'notification';

  static const String notificationAccentColor =
      'FF00FF00';


  /* =========================================
     Notification Types
  ========================================= */

  static const Map<int, String> notificationTypes = {
    1: 'System Alert',
    2: 'Health Tip',
    3: 'Admin Message',
    4: 'Reminder',
  };


  /* =========================================
     Network Timeout
  ========================================= */

  static const Duration connectionTimeout =
      Duration(seconds: 10);

  static const Duration receiveTimeout =
      Duration(seconds: 10);
}