import 'package:flutter/material.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../models/trip.dart';
import '../models/trip_departure.dart';
import '../models/carriage.dart';
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

  // Trips (if needed for dashboard)
  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  // Trip Departures
  List<TripDeparture> _tripDepartures = [];
  List<TripDeparture> get tripDepartures => _tripDepartures;

  // Carriage Types
  List<CarriageType> _carriageTypes = [];
  List<CarriageType> get carriageTypes => _carriageTypes;

  // Loading states
  bool _isLoadingStats = false;
  bool _isLoadingStations = false;
  bool _isLoadingTrains = false;
  bool _isLoadingTrips = false;
  bool _isLoadingTripDepartures = false;
  bool _isLoadingCarriageTypes = false;

  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingStations => _isLoadingStations;
  bool get isLoadingTrains => _isLoadingTrains;
  bool get isLoadingTrips => _isLoadingTrips;
  bool get isLoadingTripDepartures => _isLoadingTripDepartures;
  bool get isLoadingCarriageTypes => _isLoadingCarriageTypes;

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

  Future<void> loadStations({bool force = false}) async {
    if (!force && _stations.isNotEmpty) return;

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
    required String code,
    required String city,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _adminService.createStation(
      name: name,
      code: code,
      city: city,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );

    if (response['success']) {
      await loadStations(); // Reload list
    }

    return response;
  }

  Future<Map<String, dynamic>> updateStation({
    required String code,
    String? name,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _adminService.updateStation(
      code: code,
      name: name,
      city: city,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );

    if (response['success']) {
      await loadStations(); // Reload list
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteStation(String code) async {
    final response = await _adminService.deleteStation(code);

    if (response['success']) {
      _stations.removeWhere((s) => s.code == code);
      notifyListeners();
    }

    return response;
  }

  // ============ TRAINS MANAGEMENT ============

  Future<void> loadTrains({bool force = false}) async {
    if (!force && _trains.isNotEmpty) return;
    _isLoadingTrains = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getTrains();

    _isLoadingTrains = false;

    if (response['success']) {
      _trains = response['data'] as List<Train>;
    } else {
      _error = response['message'];
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> createTrain({
    required String trainNumber,
    required String type,
    int? capacity,
  }) async {
    final response = await _adminService.createTrain(
      trainNumber: trainNumber,
      type: type,
      capacity: capacity,
    );

    if (response['success']) {
      await loadTrains();
    }

    return response;
  }

  Future<Map<String, dynamic>> updateTrain({
    required int id,
    String? trainNumber,
    String? type,
  }) async {
    final response = await _adminService.updateTrain(
      id: id,
      trainNumber: trainNumber,
      type: type,
    );

    if (response['success']) {
      await loadTrains();
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

  // ============ USERS & BOOKINGS ============

  Future<List<dynamic>> getAllUsers() async {
    final response = await _adminService.getAllUsers();
    if (response['success']) {
      return response['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getAllBookings() async {
    final response = await _adminService.getAllBookings();
    if (response['success']) {
      return response['data'] as List<dynamic>;
    }
    return [];
  }

  // ============ TRIPS MANAGEMENT ============

  Future<void> loadTrips({bool force = false}) async {
    if (!force && _trips.isNotEmpty) return;
    _isLoadingTrips = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getTrips();

    _isLoadingTrips = false;

    if (response['success']) {
      _trips = response['data'] as List<Trip>;
    } else {
      _error = response['message'];
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> createTrip({
    required int trainId,
    required dynamic originStationId,
    required dynamic destinationStationId,
    required DateTime departure,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required double firstClassPrice,
    required double secondClassPrice,
    required double economicPrice,
    required int quantities,
  }) async {
    final response = await _adminService.createTrip(
      trainId: trainId,
      originStationId: originStationId,
      destinationStationId: destinationStationId,
      departure: departure,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      firstClassPrice: firstClassPrice,
      secondClassPrice: secondClassPrice,
      economicPrice: economicPrice,
      quantities: quantities,
    );

    if (response['success']) {
      await loadTrips();
    }

    return response;
  }

  // ============ TRIP DEPARTURES ============

  Future<void> loadTripDepartures({bool force = false}) async {
    if (!force && _tripDepartures.isNotEmpty) return;
    _isLoadingTripDepartures = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getTripDepartures();

    _isLoadingTripDepartures = false;

    if (response['success']) {
      final List<dynamic> data = response['data'];
      _tripDepartures = data.map((d) => TripDeparture.fromJson(d)).toList();
    } else {
      _error = response['message'];
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> createTripDeparture({
    required int tripId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int availableSeats,
  }) async {
    final response = await _adminService.createTripDeparture(
      tripId: tripId,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      availableSeats: availableSeats,
    );

    if (response['success']) {
      await loadTripDepartures();
    }

    return response;
  }

  Future<Map<String, dynamic>> updateTripDeparture({
    required int id,
    required int tripId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int availableSeats,
  }) async {
    final response = await _adminService.updateTripDeparture(
      id: id,
      tripId: tripId,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      availableSeats: availableSeats,
    );

    if (response['success']) {
      await loadTripDepartures();
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteTripDeparture(int id) async {
    final response = await _adminService.deleteTripDeparture(id);

    if (response['success']) {
      _tripDepartures.removeWhere((td) => td.id == id);
      notifyListeners();
    }

    return response;
  }

  // ============ CARRIAGE TYPES ============

  Future<void> loadCarriageTypes({bool force = false}) async {
    if (!force && _carriageTypes.isNotEmpty) return;
    _isLoadingCarriageTypes = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getCarriageTypes();

    _isLoadingCarriageTypes = false;

    if (response['success']) {
      final List<dynamic> data = response['data'];
      _carriageTypes = data.map((d) => CarriageType.fromJson(d)).toList();
    } else {
      _error = response['message'];
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> createCarriageType({
    required String type,
    required int capacity,
    required double price,
  }) async {
    final response = await _adminService.createCarriageType(
      type: type,
      capacity: capacity,
      price: price,
    );

    if (response['success']) {
      await loadCarriageTypes();
    }

    return response;
  }

  Future<Map<String, dynamic>> updateCarriageType({
    required int id,
    required String type,
    required int capacity,
    required double price,
  }) async {
    final response = await _adminService.updateCarriageType(
      id: id,
      type: type,
      capacity: capacity,
      price: price,
    );

    if (response['success']) {
      await loadCarriageTypes();
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteCarriageType(int id) async {
    final response = await _adminService.deleteCarriageType(id);

    if (response['success']) {
      _carriageTypes.removeWhere((ct) => ct.id == id);
      notifyListeners();
    }

    return response;
  }
}
