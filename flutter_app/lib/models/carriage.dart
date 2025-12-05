class Carriage {
  final int id;
  final String name;
  final String classType; // first, second, economic
  final int seatsCount;
  final String? model;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Carriage({
    required this.id,
    required this.name,
    required this.classType,
    required this.seatsCount,
    this.model,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Carriage.fromJson(Map<String, dynamic> json) {
    return Carriage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      classType: json['classType'] ?? json['class_type'] ?? 'economic',
      seatsCount: json['seatsCount'] ?? json['seats_count'] ?? 0,
      model: json['model'],
      description: json['description'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : 
                 (json['created_at'] != null ? DateTime.parse(json['created_at']) : null),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) :
                 (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'class_type': classType,
      'seats_count': seatsCount,
      'model': model,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get classTypeDisplay {
    switch (classType.toLowerCase()) {
      case 'first':
        return 'First Class';
      case 'second':
        return 'Second Class';
      case 'economic':
        return 'Economic';
      default:
        return classType;
    }
  }
}

class TrainCarriage {
  final int carriageId;
  final int quantity;
  final String? name;
  final String? classType;
  final int? seatsCount;
  final String? model;

  TrainCarriage({
    required this.carriageId,
    required this.quantity,
    this.name,
    this.classType,
    this.seatsCount,
    this.model,
  });

  factory TrainCarriage.fromJson(Map<String, dynamic> json) {
    return TrainCarriage(
      carriageId: json['carriageId'] ?? json['carriage_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      name: json['name'],
      classType: json['classType'] ?? json['class_type'],
      seatsCount: json['seatsCount'] ?? json['seats_count'],
      model: json['model'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carriage_id': carriageId,
      'quantity': quantity,
    };
  }

  int get totalSeats => (seatsCount ?? 0) * quantity;
}
