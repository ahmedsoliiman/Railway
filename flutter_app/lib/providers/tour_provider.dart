import 'package:flutter/material.dart';
import '../models/tour.dart';
import '../models/station.dart';
import '../models/reservation.dart';
import '../services/api_service.dart';

class TourProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Tour> _tours = [];
  List<Station> _stations = [];
  List<Reservation> _reservations = [];
  Tour? _selectedTour;
  bool _isLoading = false;
  String? _error;

  List<Tour> get tours => _tours;
  List<Station> get stations => _stations;
  List<Reservation> get reservations => _reservations;
  Tour? get selectedTour => _selectedTour;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load stations
  Future<void> loadStations() async {
    try {
      _stations = await _apiService.getStations();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load stations: $e');
    }
  }

  // Search tours
  Future<void> searchTours({
    int? originId,
    int? destinationId,
    String? date,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _tours = await _apiService.getTours(
        originId: originId,
        destinationId: destinationId,
        date: date,
      );
    } catch (e) {
      _setError('Failed to load tours: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all tours with optional filters
  Future<void> loadTours({
    int? originStationId,
    int? destinationStationId,
    DateTime? date,
    String? seatClass,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _tours = await _apiService.getTours(
        originId: originStationId,
        destinationId: destinationStationId,
        date: date?.toIso8601String().split('T')[0],
      );
      
      // Filter by seat class if specified (frontend filtering)
      if (seatClass != null) {
        _tours = _tours.where((tour) {
          if (seatClass.toLowerCase() == 'first') {
            return tour.firstClassPrice != null && tour.firstClassPrice! > 0;
          } else if (seatClass.toLowerCase() == 'second') {
            return tour.secondClassPrice != null && tour.secondClassPrice! > 0;
          }
          return true;
        }).toList();
      }
    } catch (e) {
      _setError('Failed to load tours: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load tour details
  Future<void> loadTourDetails(int tourId) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedTour = await _apiService.getTourDetails(tourId);
    } catch (e) {
      _setError('Failed to load tour details: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set selected tour
  void setSelectedTour(Tour tour) {
    _selectedTour = tour;
    notifyListeners();
  }

  // Create reservation
  Future<Map<String, dynamic>> createReservation({
    required int tourId,
    required String seatClass,
    required int numberOfSeats,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.createReservation(
      tourId: tourId,
      seatClass: seatClass,
      numberOfSeats: numberOfSeats,
    );

    _setLoading(false);

    if (response['success']) {
      // Reload reservations
      await loadReservations();
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Load user reservations
  Future<void> loadReservations() async {
    _setLoading(true);
    _setError(null);

    try {
      _reservations = await _apiService.getMyReservations();
    } catch (e) {
      _setError('Failed to load reservations: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cancel reservation
  Future<Map<String, dynamic>> cancelReservation(int reservationId) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.cancelReservation(reservationId);

    _setLoading(false);

    if (response['success']) {
      // Reload reservations
      await loadReservations();
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Get upcoming reservations
  List<Reservation> get upcomingReservations {
    return _reservations.where((reservation) {
      if (reservation.status == 'cancelled') return false;
      if (reservation.departureTime == null) return false;
      return reservation.departureTime!.isAfter(DateTime.now());
    }).toList();
  }

  // Get past reservations
  List<Reservation> get pastReservations {
    return _reservations.where((reservation) {
      if (reservation.status == 'cancelled') return true;
      if (reservation.departureTime == null) return false;
      return reservation.departureTime!.isBefore(DateTime.now());
    }).toList();
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

  void clearTours() {
    _tours = [];
    notifyListeners();
  }
}
