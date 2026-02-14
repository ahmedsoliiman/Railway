import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // Helper: Get Stations for Dropdown
  Future<List<Map<String, dynamic>>> getStations() async {
    try {
      final response = await _supabase.from('station').select('name, code');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Report 1: Most Reserved Trains in a Specific Station
  Future<Map<String, dynamic>> getMostReservedTrains({
    required String stationCode,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 1. Get trips departing from this station in the date range
      // Using explicit relationships logic or just basic fetch
      // Since train relationship might be tricky, let's select simple columns first.

      // We need trip IDs to count bookings.
      // We need Train_ID to group by Train.
      // We can fetch train details later or via join.

      final tripsResponse = await _supabase
          .from('trip')
          .select('Trip_ID, Train_ID, train:Train_ID(Train_Name)')
          .eq('From', stationCode)
          .gte('Date',
              startDate.toIso8601String().split('T')[0]) // FIX: Date format
          .lte('Date', endDate.toIso8601String().split('T')[0]);

      if (tripsResponse.isEmpty) {
        return {'success': true, 'data': <Map<String, dynamic>>[]};
      }

      final tripIds = (tripsResponse as List).map((t) => t['Trip_ID']).toList();

      // 2. Fetch bookings for these trips
      // Use filter 'in' correctly
      final bookingsResponse = await _supabase
          .from('booking')
          .select('Trip_ID, numberOfSeats')
          .filter('Trip_ID', 'in', tripIds);

      // 3. Aggregate
      final Map<String, int> trainCounts = {};
      final Map<int, String> tripTrainMap = {}; // TripID -> TrainName

      for (var t in tripsResponse) {
        final train = t['train'];
        // Handle if train is list or map or null
        String trainName = 'Unknown Train';
        if (train != null) {
          if (train is Map) {
            trainName = train['Train_Name'] ?? 'Unknown';
          } else if (train is List && train.isNotEmpty) {
            trainName = train[0]['Train_Name'] ?? 'Unknown';
          }
        }
        tripTrainMap[t['Trip_ID']] = trainName;
      }

      for (var b in bookingsResponse) {
        final tripId = b['Trip_ID'];
        // numberOfSeats might be null (if not selected) or int
        final seats =
            (b['numberOfSeats'] as num?)?.toInt() ?? 1; // Default to 1 if null

        final trainName = tripTrainMap[tripId] ?? 'Unknown';
        trainCounts[trainName] = (trainCounts[trainName] ?? 0) + seats;
      }

      final result = trainCounts.entries
          .map((e) => {
                'trainName': e.key,
                'bookings': e.value,
              })
          .toList();

      result.sort(
          (a, b) => (b['bookings'] as int).compareTo(a['bookings'] as int));

      return {'success': true, 'data': result};
    } catch (e) {
      print('Manager report error: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Report 2: Busiest Travel Days Report
  Future<Map<String, dynamic>> getBusiestTravelDays({
    required int month,
    required int year,
  }) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0);

      final tripsResponse = await _supabase
          .from('trip')
          .select('Trip_ID, Date')
          .gte('Date', startOfMonth.toIso8601String().split('T')[0]) // FIX
          .lte('Date', endOfMonth.toIso8601String().split('T')[0]); // FIX

      if (tripsResponse.isEmpty) {
        return {'success': true, 'data': <Map<String, dynamic>>[]};
      }

      final tripIds = (tripsResponse as List).map((t) => t['Trip_ID']).toList();

      final bookingsResponse = await _supabase
          .from('booking')
          .select('Trip_ID, numberOfSeats')
          .filter('Trip_ID', 'in', tripIds);

      final Map<String, int> dateCounts = {};
      final Map<int, String> tripDateMap = {};

      for (var t in tripsResponse) {
        tripDateMap[t['Trip_ID']] = t['Date'].toString();
      }

      for (var b in bookingsResponse) {
        final tripId = b['Trip_ID'];
        final seats = (b['numberOfSeats'] as num?)?.toInt() ?? 1;
        final date = tripDateMap[tripId] ?? 'Unknown';

        dateCounts[date] = (dateCounts[date] ?? 0) + seats;
      }

      final result = dateCounts.entries
          .map((e) => {
                'date': e.key,
                'passengers': e.value,
              })
          .toList();

      result.sort(
          (a, b) => (b['passengers'] as int).compareTo(a['passengers'] as int));

      return {'success': true, 'data': result};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
