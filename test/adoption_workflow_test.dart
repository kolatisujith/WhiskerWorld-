import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/adoption_request_model.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/user_model.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';

void main() {
  group('Phase 6: Adoption Requests + Favorites Comprehensive Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;

    final owner = UserModel(
      id: 'owner-alpha',
      name: 'Alice Owner',
      email: 'alice@shelter.org',
      role: UserRole.petOwner,
      createdAt: DateTime.now(),
    );

    final adopter1 = UserModel(
      id: 'adopter-bob',
      name: 'Bob Adopter',
      email: 'bob@example.com',
      role: UserRole.petAdopter,
      createdAt: DateTime.now(),
    );

    final adopter2 = UserModel(
      id: 'adopter-charlie',
      name: 'Charlie Adopter',
      email: 'charlie@example.com',
      role: UserRole.petAdopter,
      createdAt: DateTime.now(),
    );

    setUp(() async {
      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);

      await repository.saveUser(owner);
      await repository.saveUser(adopter1);
      await repository.saveUser(adopter2);
    });

    tearDown(() async {
      await dbService.close();
    });

    test('1. Favorites: add, remove, and duplicate prevention', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-fav-1',
        ownerId: 'owner-alpha',
        name: 'Biscuit',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever',
        ageValue: 8,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Golden puppy',
        location: 'Austin, TX',
        createdAt: now,
      );
      await repository.savePet(pet);

      // 1. Add favorite
      await repository.addFavorite('adopter-bob', 'pet-fav-1');
      expect(await repository.isFavorite('adopter-bob', 'pet-fav-1'), isTrue);

      // 2. Prevent duplicate favorites
      await repository.addFavorite('adopter-bob', 'pet-fav-1');
      final favs = await repository.getFavorites('adopter-bob');
      expect(favs.length, 1);

      // 3. Remove favorite
      await repository.removeFavorite('adopter-bob', 'pet-fav-1');
      expect(await repository.isFavorite('adopter-bob', 'pet-fav-1'), isFalse);
      expect(await repository.getFavorites('adopter-bob'), isEmpty);
    });

    test('2. Adoption Application & Duplicate Prevention', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-app-1',
        ownerId: 'owner-alpha',
        name: 'Mochi',
        animalType: AnimalType.cat,
        breed: 'Ragdoll Kitten',
        ageValue: 10,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        gender: Gender.male,
        description: 'Sweet ragdoll',
        location: 'Seattle, WA',
        createdAt: now,
      );
      await repository.savePet(pet);

      final req1 = AdoptionRequestModel(
        id: 'req-mochi-1',
        petId: 'pet-app-1',
        adopterId: 'adopter-bob',
        ownerId: 'owner-alpha',
        status: AdoptionRequestStatus.pending,
        message: 'Looking forward to meeting Mochi!',
        reasonForAdoption: 'Loving companion for our household',
        petExperience: 'Experienced with cats',
        livingEnvironment: 'Apartment',
        otherPets: 'None',
        contactPreference: 'Email',
        createdAt: now,
        updatedAt: now,
      );

      // 1. Submit application
      await repository.saveAdoptionRequest(req1);

      // Verify active request exists
      expect(await repository.hasActiveAdoptionRequest('adopter-bob', 'pet-app-1'), isTrue);

      // 2. Duplicate application prevention
      final reqDuplicate = req1.copyWith(id: 'req-mochi-2');
      expect(
        () async => await repository.saveAdoptionRequest(reqDuplicate),
        throwsA(isA<StateError>()),
      );

      // Verify details retrieval
      final details = await repository.getAdoptionRequestDetailsForAdopter('adopter-bob');
      expect(details.length, 1);
      expect(details.first.petName, 'Mochi');
      expect(details.first.request.reasonForAdoption, 'Loving companion for our household');
      expect(details.first.isPending, isTrue);
    });

    test('3. Owner Approval Workflow & Status Transition (Atomic Transaction)', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-approve-1',
        ownerId: 'owner-alpha',
        name: 'Pip',
        animalType: AnimalType.rabbit,
        breed: 'Mini Lop',
        ageValue: 2,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Gentle bunny',
        location: 'Denver, CO',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );
      await repository.savePet(pet);

      final req = AdoptionRequestModel(
        id: 'req-pip-1',
        petId: 'pet-approve-1',
        adopterId: 'adopter-bob',
        ownerId: 'owner-alpha',
        status: AdoptionRequestStatus.pending,
        message: 'We adore bunnies!',
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveAdoptionRequest(req);

      // Owner approves request
      await repository.approveAdoptionRequest('req-pip-1');

      // Assert request status = APPROVED
      final updatedReq = await repository.getAdoptionRequestById('req-pip-1');
      expect(updatedReq!.status, AdoptionRequestStatus.approved);

      // Assert pet availability_status = PENDING (pending adoption)
      final updatedPet = await repository.getPetById('pet-approve-1');
      expect(updatedPet!.availabilityStatus, PetAvailabilityStatus.pending);
    });

    test('4. Owner Rejection Workflow & Status Transition (Atomic Transaction)', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-reject-1',
        ownerId: 'owner-alpha',
        name: 'Shadow',
        animalType: AnimalType.dog,
        breed: 'Husky Pup',
        ageValue: 12,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.young,
        gender: Gender.male,
        description: 'Active husky puppy',
        location: 'Portland, OR',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );
      await repository.savePet(pet);

      final req = AdoptionRequestModel(
        id: 'req-shadow-1',
        petId: 'pet-reject-1',
        adopterId: 'adopter-bob',
        ownerId: 'owner-alpha',
        status: AdoptionRequestStatus.pending,
        message: 'Looking for a running partner',
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveAdoptionRequest(req);

      // 1. First approve it -> pet becomes pending
      await repository.approveAdoptionRequest('req-shadow-1');
      expect((await repository.getPetById('pet-reject-1'))!.availabilityStatus, PetAvailabilityStatus.pending);

      // 2. Reject it -> request becomes REJECTED and pet reverts to AVAILABLE
      await repository.rejectAdoptionRequest('req-shadow-1');

      final rejectedReq = await repository.getAdoptionRequestById('req-shadow-1');
      expect(rejectedReq!.status, AdoptionRequestStatus.rejected);

      final revertedPet = await repository.getPetById('pet-reject-1');
      expect(revertedPet!.availabilityStatus, PetAvailabilityStatus.available);
    });

    test('5. Owner Finalize Adoption / Completion Workflow (Atomic Transaction)', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-complete-1',
        ownerId: 'owner-alpha',
        name: 'Oliver',
        animalType: AnimalType.cat,
        breed: 'Tabby Kitten',
        ageValue: 8,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        gender: Gender.male,
        description: 'Playful orange tabby',
        location: 'Chicago, IL',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
      );
      await repository.savePet(pet);

      // Adopter 1 applies
      await repository.saveAdoptionRequest(AdoptionRequestModel(
        id: 'req-oliver-bob',
        petId: 'pet-complete-1',
        adopterId: 'adopter-bob',
        ownerId: 'owner-alpha',
        status: AdoptionRequestStatus.pending,
        message: 'Bob application',
        createdAt: now,
        updatedAt: now,
      ));

      // Adopter 2 applies
      await repository.saveAdoptionRequest(AdoptionRequestModel(
        id: 'req-oliver-charlie',
        petId: 'pet-complete-1',
        adopterId: 'adopter-charlie',
        ownerId: 'owner-alpha',
        status: AdoptionRequestStatus.pending,
        message: 'Charlie application',
        createdAt: now,
        updatedAt: now,
      ));

      // Owner approves Bob
      await repository.approveAdoptionRequest('req-oliver-bob');

      // Owner completes adoption with Bob
      await repository.completeAdoptionRequest('req-oliver-bob');

      // 1. Bob's request is COMPLETED
      final bobReq = await repository.getAdoptionRequestById('req-oliver-bob');
      expect(bobReq!.status, AdoptionRequestStatus.completed);

      // 2. Pet availability status is ADOPTED
      final adoptedPet = await repository.getPetById('pet-complete-1');
      expect(adoptedPet!.availabilityStatus, PetAvailabilityStatus.adopted);

      // 3. Charlie's pending request was automatically rejected
      final charlieReq = await repository.getAdoptionRequestById('req-oliver-charlie');
      expect(charlieReq!.status, AdoptionRequestStatus.rejected);
    });

    test('6. Adopter Cancellation Workflow (Atomic Transaction)', () async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-cancel-1',
        ownerId: 'owner-alpha',
        name: 'Coco',
        animalType: AnimalType.dog,
        breed: 'Poodle Pup',
        ageValue: 3,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Mini poodle',
        location: 'Dallas, TX',
        createdAt: now,
      );
      await repository.savePet(pet);

      await repository.saveAdoptionRequest(AdoptionRequestModel(
        id: 'req-coco-1',
        petId: 'pet-cancel-1',
        adopterId: 'adopter-bob',
        ownerId: 'owner-alpha',
        status: AdoptionRequestStatus.pending,
        message: 'Application to cancel',
        createdAt: now,
        updatedAt: now,
      ));

      // Cancel pending request
      await repository.cancelAdoptionRequest('req-coco-1', 'adopter-bob');

      final cancelledReq = await repository.getAdoptionRequestById('req-coco-1');
      expect(cancelledReq!.status, AdoptionRequestStatus.cancelled);

      // Unauthorized user cannot cancel
      expect(
        () async => await repository.cancelAdoptionRequest('req-coco-1', 'adopter-charlie'),
        throwsA(isA<StateError>()),
      );
    });

    test('7. Owner Request queries strictly isolate owner listings', () async {
      final now = DateTime.now();

      final otherOwner = UserModel(
        id: 'owner-beta',
        name: 'Beta Owner',
        email: 'beta@shelter.org',
        role: UserRole.petOwner,
        createdAt: now,
      );
      await repository.saveUser(otherOwner);

      // Pet owned by owner-alpha
      await repository.savePet(PetModel(
        id: 'pet-alpha-1',
        ownerId: 'owner-alpha',
        name: 'Alpha Dog',
        animalType: AnimalType.dog,
        breed: 'Lab',
        ageValue: 4,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.young,
        gender: Gender.male,
        description: 'Alpha Lab',
        location: 'Austin',
        createdAt: now,
      ));

      // Pet owned by owner-beta
      await repository.savePet(PetModel(
        id: 'pet-beta-1',
        ownerId: 'owner-beta',
        name: 'Beta Cat',
        animalType: AnimalType.cat,
        breed: 'Siamese',
        ageValue: 3,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        gender: Gender.female,
        description: 'Beta Cat',
        location: 'Houston',
        createdAt: now,
      ));

      // Requests for each
      await repository.saveAdoptionRequest(AdoptionRequestModel(
        id: 'req-for-alpha',
        petId: 'pet-alpha-1',
        adopterId: 'adopter-bob',
        ownerId: 'owner-alpha',
        status: AdoptionRequestStatus.pending,
        message: 'For Alpha',
        createdAt: now,
        updatedAt: now,
      ));

      await repository.saveAdoptionRequest(AdoptionRequestModel(
        id: 'req-for-beta',
        petId: 'pet-beta-1',
        adopterId: 'adopter-bob',
        ownerId: 'owner-beta',
        status: AdoptionRequestStatus.pending,
        message: 'For Beta',
        createdAt: now,
        updatedAt: now,
      ));

      final alphaRequests = await repository.getAdoptionRequestDetailsForOwner('owner-alpha');
      expect(alphaRequests.length, 1);
      expect(alphaRequests.first.petName, 'Alpha Dog');

      final betaRequests = await repository.getAdoptionRequestDetailsForOwner('owner-beta');
      expect(betaRequests.length, 1);
      expect(betaRequests.first.petName, 'Beta Cat');
    });
  });
}
