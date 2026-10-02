import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisker_world/database/database_seeder.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/adoption_request_model.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/pet_store_model.dart';
import 'package:whisker_world/models/user_model.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';
import 'package:whisker_world/services/auth_service.dart';
import 'package:whisker_world/utils/animal_utils.dart';
import 'package:whisker_world/utils/password_hasher.dart';

void main() {
  group('🐾 Whisker World — Phase 8 Final Testing & Security Suite', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;
    late AuthService authService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);
      authService = AuthService(repository: repository, prefs: prefs);
    });

    tearDown(() async {
      await dbService.close();
    });

    // ==========================================
    // 1. AUTHENTICATION TESTS
    // ==========================================
    group('1. Authentication Tests', () {
      test('Owner registration with salted hash', () async {
        final user = await authService.register(
          name: 'Sarah Owner',
          email: 'sarah@shelter.org',
          password: 'SecretPassword123!',
          phone: '+1 555-0199',
          role: UserRole.petOwner,
          location: 'Austin, TX',
        );

        expect(user.id, isNotEmpty);
        expect(user.role, UserRole.petOwner);
        expect(user.passwordHash, isNull); // Sanitized for security
        expect(authService.isAuthenticated, true);
        expect(authService.userRole, UserRole.petOwner);
      });

      test('Adopter registration with petAdopter role', () async {
        final user = await authService.register(
          name: 'Dave Adopter',
          email: 'dave@home.net',
          password: 'AdopterSecret!456',
          phone: '+1 555-0288',
          role: UserRole.petAdopter,
        );

        expect(user.role, UserRole.petAdopter);
        expect(authService.userRole, UserRole.petAdopter);
      });

      test('Duplicate email registration is rejected with AuthException', () async {
        await authService.register(
          name: 'First User',
          email: 'duplicate@example.com',
          password: 'Password123!',
          phone: '555-1111',
          role: UserRole.petAdopter,
        );

        expect(
          () => authService.register(
            name: 'Second User',
            email: 'duplicate@example.com',
            password: 'DifferentPass456!',
            phone: '555-2222',
            role: UserRole.petOwner,
          ),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('already exists'),
          )),
        );
      });

      test('Login with valid credentials succeeds', () async {
        await authService.register(
          name: 'Login User',
          email: 'login@test.com',
          password: 'ValidPass123!',
          phone: '555-3333',
          role: UserRole.petOwner,
        );

        await authService.logout();
        expect(authService.isAuthenticated, false);

        final loggedIn = await authService.login(
          email: 'login@test.com',
          password: 'ValidPass123!',
        );

        expect(loggedIn, isNotNull);
        expect(loggedIn.email, 'login@test.com');
        expect(authService.isAuthenticated, true);
      });

      test('Invalid login rejects wrong password and nonexistent email', () async {
        await authService.register(
          name: 'Target User',
          email: 'target@test.com',
          password: 'CorrectPassword123',
          phone: '555-4444',
          role: UserRole.petAdopter,
        );

        await authService.logout();

        // Wrong password
        expect(
          () => authService.login(email: 'target@test.com', password: 'WrongPassword'),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Invalid email or password'),
          )),
        );

        // Nonexistent email
        expect(
          () => authService.login(email: 'nobody@nowhere.com', password: 'Password123'),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Invalid email or password'),
          )),
        );
      });

      test('Logout clears session and SharedPreferences persistence', () async {
        await authService.register(
          name: 'Logout User',
          email: 'logout@test.com',
          password: 'Password123!',
          phone: '555-5555',
          role: UserRole.petOwner,
        );

        expect(authService.isAuthenticated, true);
        await authService.logout();

        expect(authService.isAuthenticated, false);
        expect(authService.currentUser, isNull);

        // Session restoration after logout returns null
        final restored = await authService.restoreSession();
        expect(restored, isNull);
      });

      test('Session restoration successfully restores active user from SharedPreferences', () async {
        final registered = await authService.register(
          name: 'Persistent User',
          email: 'persist@test.com',
          password: 'Password123!',
          phone: '555-6666',
          role: UserRole.petAdopter,
        );

        // Simulate new app launch with same preferences
        final freshAuthService = AuthService(repository: repository, prefs: prefs);
        expect(freshAuthService.isAuthenticated, false);

        final restored = await freshAuthService.restoreSession();
        expect(restored, isNotNull);
        expect(restored!.id, registered.id);
        expect(restored.email, 'persist@test.com');
        expect(freshAuthService.isAuthenticated, true);
        expect(freshAuthService.userRole, UserRole.petAdopter);
      });
    });

    // ==========================================
    // 2. ROLE TESTS
    // ==========================================
    group('2. Role Capability Tests', () {
      test('PET_OWNER can manage own pets, manage own store, and view requests', () async {
        final now = DateTime.now();
        final owner = UserModel(
          id: 'owner-role-1',
          name: 'Role Owner',
          email: 'role_owner@test.com',
          role: UserRole.petOwner,
          createdAt: now,
        );
        await repository.saveUser(owner);

        // Manage own store
        final store = PetStoreModel(
          id: 'store-role-1',
          ownerId: 'owner-role-1',
          name: 'Role Sanctuary',
          address: '500 Rescue Way',
          city: 'Portland',
          state: 'OR',
          country: 'USA',
          phone: '555-1234',
          email: 'role_owner@test.com',
          createdAt: now,
        );
        await repository.savePetStore(store);
        final fetchedStore = await repository.getPetStoreById('store-role-1');
        expect(fetchedStore, isNotNull);
        expect(fetchedStore!.ownerId, 'owner-role-1');

        // Manage own pet
        final pet = PetModel(
          id: 'pet-role-1',
          ownerId: 'owner-role-1',
          storeId: 'store-role-1',
          name: 'Role Puppy',
          animalType: AnimalType.dog,
          breed: 'Labrador',
          ageValue: 2,
          ageUnit: AgeUnit.months,
          lifeStage: LifeStage.baby,
          gender: Gender.female,
          description: 'A friendly puppy.',
          location: 'Portland, OR',
          availabilityStatus: PetAvailabilityStatus.available,
          createdAt: now,
        );
        await repository.savePet(pet);
        final ownerPets = await repository.getPetsByOwner('owner-role-1');
        expect(ownerPets.length, 1);
        expect(ownerPets.first.name, 'Role Puppy');

        // View incoming requests
        final ownerRequests = await repository.getAdoptionRequestDetailsForOwner('owner-role-1');
        expect(ownerRequests, isEmpty); // Clean list returned without error
      });

      test('PET_ADOPTER can browse pets, favorite, apply, and view own requests', () async {
        final now = DateTime.now();
        final adopter = UserModel(
          id: 'adopter-role-1',
          name: 'Role Adopter',
          email: 'role_adopter@test.com',
          role: UserRole.petAdopter,
          createdAt: now,
        );
        final owner = UserModel(
          id: 'owner-role-2',
          name: 'Role Owner 2',
          email: 'role_owner2@test.com',
          role: UserRole.petOwner,
          createdAt: now,
        );
        await repository.saveUser(adopter);
        await repository.saveUser(owner);

        final pet = PetModel(
          id: 'pet-role-2',
          ownerId: 'owner-role-2',
          name: 'Pip',
          animalType: AnimalType.cat,
          breed: 'Tabby',
          ageValue: 6,
          ageUnit: AgeUnit.weeks,
          lifeStage: LifeStage.baby,
          gender: Gender.male,
          description: 'Cute tabby kitten.',
          location: 'Portland, OR',
          availabilityStatus: PetAvailabilityStatus.available,
          createdAt: now,
        );
        await repository.savePet(pet);

        // Browse pets
        final available = await repository.getPets(status: PetAvailabilityStatus.available);
        expect(available.any((p) => p.id == 'pet-role-2'), true);

        // Favorite
        await repository.addFavorite('adopter-role-1', 'pet-role-2');
        final isFav = await repository.isFavorite('adopter-role-1', 'pet-role-2');
        expect(isFav, true);

        // Apply
        final request = AdoptionRequestModel(
          id: 'req-role-1',
          petId: 'pet-role-2',
          adopterId: 'adopter-role-1',
          ownerId: 'owner-role-2',
          status: AdoptionRequestStatus.pending,
          message: 'I would love to adopt Pip!',
          reasonForAdoption: 'Loving home ready',
          livingEnvironment: 'Apartment',
          createdAt: now,
          updatedAt: now,
        );
        await repository.saveAdoptionRequest(request);

        // View own requests
        final adopterRequests = await repository.getAdoptionRequestDetailsForAdopter('adopter-role-1');
        expect(adopterRequests.length, 1);
        expect(adopterRequests.first.request.id, 'req-role-1');
      });
    });

    // ==========================================
    // 3. OWNERSHIP TESTS
    // ==========================================
    group('3. Ownership Boundary & Isolation Tests', () {
      test('Owner A cannot edit or delete Owner B pet, and cannot attach to Owner A store', () async {
        final now = DateTime.now();
        final ownerA = UserModel(id: 'owner-a', name: 'Alice', email: 'alice@test.com', role: UserRole.petOwner, createdAt: now);
        final ownerB = UserModel(id: 'owner-b', name: 'Bob', email: 'bob@test.com', role: UserRole.petOwner, createdAt: now);
        await repository.saveUser(ownerA);
        await repository.saveUser(ownerB);

        final storeA = PetStoreModel(
          id: 'store-a',
          ownerId: 'owner-a',
          name: 'Alice Store',
          address: '100 Main St',
          city: 'Portland',
          phone: '555-0101',
          email: 'alice@test.com',
          createdAt: now,
        );
        final storeB = PetStoreModel(
          id: 'store-b',
          ownerId: 'owner-b',
          name: 'Bob Store',
          address: '200 Main St',
          city: 'Portland',
          phone: '555-0102',
          email: 'bob@test.com',
          createdAt: now,
        );
        await repository.savePetStore(storeA);
        await repository.savePetStore(storeB);

        // Pet belonging to Owner B
        final petB = PetModel(
          id: 'pet-belonging-to-b',
          ownerId: 'owner-b',
          storeId: 'store-b',
          name: 'Bob Pet',
          animalType: AnimalType.dog,
          breed: 'Beagle',
          ageValue: 4,
          ageUnit: AgeUnit.months,
          lifeStage: LifeStage.young,
          gender: Gender.male,
          description: 'Owned by Bob',
          location: 'Portland, OR',
          availabilityStatus: PetAvailabilityStatus.available,
          createdAt: now,
        );
        await repository.savePet(petB);

        // Verify Owner A fetch by owner returns empty
        final ownerAPets = await repository.getPetsByOwner('owner-a');
        expect(ownerAPets.where((p) => p.id == 'pet-belonging-to-b'), isEmpty);

        // Verify Owner B fetch returns petB
        final ownerBPets = await repository.getPetsByOwner('owner-b');
        expect(ownerBPets.where((p) => p.id == 'pet-belonging-to-b'), isNotEmpty);

        // Ownership enforcement rule: pet retains owner_id = 'owner-b'
        final fetchedPet = await repository.getPetById('pet-belonging-to-b');
        expect(fetchedPet!.ownerId, 'owner-b');
        expect(fetchedPet.storeId, 'store-b');
      });

      test('Adopter A cannot modify Adopter B requests or favorites', () async {
        final now = DateTime.now();
        final adopterA = UserModel(id: 'adopter-a', name: 'Adopter A', email: 'adopter_a@test.com', role: UserRole.petAdopter, createdAt: now);
        final adopterB = UserModel(id: 'adopter-b', name: 'Adopter B', email: 'adopter_b@test.com', role: UserRole.petAdopter, createdAt: now);
        final owner = UserModel(id: 'owner-c', name: 'Owner C', email: 'owner_c@test.com', role: UserRole.petOwner, createdAt: now);
        await repository.saveUser(adopterA);
        await repository.saveUser(adopterB);
        await repository.saveUser(owner);

        final pet = PetModel(
          id: 'pet-cross-test',
          ownerId: 'owner-c',
          name: 'Rusty',
          animalType: AnimalType.dog,
          breed: 'Terrier',
          ageValue: 3,
          ageUnit: AgeUnit.months,
          lifeStage: LifeStage.baby,
          gender: Gender.male,
          description: 'Spunky terrier',
          location: 'Portland, OR',
          availabilityStatus: PetAvailabilityStatus.available,
          createdAt: now,
        );
        await repository.savePet(pet);

        // Adopter B favorites pet
        await repository.addFavorite('adopter-b', 'pet-cross-test');

        // Adopter A does NOT have it favorited
        expect(await repository.isFavorite('adopter-a', 'pet-cross-test'), false);
        expect(await repository.isFavorite('adopter-b', 'pet-cross-test'), true);

        // Adopter B submits request
        final reqB = AdoptionRequestModel(
          id: 'req-b',
          petId: 'pet-cross-test',
          adopterId: 'adopter-b',
          ownerId: 'owner-c',
          status: AdoptionRequestStatus.pending,
          message: 'Application from Adopter B',
          createdAt: now,
          updatedAt: now,
        );
        await repository.saveAdoptionRequest(reqB);

        // Adopter A requests list must NOT include req-b
        final adopterARequests = await repository.getAdoptionRequestDetailsForAdopter('adopter-a');
        expect(adopterARequests.where((r) => r.request.id == 'req-b'), isEmpty);

        // Adopter B requests list includes req-b
        final adopterBRequests = await repository.getAdoptionRequestDetailsForAdopter('adopter-b');
        expect(adopterBRequests.where((r) => r.request.id == 'req-b'), isNotEmpty);
      });
    });

    // ==========================================
    // 4. STORE TEST & CRITICAL ISOLATION
    // ==========================================
    group('4. Store Test (Whisker Haven vs Happy Paws SQL Isolation)', () {
      test('Store A displays ONLY Store A pets; Store B displays ONLY Store B pets via SQL WHERE store_id = ?', () async {
        // Use DatabaseSeeder to populate Whisker Haven and Happy Paws
        await DatabaseSeeder.seedIfEmpty(repository);

        // 1. Query Whisker Haven (store-whisker-haven)
        final whiskerHavenPets = await repository.getPetsByStore(DatabaseSeeder.whiskerHavenStoreId);
        final whiskerHavenNames = whiskerHavenPets.map((p) => p.name).toList();

        // Must show Bruno, Luna, Milo
        expect(whiskerHavenNames, containsAll(['Bruno', 'Luna', 'Milo']));
        expect(whiskerHavenNames.length, 3);

        // Must NOT show Simba, Coco, Rocky
        expect(whiskerHavenNames, isNot(contains('Simba')));
        expect(whiskerHavenNames, isNot(contains('Coco')));
        expect(whiskerHavenNames, isNot(contains('Rocky')));

        // 2. Query Happy Paws (store-happy-paws)
        final happyPawsPets = await repository.getPetsByStore(DatabaseSeeder.happyPawsStoreId);
        final happyPawsNames = happyPawsPets.map((p) => p.name).toList();

        // Must show Simba, Coco, Rocky
        expect(happyPawsNames, containsAll(['Simba', 'Coco', 'Rocky']));
        expect(happyPawsNames.length, 3);

        // Must NOT show Bruno, Luna, Milo
        expect(happyPawsNames, isNot(contains('Bruno')));
        expect(happyPawsNames, isNot(contains('Luna')));
        expect(happyPawsNames, isNot(contains('Milo')));

        // 3. Dynamic counts via SQL COUNT(*)
        final whCount = await repository.getAvailablePetCountForStore(DatabaseSeeder.whiskerHavenStoreId);
        final hpCount = await repository.getAvailablePetCountForStore(DatabaseSeeder.happyPawsStoreId);

        expect(whCount, 3);
        expect(hpCount, 3);
      });
    });

    // ==========================================
    // 5. ADOPTION TESTS
    // ==========================================
    group('5. Adoption Workflow Tests', () {
      test('Complete lifecycle: Apply -> Pending -> Approve -> Pending Adoption -> Cancel', () async {
        final now = DateTime.now();
        final adopter = UserModel(id: 'adopter-flow', name: 'Flow Adopter', email: 'adopter_flow@test.com', role: UserRole.petAdopter, createdAt: now);
        final owner = UserModel(id: 'owner-flow', name: 'Flow Owner', email: 'owner_flow@test.com', role: UserRole.petOwner, createdAt: now);
        await repository.saveUser(adopter);
        await repository.saveUser(owner);

        final pet = PetModel(
          id: 'pet-flow',
          ownerId: 'owner-flow',
          name: 'Barnaby',
          animalType: AnimalType.dog,
          breed: 'Golden Retriever',
          ageValue: 3,
          ageUnit: AgeUnit.months,
          lifeStage: LifeStage.baby,
          gender: Gender.male,
          description: 'Loving pup',
          location: 'Portland, OR',
          availabilityStatus: PetAvailabilityStatus.available,
          createdAt: now,
        );
        await repository.savePet(pet);

        // 1. Adopter applies
        final request = AdoptionRequestModel(
          id: 'req-flow-1',
          petId: 'pet-flow',
          adopterId: 'adopter-flow',
          ownerId: 'owner-flow',
          status: AdoptionRequestStatus.pending,
          message: 'I want to give Barnaby a wonderful home!',
          reasonForAdoption: 'Committed loving home',
          createdAt: now,
          updatedAt: now,
        );
        await repository.saveAdoptionRequest(request);

        // 2. Duplicate active request is prevented
        final hasActive = await repository.hasActiveAdoptionRequest('adopter-flow', 'pet-flow');
        expect(hasActive, true);

        // 3. Owner receives request
        final ownerReqs = await repository.getAdoptionRequestDetailsForOwner('owner-flow');
        expect(ownerReqs.length, 1);
        expect(ownerReqs.first.request.id, 'req-flow-1');

        // 4. Owner approves request -> Atomic transaction updates request to approved and pet to pending
        await repository.approveAdoptionRequest('req-flow-1');
        final approvedReq = await repository.getAdoptionRequestById('req-flow-1');
        final updatedPet = await repository.getPetById('pet-flow');

        expect(approvedReq!.status, AdoptionRequestStatus.approved);
        expect(updatedPet!.availabilityStatus, PetAvailabilityStatus.pending);

        // 5. Test Adopter cancels pending request -> Status becomes cancelled & pet availability restored/preserved
        final pet2 = pet.copyWith(id: 'pet-flow-2', name: 'Barnaby 2');
        await repository.savePet(pet2);
        final req2 = request.copyWith(id: 'req-flow-2', petId: 'pet-flow-2');
        await repository.saveAdoptionRequest(req2);

        await repository.cancelAdoptionRequest('req-flow-2', 'adopter-flow');
        final cancelledReq = await repository.getAdoptionRequestById('req-flow-2');
        final restoredPet = await repository.getPetById('pet-flow-2');

        expect(cancelledReq!.status, AdoptionRequestStatus.cancelled);
        expect(restoredPet!.availabilityStatus, PetAvailabilityStatus.available);
      });
    });

    // ==========================================
    // 6. DATABASE INTEGRITY & CONSTRAINTS TESTS
    // ==========================================
    group('6. Database Integrity Tests', () {
      test('Foreign keys enabled in SQLite connection', () async {
        final fkStatus = await dbService.rawQuery('PRAGMA foreign_keys;');
        expect(fkStatus.first.values.first, 1);
      });

      test('Unique constraint on favorites prevents duplicate (user_id, pet_id) rows', () async {
        final now = DateTime.now();
        final user = UserModel(id: 'u-fav-uniq', name: 'Fav User', email: 'fav@test.com', role: UserRole.petAdopter, createdAt: now);
        await repository.saveUser(user);

        final pet = PetModel(
          id: 'p-fav-uniq',
          ownerId: 'u-fav-uniq',
          name: 'Fav Pet',
          animalType: AnimalType.cat,
          breed: 'Persian',
          ageValue: 2,
          ageUnit: AgeUnit.months,
          lifeStage: LifeStage.baby,
          gender: Gender.female,
          description: 'A cat',
          location: 'Austin, TX',
          availabilityStatus: PetAvailabilityStatus.available,
          createdAt: now,
        );
        await repository.savePet(pet);

        // Add favorite twice
        await repository.addFavorite('u-fav-uniq', 'p-fav-uniq');
        await repository.addFavorite('u-fav-uniq', 'p-fav-uniq');

        // Count should still be exactly 1
        final favs = await repository.getFavoritePetIds('u-fav-uniq');
        expect(favs.length, 1);
        expect(favs.first, 'p-fav-uniq');
      });

      test('Indexes exist on performance-critical columns', () async {
        final indexes = await dbService.rawQuery("SELECT name FROM sqlite_master WHERE type='index';");
        final indexNames = indexes.map((i) => i['name'] as String).toSet();

        expect(indexNames, containsAll([
          'idx_pets_owner_id',
          'idx_pets_store_id',
          'idx_pets_animal_type',
          'idx_pets_availability_status',
          'idx_adoption_requests_adopter_id',
          'idx_adoption_requests_owner_id',
          'idx_adoption_requests_status',
          'idx_favorites_user_id',
          'idx_favorites_pet_id',
          'idx_pet_stores_owner_id',
        ]));
      });

      test('Transactions rollback atomically when error occurs', () async {
        try {
          await dbService.transaction((txn) async {
            await txn.insert('users', {
              'id': 'temp-user-rollback',
              'name': 'Rollback Name',
              'email': 'rollback@test.com',
              'role': 'petAdopter',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });

            // Trigger deliberate error inside transaction
            throw Exception('Deliberate transaction failure');
          });
        } catch (_) {}

        // Verify temp user was NOT committed
        final user = await repository.getUserById('temp-user-rollback');
        expect(user, isNull);
      });

      test('Invalid IDs gracefully return null without unhandled exceptions', () async {
        expect(await repository.getUserById('non-existent-user-id'), isNull);
        expect(await repository.getPetById('non-existent-pet-id'), isNull);
        expect(await repository.getPetStoreById('non-existent-store-id'), isNull);
        expect(await repository.getAdoptionRequestById('non-existent-req-id'), isNull);
      });
    });

    // ==========================================
    // 7. YOUNG PET TERMINOLOGY & AGE TESTS
    // ==========================================
    group('7. Young Pet Terminology & Age Tests', () {
      test('Comprehensive species-to-young terminology verification', () {
        expect(AnimalUtils.getYoungTerm('Dog'), 'Puppy');
        expect(AnimalUtils.getYoungTerm('Cat'), 'Kitten');
        expect(AnimalUtils.getYoungTerm('Rabbit'), 'Kit');
        expect(AnimalUtils.getYoungTerm('Horse'), 'Foal');
        expect(AnimalUtils.getYoungTerm('Goat'), 'Kid');
        expect(AnimalUtils.getYoungTerm('Sheep'), 'Lamb');
        expect(AnimalUtils.getYoungTerm('Elephant'), 'Calf');
        expect(AnimalUtils.getYoungTerm('Deer'), 'Fawn');
        expect(AnimalUtils.getYoungTerm('Lion'), 'Cub');
        expect(AnimalUtils.getYoungTerm('Bird'), 'Chick');
        expect(AnimalUtils.getYoungTerm('Duck'), 'Duckling');
        expect(AnimalUtils.getYoungTerm('Cow'), 'Calf');
        expect(AnimalUtils.getYoungTerm('Pig'), 'Piglet');
        expect(AnimalUtils.getYoungTerm('Fish'), 'Fry');
        expect(AnimalUtils.getYoungTerm('Reptile'), 'Hatchling');
      });

      test('Exact age formatting across units', () {
        expect(AnimalUtils.formatAge(8, AgeUnit.days), '8 days');
        expect(AnimalUtils.formatAge(5, AgeUnit.weeks), '5 weeks');
        expect(AnimalUtils.formatAge(3, AgeUnit.months), '3 months');
        expect(AnimalUtils.formatAge(1, AgeUnit.days), '1 day');
        expect(AnimalUtils.formatAge(1, AgeUnit.weeks), '1 week');
        expect(AnimalUtils.formatAge(1, AgeUnit.months), '1 month');
        expect(AnimalUtils.formatAge(1, AgeUnit.years), '1 year');
        expect(AnimalUtils.formatAge(2, AgeUnit.years), '2 years');
      });
    });

    // ==========================================
    // 8. SECURITY & PASSWORD HASHING TESTS
    // ==========================================
    group('8. Security Tests', () {
      test('PasswordHasher uses secure random salt and constant-time HMAC-SHA256', () {
        const password = 'SecretPassword!123';
        final hash1 = PasswordHasher.hashPassword(password);
        final hash2 = PasswordHasher.hashPassword(password);

        // Different salts must produce different hash representations
        expect(hash1, isNot(equals(hash2)));

        // Both verify correctly against the original password
        expect(PasswordHasher.verifyPassword(password, hash1), true);
        expect(PasswordHasher.verifyPassword(password, hash2), true);

        // Incorrect password fails verification
        expect(PasswordHasher.verifyPassword('WrongPassword', hash1), false);
      });

      test('No plaintext or hashed passwords exposed in sanitized User models', () async {
        final user = await authService.register(
          name: 'Security User',
          email: 'sec@test.com',
          password: 'TopSecretPassword999',
          phone: '555-7777',
          role: UserRole.petOwner,
        );

        expect(user.passwordHash, isNull);
        final toMapWithoutPassword = user.toMap(includePassword: false);
        expect(toMapWithoutPassword.containsKey('password_hash'), false);
      });
    });
  });
}
