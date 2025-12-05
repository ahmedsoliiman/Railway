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
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'user',
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now()),
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
