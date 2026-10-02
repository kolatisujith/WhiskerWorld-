/// Whisker World Pet Image Model
class PetImageModel {
  final String id;
  final String petId;
  final String imageUrl;
  final bool isPrimary;
  final DateTime createdAt;

  const PetImageModel({
    required this.id,
    required this.petId,
    required this.imageUrl,
    this.isPrimary = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_id': petId,
      'image_url': imageUrl,
      'is_primary': isPrimary ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PetImageModel.fromMap(Map<String, dynamic> map) {
    return PetImageModel(
      id: map['id'] as String,
      petId: map['pet_id'] as String,
      imageUrl: map['image_url'] as String,
      isPrimary: (map['is_primary'] is int)
          ? (map['is_primary'] as int) == 1
          : (map['is_primary'] as bool? ?? false),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  PetImageModel copyWith({
    String? id,
    String? petId,
    String? imageUrl,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return PetImageModel(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetImageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PetImageModel(id: $id, petId: $petId, isPrimary: $isPrimary)';
}
