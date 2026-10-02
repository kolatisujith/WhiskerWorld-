/// Whisker World Pet Store Model with Phase 5 Ownership & Storefront Details
class PetStoreModel {
  final String id;
  final String? ownerId;
  final String name;
  final String? description;
  final String address;
  final String city;
  final String? state;
  final String country;
  final String phone;
  final String email;
  final String? website;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? openingHours;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetStoreModel({
    required this.id,
    this.ownerId,
    required this.name,
    this.description,
    required this.address,
    required this.city,
    this.state,
    this.country = 'United States',
    required this.phone,
    required this.email,
    this.website,
    this.logoUrl,
    this.coverImageUrl,
    this.openingHours,
    this.latitude,
    this.longitude,
    this.isActive = true,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  /// Human-friendly combined location e.g. "Austin, TX, United States"
  String get fullLocation {
    final parts = [city, if (state != null && state!.isNotEmpty) state, country];
    return parts.join(', ');
  }

  /// Display cover image fallback
  String get displayCoverUrl {
    if (coverImageUrl != null && coverImageUrl!.isNotEmpty) return coverImageUrl!;
    return 'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=1200&q=80';
  }

  /// Display logo fallback
  String get displayLogoUrl {
    if (logoUrl != null && logoUrl!.isNotEmpty) return logoUrl!;
    return 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&w=300&q=80';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'phone': phone,
      'email': email,
      'website': website,
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'opening_hours': openingHours,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PetStoreModel.fromMap(Map<String, dynamic> map) {
    final created = map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : DateTime.now();
    final updated = map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : created;

    return PetStoreModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String?,
      name: map['name'] as String,
      description: map['description'] as String?,
      address: map['address'] as String,
      city: map['city'] as String,
      state: map['state'] as String?,
      country: (map['country'] as String?) ?? 'United States',
      phone: map['phone'] as String,
      email: map['email'] as String,
      website: map['website'] as String?,
      logoUrl: map['logo_url'] as String?,
      coverImageUrl: map['cover_image_url'] as String?,
      openingHours: map['opening_hours'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isActive: (map['is_active'] as int?) != 0,
      createdAt: created,
      updatedAt: updated,
    );
  }

  PetStoreModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? country,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    String? coverImageUrl,
    String? openingHours,
    double? latitude,
    double? longitude,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetStoreModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      openingHours: openingHours ?? this.openingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetStoreModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PetStoreModel(id: $id, name: $name, city: $city, active: $isActive)';
}
