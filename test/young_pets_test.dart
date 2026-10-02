import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_image_model.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/pet_store_model.dart';
import 'package:whisker_world/models/user_model.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';

void main() {
  group('Phase 3: Young Pet Management Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;

    setUp(() async {
      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);

      // Seed 2 owners and 1 store
      final now = DateTime.now();
      await repository.saveUser(UserModel(
        id: 'owner-1',
        name: 'Alice Owner',
        email: 'alice@example.com',
        role: UserRole.petOwner,
        createdAt: now,
      ));

      await repository.saveUser(UserModel(
        id: 'owner-2',
        name: 'Bob Owner',
        email: 'bob@example.com',
        role: UserRole.petOwner,
        createdAt: now,
      ));

      await repository.savePetStore(PetStoreModel(
        id: 'store-1',
        name: 'Downtown Pup Sanctuary',
        description: 'Quality care for young rescues',
        address: '100 Main St',
        city: 'Austin',
        state: 'TX',
        phone: '555-1234',
        email: 'downtown@sanctuary.com',
        createdAt: now,
      ));
    });

    tearDown(() async {
      await dbService.close();
    });

    test('Add Pet with complete 24+ fields', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-101',
        ownerId: 'owner-1',
        storeId: 'store-1',
        name: 'Barnaby',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever',
        ageValue: 7,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Puppy',
        gender: Gender.male,
        description: 'Fluffy, gentle, and loves playing fetch with small balls.',
        personality: 'Affectionate, energetic, curious',
        color: 'Golden Cream',
        size: 'Medium',
        weight: 5.2,
        healthInformation: 'First vet examination clear; healthy heart and lungs.',
        vaccinationStatus: 'First round core vaccines given',
        dewormingStatus: 'Up to date (2 doses)',
        veterinaryCheck: 'Passed',
        isNeutered: false,
        adoptionFee: 200.0,
        location: 'Austin, TX',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
        updatedAt: now,
        images: [
          PetImageModel(
            id: 'img-101',
            petId: 'pet-101',
            imageUrl: 'https://images.unsplash.com/puppy.jpg',
            isPrimary: true,
            createdAt: now,
          ),
        ],
      );

      await repository.savePet(pet);

      final retrieved = await repository.getPetById('pet-101');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Barnaby');
      expect(retrieved.youngAnimalName, 'Puppy');
      expect(retrieved.personality, 'Affectionate, energetic, curious');
      expect(retrieved.color, 'Golden Cream');
      expect(retrieved.weight, 5.2);
      expect(retrieved.healthInformation, contains('healthy heart'));
      expect(retrieved.vaccinationStatus, 'First round core vaccines given');
      expect(retrieved.dewormingStatus, 'Up to date (2 doses)');
      expect(retrieved.veterinaryCheck, 'Passed');
      expect(retrieved.isNeutered, false);
      expect(retrieved.adoptionFee, 200.0);
      expect(retrieved.storeId, 'store-1');
      expect(retrieved.images.length, 1);
      expect(retrieved.primaryImageUrl, 'https://images.unsplash.com/puppy.jpg');
    });

    test('Edit Pet and update fields', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-102',
        ownerId: 'owner-1',
        name: 'Mochi',
        animalType: AnimalType.cat,
        breed: 'Siamese',
        ageValue: 8,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Kitten',
        gender: Gender.female,
        description: 'Vocal and playful kitten.',
        adoptionFee: 100.0,
        location: 'Austin, TX',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
        updatedAt: now,
      );

      await repository.savePet(pet);

      // Edit pet details
      final updated = pet.copyWith(
        name: 'Mochi Peach',
        adoptionFee: 125.0,
        isNeutered: true,
        vaccinationStatus: 'Fully Vaccinated',
        personality: 'Quiet, affectionate lap warmer',
        storeId: 'store-1',
      );

      await repository.updatePet(updated);

      final reloaded = await repository.getPetById('pet-102');
      expect(reloaded!.name, 'Mochi Peach');
      expect(reloaded.adoptionFee, 125.0);
      expect(reloaded.isNeutered, true);
      expect(reloaded.vaccinationStatus, 'Fully Vaccinated');
      expect(reloaded.personality, 'Quiet, affectionate lap warmer');
      expect(reloaded.storeId, 'store-1');
    });

    test('Change Pet Availability Status', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-103',
        ownerId: 'owner-1',
        name: 'Pip',
        animalType: AnimalType.other,
        breed: 'Syrian Hamster',
        ageValue: 4,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Pup',
        gender: Gender.male,
        description: 'Tiny energetic hamster pup.',
        adoptionFee: 25.0,
        location: 'Austin, TX',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );

      await repository.savePet(pet);

      // Toggle to pending
      await repository.updatePet(pet.copyWith(availabilityStatus: PetAvailabilityStatus.pending));
      expect((await repository.getPetById('pet-103'))!.availabilityStatus, PetAvailabilityStatus.pending);

      // Toggle to adopted
      await repository.updatePet(pet.copyWith(availabilityStatus: PetAvailabilityStatus.adopted));
      expect((await repository.getPetById('pet-103'))!.availabilityStatus, PetAvailabilityStatus.adopted);

      // Toggle to unavailable
      await repository.updatePet(pet.copyWith(availabilityStatus: PetAvailabilityStatus.unavailable));
      expect((await repository.getPetById('pet-103'))!.availabilityStatus, PetAvailabilityStatus.unavailable);
    });

    test('Delete Pet cascades and removes related images and favorites', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-104',
        ownerId: 'owner-1',
        name: 'Sunny',
        animalType: AnimalType.bird,
        breed: 'Cockatiel',
        ageValue: 6,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Chick',
        gender: Gender.unknown,
        description: 'Sweet baby cockatiel learning to perch.',
        location: 'Austin, TX',
        createdAt: now,
        images: [
          PetImageModel(
            id: 'img-104',
            petId: 'pet-104',
            imageUrl: 'https://example.com/bird.jpg',
            createdAt: now,
          ),
        ],
      );

      await repository.savePet(pet);
      await repository.toggleFavorite('owner-2', 'pet-104');

      expect(await repository.getPetById('pet-104'), isNotNull);
      expect((await repository.getImagesForPet('pet-104')).length, 1);
      expect(await repository.isFavorite('owner-2', 'pet-104'), true);

      // Delete the pet
      await repository.deletePet('pet-104');

      expect(await repository.getPetById('pet-104'), isNull);
      expect(await repository.getImagesForPet('pet-104'), isEmpty);
      expect(await repository.isFavorite('owner-2', 'pet-104'), false);
    });

    test('Owner Isolation: Owner only views their own pets', () async {
      final now = DateTime.now();

      // Owner 1 pet
      await repository.savePet(PetModel(
        id: 'pet-alice-1',
        ownerId: 'owner-1',
        name: 'Alice Pup',
        animalType: AnimalType.dog,
        breed: 'Poodle',
        ageValue: 10,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Alice dog',
        location: 'Austin',
        createdAt: now,
      ));

      // Owner 2 pet
      await repository.savePet(PetModel(
        id: 'pet-bob-1',
        ownerId: 'owner-2',
        name: 'Bob Kitten',
        animalType: AnimalType.cat,
        breed: 'Tabby',
        ageValue: 9,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        gender: Gender.male,
        description: 'Bob cat',
        location: 'Austin',
        createdAt: now,
      ));

      // Fetch pets by owner
      final alicePets = await repository.getPetsByOwner('owner-1');
      final bobPets = await repository.getPetsByOwner('owner-2');

      expect(alicePets.length, 1);
      expect(alicePets.first.name, 'Alice Pup');
      expect(alicePets.any((p) => p.ownerId == 'owner-2'), false);

      expect(bobPets.length, 1);
      expect(bobPets.first.name, 'Bob Kitten');
      expect(bobPets.any((p) => p.ownerId == 'owner-1'), false);
    });
  });
}
