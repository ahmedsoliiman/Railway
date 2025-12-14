import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/station.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class TripProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Trip> _trips = [];
  List<Station> _stations = [];
  List<Booking> _bookings = [];
  Trip? _selectedTrip;
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  List<Station> get stations => _stations;
  List<Booking> get bookings => _bookings;
  Trip? get selectedTrip => _selectedTrip;
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

  // Search trips
  Future<void> searchTrips({
    int? originId,
    int? destinationId,
    String? date,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _trips = await _apiService.getTrips(
        originId: originId,
        destinationId: destinationId,
        date: date,
      );
    } catch (e) {
      _setError('Failed to load trips: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all trips with optional filters
  Future<void> loadTrips({
    int? originStationId,
    int? destinationStationId,
    DateTime? date,
    String? seatClass,
    String? trainType,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _trips = await _apiService.getTrips(
        originId: originStationId,
        destinationId: destinationStationId,
        date: date?.toIso8601String().split('T')[0],
        trainType: trainType,
      );
      
      // Additional client-side filtering to ensure exact matches
      if (originStationId != null || destinationStationId != null) {
        _trips = _trips.where((trip) {
          bool matchesOrigin = originStationId == null || trip.originStationId == originStationId;
          bool matchesDestination = destinationStationId == null || trip.destinationStationId == destinationStationId;
          return matchesOrigin && matchesDestination;
        }).toList();
      }
      
      // Filter by seat class if specified (frontend filtering)
      if (seatClass != null) {
        _trips = _trips.where((trip) {
          if (seatClass.toLowerCase() == 'first') {
            return trip.firstClassPrice != null && trip.firstClassPrice! > 0;
          } else if (seatClass.toLowerCase() == 'second') {
            return trip.secondClassPrice != null && trip.secondClassPrice! > 0;
          }
          return true;
        }).toList();
      }
    } catch (e) {
      _setError('Failed to load trips: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load trip details
  Future<void> loadTripDetails(int tripId) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedTrip = await _apiService.getTripDetails(tripId);
    } catch (e) {
      _setError('Failed to load trip details: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set selected trip
  void setSelectedTrip(Trip trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  // Create Booking
  Future<Map<String, dynamic>> createBooking({
    required int tripId,
    required String seatClass,
    required int numberOfSeats,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.createBooking(
      tripId: tripId,
      seatClass: seatClass,
      numberOfSeats: numberOfSeats,
    );

    _setLoading(false);

    if (response['success']) {
      // Reload bookings
      await loadBookings();
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Load user bookings
  Future<void> loadBookings() async {
    _setLoading(true);
    _setError(null);

    try {
      _bookings = await _apiService.getMyBookings();
    } catch (e) {
      _setError('Failed to load bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cancel Booking
  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.cancelBooking(bookingId);

    _setLoading(false);

    if (response['success']) {
      // Reload bookings
      await loadBookings();
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Get upcoming bookings
  List<Booking> get upcomingBookings {
    return _bookings.where((booking) {
      if (booking.status == 'cancelled') return false;
      if (booking.departureTime == null) return false;
      return booking.departureTime!.isAfter(DateTime.now());
    }).toList();
  }

  // Get past bookings
  List<Booking> get pastBookings {
    return _bookings.where((booking) {
      if (booking.status == 'cancelled') return true;
      if (booking.departureTime == null) return false;
      return booking.departureTime!.isBefore(DateTime.now());
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

  void clearTrips() {
    _trips = [];
    notifyListeners();
  }
}
