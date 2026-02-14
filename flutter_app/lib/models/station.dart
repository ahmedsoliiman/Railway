class Station {
  final String code; // Primary Key
  final String name;
  final String city;
  final String? address;

  Station({
    required this.code,
    required this.name,
    required this.city,
    this.address,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'city': city,
      'address': address,
    };
  }

  // Getter for backward compatibility
  String get id => code;
}
