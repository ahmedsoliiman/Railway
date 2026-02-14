import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/station.dart';
import '../models/train.dart';
import '../models/trip.dart';
import '../models/booking.dart';
import 'storage_service.dart';

class AdminService {
  final StorageService _storageService = StorageService();
  SupabaseClient get _supabase => Supabase.instance.client;

  // ============ DASHBOARD STATS ============

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersCount = await _supabase.from('passenger').count();
      final stationsCount = await _supabase.from('station').count();
      final trainsCount = await _supabase.from('train').count();
      final reservationsCount = await _supabase.from('booking').count();

      final reservations = await _supabase.from('booking').select('Amount');
      double revenue = 0;
      for (var r in reservations) {
        revenue += (r['Amount'] as num).toDouble();
      }

      return {
        'success': true,
        'data': {
          'totalUsers': usersCount,
          'totalStations': stationsCount,
          'totalTrains': trainsCount,
          'totalReservations': reservationsCount,
          'totalRevenue': revenue,
          'activeTours': 0,
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ============ STATIONS MANAGEMENT ============

  Future<Map<String, dynamic>> getStations() async {
    try {
      final List<dynamic> response = await _supabase.from('station').select();
      final stations = response.map((s) => Station.fromJson(s)).toList();
      return {'success': true, 'data': stations};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createStation({
    required String name,
    required String code,
    required String city,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _supabase
          .from('station')
          .insert({
            'name': name,
            'code': code,
            'city': city,
            'address': address ?? '',
          })
          .select()
          .single();

      return {
        'success': true,
        'message': 'Station created successfully',
        'data': Station.fromJson(response),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateStation({
    required String code,
    String? name,
    String? city,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _supabase
          .from('station')
          .update({
            if (name != null) 'name': name,
            if (city != null) 'city': city,
            if (address != null) 'address': address,
          })
          .eq('code', code)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Station updated successfully',
        'data': Station.fromJson(response),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteStation(String code) async {
    try {
      await _supabase.from('station').delete().eq('code', code);
      return {'success': true, 'message': 'Station deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ============ TRAINS MANAGEMENT ============

  Future<Map<String, dynamic>> getTrains() async {
    try {
      final List<dynamic> response = await _supabase.from('train').select();
      final trains = response.map((t) => Train.fromJson(t)).toList();
      return {'success': true, 'data': trains};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createTrain({
    required String trainNumber,
    required String type,
    int? capacity,
  }) async {
    try {
      final response = await _supabase
          .from('train')
          .insert({
            'Train_Name': trainNumber,
            'Train_Type': type,
            'Status': 'Active',
          })
          .select()
          .single();

      return {'success': true, 'data': Train.fromJson(response)};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateTrain({
    required int id,
    String? trainNumber,
    String? type,
  }) async {
    try {
      final response = await _supabase
          .from('train')
          .update({
            if (trainNumber != null) 'Train_Name': trainNumber,
            if (type != null) 'Train_Type': type,
          })
          .eq('Train_ID', id)
          .select()
          .single();

      return {'success': true, 'data': Train.fromJson(response)};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteTrain(int id) async {
    try {
      await _supabase.from('train').delete().eq('Train_ID', id);
      return {'success': true, 'message': 'Train deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ============ USERS & BOOKINGS ============

  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final List<dynamic> response = await _supabase.from('passenger').select();
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getAllBookings() async {
    try {
      try {
        final List<dynamic> response = await _supabase
            .from('booking')
            .select('*, passenger(*), trip(*)')
            .order('Booking_ID', ascending: false);
        return {'success': true, 'data': response};
      } catch (joinError) {
        print('⚠️ Admin getAllBookings join error: $joinError');
        // Fallback: Fetch raw bookings
        final List<dynamic> response = await _supabase
            .from('booking')
            .select()
            .order('Booking_ID', ascending: false);
        return {'success': true, 'data': response};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ============ TRIPS MANAGEMENT ============

  Future<Map<String, dynamic>> getTrips() async {
    try {
      final List<dynamic> response = await _supabase.from('trip').select('''
        *,
        train(*),
        station_from:station!From(*),
        station_to:station!To(*)
      ''');
      final trips = response.map((t) => Trip.fromJson(t)).toList();
      return {'success': true, 'data': trips};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
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
    try {
      final response = await _supabase
          .from('trip')
          .insert({
            'Train_ID': trainId,
            'From': originStationId.toString(),
            'To': destinationStationId.toString(),
            'Date': departure.toIso8601String().split('T')[0],
            'Time': departureTime.toIso8601String().split('T')[1].split('.')[0],
            'Base_Price': economicPrice,
          })
          .select()
          .single();

      return {
        'success': true,
        'message': 'Trip created successfully',
        'data': Trip.fromJson(response),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ============ TRIP DEPARTURES ============

  Future<Map<String, dynamic>> getTripDepartures() async {
    try {
      final List<dynamic> response =
          await _supabase.from('trip_departures').select('*, trip(*)');
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createTripDeparture({
    required int tripId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int availableSeats,
  }) async {
    try {
      final response = await _supabase
          .from('trip_departures')
          .insert({
            'trip_id': tripId,
            'departure_time': departureTime.toIso8601String(),
            'arrival_time': arrivalTime.toIso8601String(),
            'available_seats': availableSeats,
          })
          .select()
          .single();

      return {
        'success': true,
        'message': 'Trip Departure created successfully',
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateTripDeparture({
    required int id,
    required int tripId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int availableSeats,
  }) async {
    try {
      final response = await _supabase
          .from('trip_departures')
          .update({
            'trip_id': tripId,
            'departure_time': departureTime.toIso8601String(),
            'arrival_time': arrivalTime.toIso8601String(),
            'available_seats': availableSeats,
          })
          .eq('id', id)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Trip Departure updated successfully',
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteTripDeparture(int id) async {
    try {
      await _supabase.from('trip_departures').delete().eq('id', id);
      return {
        'success': true,
        'message': 'Trip Departure deleted successfully'
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // ============ CARRIAGE TYPES ============

  Future<Map<String, dynamic>> getCarriageTypes() async {
    try {
      final List<dynamic> response =
          await _supabase.from('carriage_type').select();
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createCarriageType({
    required String type,
    required int capacity,
    required double price,
  }) async {
    try {
      final response = await _supabase
          .from('carriage_type')
          .insert({
            'type': type,
            'capacity': capacity,
            'price': price,
          })
          .select()
          .single();

      return {
        'success': true,
        'message': 'Carriage Type created successfully',
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateCarriageType({
    required int id,
    required String type,
    required int capacity,
    required double price,
  }) async {
    try {
      final response = await _supabase
          .from('carriage_type')
          .update({
            'type': type,
            'capacity': capacity,
            'price': price,
          })
          .eq('carriage_type_id', id)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Carriage Type updated successfully',
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteCarriageType(int id) async {
    try {
      await _supabase.from('carriage_type').delete().eq('carriage_type_id', id);
      return {'success': true, 'message': 'Carriage Type deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
