class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String vehicleType;
  final String category;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.vehicleType,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });

  static String categoryFromId(String id) {
    switch (id) {
      case 's1':
        return 'Basic';
      case 's2':
        return 'Premium';
      case 's3':
        return 'Interior';
      case 's4':
        return 'Detailing';
      default:
        if (id.startsWith('s1')) return 'Basic';
        return 'Basic';
    }
  }

  static String _resolveCategory(String id, String name) {
    switch (id) {
      case 's1':
        return 'Basic';
      case 's2':
        return 'Premium';
      case 's3':
        return 'Interior';
      case 's4':
        return 'Detailing';
      default:
        return categoryFromName(name);
    }
  }

  static String categoryFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('premium')) return 'Premium';
    if (lower.contains('interior')) return 'Interior';
    if (lower.contains('detail')) return 'Detailing';
    return 'Basic';
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String;
    final name = map['name'] as String;
    return ServiceModel(
      id: id,
      name: name,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      durationMinutes: map['duration_minutes'] as int,
      vehicleType: map['vehicle_type'] as String,
      category: _resolveCategory(id, name),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'vehicle_type': vehicleType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? vehicleType,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      vehicleType: vehicleType ?? this.vehicleType,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
