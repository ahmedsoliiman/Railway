import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart'; // Contains Passenger class
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Passenger? _user;
  bool _isLoading = false;
  String? _error;

  Passenger? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  // TODO: Add isAdmin property to Passenger if needed, or check specific email
  bool get isAdmin =>
      _user?.email == 'admin@railway.com'; // Simple check for now

  bool get isManager =>
      _user?.email == 'manager@railway.com'; // Simple check for Manager role

  // Signup
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.signup(
      fullName: fullName,
      email: email,
      password: password,
    );

    _setLoading(false);

    if (response['success']) {
      _user = response['data'] as Passenger;
      await _storageService.saveUser(_user!);
      notifyListeners();
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    await _storageService.clearAll();

    final response = await _apiService.login(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (response['success']) {
      await _storageService.saveToken(response['token']);

      _user = response['data'] as Passenger;
      await _storageService.saveUser(_user!);

      notifyListeners();
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Logout
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Supabase signOut error: $e');
    }

    await _storageService.clearAll();
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Forgot Password (Trigger Reset Email)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _setLoading(false);
      return {'success': true};
    } catch (e) {
      _setLoading(false);
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  StorageService get storageService => _storageService;

  // Verify Email
  Future<Map<String, dynamic>> verifyEmail(
      {required String email, required String code}) async {
    _setLoading(true);
    final response = await _apiService.verifyEmail(email, code);
    _setLoading(false);
    return response;
  }

  // Resend Verification Code
  Future<Map<String, dynamic>> resendCode({required String email}) async {
    _setLoading(true);
    final response = await _apiService.resendCode(email: email);
    _setLoading(false);
    return response;
  }

  // Load User (Alias for checkAuthStatus/fetchCurrentUser)
  Future<void> loadUser() async {
    if (_user != null) return;
    await fetchCurrentUser();
  }

  // Check Auth Status & Load User
  Future<bool> checkAuthStatus() async {
    // 1. Check if user is already in memory
    if (_user != null) return true;

    // 2. Check cached user for instant-boot
    final cachedUser = await _storageService.getUser();
    if (cachedUser != null) {
      _user = cachedUser;
      notifyListeners();

      // Background refresh to ensure data is up to date
      _apiService.getCurrentUser().then((updatedUser) {
        if (updatedUser != null) {
          _user = updatedUser;
          _storageService.saveUser(updatedUser);
          notifyListeners();
        }
      });
      return true;
    }

    // 3. Fallback to token validation if no cached user
    final token = await _storageService.getToken();
    if (token != null) {
      try {
        final passenger = await _apiService.getCurrentUser();
        if (passenger != null) {
          _user = passenger;
          await _storageService.saveUser(passenger);
          notifyListeners();
          return true;
        }
      } catch (e) {
        print('Error checking auth status: $e');
      }
    }
    return false;
  }

  // Fetch current user (forced refresh)
  Future<void> fetchCurrentUser() async {
    try {
      final passenger = await _apiService.getCurrentUser();
      if (passenger != null) {
        _user = passenger;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
