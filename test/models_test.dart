import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/models/adoption_request_model.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/favorite_model.dart';
import 'package:whisker_world/models/pet_image_model.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/pet_store_model.dart';
import 'package:whisker_world/models/user_model.dart';

void main() {
  group('Whisker World Models Serialization & Integrity', () {
    test('UserModel serialization and equality', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'u-1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        role: UserRole.adopter,
        avatarUrl: 'https://example.com/avatar.jpg',
        latitude: 45.5152,
        longitude: -122.6784,
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['id'], 'u-1');
      expect(map['role'], 'petAdopter');
      expect(map['latitude'], 45.5152);
      expect(map['longitude'], -122.6784);

      final deserialized = UserModel.fromMap(map);
      expect(deserialized.id, user.id);
      expect(deserialized.email, user.email);
      expect(deserialized.latitude, 45.5152);
      expect(deserialized.longitude, -122.6784);
      expect(deserialized.role, UserRole.petAdopter);
      expect(deserialized, equals(user));

      // Test password sanitization
      final secureUser = user.copyWith(passwordHash: 'secret_hash_123');
      expect(secureUser.passwordHash, 'secret_hash_123');
      final sanitized = secureUser.sanitize();
      expect(sanitized.passwordHash, isNull);
    });

    test('PetStoreModel serialization', () {
      final now = DateTime.now();
      final store = PetStoreModel(
        id: 's-1',
        ownerId: 'u-1',
        name: 'Happy Paws Sanctuary',
        description: 'Loving care for young animals',
        address: '123 Paw Street',
        city: 'Austin',
        state: 'TX',
        country: 'United States',
        phone: '555-0199',
        email: 'contact@happypaws.org',
        website: 'https://happypaws.org',
        logoUrl: 'https://example.com/logo.png',
        coverImageUrl: 'https://example.com/cover.jpg',
        openingHours: 'Mon-Sat 9AM - 6PM',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = store.toMap();
      expect(map['city'], 'Austin');
      expect(map['owner_id'], 'u-1');
      expect(map['country'], 'United States');
      expect(map['opening_hours'], 'Mon-Sat 9AM - 6PM');
      expect(map['is_active'], 1);

      final deserialized = PetStoreModel.fromMap(map);
      expect(deserialized.name, 'Happy Paws Sanctuary');
      expect(deserialized.id, store.id);
      expect(deserialized.ownerId, 'u-1');
      expect(deserialized.coverImageUrl, 'https://example.com/cover.jpg');
      expect(deserialized.fullLocation, 'Austin, TX, United States');
      expect(deserialized.isActive, true);
      expect(deserialized, equals(store));
    });

    test('PetModel and PetImageModel serialization', () {
      final now = DateTime.now();
      final image = PetImageModel(
        id: 'img-1',
        petId: 'p-1',
        imageUrl: 'https://example.com/puppy.jpg',
        isPrimary: true,
        createdAt: now,
      );

      final imgMap = image.toMap();
      expect(imgMap['is_primary'], 1);
      final imgDeserialized = PetImageModel.fromMap(imgMap);
      expect(imgDeserialized.isPrimary, true);

      final pet = PetModel(
        id: 'p-1',
        ownerId: 'u-1',
        name: 'Mochi',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever',
        ageValue: 8,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Puppy',
        gender: Gender.male,
        description: 'Playful and gentle golden pup.',
        personality: 'Friendly, cuddly',
        color: 'Golden',
        size: 'medium',
        weight: 6.0,
        healthInformation: 'First vet visit completed, fully dewormed',
        vaccinationStatus: 'First Round',
        dewormingStatus: 'Completed',
        veterinaryCheck: 'Passed',
        isNeutered: false,
        adoptionFee: 250.0,
        location: 'Austin, TX',
        availabilityStatus: PetAvailabilityStatus.available,
        storeId: 's-1',
        createdAt: now,
        updatedAt: now,
        images: [image],
      );

      final petMap = pet.toMap();
      expect(petMap['animal_type'], 'dog');
      expect(petMap['life_stage'], 'baby');
      expect(petMap['young_animal_name'], 'Puppy');
      expect(petMap['adoption_fee'], 250.0);
      expect(petMap['veterinary_check'], 'Passed');
      expect(petMap['is_neutered'], 0);

      final petDeserialized = PetModel.fromMap(petMap, images: [imgDeserialized]);
      expect(petDeserialized.name, 'Mochi');
      expect(petDeserialized.youngAnimalName, 'Puppy');
      expect(petDeserialized.displayYoungName, 'Puppy');
      expect(petDeserialized.formattedAge, '8 weeks');
      expect(petDeserialized.primaryImageUrl, 'https://example.com/puppy.jpg');
      expect(petDeserialized.adoptionFee, 250.0);
      expect(petDeserialized.veterinaryCheck, 'Passed');
      expect(petDeserialized.isNeutered, false);
      expect(petDeserialized.images.length, 1);
      expect(petDeserialized.images.first.isPrimary, true);
    });

    test('AdoptionRequestModel serialization', () {
      final now = DateTime.now();
      final req = AdoptionRequestModel(
        id: 'req-1',
        petId: 'p-1',
        adopterId: 'u-1',
        ownerId: 'owner-1',
        storeId: 's-1',
        status: AdoptionRequestStatus.pending,
        message: 'We have a big fenced yard and love puppies!',
        reasonForAdoption: 'Loving companion for our family',
        petExperience: 'Lifelong pet owner',
        livingEnvironment: 'House with fenced yard',
        otherPets: 'None',
        contactPreference: 'Email',
        createdAt: now,
        updatedAt: now,
      );

      final map = req.toMap();
      expect(map['status'], 'pending');
      expect(map['reason_for_adoption'], 'Loving companion for our family');
      expect(map['pet_experience'], 'Lifelong pet owner');
      expect(map['living_environment'], 'House with fenced yard');
      expect(map['other_pets'], 'None');
      expect(map['contact_preference'], 'Email');

      final deserialized = AdoptionRequestModel.fromMap(map);
      expect(deserialized.id, 'req-1');
      expect(deserialized.status, AdoptionRequestStatus.pending);
      expect(deserialized.reasonForAdoption, 'Loving companion for our family');
      expect(deserialized.livingEnvironment, 'House with fenced yard');
      expect(deserialized.message, contains('fenced yard'));
    });

    test('FavoriteModel serialization', () {
      final now = DateTime.now();
      final fav = FavoriteModel(
        id: 'fav-1',
        userId: 'u-1',
        petId: 'p-1',
        createdAt: now,
      );

      final map = fav.toMap();
      final deserialized = FavoriteModel.fromMap(map);
      expect(deserialized.userId, 'u-1');
      expect(deserialized.petId, 'p-1');
    });

    test('Enums parsing with fallback', () {
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
      expect(UserRole.fromString('non_existent'), UserRole.adopter);

      expect(AnimalType.fromString('cat'), AnimalType.cat);
      expect(AnimalType.fromString('unknown_animal'), AnimalType.other);

      expect(AgeUnit.fromString('weeks'), AgeUnit.weeks);
      expect(LifeStage.fromString('newborn'), LifeStage.newborn);
      expect(Gender.fromString('FEMALE'), Gender.female);
      expect(PetAvailabilityStatus.fromString('adopted'), PetAvailabilityStatus.adopted);
      expect(AdoptionRequestStatus.fromString('approved'), AdoptionRequestStatus.approved);
    });
  });
}
