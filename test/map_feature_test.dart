import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:whisker_world/database/database_seeder.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/providers/map_provider.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';
import 'package:whisker_world/services/geo_location_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('GeoLocationService Tests', () {
    test('Resolves known cities correctly without explicit lat/lng', () {
      final portland = GeoLocationService.resolveCoordinates(city: 'Portland, OR');
      expect(portland.latitude, closeTo(45.5152, 0.001));
      expect(portland.longitude, closeTo(-122.6784, 0.001));

      final seattle = GeoLocationService.resolveCoordinates(city: 'Seattle, WA');
      expect(seattle.latitude, closeTo(47.6062, 0.001));
      expect(seattle.longitude, closeTo(-122.3321, 0.001));

      final austin = GeoLocationService.resolveCoordinates(city: 'Austin, TX');
      expect(austin.latitude, closeTo(30.2672, 0.001));
      expect(austin.longitude, closeTo(-97.7431, 0.001));
    });

    test('Preserves explicit coordinates when provided', () {
      final custom = GeoLocationService.resolveCoordinates(
        explicitLat: 34.0522,
        explicitLng: -118.2437,
        city: 'Portland', // Even if text says Portland
      );
      expect(custom.latitude, 34.0522);
      expect(custom.longitude, -118.2437);
    });

    test('Applies deterministic jitter when multiple entities share a city', () {
      final storeCoord = GeoLocationService.resolveCoordinates(
        city: 'Portland, OR',
        entityId: 'store-1',
      );
      final ownerCoord = GeoLocationService.resolveCoordinates(
        city: 'Portland, OR',
        entityId: 'owner-1',
      );

      // Pins should not be identical (anti-collision)
      expect(storeCoord.latitude == ownerCoord.latitude && storeCoord.longitude == ownerCoord.longitude, isFalse);

      // Same entityId produces exact same deterministic jitter
      final storeCoordAgain = GeoLocationService.resolveCoordinates(
        city: 'Portland, OR',
        entityId: 'store-1',
      );
      expect(storeCoord.latitude, equals(storeCoordAgain.latitude));
      expect(storeCoord.longitude, equals(storeCoordAgain.longitude));
    });

    test('Haversine distance calculation is accurate', () {
      // Portland, OR: 45.5152, -122.6784
      // Seattle, WA: 47.6062, -122.3321
      // Distance is ~145 miles
      final miles = GeoLocationService.calculateDistanceMiles(
        45.5152,
        -122.6784,
        47.6062,
        -122.3321,
      );
      expect(miles, inInclusiveRange(140.0, 150.0));

      final km = GeoLocationService.calculateDistanceKm(
        45.5152,
        -122.6784,
        47.6062,
        -122.3321,
      );
      expect(km, inInclusiveRange(225.0, 245.0));

      expect(GeoLocationService.formatDistance(0.05), 'Less than 0.1 miles away');
      expect(GeoLocationService.formatDistance(4.52), '4.5 miles away');
      expect(GeoLocationService.formatDistance(145.2), '145 miles away');
    });
  });

  group('Database Repository & MapProvider Integration Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;
    late MapProvider mapProvider;

    setUp(() async {
      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);
      await DatabaseSeeder.seedIfEmpty(repository);
      mapProvider = MapProvider(repository: repository);
    });

    tearDown(() async {
      await dbService.close();
    });

    test('getPetOwners returns only users with petOwner role', () async {
      final petOwners = await repository.getPetOwners();
      expect(petOwners.isNotEmpty, isTrue);
      for (final owner in petOwners) {
        expect(owner.role, UserRole.petOwner);
      }
    });

    test('MapProvider loads stores, owners, and pets properly', () async {
      await mapProvider.loadMapData();

      expect(mapProvider.isLoading, isFalse);
      expect(mapProvider.stores.length, greaterThanOrEqualTo(2));
      expect(mapProvider.petOwners.length, greaterThanOrEqualTo(1));
      expect(mapProvider.allPets.length, greaterThanOrEqualTo(6));

      // Check store pet counts are calculated
      expect(mapProvider.storePetCounts[DatabaseSeeder.whiskerHavenStoreId], greaterThanOrEqualTo(3));
      expect(mapProvider.storePetCounts[DatabaseSeeder.happyPawsStoreId], greaterThanOrEqualTo(3));
    });

    test('MapProvider chooses pet and resolves its owner and store', () async {
      await mapProvider.loadMapData(initialPetId: 'pet-bruno');

      expect(mapProvider.chosenPet, isNotNull);
      expect(mapProvider.chosenPet!.name, 'Bruno');
      expect(mapProvider.chosenPet!.breed, 'Golden Retriever');

      // Bruno belongs to store-whisker-haven and demo-owner-100
      expect(mapProvider.chosenPetStore, isNotNull);
      expect(mapProvider.chosenPetStore!.id, DatabaseSeeder.whiskerHavenStoreId);
      expect(mapProvider.chosenPetOwner, isNotNull);
      expect(mapProvider.chosenPetOwner!.id, DatabaseSeeder.demoOwnerId);

      // Selected map item is automatically set to chosen pet
      expect(mapProvider.selectedItem, isNotNull);
      expect(mapProvider.selectedItem!.type, MapItemType.pet);
      expect(mapProvider.selectedItem!.title, 'Bruno');

      // Clear chosen pet
      mapProvider.clearChosenPet();
      expect(mapProvider.chosenPet, isNull);
      expect(mapProvider.chosenPetStore, isNull);
      expect(mapProvider.chosenPetOwner, isNull);
      expect(mapProvider.selectedItem, isNull);
    });

    test('MapProvider filter modes filter list correctly', () async {
      await mapProvider.loadMapData();

      mapProvider.setFilterMode(MapFilterMode.stores);
      expect(mapProvider.filteredStores.isNotEmpty, isTrue);
      expect(mapProvider.filteredPetOwners.isEmpty, isTrue);

      mapProvider.setFilterMode(MapFilterMode.owners);
      expect(mapProvider.filteredStores.isEmpty, isTrue);
      expect(mapProvider.filteredPetOwners.isNotEmpty, isTrue);

      mapProvider.setFilterMode(MapFilterMode.all);
      expect(mapProvider.filteredStores.isNotEmpty, isTrue);
      expect(mapProvider.filteredPetOwners.isNotEmpty, isTrue);
    });

    test('MapProvider search query filters stores and owners by name and city', () async {
      await mapProvider.loadMapData();

      mapProvider.setSearchQuery('Portland');
      expect(mapProvider.filteredStores.any((s) => s.city.contains('Portland')), isTrue);
      expect(mapProvider.filteredStores.any((s) => s.city.contains('Seattle')), isFalse);

      mapProvider.setSearchQuery('Eleanor');
      expect(mapProvider.filteredPetOwners.any((o) => o.name.contains('Eleanor')), isTrue);

      mapProvider.setSearchQuery('');
      expect(mapProvider.filteredStores.length, equals(mapProvider.stores.length));
    });
  });
}
