import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

class TripDepartureService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getTripDepartures(int tripId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/trips/$tripId/departures'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch departures',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createTripDeparture({
    required int tripId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int availableSeats,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/trip-departures'),
        headers: headers,
        body: json.encode({
          'tripId': tripId,
          'departureTime': departureTime.toIso8601String(),
          'arrivalTime': arrivalTime.toIso8601String(),
          'availableSeats': availableSeats,
        }),
      );

      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 201 && data['success'],
        'message': data['message'] ?? (response.statusCode == 201 ? 'Created successfully' : 'Failed'),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateTripDeparture({
    required int id,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int availableSeats,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/admin/trip-departures/$id'),
        headers: headers,
        body: json.encode({
          'departureTime': departureTime.toIso8601String(),
          'arrivalTime': arrivalTime.toIso8601String(),
          'availableSeats': availableSeats,
        }),
      );

      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200 && data['success'],
        'message': data['message'] ?? (response.statusCode == 200 ? 'Updated successfully' : 'Failed'),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteTripDeparture(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/admin/trip-departures/$id'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      return {
        'success': response.statusCode == 200 && data['success'],
        'message': data['message'] ?? (response.statusCode == 200 ? 'Deleted successfully' : 'Failed'),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
