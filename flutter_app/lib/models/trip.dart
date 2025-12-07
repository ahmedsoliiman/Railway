class Trip {
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
  final DateTime departure;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double? firstClassPrice;
  final double? secondClassPrice;
  final double? economicPrice;
  final int quantities;

  Trip({
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
    required this.departure,
    required this.departureTime,
    required this.arrivalTime,
    this.firstClassPrice,
    this.secondClassPrice,
    this.economicPrice,
    required this.quantities,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    // Handle both admin API format (with nested objects) and user API format (flat structure)
    final trainData = json['train'];
    final departureStationData = json['departureStation'];
    final arrivalStationData = json['arrivalStation'];
    
    // Parse departure time first
    final departureTimeStr = json['departureTime'] ?? json['departure_time'];
    final parsedDepartureTime = DateTime.parse(departureTimeStr);
    
    // If departure field exists, use it; otherwise extract date from departureTime
    final departure = json['departure'] != null 
        ? DateTime.parse(json['departure'])
        : DateTime(parsedDepartureTime.year, parsedDepartureTime.month, parsedDepartureTime.day);
    
    return Trip(
      id: json['id'],
      trainId: json['trainId'] ?? json['train_id'],
      trainName: trainData?['name'] ?? json['train_name'] ?? '',
      trainNumber: trainData?['trainNumber'] ?? json['train_number'] ?? '',
      trainType: trainData?['type'] ?? json['train_type'] ?? 'Standard',
      trainFacilities: trainData?['facilities'] ?? json['train_facilities'],
      originStationId: json['originStationId'] ?? json['origin_station_id'],
      originName: departureStationData?['name'] ?? json['origin_name'] ?? '',
      originCity: departureStationData?['city'] ?? json['origin_city'] ?? '',
      destinationStationId: json['destinationStationId'] ?? json['destination_station_id'],
      destinationName: arrivalStationData?['name'] ?? json['destination_name'] ?? '',
      destinationCity: arrivalStationData?['city'] ?? json['destination_city'] ?? '',
      departure: departure,
      departureTime: parsedDepartureTime,
      arrivalTime: DateTime.parse(json['arrivalTime'] ?? json['arrival_time']),
      firstClassPrice: (json['firstClassPrice'] ?? json['first_class_price']) != null 
          ? double.parse((json['firstClassPrice'] ?? json['first_class_price']).toString()) 
          : null,
      secondClassPrice: (json['secondClassPrice'] ?? json['second_class_price']) != null 
          ? double.parse((json['secondClassPrice'] ?? json['second_class_price']).toString()) 
          : null,
      economicPrice: (json['economicPrice'] ?? json['economic_price']) != null 
          ? double.parse((json['economicPrice'] ?? json['economic_price']).toString()) 
          : null,
      quantities: json['quantities'] ?? 0,
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
      'departure': departure.toIso8601String().split('T')[0],
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'first_class_price': firstClassPrice,
      'second_class_price': secondClassPrice,
      'quantities': quantities,
    };
  }
}
