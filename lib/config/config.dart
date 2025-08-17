class Config {
  // OneSignal Configuration
  static const String oneSignalAppId = 'e54e63b8-38c5-4270-b161-2cb0770d0fa2';
  static const String oneSignalRestApiKey = 
      'os_v2_app_4vhghobyyvbhbmlbfsyhodipujuma4g6w26udafxy6kq57lih7zihg2b2ujw3snr3gazagyqwefj6xmuy74u62bhcfc2dxgr4hcytzy';

  // API Configuration
  static const String baseUrl = 'http://10.228.36.188:3000/api/auth/notification';
  
  // Notification Configuration
  static const String androidChannelId = 'mensuration-tracker';
  static const String androidChannelName = 'mensuration-tracker';
  static const String notificationIcon = 'ic_stat_onesignal_default';
  static const String notificationSound = 'notification';
  static const String notificationAccentColor = 'FF00FF00';
  
  // Notification Types
  static const Map<int, String> notificationTypes = {
    1: 'System Alert',
    2: 'Health Tip',
    3: 'Admin Message',
    4: 'Reminder',
  };

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}