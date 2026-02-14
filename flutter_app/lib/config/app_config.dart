class AppConfig {
  // Supabase Configuration
  // Supabase project URL and Anon Key
  // Supabase URL added from user request; replace anon key below.
  static const String supabaseUrl = 'https://xapwfwlkuhlbgvasrocv.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhcHdmd2xrdWhsYmd2YXNyb2N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4MDAwNDIsImV4cCI6MjA4NjM3NjA0Mn0.Rus9idmy3mt-Q3nLflxNJ4wTsoFwZWnrOMtDkVc98sw';

  // App Information
  static const String appName = 'Train Booking System';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String emailKey = 'user_email';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int itemsPerPage = 20;
}
