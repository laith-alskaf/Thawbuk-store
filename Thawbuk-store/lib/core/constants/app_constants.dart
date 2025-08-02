class AppConstants {
  // App Info
  static const String appName = 'متجر ثوبك';
  static const String appVersion = '1.0.0';
  
  // Email Verification
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;
  
  // API Endpoints
  static const String baseUrl = 'https://thawbuk.vercel.app/api';
  static const String authEndpoint = '/auth';
  static const String userEndpoint = '/user';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const int defaultAnimationDuration = 300;
  static const int fastAnimationDuration = 150;
  static const int slowAnimationDuration = 500;
}