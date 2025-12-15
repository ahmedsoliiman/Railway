import 'trip_departure.dart';

class Trip {
  final int id;
  final int trainId;
  final String? trainName;
  final String trainNumber;
  final String trainType;
  final String? trainFacilities;
  final int originStationId;
  final String originName;
  final String originCity;
  final int destinationStationId;
  final String destinationName;
  final String destinationCity;
  final DateTime? departure;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final double? firstClassPrice;
  final double? secondClassPrice;
  final double? economicPrice;
  final int quantities;
  final List<TripDeparture>? departures;
  final List<Map<String, dynamic>>? availableSeatClasses;

  Trip({
    required this.id,
    required this.trainId,
    this.trainName,
    required this.trainNumber,
    required this.trainType,
    this.trainFacilities,
    required this.originStationId,
    required this.originName,
    required this.originCity,
    required this.destinationStationId,
    required this.destinationName,
    required this.destinationCity,
    this.departure,
    this.departureTime,
    this.arrivalTime,
    this.firstClassPrice,
    this.secondClassPrice,
    this.economicPrice,
    required this.quantities,
    this.departures,
    this.availableSeatClasses,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    // Handle both admin API format (with nested objects) and user API format (flat structure)
    final trainData = json['train'];
    final departureStationData = json['departureStation'];
    final arrivalStationData = json['arrivalStation'];
    
    // Parse departure time if available
    final departureTimeStr = json['departureTime'] ?? json['departure_time'];
    final arrivalTimeStr = json['arrivalTime'] ?? json['arrival_time'];
    
    DateTime? parsedDepartureTime;
    DateTime? parsedArrivalTime;
    DateTime? departure;
    
    if (departureTimeStr != null) {
      parsedDepartureTime = DateTime.parse(departureTimeStr);
      departure = json['departure'] != null 
          ? DateTime.parse(json['departure'])
          : DateTime(parsedDepartureTime.year, parsedDepartureTime.month, parsedDepartureTime.day);
    }
    
    if (arrivalTimeStr != null) {
      parsedArrivalTime = DateTime.parse(arrivalTimeStr);
    }

    // Parse departures array if present
    List<TripDeparture>? departures;
    if (json['departures'] != null && json['departures'] is List) {
      departures = (json['departures'] as List)
          .map((d) => TripDeparture.fromJson(d))
          .toList();
    }
    
    return Trip(
      id: json['id'],
      trainId: json['trainId'] ?? json['train_id'] ?? trainData?['id'] ?? 0,
      trainName: trainData?['name'] ?? json['train_name'],
      trainNumber: trainData?['trainNumber'] ?? trainData?['train_number'] ?? json['train_number'] ?? '',
      trainType: trainData?['type'] ?? json['train_type'] ?? 'Standard',
      trainFacilities: trainData?['facilities'] ?? json['train_facilities'],
      originStationId: json['originStationId'] ?? json['origin_station_id'] ?? departureStationData?['id'] ?? 0,
      originName: departureStationData?['name'] ?? json['origin_name'] ?? '',
      originCity: departureStationData?['city'] ?? json['origin_city'] ?? '',
      destinationStationId: json['destinationStationId'] ?? json['destination_station_id'] ?? arrivalStationData?['id'] ?? 0,
      destinationName: arrivalStationData?['name'] ?? json['destination_name'] ?? '',
      destinationCity: arrivalStationData?['city'] ?? json['destination_city'] ?? '',
      departure: departure,
      departureTime: parsedDepartureTime,
      arrivalTime: parsedArrivalTime,
      firstClassPrice: (json['firstClassPrice'] ?? json['first_class_price']) != null 
          ? double.parse((json['firstClassPrice'] ?? json['first_class_price']).toString()) 
          : null,
      secondClassPrice: (json['secondClassPrice'] ?? json['second_class_price']) != null 
          ? double.parse((json['secondClassPrice'] ?? json['second_class_price']).toString()) 
          : null,
      economicPrice: (json['economicPrice'] ?? json['economic_price']) != null 
          ? double.parse((json['economicPrice'] ?? json['economic_price']).toString()) 
          : null,
      quantities: json['quantities'] ?? json['availableSeats'] ?? json['available_seats'] ?? 0,
      departures: departures,
      availableSeatClasses: json['availableSeatClasses'] != null 
          ? List<Map<String, dynamic>>.from(json['availableSeatClasses'])
          : null,
    );
  }

  // Convenience getters that return the first departure's time if no direct time is set
  DateTime? get effectiveDepartureTime {
    if (departureTime != null) return departureTime;
    if (departures != null && departures!.isNotEmpty) {
      return departures!.first.departureTime;
    }
    return null;
  }

  DateTime? get effectiveArrivalTime {
    if (arrivalTime != null) return arrivalTime;
    if (departures != null && departures!.isNotEmpty) {
      return departures!.first.arrivalTime;
    }
    return null;
  }

  Duration? get duration {
    final depTime = effectiveDepartureTime;
    final arrTime = effectiveArrivalTime;
    if (depTime == null || arrTime == null) return null;
    return arrTime.difference(depTime);
  }

  String get durationFormatted {
    if (duration == null) return 'N/A';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  int get departuresCount => departures?.length ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'train_id': trainId,
      if (trainName != null) 'train_name': trainName,
      'train_number': trainNumber,
      'train_type': trainType,
      if (trainFacilities != null) 'train_facilities': trainFacilities,
      'origin_station_id': originStationId,
      'origin_name': originName,
      'origin_city': originCity,
      'destination_station_id': destinationStationId,
      'destination_name': destinationName,
      'destination_city': destinationCity,
      if (departure != null) 'departure': departure!.toIso8601String().split('T')[0],
      if (departureTime != null) 'departure_time': departureTime!.toIso8601String(),
      if (arrivalTime != null) 'arrival_time': arrivalTime!.toIso8601String(),
      if (firstClassPrice != null) 'first_class_price': firstClassPrice,
      if (secondClassPrice != null) 'second_class_price': secondClassPrice,
      if (economicPrice != null) 'economic_price': economicPrice,
      'quantities': quantities,
    };
  }
}
