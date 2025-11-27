class User {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final bool isVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
