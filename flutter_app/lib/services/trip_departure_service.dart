import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class TripDepartureService {
  final StorageService _storageService = StorageService();
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getTripDepartures(int tripId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('trip_departures')
          .select()
          .eq('trip_id', tripId);

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
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
      final response = await _supabase.from('trip_departures').insert({
        'trip_id': tripId,
        'departure_time': departureTime.toIso8601String(),
        'arrival_time': arrivalTime.toIso8601String(),
        'available_seats': availableSeats,
      }).select().single();

      return {
        'success': true,
        'message': 'Created successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
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
      final response = await _supabase.from('trip_departures').update({
        'departure_time': departureTime.toIso8601String(),
        'arrival_time': arrivalTime.toIso8601String(),
        'available_seats': availableSeats,
      }).eq('id', id).select().single();

      return {
        'success': true,
        'message': 'Updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteTripDeparture(int id) async {
    try {
      await _supabase.from('trip_departures').delete().eq('id', id);
      return {
        'success': true,
        'message': 'Deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}

