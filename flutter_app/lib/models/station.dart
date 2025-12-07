class Station {
  final int id;
  final String name;
  final String code;
  final String city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? facilities;

  Station({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.facilities,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      city: json['city'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      facilities: json['facilities'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'facilities': facilities,
    };
  }
}
