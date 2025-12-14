import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../models/station.dart';
import '../models/booking.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication APIs
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.signupEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.verifyEmailEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resendCode({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.resendCodeEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.meEndpoint}'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        return User.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Trips APIs
  Future<List<Trip>> getTrips({
    int? originId,
    int? destinationId,
    String? date,
    String? trainType,
  }) async {
    try {
      final headers = await _getHeaders();
      var url = '${AppConfig.baseUrl}${AppConfig.tripsEndpoint}';
      
      final queryParams = <String>[];
      if (originId != null) queryParams.add('originId=$originId');
      if (destinationId != null) queryParams.add('destinationId=$destinationId');
      if (date != null) queryParams.add('date=$date');
      if (trainType != null) queryParams.add('train_type=$trainType');
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      print('🔍 Fetching trips with URL: $url'); // Debug log

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        final List tripsJson = data['data'];
        print('✅ Found ${tripsJson.length} trips'); // Debug log
        return tripsJson.map((json) => Trip.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get trips error: $e');
      return [];
    }
  }

  Future<Trip?> getTripDetails(int tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.tripsEndpoint}/$tripId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        return Trip.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Get trip details error: $e');
      return null;
    }
  }

  // Stations APIs
  Future<List<Station>> getStations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.stationsEndpoint}'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null && data['data']['stations'] != null) {
        final List stationsJson = data['data']['stations'];
        return stationsJson.map((json) => Station.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get stations error: $e');
      return [];
    }
  }

  // Bookings APIs
  Future<Map<String, dynamic>> createBooking({
    required int tripId,
    required String seatClass,
    required int numberOfSeats,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservationsEndpoint}'),
        headers: headers,
        body: jsonEncode({
          'tourId': tripId,
          'seatClass': seatClass,
          'numberOfSeats': numberOfSeats,
        }),
      );

      print('📝 Creating booking response: ${response.statusCode}');
      print('📝 Response body: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Create booking error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservationsEndpoint}'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        final List bookingsJson = data['data'];
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get bookings error: $e');
      return [];
    }
  }

  Future<Booking?> getBookingDetails(int bookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservationsEndpoint}/$bookingId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['data'] != null) {
        return Booking.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Get booking details error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservationsEndpoint}/$bookingId'),
        headers: headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.reservationsEndpoint}/$bookingId/payment'),
        headers: headers,
        body: jsonEncode({
          'paymentMethod': paymentMethod,
          if (cardNumber != null) 'cardNumber': cardNumber,
          if (cardHolder != null) 'cardHolder': cardHolder,
          if (expiryDate != null) 'expiryDate': expiryDate,
          if (cvv != null) 'cvv': cvv,
        }),
      );

      print('💳 Payment response: ${response.statusCode}');
      print('💳 Response body: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Process payment error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Profile APIs
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.profileEndpoint}'),
        headers: headers,
        body: jsonEncode({
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
