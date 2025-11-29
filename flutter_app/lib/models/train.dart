class Train {
  final int id;
  final String trainNumber;
  final String name;
  final String type; // Express, Premium, Standard
  final int totalSeats;
  final int firstClassSeats;
  final int secondClassSeats;
  final String? facilities;
  final String status; // active, maintenance, retired
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Train({
    required this.id,
    required this.trainNumber,
    required this.name,
    required this.type,
    required this.totalSeats,
    required this.firstClassSeats,
    required this.secondClassSeats,
    this.facilities,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
    return Train(
      id: json['id'] ?? 0,
      trainNumber: json['train_number'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Standard',
      totalSeats: json['total_seats'] ?? 0,
      firstClassSeats: json['first_class_seats'] ?? 0,
      secondClassSeats: json['second_class_seats'] ?? 0,
      facilities: json['facilities'],
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'train_number': trainNumber,
      'name': name,
      'type': type,
      'total_seats': totalSeats,
      'first_class_seats': firstClassSeats,
      'second_class_seats': secondClassSeats,
      'facilities': facilities,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  List<String> get facilitiesList {
    if (facilities == null || facilities!.isEmpty) return [];
    return facilities!.split(',').map((f) => f.trim()).toList();
  }

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'maintenance':
        return 'Under Maintenance';
      case 'retired':
        return 'Retired';
      default:
        return status;
    }
  }

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'express':
        return 'Express';
      case 'premium':
        return 'Premium';
      case 'standard':
        return 'Standard';
      default:
        return type;
    }
  }
}
