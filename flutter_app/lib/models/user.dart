class Passenger {
  final int id;
  final String fullName;
  final String email;
  final bool isVerified;
  final String role; // 'user' or 'admin'

  Passenger({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isVerified,
    this.role = 'user',
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['PassengerID'],
      fullName: json['Full_Name'] ?? '',
      email: json['Email'] ?? '',
      isVerified: json['IsVerified'] == 1 || json['IsVerified'] == true,
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PassengerID': id,
      'Full_Name': fullName,
      'Email': email,
      'IsVerified': isVerified,
      'role': role,
    };
  }
}
