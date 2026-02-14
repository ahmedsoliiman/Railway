class Booking {
  final int bookingId;
  final int passengerId;
  final int tripId;
  final int numberOfSeats;
  final double amount;
  final int? instanceId; // Optional as per schema

  // Joined details
  final String? trainName;
  final String? fromCity;
  final String? toCity;
  final String? date;
  final String? time;

  final String status;

  Booking({
    required this.bookingId,
    required this.passengerId,
    required this.tripId,
    required this.numberOfSeats,
    required this.amount,
    this.instanceId,
    this.status = 'confirmed',
    this.trainName,
    this.fromCity,
    this.toCity,
    this.date,
    this.time,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Supabase can sometimes return nested objects as a list if relationship is ambiguous
    dynamic tripData = json['trip'];
    if (tripData is List && tripData.isNotEmpty) tripData = tripData.first;

    final Map<String, dynamic>? trip =
        tripData is Map<String, dynamic> ? tripData : null;

    dynamic trainData = trip?['train'];
    if (trainData is List && trainData.isNotEmpty) trainData = trainData.first;
    final Map<String, dynamic>? train =
        trainData is Map<String, dynamic> ? trainData : null;

    return Booking(
      bookingId: json['Booking_ID'] ?? 0,
      passengerId: json['PassengerID'] ?? 0,
      tripId: json['Trip_ID'] ?? 0,
      numberOfSeats: json['numberOfSeats'] ?? 1,
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
      instanceId: json['instance_ID'] ?? json['Instance_ID'],
      status: json['Status'] ?? 'confirmed',
      trainName: train != null ? train['Train_Name'] : null,
      fromCity: trip != null && trip['station_from'] != null
          ? (trip['station_from'] is List
              ? trip['station_from'].first['city']
              : (trip['station_from']['city'] ?? trip['station_from']['City']))
          : null,
      toCity: trip != null && trip['station_to'] != null
          ? (trip['station_to'] is List
              ? trip['station_to'].first['city']
              : (trip['station_to']['city'] ?? trip['station_to']['City']))
          : null,
      date: trip != null ? (trip['Date'] ?? trip['date'])?.toString() : null,
      time: trip != null ? (trip['Time'] ?? trip['time'])?.toString() : null,
    );
  }

  DateTime? get departureTime {
    if (date == null || time == null) return null;
    try {
      // Handle potential format issues
      final dateClean = date!.trim();
      final timeClean = time!.trim();
      return DateTime.parse('$dateClean $timeClean');
    } catch (e) {
      print('⚠️ Date Parse Error for booking $bookingId: $date $time -> $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Booking_ID': bookingId,
      'PassengerID': passengerId,
      'Trip_ID': tripId,
      'numberOfSeats': numberOfSeats,
      'Amount': amount,
      'Instance_ID': instanceId,
      'Status': status,
    };
  }

  // Compatibility Getters
  String get bookingReference => '#$bookingId';
  String? get trainNumber => trainName;
  String? get originName => fromCity;
  String? get destinationName => toCity;
  String get seatClassFormatted => 'Standard'; // Default
  double get totalPrice => amount;
  int get id => bookingId;
  bool get canCancel => status.toLowerCase() == 'confirmed';
}
