import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  StorageService get storageService => _storageService;

  // Signup
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.signup(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );

    _setLoading(false);

    if (response['success']) {
      // Save email for verification
      await _storageService.saveEmail(email);
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

    final response = await _apiService.login(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (response['success']) {
      // Save token
      await _storageService.saveToken(response['data']['token']);
      
      // Set user
      _user = User.fromJson(response['data']['user']);
      await _storageService.saveUser(_user!);
      notifyListeners();
      
      // Return user role for routing
      response['userRole'] = _user!.role;
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Verify Email
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.verifyEmail(
      email: email,
      code: code,
    );

    _setLoading(false);

    if (!response['success']) {
      _setError(response['message']);
    }

    return response;
  }

  // Resend verification code
  Future<Map<String, dynamic>> resendCode({required String email}) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.resendCode(email: email);

    _setLoading(false);

    if (!response['success']) {
      _setError(response['message']);
    }

    return response;
  }

  // Load user from storage
  Future<void> loadUser() async {
    final storedUser = await _storageService.getUser();
    if (storedUser != null) {
      _user = storedUser;
      notifyListeners();
      
      // Refresh user data from server
      final currentUser = await _apiService.getCurrentUser();
      if (currentUser != null) {
        _user = currentUser;
        await _storageService.saveUser(currentUser);
        notifyListeners();
      }
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.updateProfile(
      fullName: fullName,
      phone: phone,
    );

    _setLoading(false);

    if (response['success']) {
      _user = User.fromJson(response['data']['user']);
      await _storageService.saveUser(_user!);
      notifyListeners();
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearAll();
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    return await _storageService.isLoggedIn();
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
