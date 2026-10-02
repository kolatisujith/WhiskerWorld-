import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/pet_store_model.dart';
import 'package:whisker_world/models/user_model.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';

void main() {
  group('Phase 5: Pet Stores & Store-Specific Pet Listings Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;

    // Test Users
    final ownerA = UserModel(
      id: 'owner-a',
      name: 'Owner Alice',
      email: 'alice@whiskerhaven.com',
      role: UserRole.petOwner,
      createdAt: DateTime.now(),
    );

    final ownerB = UserModel(
      id: 'owner-b',
      name: 'Owner Bob',
      email: 'bob@happypaws.com',
      role: UserRole.petOwner,
      createdAt: DateTime.now(),
    );

    setUp(() async {
      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);

      await repository.saveUser(ownerA);
      await repository.saveUser(ownerB);
    });

    tearDown(() async {
      await dbService.close();
    });

    test('Store CRUD lifecycle and status toggling', () async {
      final now = DateTime.now();
      final store = PetStoreModel(
        id: 'store-1',
        ownerId: 'owner-a',
        name: 'Whisker Haven Sanctuary',
        description: 'Boutique shelter for young pets',
        address: '100 Paw Lane',
        city: 'Seattle',
        state: 'WA',
        country: 'USA',
        phone: '206-555-0100',
        email: 'info@whiskerhaven.com',
        website: 'https://whiskerhaven.org',
        logoUrl: 'https://images.unsplash.com/photo-1548767797-d8c844163c4c',
        coverImageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b',
        openingHours: 'Mon-Sat 9:00 AM - 6:00 PM',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Create
      await repository.savePetStore(store);
      final fetched = await repository.getPetStoreById('store-1');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Whisker Haven Sanctuary');
      expect(fetched.ownerId, 'owner-a');
      expect(fetched.city, 'Seattle');
      expect(fetched.country, 'USA');
      expect(fetched.isActive, true);

      // Update
      final updated = fetched.copyWith(
        name: 'Whisker Haven Elite Sanctuary',
        openingHours: 'Mon-Sun 8:00 AM - 8:00 PM',
      );
      await repository.updatePetStore(updated);
      final refetched = await repository.getPetStoreById('store-1');
      expect(refetched!.name, 'Whisker Haven Elite Sanctuary');
      expect(refetched.openingHours, 'Mon-Sun 8:00 AM - 8:00 PM');

      // Toggle active status
      await repository.toggleStoreActiveStatus('store-1', false);
      final deactivated = await repository.getPetStoreById('store-1');
      expect(deactivated!.isActive, false);

      // Active only queries
      final activeOnly = await repository.getAllPetStores(activeOnly: true);
      expect(activeOnly.where((s) => s.id == 'store-1'), isEmpty);

      final allStores = await repository.getAllPetStores(activeOnly: false);
      expect(allStores.where((s) => s.id == 'store-1'), isNotEmpty);
    });

    test('CRITICAL: Store-Specific Pet Listings Isolation (Whisker Haven vs Happy Paws)', () async {
      final now = DateTime.now();

      // Create Store A (Whisker Haven) owned by Alice
      final storeA = PetStoreModel(
        id: 'store-whisker-haven',
        ownerId: 'owner-a',
        name: 'Whisker Haven',
        address: '100 Paw Lane',
        city: 'Portland',
        state: 'OR',
        phone: '503-555-0101',
        email: 'alice@whiskerhaven.com',
        createdAt: now,
      );
      await repository.savePetStore(storeA);

      // Create Store B (Happy Paws) owned by Bob
      final storeB = PetStoreModel(
        id: 'store-happy-paws',
        ownerId: 'owner-b',
        name: 'Happy Paws',
        address: '200 Bark Ave',
        city: 'Seattle',
        state: 'WA',
        phone: '206-555-0202',
        email: 'bob@happypaws.com',
        createdAt: now,
      );
      await repository.savePetStore(storeB);

      // Pets for Whisker Haven: Bruno, Luna, Milo
      final bruno = PetModel(
        id: 'pet-bruno',
        ownerId: 'owner-a',
        storeId: 'store-whisker-haven',
        name: 'Bruno',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever Puppy',
        ageValue: 3,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        gender: Gender.male,
        description: 'Playful Bruno ready for fetching!',
        location: 'Portland, OR',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );
      final luna = PetModel(
        id: 'pet-luna',
        ownerId: 'owner-a',
        storeId: 'store-whisker-haven',
        name: 'Luna',
        animalType: AnimalType.cat,
        breed: 'Siamese Kitten',
        ageValue: 2,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Sweet purring kitten Luna.',
        location: 'Portland, OR',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );
      final milo = PetModel(
        id: 'pet-milo',
        ownerId: 'owner-a',
        storeId: 'store-whisker-haven',
        name: 'Milo',
        animalType: AnimalType.dog,
        breed: 'Beagle Pup',
        ageValue: 4,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.young,
        gender: Gender.male,
        description: 'Energetic tracker pup Milo.',
        location: 'Portland, OR',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );

      // Pets for Happy Paws: Simba, Coco, Rocky
      final simba = PetModel(
        id: 'pet-simba',
        ownerId: 'owner-b',
        storeId: 'store-happy-paws',
        name: 'Simba',
        animalType: AnimalType.cat,
        breed: 'Bengal Kitten',
        ageValue: 3,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        gender: Gender.male,
        description: 'Little king Simba with striking spots.',
        location: 'Seattle, WA',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );
      final coco = PetModel(
        id: 'pet-coco',
        ownerId: 'owner-b',
        storeId: 'store-happy-paws',
        name: 'Coco',
        animalType: AnimalType.rabbit,
        breed: 'Mini Lop Kit',
        ageValue: 8,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Gentle bunny Coco loves cuddles.',
        location: 'Seattle, WA',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );
      final rocky = PetModel(
        id: 'pet-rocky',
        ownerId: 'owner-b',
        storeId: 'store-happy-paws',
        name: 'Rocky',
        animalType: AnimalType.dog,
        breed: 'Bulldog Puppy',
        ageValue: 5,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.young,
        gender: Gender.male,
        description: 'Chubby and friendly Bulldog puppy Rocky.',
        location: 'Seattle, WA',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );

      // Save all pets
      for (final pet in [bruno, luna, milo, simba, coco, rocky]) {
        await repository.savePet(pet);
      }

      // 1. Fetch pets for Whisker Haven
      final whiskerHavenPets = await repository.getPetsByStore('store-whisker-haven');
      final whiskerHavenNames = whiskerHavenPets.map((p) => p.name).toList();

      expect(whiskerHavenPets.length, 3);
      expect(whiskerHavenNames, containsAll(['Bruno', 'Luna', 'Milo']));
      expect(whiskerHavenNames, isNot(contains('Simba')));
      expect(whiskerHavenNames, isNot(contains('Coco')));
      expect(whiskerHavenNames, isNot(contains('Rocky')));

      // 2. Fetch pets for Happy Paws
      final happyPawsPets = await repository.getPetsByStore('store-happy-paws');
      final happyPawsNames = happyPawsPets.map((p) => p.name).toList();

      expect(happyPawsPets.length, 3);
      expect(happyPawsNames, containsAll(['Simba', 'Coco', 'Rocky']));
      expect(happyPawsNames, isNot(contains('Bruno')));
      expect(happyPawsNames, isNot(contains('Luna')));
      expect(happyPawsNames, isNot(contains('Milo')));

      // 3. Dynamic Pet Count calculation verification (Requirement 9)
      final whiskerHavenCount = await repository.getAvailablePetCountForStore('store-whisker-haven');
      final happyPawsCount = await repository.getAvailablePetCountForStore('store-happy-paws');

      expect(whiskerHavenCount, 3);
      expect(happyPawsCount, 3);

      // 4. Availability Status Impact: adopt Bruno and verify dynamic recount
      final adoptedBruno = bruno.copyWith(availabilityStatus: PetAvailabilityStatus.adopted);
      await repository.updatePet(adoptedBruno);

      final newWhiskerHavenCount = await repository.getAvailablePetCountForStore('store-whisker-haven');
      expect(newWhiskerHavenCount, 2);

      final remainingWhiskerHaven = await repository.getPetsByStore('store-whisker-haven');
      expect(remainingWhiskerHaven.map((p) => p.name), containsAll(['Luna', 'Milo']));
      expect(remainingWhiskerHaven.map((p) => p.name), isNot(contains('Bruno')));
    });

    test('In-store search and filtering strictly maintains store isolation', () async {
      final now = DateTime.now();

      final storeA = PetStoreModel(
        id: 'store-a',
        ownerId: 'owner-a',
        name: 'Alpha Pets',
        address: '11 Alpha St',
        city: 'Denver',
        phone: '303-555-0111',
        email: 'info@alphapets.com',
        createdAt: now,
      );
      final storeB = PetStoreModel(
        id: 'store-b',
        ownerId: 'owner-b',
        name: 'Beta Pets',
        address: '22 Beta St',
        city: 'Denver',
        phone: '303-555-0222',
        email: 'info@betapets.com',
        createdAt: now,
      );
      await repository.savePetStore(storeA);
      await repository.savePetStore(storeB);

      // Save dog and cat in Store A
      await repository.savePet(PetModel(
        id: 'pet-a1',
        ownerId: 'owner-a',
        storeId: 'store-a',
        name: 'Bella',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever',
        ageValue: 2,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Gentle Bella',
        location: 'Denver, CO',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      ));
      await repository.savePet(PetModel(
        id: 'pet-a2',
        ownerId: 'owner-a',
        storeId: 'store-a',
        name: 'Felix',
        animalType: AnimalType.cat,
        breed: 'British Shorthair',
        ageValue: 3,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        gender: Gender.male,
        description: 'Quiet Felix',
        location: 'Denver, CO',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      ));

      // Save dog in Store B with same breed
      await repository.savePet(PetModel(
        id: 'pet-b1',
        ownerId: 'owner-b',
        storeId: 'store-b',
        name: 'Golden Boy',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever',
        ageValue: 4,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.young,
        gender: Gender.male,
        description: 'Energetic Golden Boy',
        location: 'Denver, CO',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      ));

      // Filter dogs in Store A only
      final dogsInStoreA = await repository.getPetsByStore('store-a', animalType: AnimalType.dog);
      expect(dogsInStoreA.length, 1);
      expect(dogsInStoreA.first.name, 'Bella');

      // Search "Golden" in Store A only -> Bella only, NOT Golden Boy from Store B
      final searchGoldenInStoreA = await repository.getPetsByStore('store-a', searchQuery: 'Golden');
      expect(searchGoldenInStoreA.length, 1);
      expect(searchGoldenInStoreA.first.name, 'Bella');

      // Search "Golden" in Store B only -> Golden Boy only
      final searchGoldenInStoreB = await repository.getPetsByStore('store-b', searchQuery: 'Golden');
      expect(searchGoldenInStoreB.length, 1);
      expect(searchGoldenInStoreB.first.name, 'Golden Boy');
    });

    test('Store deletion safely unlinks pets without deleting pet records', () async {
      final now = DateTime.now();

      final store = PetStoreModel(
        id: 'store-to-delete',
        ownerId: 'owner-a',
        name: 'Temporary Shelter',
        address: '50 Shelter Way',
        city: 'Austin',
        phone: '512-555-0999',
        email: 'shelter@austin.org',
        createdAt: now,
      );
      await repository.savePetStore(store);

      final pet = PetModel(
        id: 'pet-saved',
        ownerId: 'owner-a',
        storeId: 'store-to-delete',
        name: 'Lucky',
        animalType: AnimalType.dog,
        breed: 'Mixed Terrier',
        ageValue: 6,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.young,
        gender: Gender.male,
        description: 'Lucky the resilient terrier',
        location: 'Austin, TX',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );
      await repository.savePet(pet);

      // Verify pet linked to store
      final petsBefore = await repository.getPetsByStore('store-to-delete');
      expect(petsBefore.length, 1);

      // Delete store
      await repository.deletePetStore('store-to-delete');

      // Verify store is deleted
      final deletedStore = await repository.getPetStoreById('store-to-delete');
      expect(deletedStore, isNull);

      // Verify pet is still alive and has null storeId
      final preservedPet = await repository.getPetById('pet-saved');
      expect(preservedPet, isNotNull);
      expect(preservedPet!.storeId, isNull);
      expect(preservedPet.name, 'Lucky');
    });

    test('Owner store queries only return stores belonging to that owner', () async {
      final now = DateTime.now();

      await repository.savePetStore(PetStoreModel(
        id: 'alice-store-1',
        ownerId: 'owner-a',
        name: 'Alice Store 1',
        address: '1st Ave',
        city: 'Austin',
        phone: '512-555-1111',
        email: 'a1@test.com',
        createdAt: now,
      ));
      await repository.savePetStore(PetStoreModel(
        id: 'alice-store-2',
        ownerId: 'owner-a',
        name: 'Alice Store 2',
        address: '2nd Ave',
        city: 'Austin',
        phone: '512-555-2222',
        email: 'a2@test.com',
        createdAt: now,
      ));
      await repository.savePetStore(PetStoreModel(
        id: 'bob-store-1',
        ownerId: 'owner-b',
        name: 'Bob Store 1',
        address: '3rd Ave',
        city: 'Austin',
        phone: '512-555-3333',
        email: 'b1@test.com',
        createdAt: now,
      ));

      final aliceStores = await repository.getStoresByOwner('owner-a');
      expect(aliceStores.length, 2);
      expect(aliceStores.map((s) => s.id), containsAll(['alice-store-1', 'alice-store-2']));
      expect(aliceStores.map((s) => s.id), isNot(contains('bob-store-1')));

      final bobStores = await repository.getStoresByOwner('owner-b');
      expect(bobStores.length, 1);
      expect(bobStores.first.id, 'bob-store-1');
    });
  });
}
