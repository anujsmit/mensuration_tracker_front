class ApiConstants {

  // ======================================================
  // BASE URL
  // ======================================================

  // Replace with your PC local IP

  static const String baseUrl = 'http://192.168.1.10:5000/api';


  static const String profile =
      '/profile';

  // ======================================================
  // CYCLES
  // ======================================================

  static const String cycles =
      '/cycles';

  // ======================================================
  // NOTES
  // ======================================================

  static const String notes =
      '/notes';

  // ======================================================
  // SYMPTOMS
  // ======================================================

  static const String symptoms =
      '/symptoms';

  static const String symptomAnalytics =
      '/symptoms/analytics';

  // ======================================================
  // NOTIFICATIONS
  // ======================================================

  static const String notifications =
      '/notifications';

  static const String saveFcmToken =
      '/notifications/save-token';

  // ======================================================
  // REPORTS
  // ======================================================

  static const String reports =
      '/reports';

  // ======================================================
  // TIMEOUTS
  // ======================================================

  static const int connectTimeout =
      30000;

  static const int receiveTimeout =
      30000;

}