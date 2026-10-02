import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/database/database_helper.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/adoption_request_model.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_image_model.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/pet_store_model.dart';
import 'package:whisker_world/models/user_model.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';

void main() {
  group('Whisker World SQLite Database & Migration Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;

    setUp(() async {
      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);
    });

    tearDown(() async {
      await dbService.close();
    });

    test('Database schema version and foreign keys enabled', () async {
      expect(dbService.isInitialized, true);

      // Verify PRAGMA user_version == 1
      final versionRows = await dbService.rawQuery('PRAGMA user_version;');
      expect(versionRows.first.values.first, DatabaseHelper.currentVersion);

      // Verify PRAGMA foreign_keys == 1
      final fkRows = await dbService.rawQuery('PRAGMA foreign_keys;');
      expect(fkRows.first.values.first, 1);

      // Verify all 6 core tables exist
      final tables = await dbService.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      );
      final tableNames = tables.map((t) => t['name'] as String).toSet();
      expect(tableNames, containsAll([
        'users',
        'pet_stores',
        'pets',
        'pet_images',
        'adoption_requests',
        'favorites',
      ]));
    });

    test('Required indexes exist', () async {
      final indexes = await dbService.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index';",
      );
      final indexNames = indexes.map((i) => i['name'] as String).toSet();
      expect(indexNames, containsAll([
        'idx_pets_owner_id',
        'idx_pets_store_id',
        'idx_pets_animal_type',
        'idx_pets_breed',
        'idx_pets_location',
        'idx_pets_availability_status',
        'idx_pets_young_animal_name',
        'idx_pets_adoption_fee',
        'idx_adoption_requests_adopter_id',
        'idx_adoption_requests_owner_id',
        'idx_adoption_requests_pet_id',
        'idx_adoption_requests_status',
        'idx_favorites_user_id',
        'idx_favorites_pet_id',
        'idx_pet_stores_owner_id',
        'idx_pet_stores_is_active',
      ]));
    });

    test('Complete CRUD lifecycle via DatabaseRepository', () async {
      final now = DateTime.now();

      // 1. Create User
      final user = UserModel(
        id: 'u-101',
        name: 'Sarah Connor',
        email: 'sarah@example.com',
        phone: '555-4321',
        role: UserRole.adopter,
        createdAt: now,
      );
      await repository.saveUser(user);

      final fetchedUser = await repository.getUserById('u-101');
      expect(fetchedUser, isNotNull);
      expect(fetchedUser!.name, 'Sarah Connor');
      expect(fetchedUser.email, 'sarah@example.com');

      // 2. Create Pet Store
      final store = PetStoreModel(
        id: 's-201',
        name: 'Little Paws Nursery',
        description: 'Certified puppy and kitten sanctuary',
        address: '456 Oak Avenue',
        city: 'Austin',
        state: 'TX',
        phone: '555-9876',
        email: 'info@littlepaws.org',
        createdAt: now,
      );
      await repository.savePetStore(store);

      final fetchedStore = await repository.getPetStoreById('s-201');
      expect(fetchedStore, isNotNull);
      expect(fetchedStore!.name, 'Little Paws Nursery');

      // 3. Create Pet with Image
      final image = PetImageModel(
        id: 'img-301',
        petId: 'p-301',
        imageUrl: 'https://images.example.com/biscuit.jpg',
        isPrimary: true,
        createdAt: now,
      );

      final pet = PetModel(
        id: 'p-301',
        name: 'Biscuit',
        animalType: AnimalType.cat,
        breed: 'Ragdoll',
        ageValue: 10,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Gentle and cuddly ragdoll kitten.',
        location: 'Austin',
        availabilityStatus: PetAvailabilityStatus.available,
        storeId: 's-201',
        createdAt: now,
        images: [image],
      );
      await repository.savePet(pet);

      final fetchedPet = await repository.getPetById('p-301');
      expect(fetchedPet, isNotNull);
      expect(fetchedPet!.name, 'Biscuit');
      expect(fetchedPet.animalType, AnimalType.cat);
      expect(fetchedPet.images.length, 1);
      expect(fetchedPet.images.first.isPrimary, true);

      // Verify updatePet
      final updatedPet = fetchedPet.copyWith(
        name: 'Biscuit Jr.',
        availabilityStatus: PetAvailabilityStatus.pending,
        adoptionFee: 150.0,
      );
      await repository.updatePet(updatedPet);
      final refetchedPet = await repository.getPetById('p-301');
      expect(refetchedPet!.name, 'Biscuit Jr.');
      expect(refetchedPet.availabilityStatus, PetAvailabilityStatus.pending);
      expect(refetchedPet.adoptionFee, 150.0);

      // Filter query test
      final filteredCats = await repository.getPets(
        animalType: AnimalType.cat,
        lifeStage: LifeStage.baby,
      );
      expect(filteredCats.length, 1);
      expect(filteredCats.first.name, 'Biscuit Jr.');

      final emptyDogs = await repository.getPets(animalType: AnimalType.dog);
      expect(emptyDogs, isEmpty);

      // 4. Adoption Request
      final adoptionReq = AdoptionRequestModel(
        id: 'req-401',
        petId: 'p-301',
        adopterId: 'u-101',
        storeId: 's-201',
        status: AdoptionRequestStatus.pending,
        message: 'Looking forward to giving Biscuit a loving home!',
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveAdoptionRequest(adoptionReq);

      final fetchedRequests = await repository.getAdoptionRequestsForUser('u-101');
      expect(fetchedRequests.length, 1);
      expect(fetchedRequests.first.status, AdoptionRequestStatus.pending);

      await repository.updateAdoptionRequestStatus('req-401', AdoptionRequestStatus.approved);
      final updatedReq = await repository.getAdoptionRequestById('req-401');
      expect(updatedReq!.status, AdoptionRequestStatus.approved);

      // 5. Favorites Toggle and Retrieval
      await repository.toggleFavorite('u-101', 'p-301');
      expect(await repository.isFavorite('u-101', 'p-301'), true);

      final favPets = await repository.getFavoritePets('u-101');
      expect(favPets.length, 1);
      expect(favPets.first.id, 'p-301');

      await repository.toggleFavorite('u-101', 'p-301');
      expect(await repository.isFavorite('u-101', 'p-301'), false);

      // 6. Foreign Key Cascade Verification
      // Re-add favorite and verify pet deletion cascades
      await repository.toggleFavorite('u-101', 'p-301');
      expect(await repository.isFavorite('u-101', 'p-301'), true);

      await repository.deletePet('p-301');

      final petAfterDelete = await repository.getPetById('p-301');
      expect(petAfterDelete, isNull);

      final imagesAfterDelete = await repository.getImagesForPet('p-301');
      expect(imagesAfterDelete, isEmpty);

      final favsAfterDelete = await repository.getFavoritePetIds('u-101');
      expect(favsAfterDelete, isEmpty);
    });
  });
}
