import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../models/tour.dart';
import 'storage_service.dart';

class AdminService {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============ DASHBOARD STATS ============
  
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/dashboard-stats'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'data': data['data']['stats'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============ STATIONS MANAGEMENT ============
  
  Future<Map<String, dynamic>> getStations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/stations'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        final stations = (data['data']['stations'] as List)
            .map((s) => Station.fromJson(s))
            .toList();
        
        return {
          'success': true,
          'data': stations,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch stations',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createStation({
    required String name,
    required String city,
    String? address,
    double? latitude,
    double? longitude,
    String? facilities,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/stations'),
        headers: headers,
        body: json.encode({
          'name': name,
          'city': city,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'facilities': facilities,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'data': Station.fromJson(data['data']['station']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create station',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateStation({
    required int id,
    String? name,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
    String? facilities,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/admin/stations/$id'),
        headers: headers,
        body: json.encode({
          if (name != null) 'name': name,
          if (city != null) 'city': city,
          if (address != null) 'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (facilities != null) 'facilities': facilities,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'data': Station.fromJson(data['data']['station']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update station',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteStation(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/admin/stations/$id'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete station',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============ TRAINS MANAGEMENT ============
  
  Future<Map<String, dynamic>> getTrains() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/trains'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        final trains = (data['data']['trains'] as List)
            .map((t) => Train.fromJson(t))
            .toList();
        
        return {
          'success': true,
          'data': trains,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch trains',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createTrain({
    required String trainNumber,
    required String name,
    required String type,
    required int totalSeats,
    required int firstClassSeats,
    required int secondClassSeats,
    String? facilities,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/trains'),
        headers: headers,
        body: json.encode({
          'train_number': trainNumber,
          'name': name,
          'type': type,
          'total_seats': totalSeats,
          'first_class_seats': firstClassSeats,
          'second_class_seats': secondClassSeats,
          'facilities': facilities,
          'status': status ?? 'active',
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'data': Train.fromJson(data['data']['train']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create train',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateTrain({
    required int id,
    String? trainNumber,
    String? name,
    String? type,
    int? totalSeats,
    int? firstClassSeats,
    int? secondClassSeats,
    String? facilities,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/admin/trains/$id'),
        headers: headers,
        body: json.encode({
          if (trainNumber != null) 'train_number': trainNumber,
          if (name != null) 'name': name,
          if (type != null) 'type': type,
          if (totalSeats != null) 'total_seats': totalSeats,
          if (firstClassSeats != null) 'first_class_seats': firstClassSeats,
          if (secondClassSeats != null) 'second_class_seats': secondClassSeats,
          if (facilities != null) 'facilities': facilities,
          if (status != null) 'status': status,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'data': Train.fromJson(data['data']['train']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update train',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteTrain(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/admin/trains/$id'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete train',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============ TOURS MANAGEMENT ============
  
  Future<Map<String, dynamic>> getTours() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/tours'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        final tours = (data['data']['tours'] as List)
            .map((t) => Tour.fromJson(t))
            .toList();
        
        return {
          'success': true,
          'data': tours,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch tours',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createTour({
    required int trainId,
    required int originStationId,
    required int destinationStationId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required double firstClassPrice,
    required double secondClassPrice,
    required int availableSeats,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/tours'),
        headers: headers,
        body: json.encode({
          'train_id': trainId,
          'origin_station_id': originStationId,
          'destination_station_id': destinationStationId,
          'departure_time': departureTime.toIso8601String(),
          'arrival_time': arrivalTime.toIso8601String(),
          'first_class_price': firstClassPrice,
          'second_class_price': secondClassPrice,
          'available_seats': availableSeats,
          'status': status ?? 'scheduled',
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'data': Tour.fromJson(data['data']['tour']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create tour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateTour({
    required int id,
    int? trainId,
    int? originStationId,
    int? destinationStationId,
    DateTime? departureTime,
    DateTime? arrivalTime,
    double? firstClassPrice,
    double? secondClassPrice,
    int? availableSeats,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/admin/tours/$id'),
        headers: headers,
        body: json.encode({
          if (trainId != null) 'train_id': trainId,
          if (originStationId != null) 'origin_station_id': originStationId,
          if (destinationStationId != null) 'destination_station_id': destinationStationId,
          if (departureTime != null) 'departure_time': departureTime.toIso8601String(),
          if (arrivalTime != null) 'arrival_time': arrivalTime.toIso8601String(),
          if (firstClassPrice != null) 'first_class_price': firstClassPrice,
          if (secondClassPrice != null) 'second_class_price': secondClassPrice,
          if (availableSeats != null) 'available_seats': availableSeats,
          if (status != null) 'status': status,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
          'data': Tour.fromJson(data['data']['tour']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update tour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteTour(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/admin/tours/$id'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete tour',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============ RESERVATIONS ============
  
  Future<Map<String, dynamic>> getAllReservations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/reservations'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'data': data['data']['reservations'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch reservations',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
