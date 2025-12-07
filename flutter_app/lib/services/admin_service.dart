import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/station.dart';
import '../models/carriage.dart';
import '../models/train.dart';
import '../models/trip.dart';
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
        final List<dynamic> stationsJson = data['data'];
        final stations = stationsJson
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
    required String code,
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
          'code': code,
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
    String? code,
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
          if (code != null) 'code': code,
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

  // ============ CARRIAGES MANAGEMENT ============
  
  Future<Map<String, dynamic>> getCarriages() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/carriages'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        final List<dynamic> carriagesJson = data['data'];
        return {
          'success': true,
          'data': carriagesJson.map((json) => Carriage.fromJson(json)).toList(),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch carriages',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createCarriage({
    required String name,
    required String classType,
    required int seatsCount,
    String? model,
    String? description,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/carriages'),
        headers: headers,
        body: json.encode({
          'name': name,
          'class_type': classType,
          'seats_count': seatsCount,
          if (model != null) 'model': model,
          if (description != null) 'description': description,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateCarriage({
    required int id,
    String? name,
    String? classType,
    int? seatsCount,
    String? model,
    String? description,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/admin/carriages/$id'),
        headers: headers,
        body: json.encode({
          if (name != null) 'name': name,
          if (classType != null) 'class_type': classType,
          if (seatsCount != null) 'seats_count': seatsCount,
          if (model != null) 'model': model,
          if (description != null) 'description': description,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteCarriage(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/admin/carriages/$id'),
        headers: headers,
      );

      return json.decode(response.body);
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
        final List<dynamic> trainsJson = data['data'];
        final trains = trainsJson
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
    required List<Map<String, dynamic>> carriages,
    String? facilities,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/trains'),
        headers: headers,
        body: json.encode({
          'trainNumber': trainNumber,
          'name': name,
          'type': type,
          'carriages': carriages,
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
    List<Map<String, dynamic>>? carriages,
    String? facilities,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/admin/trains/$id'),
        headers: headers,
        body: json.encode({
          if (trainNumber != null) 'trainNumber': trainNumber,
          if (name != null) 'name': name,
          if (type != null) 'type': type,
          if (carriages != null) 'carriages': carriages,
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

  // ============ TRIPS MANAGEMENT ============
  
  Future<Map<String, dynamic>> getTrips() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/trips'),
        headers: headers,
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        final List<dynamic> tripsJson = data['data'];
        print('DEBUG: Fetched ${tripsJson.length} trips from API');
        
        try {
          final trips = tripsJson
              .map((t) {
                try {
                  return Trip.fromJson(t);
                } catch (parseError) {
                  print('ERROR parsing trip: $parseError');
                  print('Trip data: $t');
                  rethrow;
                }
              })
              .toList();
          
          print('DEBUG: Successfully parsed ${trips.length} trips');
          return {
            'success': true,
            'data': trips,
          };
        } catch (parseError) {
          print('ERROR during trips parsing: $parseError');
          return {
            'success': false,
            'message': 'Failed to parse trips: ${parseError.toString()}',
          };
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch trips',
        };
      }
    } catch (e) {
      print('ERROR fetching trips: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createTrip({
    required int trainId,
    required int originStationId,
    required int destinationStationId,
    required DateTime departure,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required double firstClassPrice,
    required double secondClassPrice,
    required double economicPrice,
    required int quantities,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/admin/trips'),
        headers: headers,
        body: json.encode({
          'trainId': trainId,
          'originStationId': originStationId,
          'destinationStationId': destinationStationId,
          'departure': departure.toIso8601String().split('T')[0],
          'departureTime': departureTime.toIso8601String(),
          'arrivalTime': arrivalTime.toIso8601String(),
          'firstClassPrice': firstClassPrice,
          'secondClassPrice': secondClassPrice,
          'economicPrice': economicPrice,
          'quantities': quantities,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 201 && data['success']) {
        try {
          final trip = Trip.fromJson(data['data']['trip']);
          return {
            'success': true,
            'message': data['message'],
            'data': trip,
          };
        } catch (parseError) {
          print('Trip parsing error: $parseError');
          print('Trip data: ${data['data']['trip']}');
          return {
            'success': false,
            'message': 'Failed to parse trip data: ${parseError.toString()}',
          };
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create trip',
        };
      }
    } catch (e) {
      print('Create trip error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateTrip({
    required int id,
    int? trainId,
    int? originStationId,
    int? destinationStationId,
    DateTime? departure,
    DateTime? departureTime,
    DateTime? arrivalTime,
    double? firstClassPrice,
    double? economicPrice,
    double? secondClassPrice,
    int? quantities,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/admin/trips/$id'),
        headers: headers,
        body: json.encode({
          if (trainId != null) 'trainId': trainId,
          if (originStationId != null) 'originStationId': originStationId,
          if (destinationStationId != null) 'destinationStationId': destinationStationId,
          if (departure != null) 'departure': departure.toIso8601String().split('T')[0],
          if (departureTime != null) 'departureTime': departureTime.toIso8601String(),
          if (arrivalTime != null) 'arrivalTime': arrivalTime.toIso8601String(),
          if (firstClassPrice != null) 'firstClassPrice': firstClassPrice,
          if (secondClassPrice != null) 'secondClassPrice': secondClassPrice,
          if (economicPrice != null) 'economicPrice': economicPrice,
          if (quantities != null) 'quantities': quantities,
          if (quantities != null) 'quantities': quantities,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        try {
          final trip = Trip.fromJson(data['data']['trip']);
          return {
            'success': true,
            'message': data['message'],
            'data': trip,
          };
        } catch (parseError) {
          print('Trip parsing error: $parseError');
          print('Trip data: ${data['data']['trip']}');
          return {
            'success': false,
            'message': 'Failed to parse trip data: ${parseError.toString()}',
          };
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update trip',
        };
      }
    } catch (e) {
      print('Update trip error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteTrip(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/admin/trips/$id'),
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
          'message': data['message'] ?? 'Failed to delete trip',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============ USERS ============
  
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/admin/users'),
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
          'message': data['message'] ?? 'Failed to fetch users',
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
          'data': data['data'],
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
