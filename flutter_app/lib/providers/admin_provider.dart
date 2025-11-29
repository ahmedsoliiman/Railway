import 'package:flutter/material.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../models/tour.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  // Dashboard stats
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  // Stations
  List<Station> _stations = [];
  List<Station> get stations => _stations;

  // Trains
  List<Train> _trains = [];
  List<Train> get trains => _trains;

  // Tours
  List<Tour> _tours = [];
  List<Tour> get tours => _tours;

  // Loading states
  bool _isLoadingStats = false;
  bool _isLoadingStations = false;
  bool _isLoadingTrains = false;
  bool _isLoadingTours = false;

  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingStations => _isLoadingStations;
  bool get isLoadingTrains => _isLoadingTrains;
  bool get isLoadingTours => _isLoadingTours;

  String? _error;
  String? get error => _error;

  // ============ DASHBOARD STATS ============

  Future<void> loadDashboardStats() async {
    _isLoadingStats = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getDashboardStats();

    _isLoadingStats = false;

    if (response['success']) {
      _dashboardStats = response['data'];
    } else {
      _error = response['message'];
    }

    notifyListeners();
  }

  // ============ STATIONS MANAGEMENT ============

  Future<void> loadStations() async {
    _isLoadingStations = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getStations();

    _isLoadingStations = false;

    if (response['success']) {
      _stations = response['data'];
    } else {
      _error = response['message'];
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> createStation({
    required String name,
    required String city,
    String? address,
    double? latitude,
    double? longitude,
    String? facilities,
  }) async {
    final response = await _adminService.createStation(
      name: name,
      city: city,
      address: address,
      latitude: latitude,
      longitude: longitude,
      facilities: facilities,
    );

    if (response['success']) {
      await loadStations(); // Reload list
    }

    return response;
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
    final response = await _adminService.updateStation(
      id: id,
      name: name,
      city: city,
      address: address,
      latitude: latitude,
      longitude: longitude,
      facilities: facilities,
    );

    if (response['success']) {
      await loadStations(); // Reload list
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteStation(int id) async {
    final response = await _adminService.deleteStation(id);

    if (response['success']) {
      _stations.removeWhere((s) => s.id == id);
      notifyListeners();
    }

    return response;
  }

  // ============ TRAINS MANAGEMENT ============

  Future<void> loadTrains() async {
    _isLoadingTrains = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getTrains();

    _isLoadingTrains = false;

    if (response['success']) {
      _trains = response['data'];
    } else {
      _error = response['message'];
    }

    notifyListeners();
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
    final response = await _adminService.createTrain(
      trainNumber: trainNumber,
      name: name,
      type: type,
      totalSeats: totalSeats,
      firstClassSeats: firstClassSeats,
      secondClassSeats: secondClassSeats,
      facilities: facilities,
      status: status,
    );

    if (response['success']) {
      await loadTrains(); // Reload list
    }

    return response;
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
    final response = await _adminService.updateTrain(
      id: id,
      trainNumber: trainNumber,
      name: name,
      type: type,
      totalSeats: totalSeats,
      firstClassSeats: firstClassSeats,
      secondClassSeats: secondClassSeats,
      facilities: facilities,
      status: status,
    );

    if (response['success']) {
      await loadTrains(); // Reload list
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteTrain(int id) async {
    final response = await _adminService.deleteTrain(id);

    if (response['success']) {
      _trains.removeWhere((t) => t.id == id);
      notifyListeners();
    }

    return response;
  }

  // ============ TOURS MANAGEMENT ============

  Future<void> loadTours() async {
    _isLoadingTours = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getTours();

    _isLoadingTours = false;

    if (response['success']) {
      _tours = response['data'];
    } else {
      _error = response['message'];
    }

    notifyListeners();
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
    final response = await _adminService.createTour(
      trainId: trainId,
      originStationId: originStationId,
      destinationStationId: destinationStationId,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      firstClassPrice: firstClassPrice,
      secondClassPrice: secondClassPrice,
      availableSeats: availableSeats,
      status: status,
    );

    if (response['success']) {
      await loadTours(); // Reload list
    }

    return response;
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
    final response = await _adminService.updateTour(
      id: id,
      trainId: trainId,
      originStationId: originStationId,
      destinationStationId: destinationStationId,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      firstClassPrice: firstClassPrice,
      secondClassPrice: secondClassPrice,
      availableSeats: availableSeats,
      status: status,
    );

    if (response['success']) {
      await loadTours(); // Reload list
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteTour(int id) async {
    final response = await _adminService.deleteTour(id);

    if (response['success']) {
      _tours.removeWhere((t) => t.id == id);
      notifyListeners();
    }

    return response;
  }

  // ============ RESERVATIONS ============

  Future<List<dynamic>> getAllReservations() async {
    final response = await _adminService.getAllReservations();

    if (response['success']) {
      return response['data'] as List<dynamic>;
    } else {
      throw Exception(response['message']);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
