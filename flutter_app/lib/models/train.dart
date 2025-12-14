import 'carriage.dart';

class Train {
  final int id;
  final String trainNumber;
  final String type; // Express, ordinary, VIP, tahya masr, sleeper
  final String status; // active, maintenance, retired
  final List<TrainCarriage>? carriages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Train({
    required this.id,
    required this.trainNumber,
    required this.type,
    required this.status,
    this.carriages,
    this.createdAt,
    this.updatedAt,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
    List<TrainCarriage>? carriages;
    if (json['carriages'] != null && json['carriages'] is List) {
      carriages = (json['carriages'] as List)
          .map((c) => TrainCarriage.fromJson(c))
          .toList();
    }

    return Train(
      id: json['id'] ?? 0,
      trainNumber: json['trainNumber'] ?? json['train_number'] ?? '',
      type: json['type'] ?? 'ordinary',
      status: json['status'] ?? 'active',
      carriages: carriages,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : 
                 (json['created_at'] != null ? DateTime.parse(json['created_at']) : null),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) :
                 (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'train_number': trainNumber,
      'type': type,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
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
      case 'ordinary':
        return 'Ordinary';
      case 'vip':
        return 'VIP';
      case 'tahya masr':
        return 'Tahya Masr';
      case 'sleeper':
        return 'Sleeper';
      default:
        return type;
    }
  }
}
