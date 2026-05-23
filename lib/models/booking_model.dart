class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String serviceId;
  final String serviceName;
  final String vehicleType;
  final String plateNumber;
  final String bookingDate;
  final String bookingTime;
  final int queueNumber;
  final String status;
  final double price;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.serviceId,
    required this.serviceName,
    required this.vehicleType,
    required this.plateNumber,
    required this.bookingDate,
    required this.bookingTime,
    required this.queueNumber,
    required this.status,
    required this.price,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      serviceId: map['service_id'] as String,
      serviceName: map['service_name'] as String,
      vehicleType: map['vehicle_type'] as String,
      plateNumber: map['plate_number'] as String,
      bookingDate: map['booking_date'] as String,
      bookingTime: map['booking_time'] as String,
      queueNumber: map['queue_number'] as int,
      status: map['status'] as String,
      price: (map['price'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'service_id': serviceId,
      'service_name': serviceName,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'queue_number': queueNumber,
      'status': status,
      'price': price,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? serviceId,
    String? serviceName,
    String? vehicleType,
    String? plateNumber,
    String? bookingDate,
    String? bookingTime,
    int? queueNumber,
    String? status,
    double? price,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
