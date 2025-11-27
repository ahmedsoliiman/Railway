class Tour {
  final int id;
  final int trainId;
  final String trainName;
  final String trainNumber;
  final String trainType;
  final String? trainFacilities;
  final int originStationId;
  final String originName;
  final String originCity;
  final int destinationStationId;
  final String destinationName;
  final String destinationCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double? firstClassPrice;
  final double? secondClassPrice;
  final int availableSeats;
  final String status;

  Tour({
    required this.id,
    required this.trainId,
    required this.trainName,
    required this.trainNumber,
    required this.trainType,
    this.trainFacilities,
    required this.originStationId,
    required this.originName,
    required this.originCity,
    required this.destinationStationId,
    required this.destinationName,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
    this.firstClassPrice,
    this.secondClassPrice,
    required this.availableSeats,
    required this.status,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'],
      trainId: json['train_id'],
      trainName: json['train_name'],
      trainNumber: json['train_number'],
      trainType: json['train_type'] ?? 'Standard',
      trainFacilities: json['train_facilities'],
      originStationId: json['origin_station_id'],
      originName: json['origin_name'],
      originCity: json['origin_city'],
      destinationStationId: json['destination_station_id'],
      destinationName: json['destination_name'],
      destinationCity: json['destination_city'],
      departureTime: DateTime.parse(json['departure_time']),
      arrivalTime: DateTime.parse(json['arrival_time']),
      firstClassPrice: json['first_class_price'] != null ? double.parse(json['first_class_price'].toString()) : null,
      secondClassPrice: json['second_class_price'] != null ? double.parse(json['second_class_price'].toString()) : null,
      availableSeats: json['available_seats'],
      status: json['status'],
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
      'train_id': trainId,
      'train_name': trainName,
      'train_number': trainNumber,
      'train_type': trainType,
      'train_facilities': trainFacilities,
      'origin_station_id': originStationId,
      'origin_name': originName,
      'origin_city': originCity,
      'destination_station_id': destinationStationId,
      'destination_name': destinationName,
      'destination_city': destinationCity,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'first_class_price': firstClassPrice,
      'second_class_price': secondClassPrice,
      'available_seats': availableSeats,
      'status': status,
    };
  }
}
