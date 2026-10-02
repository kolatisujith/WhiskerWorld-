import 'enums.dart';

/// Whisker World User Model
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? passwordHash;
  final String? phone;
  final String? profileImage;
  final String? location;
  final String? bio;
  final double? latitude;
  final double? longitude;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.passwordHash,
    this.phone,
    String? profileImage,
    String? avatarUrl,
    this.location,
    this.bio,
    this.latitude,
    this.longitude,
    required this.role,
    required this.createdAt,
    DateTime? updatedAt,
  })  : profileImage = profileImage ?? avatarUrl,
        updatedAt = updatedAt ?? createdAt;

  /// Alias for backward compatibility
  String? get avatarUrl => profileImage;

  /// Serializes model to SQLite storage map.
  Map<String, dynamic> toMap({bool includePassword = true}) {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'avatar_url': profileImage, // compatibility with Schema V1 column
      'location': location,
      'bio': bio,
      'latitude': latitude,
      'longitude': longitude,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (includePassword && passwordHash != null) {
      map['password_hash'] = passwordHash;
    }
    return map;
  }

  /// Deserializes model from SQLite row map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    final created = map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : DateTime.now();
    final updated = map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : created;

    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String?,
      phone: map['phone'] as String?,
      profileImage: (map['profile_image'] ?? map['avatar_url']) as String?,
      location: map['location'] as String?,
      bio: map['bio'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      role: UserRole.fromString(map['role'] as String? ?? 'petAdopter'),
      createdAt: created,
      updatedAt: updated,
    );
  }

  /// Returns a clean copy of the user with passwordHash removed for safe UI display.
  UserModel sanitize() {
    return UserModel(
      id: id,
      name: name,
      email: email,
      passwordHash: null,
      phone: phone,
      profileImage: profileImage,
      location: location,
      bio: bio,
      latitude: latitude,
      longitude: longitude,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
    String? profileImage,
    String? location,
    String? bio,
    double? latitude,
    double? longitude,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, email: $email, role: ${role.displayName})';
}
