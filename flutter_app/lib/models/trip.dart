class Trip {
  final int tripId;
  final int trainId;
  final String fromStationCode;
  final String toStationCode;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm:ss
  final double basePrice;

  // Optional joined data
  final String? trainName;
  final String? originCity;
  final String? destinationCity;

  Trip({
    required this.tripId,
    required this.trainId,
    required this.fromStationCode,
    required this.toStationCode,
    required this.date,
    required this.time,
    required this.basePrice,
    this.trainName,
    this.originCity,
    this.destinationCity,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    dynamic train = json['train'];
    if (train is List && train.isNotEmpty) train = train.first;

    dynamic stationFrom = json['station_from'];
    if (stationFrom is List && stationFrom.isNotEmpty)
      stationFrom = stationFrom.first;

    dynamic stationTo = json['station_to'];
    if (stationTo is List && stationTo.isNotEmpty) stationTo = stationTo.first;

    return Trip(
      tripId: json['Trip_ID'] ?? 0,
      trainId: json['Train_ID'] ?? 0,
      fromStationCode: json['From']?.toString() ?? '',
      toStationCode: json['To']?.toString() ?? '',
      date: json['Date']?.toString() ?? '',
      time: json['Time']?.toString() ?? '',
      basePrice: (json['Base_Price'] as num?)?.toDouble() ?? 0.0,

      // Joined data
      trainName: train != null ? train['Train_Name'] : null,
      originCity: stationFrom != null
          ? (stationFrom['city'] ?? stationFrom['City'])
          : null,
      destinationCity:
          stationTo != null ? (stationTo['city'] ?? stationTo['City']) : null,
    );
  }

  DateTime get departureDateTime {
    try {
      if (time.contains('T')) return DateTime.parse(time);
      return DateTime.parse('$date $time');
    } catch (_) {
      return DateTime.now();
    }
  }

  // Helpers for UI compatibility
  String get trainNumber => trainName ?? 'Train #$trainId';
  String get trainType => 'Express';
  String get durationFormatted => '2h 30m';

  String get originName => fromStationCode;
  String get destinationName => toStationCode;
  DateTime? get effectiveDepartureTime => departureDateTime;
  DateTime? get effectiveArrivalTime =>
      departureDateTime.add(const Duration(hours: 2, minutes: 30));

  // Mock prices based on Base Price
  double get firstClassPrice => basePrice * 2.5;
  double get secondClassPrice => basePrice * 1.5;
  double get economicPrice => basePrice;

  // Identify available classes
  List<Map<String, dynamic>> get availableSeatClasses => [
        {'value': 'first', 'label': 'First Class', 'price': firstClassPrice},
        {'value': 'second', 'label': 'Second Class', 'price': secondClassPrice},
        {'value': 'economic', 'label': 'Economic', 'price': economicPrice},
      ];

  int get quantities => 50;
  int get id => tripId;
}
