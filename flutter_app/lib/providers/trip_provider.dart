import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/station.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

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
    if (_stations.isNotEmpty) return;
    try {
      _stations = await _apiService.getStations();
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _setError('Failed to load stations: $e');
    }
  }

  // Search trips
  Future<void> searchTrips({
    String? originCity,
    String? destinationCity,
    String? date,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _trips = await _apiService.getTrips(
        originStationCode:
            originCity, // These were passed as codes from some screens
        destinationStationCode: destinationCity,
        date: date,
      );
    } catch (e) {
      _setError('Failed to load trips: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load trips (backward compatibility)
  Future<void> loadTrips({
    int? originStationId,
    int? destinationStationId,
    String? originStationCode,
    String? destinationStationCode,
    DateTime? date,
    String? seatClass,
    String? trainType,
    double? maxPrice,
    TimeOfDay? departureTime,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _trips = await _apiService.getTrips(
        originStationCode: originStationCode,
        destinationStationCode: destinationStationCode,
        date: date?.toIso8601String().split('T')[0],
      );

      print('📊 Provider: Loaded ${_trips.length} trips from API');

      // Filter by trainType (client-side)
      if (trainType != null && trainType.isNotEmpty) {
        _trips = _trips
            .where((t) => t.trainType.toLowerCase() == trainType.toLowerCase())
            .toList();
        print('📉 After trainType filter: ${_trips.length}');
      }

      // Filter by seat class if specified (frontend filtering)
      if (seatClass != null) {
        _trips = _trips.where((trip) {
          if (seatClass.toLowerCase() == 'first') {
            return trip.firstClassPrice > 0;
          } else if (seatClass.toLowerCase() == 'second') {
            return trip.secondClassPrice > 0;
          } else if (seatClass.toLowerCase() == 'economic') {
            return trip.economicPrice > 0;
          }
          return true;
        }).toList();
        print('📉 After seatClass filter: ${_trips.length}');
      }

      // Filter by max price if specified
      if (maxPrice != null) {
        _trips = _trips.where((trip) {
          double? priceToCompare;

          if (seatClass != null) {
            final s = seatClass.toLowerCase();
            if (s == 'first') priceToCompare = trip.firstClassPrice;
            if (s == 'second') priceToCompare = trip.secondClassPrice;
            if (s == 'economic') priceToCompare = trip.economicPrice;
          } else {
            priceToCompare = trip.economicPrice;
          }

          if (priceToCompare == null) return false;
          return priceToCompare <= maxPrice;
        }).toList();
        print('📉 After price filter ($maxPrice): ${_trips.length}');
      }

      // Filter by departure time
      if (departureTime != null) {
        _trips = _trips.where((trip) {
          final dep = trip.effectiveDepartureTime;
          if (dep == null) return false;
          final depMinutes = dep.hour * 60 + dep.minute;
          final selectedMinutes =
              departureTime.hour * 60 + departureTime.minute;
          return depMinutes >= selectedMinutes;
        }).toList();
        print('📉 After time filter: ${_trips.length}');
      }

      print('🏁 Final results count: ${_trips.length}');
      Future.microtask(() => notifyListeners());
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
    Future.microtask(() => notifyListeners());
  }

  // Create Booking
  Future<Map<String, dynamic>> createBooking({
    required int tripId,
    required String passengerEmail,
    required int numberOfSeats,
    required double amount,
    String? seatClass,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.createBooking(
      tripId: tripId,
      passengerEmail: passengerEmail,
      numberOfSeats: numberOfSeats,
      amount: amount,
    );

    _setLoading(false);

    if (response['success']) {
      await loadBookings();

      // Send booking confirmation notification
      try {
        final booking = response['data'];
        if (_selectedTrip != null && booking != null) {
          await NotificationService().sendBookingConfirmation(
            bookingReference: 'REF-${booking['Booking_ID']}',
            trainName: _selectedTrip!.trainNumber,
            origin: _selectedTrip!.originName,
            destination: _selectedTrip!.destinationName,
            departureTime:
                _selectedTrip!.effectiveDepartureTime ?? DateTime.now(),
          );
        }
      } catch (e) {
        print('❌ Error sending notification: $e');
        // Continue anyway - notification failure shouldn't block booking
      }
    } else {
      _setError(response['message']);
    }

    return response;
  }

  // Process Payment
  Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiService.processPayment(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
      cardNumber: cardNumber,
      cardHolder: cardHolder,
      expiryDate: expiryDate,
      cvv: cvv,
    );

    _setLoading(false);

    if (response['success'] == true) {
      await loadBookings();
    } else {
      _setError(response['message']?.toString());
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
      final dep = booking.departureTime;
      if (dep == null) return true; // Show in upcoming as fallback
      return dep.isAfter(DateTime.now());
    }).toList();
  }

  // Get past bookings
  List<Booking> get pastBookings {
    return _bookings.where((booking) {
      if (booking.status == 'cancelled') return true;
      final dep = booking.departureTime;
      if (dep == null) return false;
      return dep.isBefore(DateTime.now());
    }).toList();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    Future.microtask(() => notifyListeners());
  }

  void _setError(String? value) {
    _error = value;
    Future.microtask(() => notifyListeners());
  }

  void clearError() {
    _error = null;
    Future.microtask(() => notifyListeners());
  }

  void clearTrips() {
    _trips = [];
    Future.microtask(() => notifyListeners());
  }
}
