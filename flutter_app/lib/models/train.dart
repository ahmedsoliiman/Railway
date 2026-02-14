class Train {
  final int id;
  final String name;
  final String type;
  final String status;

  Train({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
    return Train(
      id: json['Train_ID'],
      name: json['Train_Name'] ?? '',
      type: json['Train_Type'] ?? '',
      status: json['Status'] ?? 'active',
    );
  }
}
