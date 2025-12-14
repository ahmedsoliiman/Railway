class Carriage {
  final int id;
  final String name; // carriage_number from backend
  final int carriageTypeId;
  final CarriageType? carriageType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Carriage({
    required this.id,
    required this.name,
    required this.carriageTypeId,
    this.carriageType,
    this.createdAt,
    this.updatedAt,
  });

  // Computed properties for backward compatibility
  String get carriageNumber => name; // Alias for compatibility
  String get classType => carriageType?.type ?? 'third class';
  String get classTypeDisplay => carriageType?.typeDisplay ?? 'Third Class';
  int get seatsCount => carriageType?.capacity ?? 80;
  String get description => '${classTypeDisplay} carriage with $seatsCount seats';

  factory Carriage.fromJson(Map<String, dynamic> json) {
    return Carriage(
      id: json['id'] ?? 0,
      name: json['carriageNumber'] ?? json['carriage_number'] ?? json['name'] ?? '',
      carriageTypeId: json['carriageTypeId'] ?? json['carriage_type_id'] ?? 0,
      carriageType: json['carriageType'] != null ? CarriageType.fromJson(json['carriageType']) :
                    (json['carriage_type'] != null ? CarriageType.fromJson(json['carriage_type']) : null),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : 
                 (json['created_at'] != null ? DateTime.parse(json['created_at']) : null),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) :
                 (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carriage_number': name,
      'carriage_type_id': carriageTypeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CarriageType {
  final int id;
  final String type; // first class, second class, third class, sleeper
  final int capacity;
  final double price;

  CarriageType({
    required this.id,
    required this.type,
    required this.capacity,
    required this.price,
  });

  String get typeDisplay {
    switch (type.toLowerCase()) {
      case 'first class':
        return 'First Class';
      case 'second class':
        return 'Second Class';
      case 'third class':
        return 'Third Class';
      case 'sleeper':
        return 'Sleeper';
      default:
        return type;
    }
  }

  factory CarriageType.fromJson(Map<String, dynamic> json) {
    return CarriageType(
      id: json['id'] ?? json['carriage_type_id'] ?? 0,
      type: json['type'] ?? 'third class',
      capacity: json['capacity'] ?? 80,
      price: (json['price'] ?? 100.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carriage_type_id': id,
      'type': type,
      'capacity': capacity,
      'price': price,
    };
  }
}

class TrainCarriage {
  final int carriageId;
  final int quantity;
  final String? name;
  final int? carriageTypeId;

  TrainCarriage({
    required this.carriageId,
    required this.quantity,
    this.name,
    this.carriageTypeId,
  });

  factory TrainCarriage.fromJson(Map<String, dynamic> json) {
    return TrainCarriage(
      carriageId: json['carriageId'] ?? json['carriage_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      name: json['name'],
      carriageTypeId: json['carriageTypeId'] ?? json['carriage_type_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carriage_id': carriageId,
      'quantity': quantity,
    };
  }
}
