class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String? profileImagePath;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.profileImagePath,
    required this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : fullName;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      profileImagePath: map['profile_image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'password': password,
      'role': role,
      'profile_image_path': profileImagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? role,
    String? profileImagePath,
    bool clearProfileImage = false,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      profileImagePath: clearProfileImage
          ? null
          : (profileImagePath ?? this.profileImagePath),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
