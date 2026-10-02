/// Whisker World Favorite Model
class FavoriteModel {
  final String id;
  final String userId;
  final String petId;
  final DateTime createdAt;

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'pet_id': petId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      petId: map['pet_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? petId,
    DateTime? createdAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      petId: petId ?? this.petId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FavoriteModel(id: $id, userId: $userId, petId: $petId)';
}
