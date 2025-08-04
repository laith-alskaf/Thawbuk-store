class DebugConfig {
  // تفعيل/إلغاء تفعيل الـ logging
  static const bool enableHttpLogging = true;
  static const bool enableApiLogging = true;
  static const bool enableBlocLogging = true;
  
  // مستوى التفاصيل في الـ logging
  static const bool logHeaders = true;
  static const bool logRequestBody = true;
  static const bool logResponseBody = true;
  
  // ألوان للـ console output
  static const String resetColor = '\x1B[0m';
  static const String redColor = '\x1B[31m';
  static const String greenColor = '\x1B[32m';
  static const String yellowColor = '\x1B[33m';
  static const String blueColor = '\x1B[34m';
  static const String magentaColor = '\x1B[35m';
  static const String cyanColor = '\x1B[36m';
  
  // رموز للـ logging
  static const String requestIcon = '🚀';
  static const String responseIcon = '📥';
  static const String errorIcon = '❌';
  static const String successIcon = '✅';
  static const String warningIcon = '⚠️';
  static const String infoIcon = 'ℹ️';
}