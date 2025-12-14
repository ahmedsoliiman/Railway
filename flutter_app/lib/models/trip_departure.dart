class TripDeparture {
  final int id;
  final int tripId;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int availableSeats;
  final DateTime? createdAt;

  TripDeparture({
    required this.id,
    required this.tripId,
    required this.departureTime,
    required this.arrivalTime,
    required this.availableSeats,
    this.createdAt,
  });

  factory TripDeparture.fromJson(Map<String, dynamic> json) {
    return TripDeparture(
      id: json['id'],
      tripId: json['tripId'] ?? json['trip_id'] ?? 0,
      departureTime: DateTime.parse(json['departureTime'] ?? json['departure_time']),
      arrivalTime: DateTime.parse(json['arrivalTime'] ?? json['arrival_time']),
      availableSeats: json['availableSeats'] ?? json['available_seats'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Duration get duration {
    return arrivalTime.difference(departureTime);
  }

  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'availableSeats': availableSeats,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
