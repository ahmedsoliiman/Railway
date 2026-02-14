import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';

class StorageService {
  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  // Remove token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
  }

  // Save user
  Future<void> saveUser(Passenger user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));
  }

  // Get user
  Future<Passenger?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConfig.userKey);
    if (userJson != null) {
      return Passenger.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Remove user
  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.userKey);
  }

  // Save email (for verification)
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.emailKey, email);
  }

  // Get email
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.emailKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
