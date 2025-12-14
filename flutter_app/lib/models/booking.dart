class Booking {
  final int id;
  final int userId;
  final int tripId;
  final String seatClass;
  final String? seatNumber;
  final int numberOfSeats;
  final double totalPrice;
  final String bookingReference;
  final String status;
  final DateTime createdAt;
  
  // Trip details
  final String? trainNumber;
  final String? originName;
  final String? originCity;
  final String? destinationName;
  final String? destinationCity;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final String? tripStatus;

  Booking({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.seatClass,
    this.seatNumber,
    required this.numberOfSeats,
    required this.totalPrice,
    required this.bookingReference,
    required this.status,
    required this.createdAt,
    this.trainNumber,
    this.originName,
    this.originCity,
    this.destinationName,
    this.destinationCity,
    this.departureTime,
    this.arrivalTime,
    this.tripStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      seatClass: json['seat_class'],
      seatNumber: json['seat_number'],
      numberOfSeats: json['number_of_seats'],
      totalPrice: double.parse(json['total_price'].toString()),
      bookingReference: json['booking_reference'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      trainNumber: json['train_number'],
      originName: json['origin_name'],
      originCity: json['origin_city'],
      destinationName: json['destination_name'],
      destinationCity: json['destination_city'],
      departureTime: json['departure_time'] != null ? DateTime.parse(json['departure_time']) : null,
      arrivalTime: json['arrival_time'] != null ? DateTime.parse(json['arrival_time']) : null,
      tripStatus: json['trip_status'],
    );
  }

  String get seatClassFormatted {
    return seatClass == 'first' ? 'First Class' : 'Second Class';
  }

  bool get canCancel {
    if (status == 'cancelled') return false;
    if (departureTime == null) return false;
    final twoHoursBefore = departureTime!.subtract(const Duration(hours: 2));
    return DateTime.now().isBefore(twoHoursBefore);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trip_id': tripId,
      'seat_class': seatClass,
      'seat_number': seatNumber,
      'number_of_seats': numberOfSeats,
      'total_price': totalPrice,
      'booking_reference': bookingReference,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'train_number': trainNumber,
      'origin_name': originName,
      'origin_city': originCity,
      'destination_name': destinationName,
      'destination_city': destinationCity,
      'departure_time': departureTime?.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'trip_status': tripStatus,
    };
  }
}
