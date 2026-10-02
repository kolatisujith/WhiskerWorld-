import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/pet_store_model.dart';
import 'package:whisker_world/repositories/database_repository.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';
import 'package:whisker_world/widgets/pet_card.dart';

void main() {
  group('Phase 4: Pet Discovery & Search Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;

    setUp(() async {
      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);

      final now = DateTime.now();

      // Seed store
      await repository.savePetStore(PetStoreModel(
        id: 'store-austin',
        name: 'Austin Animal Haven',
        address: '101 Main St',
        city: 'Austin',
        state: 'TX',
        phone: '555-0101',
        email: 'austin@haven.org',
        createdAt: now,
      ));

      await repository.savePetStore(PetStoreModel(
        id: 'store-dallas',
        name: 'Dallas Paws Care',
        address: '202 Oak St',
        city: 'Dallas',
        state: 'TX',
        phone: '555-0202',
        email: 'dallas@pawscare.org',
        createdAt: now,
      ));

      // Seed test pets
      await repository.savePet(PetModel(
        id: 'pet-1',
        name: 'Bella',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever',
        ageValue: 8,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Puppy',
        gender: Gender.female,
        description: 'Golden puppy',
        adoptionFee: 250.0,
        location: 'Austin',
        storeId: 'store-austin',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now.subtract(const Duration(days: 10)),
      ));

      await repository.savePet(PetModel(
        id: 'pet-2',
        name: 'Simba',
        animalType: AnimalType.cat,
        breed: 'Ragdoll',
        ageValue: 12,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Kitten',
        gender: Gender.male,
        description: 'Fluffy ragdoll kitten',
        adoptionFee: 150.0,
        location: 'Dallas',
        storeId: 'store-dallas',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now.subtract(const Duration(days: 5)),
      ));

      await repository.savePet(PetModel(
        id: 'pet-3',
        name: 'Chirpy',
        animalType: AnimalType.bird,
        breed: 'Budgie',
        ageValue: 4,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Chick',
        gender: Gender.unknown,
        description: 'Baby parakeet chick',
        adoptionFee: 50.0,
        location: 'Austin',
        storeId: 'store-austin',
        availabilityStatus: PetAvailabilityStatus.adopted,
        createdAt: now.subtract(const Duration(days: 1)),
      ));
    });

    tearDown(() async {
      await dbService.close();
    });

    test('Search by pet name', () async {
      final results = await repository.getPets(searchQuery: 'Bella');
      expect(results.length, 1);
      expect(results.first.name, 'Bella');
    });

    test('Search by breed', () async {
      final results = await repository.getPets(searchQuery: 'Ragdoll');
      expect(results.length, 1);
      expect(results.first.name, 'Simba');
    });

    test('Search by animal type term', () async {
      final results = await repository.getPets(searchQuery: 'bird');
      expect(results.length, 1);
      expect(results.first.name, 'Chirpy');
    });

    test('Search by location', () async {
      final results = await repository.getPets(searchQuery: 'Dallas');
      expect(results.length, 1);
      expect(results.first.name, 'Simba');
    });

    test('Search by young animal name', () async {
      final results = await repository.getPets(searchQuery: 'Puppy');
      expect(results.length, 1);
      expect(results.first.name, 'Bella');
    });

    test('Filter by animal type and store', () async {
      final dogsInAustin = await repository.getPets(
        animalType: AnimalType.dog,
        storeId: 'store-austin',
      );
      expect(dogsInAustin.length, 1);
      expect(dogsInAustin.first.name, 'Bella');

      final dogsInDallas = await repository.getPets(
        animalType: AnimalType.dog,
        storeId: 'store-dallas',
      );
      expect(dogsInDallas, isEmpty);
    });

    test('Filter by adoption fee range', () async {
      final under100 = await repository.getPets(maxFee: 100);
      expect(under100.length, 1);
      expect(under100.first.name, 'Chirpy');

      final midRange = await repository.getPets(minFee: 100, maxFee: 200);
      expect(midRange.length, 1);
      expect(midRange.first.name, 'Simba');
    });

    test('Filter by availability status', () async {
      final available = await repository.getPets(status: PetAvailabilityStatus.available);
      expect(available.length, 2);
      expect(available.any((p) => p.name == 'Chirpy'), false);

      final adopted = await repository.getPets(status: PetAvailabilityStatus.adopted);
      expect(adopted.length, 1);
      expect(adopted.first.name, 'Chirpy');
    });

    test('Sort by newest and oldest', () async {
      final newest = await repository.getPets(sortOrder: PetSortOrder.newest);
      expect(newest.first.name, 'Chirpy');
      expect(newest.last.name, 'Bella');

      final oldest = await repository.getPets(sortOrder: PetSortOrder.oldest);
      expect(oldest.first.name, 'Bella');
      expect(oldest.last.name, 'Chirpy');
    });

    test('Sort by price low to high and high to low', () async {
      final cheapFirst = await repository.getPets(sortOrder: PetSortOrder.priceLowToHigh);
      expect(cheapFirst.first.name, 'Chirpy'); // $50
      expect(cheapFirst.last.name, 'Bella'); // $250

      final expensiveFirst = await repository.getPets(sortOrder: PetSortOrder.priceHighToLow);
      expect(expensiveFirst.first.name, 'Bella'); // $250
      expect(expensiveFirst.last.name, 'Chirpy'); // $50
    });

    test('Sort by youngest', () async {
      final youngestFirst = await repository.getPets(sortOrder: PetSortOrder.youngest);
      expect(youngestFirst.first.name, 'Chirpy'); // 4 weeks
      expect(youngestFirst.last.name, 'Simba'); // 12 weeks
    });
  });

  group('PetCard Widget Tests', () {
    testWidgets('Renders PetCard with details and handles callbacks', (tester) async {
      bool tappedDetails = false;
      bool toggledFavorite = false;

      final pet = PetModel(
        id: 'widget-pet-1',
        name: 'Barnaby',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever',
        ageValue: 8,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Puppy',
        gender: Gender.male,
        description: 'Friendly golden pup',
        adoptionFee: 250.0,
        location: 'Austin, TX',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 480,
              child: PetCard(
                pet: pet,
                isFavorite: false,
                onTap: () {
                  tappedDetails = true;
                },
                onFavoriteToggle: () {
                  toggledFavorite = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify name, breed, young animal name, location, and fee render
      expect(find.text('Barnaby'), findsOneWidget);
      expect(find.text('Golden Retriever'), findsOneWidget);
      expect(find.text('Puppy'), findsOneWidget);
      expect(find.text('Austin, TX'), findsOneWidget);
      expect(find.text('\$250'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);

      // Tap favorite button
      final favButton = find.byTooltip('Favorite');
      expect(favButton, findsOneWidget);
      await tester.tap(favButton);
      expect(toggledFavorite, true);

      // Tap "View Details" button
      final detailsButton = find.text('View Details');
      expect(detailsButton, findsOneWidget);
      await tester.tap(detailsButton);
      expect(tappedDetails, true);
    });
  });
}
