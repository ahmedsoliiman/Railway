import 'package:flutter/material.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../models/trip.dart';
import '../models/carriage.dart';
import '../services/admin_service.dart';
import '../services/trip_departure_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  final TripDepartureService _tripDepartureService = TripDepartureService();

  // Dashboard stats
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  // Stations
  List<Station> _stations = [];
  List<Station> get stations => _stations;

  // Carriages
  List<Carriage> _carriages = [];
  List<Carriage> get carriages => _carriages;

  // Carriage Types
  List<CarriageType> _carriageTypes = [];
  List<CarriageType> get carriageTypes => _carriageTypes;

  // Trains
  List<Train> _trains = [];
  List<Train> get trains => _trains;

  // Trips
  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  // Loading states
  bool _isLoadingStats = false;
  bool _isLoadingStations = false;
  bool _isLoadingCarriages = false;
  bool _isLoadingTrains = false;
  bool _isLoadingTrips = false;

  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingStations => _isLoadingStations;
  bool get isLoadingCarriages => _isLoadingCarriages;
  bool get isLoadingTrains => _isLoadingTrains;
  bool get isLoadingTrips => _isLoadingTrips;

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
    required int id,
    String? name,
    String? code,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _adminService.updateStation(
      id: id,
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

  Future<Map<String, dynamic>> deleteStation(int id) async {
    final response = await _adminService.deleteStation(id);

    if (response['success']) {
      _stations.removeWhere((s) => s.id == id);
      notifyListeners();
    }

    return response;
  }

  // ============ CARRIAGE TYPES ============

  Future<void> loadCarriageTypes() async {
    try {
      _carriageTypes = await _adminService.getCarriageTypes();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============ CARRIAGES ============
  // ============ CARRIAGES MANAGEMENT ============

  Future<void> loadCarriages() async {
    _isLoadingCarriages = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getCarriages();

    _isLoadingCarriages = false;

    if (response['success']) {
      _carriages = response['data'];
    } else {
      _error = response['message'];
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> createCarriage({
    required String carriageNumber,
    required int carriageTypeId,
    String? model,
  }) async {
    final response = await _adminService.createCarriage(
      carriageNumber: carriageNumber,
      carriageTypeId: carriageTypeId,
      model: model,
    );

    if (response['success']) {
      await loadCarriages(); // Reload list
    }

    return response;
  }

  Future<Map<String, dynamic>> updateCarriage({
    required int id,
    String? carriageNumber,
    int? carriageTypeId,
    String? model,
  }) async {
    final response = await _adminService.updateCarriage(
      id: id,
      carriageNumber: carriageNumber,
      carriageTypeId: carriageTypeId,
      model: model,
    );

    if (response['success']) {
      await loadCarriages(); // Reload list
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteCarriage(int id) async {
    final response = await _adminService.deleteCarriage(id);

    if (response['success']) {
      _carriages.removeWhere((c) => c.id == id);
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
    required String type,
    required List<Map<String, dynamic>> carriages,
    String? status,
  }) async {
    final response = await _adminService.createTrain(
      trainNumber: trainNumber,
      type: type,
      carriages: carriages,
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
    String? type,
    List<Map<String, dynamic>>? carriages,
    String? status,
  }) async {
    final response = await _adminService.updateTrain(
      id: id,
      trainNumber: trainNumber,
      type: type,
      carriages: carriages,
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

  // ============ TRIPS MANAGEMENT ============

  Future<void> loadTrips() async {
    print('DEBUG AdminProvider: Starting loadTrips');
    _isLoadingTrips = true;
    _error = null;
    notifyListeners();

    final response = await _adminService.getTrips();
    print('DEBUG AdminProvider: getTrips response success: ${response['success']}');

    _isLoadingTrips = false;

    if (response['success']) {
      _trips = response['data'];
      print('DEBUG AdminProvider: Loaded ${_trips.length} trips into state');
    } else {
      _error = response['message'];
      print('ERROR AdminProvider: ${response['message']}');
    }

    notifyListeners();
    print('DEBUG AdminProvider: notifyListeners called, trips count: ${_trips.length}');
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
      await loadTrips(); // Reload list
    }

    return response;
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
    double? secondClassPrice,
    double? economicPrice,
    int? quantities,
  }) async {
    final response = await _adminService.updateTrip(
      id: id,
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
      await loadTrips(); // Reload list
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteTrip(int id) async {
    final response = await _adminService.deleteTrip(id);

    if (response['success']) {
      _trips.removeWhere((t) => t.id == id);
      notifyListeners();
    }

    return response;
  }

  // ============ USERS ============

  Future<List<dynamic>> getAllUsers() async {
    final response = await _adminService.getAllUsers();

    if (response['success']) {
      return response['data'] as List<dynamic>;
    } else {
      throw Exception(response['message']);
    }
  }

  // ============ BOOKINGS ============

  Future<List<dynamic>> getAllBookings() async {
    final response = await _adminService.getAllBookings();

    if (response['success']) {
      return response['data'] as List<dynamic>;
    } else {
      throw Exception(response['message']);
    }
  }

  // ============ TRIP DEPARTURES ============

  Future<List<dynamic>> getTripDepartures(int tripId) async {
    final response = await _tripDepartureService.getTripDepartures(tripId);

    if (response['success']) {
      return response['data'] as List<dynamic>;
    } else {
      throw Exception(response['message']);
    }
  }

  Future<Map<String, dynamic>> createTripDeparture({
    required int tripId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int availableSeats,
  }) async {
    final response = await _tripDepartureService.createTripDeparture(
      tripId: tripId,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      availableSeats: availableSeats,
    );

    if (response['success']) {
      await loadTrips(); // Reload to get updated departures
    }

    return response;
  }

  Future<Map<String, dynamic>> updateTripDeparture({
    required int id,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int availableSeats,
  }) async {
    final response = await _tripDepartureService.updateTripDeparture(
      id: id,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      availableSeats: availableSeats,
    );

    if (response['success']) {
      await loadTrips(); // Reload to get updated departures
    }

    return response;
  }

  Future<Map<String, dynamic>> deleteTripDeparture(int id) async {
    final response = await _tripDepartureService.deleteTripDeparture(id);

    if (response['success']) {
      await loadTrips(); // Reload to get updated departures
    }

    return response;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
