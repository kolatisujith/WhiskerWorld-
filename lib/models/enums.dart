// Whisker World Animal & Domain Enums

/// Roles a user can hold in Whisker World.
enum UserRole {
  petOwner('Pet Owner'),
  petAdopter('Pet Adopter'),
  admin('Admin');

  /// Backward-compatible alias for Phase 1
  static const UserRole adopter = petAdopter;

  final String displayName;
  const UserRole(this.displayName);

  static UserRole fromString(String value) {
    final clean = value.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    if (clean.contains('owner')) {
      return UserRole.petOwner;
    }
    if (clean.contains('adopt')) {
      return UserRole.petAdopter;
    }
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == clean,
      orElse: () => UserRole.petAdopter,
    );
  }
}

/// Supported animal types/species.
enum AnimalType {
  dog,
  cat,
  rabbit,
  bird,
  fish,
  reptile,
  horse,
  goat,
  sheep,
  pig,
  chicken,
  duck,
  other;

  static AnimalType fromString(String value) {
    return AnimalType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AnimalType.other,
    );
  }
}

/// Supported age measurement units.
enum AgeUnit {
  days,
  weeks,
  months,
  years;

  static AgeUnit fromString(String value) {
    return AgeUnit.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AgeUnit.months,
    );
  }
}

/// Life stage classification for pets.
enum LifeStage {
  newborn,
  baby,
  young,
  adolescent,
  adult,
  senior;

  static LifeStage fromString(String value) {
    return LifeStage.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => LifeStage.young,
    );
  }
}

/// Gender of the animal.
enum Gender {
  male,
  female,
  unknown;

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Gender.unknown,
    );
  }
}

/// Pet availability for adoption.
enum PetAvailabilityStatus {
  available,
  pending,
  adopted,
  unavailable;

  static PetAvailabilityStatus fromString(String value) {
    return PetAvailabilityStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PetAvailabilityStatus.available,
    );
  }
}

/// Status of an adoption inquiry / request.
enum AdoptionRequestStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed;

  static AdoptionRequestStatus fromString(String value) {
    return AdoptionRequestStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AdoptionRequestStatus.pending,
    );
  }
}
