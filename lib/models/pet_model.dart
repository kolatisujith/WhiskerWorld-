import '../utils/animal_utils.dart';
import 'enums.dart';
import 'pet_image_model.dart';

/// Whisker World Pet Model with complete young companion attributes
class PetModel {
  final String id;
  final String? ownerId;
  final String? storeId;
  final String name;
  final AnimalType animalType;
  final String breed;
  final int ageValue;
  final AgeUnit ageUnit;
  final LifeStage lifeStage;
  final String youngAnimalName;
  final Gender gender;
  final String description;
  final String? personality;
  final String? color;
  final String? size; // Small, Medium, Large, Extra Large
  final double? weight;
  final String? healthInformation;
  final String? vaccinationStatus;
  final String? dewormingStatus;
  final String? veterinaryCheck;
  final bool isNeutered;
  final double adoptionFee;
  final String location;
  final double? latitude;
  final double? longitude;
  final PetAvailabilityStatus availabilityStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PetImageModel> images;

  PetModel({
    required this.id,
    this.ownerId,
    this.storeId,
    required this.name,
    required this.animalType,
    required this.breed,
    required this.ageValue,
    required this.ageUnit,
    required this.lifeStage,
    String? youngAnimalName,
    required this.gender,
    required this.description,
    this.personality,
    this.color,
    this.size,
    this.weight,
    this.healthInformation,
    this.vaccinationStatus,
    this.dewormingStatus,
    this.veterinaryCheck,
    this.isNeutered = false,
    this.adoptionFee = 0.0,
    required this.location,
    this.latitude,
    this.longitude,
    this.availabilityStatus = PetAvailabilityStatus.available,
    required this.createdAt,
    DateTime? updatedAt,
    this.images = const [],
  })  : youngAnimalName = (youngAnimalName != null && youngAnimalName.trim().isNotEmpty)
            ? youngAnimalName.trim()
            : AnimalUtils.getYoungTerm(animalType.name),
        updatedAt = updatedAt ?? createdAt;

  /// Returns the primary image or first available image URL
  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.where((img) => img.isPrimary).firstOrNull;
    return primary?.imageUrl ?? images.first.imageUrl;
  }

  /// Formatted age string e.g. "8 weeks" or "1 year"
  String get formattedAge => AnimalUtils.formatAge(ageValue, ageUnit);

  /// Human friendly young animal tag, e.g. "Puppy" or "Kitten"
  String get displayYoungName =>
      youngAnimalName.trim().isNotEmpty ? youngAnimalName.trim() : AnimalUtils.getYoungTerm(animalType.name);

  /// Human readable tagline e.g. "Puppy (8 weeks old)"
  String get ageDescription => AnimalUtils.getPetStageDescription(
        speciesOrType: animalType.name,
        ageValue: ageValue,
        ageUnit: ageUnit,
        lifeStage: lifeStage,
      );

  bool get isAvailable => availabilityStatus == PetAvailabilityStatus.available;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'store_id': storeId,
      'name': name,
      'animal_type': animalType.name,
      'breed': breed,
      'age_value': ageValue,
      'age_unit': ageUnit.name,
      'life_stage': lifeStage.name,
      'young_animal_name': youngAnimalName,
      'gender': gender.name,
      'description': description,
      'personality': personality,
      'color': color,
      'size': size,
      'weight': weight,
      'health_information': healthInformation,
      'vaccination_status': vaccinationStatus,
      'deworming_status': dewormingStatus,
      'veterinary_check': veterinaryCheck,
      'is_neutered': isNeutered ? 1 : 0,
      'adoption_fee': adoptionFee,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'availability_status': availabilityStatus.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PetModel.fromMap(Map<String, dynamic> map, {List<PetImageModel> images = const []}) {
    final animalType = AnimalType.fromString(map['animal_type'] as String? ?? 'other');
    final rawYoungName = map['young_animal_name'] as String?;
    final resolvedYoungName = (rawYoungName != null && rawYoungName.trim().isNotEmpty)
        ? rawYoungName.trim()
        : AnimalUtils.getYoungTerm(animalType.name);

    final createdAt = map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : DateTime.now();
    final updatedAt = map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : createdAt;

    return PetModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String?,
      storeId: map['store_id'] as String?,
      name: map['name'] as String,
      animalType: animalType,
      breed: map['breed'] as String,
      ageValue: (map['age_value'] as num?)?.toInt() ?? 1,
      ageUnit: AgeUnit.fromString(map['age_unit'] as String? ?? 'months'),
      lifeStage: LifeStage.fromString(map['life_stage'] as String? ?? 'young'),
      youngAnimalName: resolvedYoungName,
      gender: Gender.fromString(map['gender'] as String? ?? 'unknown'),
      description: map['description'] as String? ?? '',
      personality: map['personality'] as String?,
      color: map['color'] as String?,
      size: map['size'] as String?,
      weight: (map['weight'] as num?)?.toDouble(),
      healthInformation: map['health_information'] as String?,
      vaccinationStatus: map['vaccination_status'] as String?,
      dewormingStatus: map['deworming_status'] as String?,
      veterinaryCheck: map['veterinary_check'] as String?,
      isNeutered: (map['is_neutered'] as int? ?? 0) == 1,
      adoptionFee: (map['adoption_fee'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      availabilityStatus:
          PetAvailabilityStatus.fromString(map['availability_status'] as String? ?? 'available'),
      createdAt: createdAt,
      updatedAt: updatedAt,
      images: images,
    );
  }

  PetModel copyWith({
    String? id,
    String? ownerId,
    String? storeId,
    String? name,
    AnimalType? animalType,
    String? breed,
    int? ageValue,
    AgeUnit? ageUnit,
    LifeStage? lifeStage,
    String? youngAnimalName,
    Gender? gender,
    String? description,
    String? personality,
    String? color,
    String? size,
    double? weight,
    String? healthInformation,
    String? vaccinationStatus,
    String? dewormingStatus,
    String? veterinaryCheck,
    bool? isNeutered,
    double? adoptionFee,
    String? location,
    double? latitude,
    double? longitude,
    PetAvailabilityStatus? availabilityStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PetImageModel>? images,
  }) {
    return PetModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      animalType: animalType ?? this.animalType,
      breed: breed ?? this.breed,
      ageValue: ageValue ?? this.ageValue,
      ageUnit: ageUnit ?? this.ageUnit,
      lifeStage: lifeStage ?? this.lifeStage,
      youngAnimalName: youngAnimalName ?? this.youngAnimalName,
      gender: gender ?? this.gender,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      color: color ?? this.color,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      healthInformation: healthInformation ?? this.healthInformation,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      dewormingStatus: dewormingStatus ?? this.dewormingStatus,
      veterinaryCheck: veterinaryCheck ?? this.veterinaryCheck,
      isNeutered: isNeutered ?? this.isNeutered,
      adoptionFee: adoptionFee ?? this.adoptionFee,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PetModel(id: $id, name: $name, youngName: $youngAnimalName, type: ${animalType.name}, breed: $breed)';
}
