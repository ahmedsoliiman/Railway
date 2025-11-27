class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // For iOS Simulator
  // static const String baseUrl = 'http://YOUR_IP:3000/api'; // For Physical Device
  
  // App Information
  static const String appName = 'Train Booking System';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String emailKey = 'user_email';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String verifyEmailEndpoint = '/auth/verify-email';
  static const String resendCodeEndpoint = '/auth/resend-code';
  static const String meEndpoint = '/auth/me';
  static const String toursEndpoint = '/tours';
  static const String stationsEndpoint = '/stations';
  static const String reservationsEndpoint = '/reservations';
  static const String profileEndpoint = '/profile';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int itemsPerPage = 20;
}
