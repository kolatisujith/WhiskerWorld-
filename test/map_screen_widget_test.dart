import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:whisker_world/database/database_seeder.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/models/pet_store_model.dart';
import 'package:whisker_world/models/user_model.dart';
import 'package:whisker_world/providers/adoption_provider.dart';
import 'package:whisker_world/providers/auth_provider.dart';
import 'package:whisker_world/providers/favorite_provider.dart';
import 'package:whisker_world/providers/map_provider.dart';
import 'package:whisker_world/providers/pet_provider.dart';
import 'package:whisker_world/providers/store_provider.dart';
import 'package:whisker_world/providers/theme_provider.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';
import 'package:whisker_world/screens/map/map_screen.dart';
import 'package:whisker_world/services/auth_service.dart';
import 'package:whisker_world/widgets/map/map_marker_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MapMarkerCard Component Tests', () {
    testWidgets('Renders Store Preview Card accurately', (tester) async {
      final now = DateTime.now();
      final store = PetStoreModel(
        id: 'store-1',
        name: 'Whisker Haven',
        address: '100 Paw Lane',
        city: 'Portland',
        state: 'OR',
        phone: '503-555-0101',
        email: 'info@whiskerhaven.com',
        openingHours: 'Mon-Sat 9AM-6PM',
        createdAt: now,
      );

      final item = SelectedMapItem(
        type: MapItemType.store,
        store: store,
        coordinates: const LatLng(45.5231, -122.6865),
        title: store.name,
        subtitle: store.fullLocation,
      );

      bool closed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapMarkerCard(
              item: item,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('Pet Store'), findsOneWidget);
      expect(find.text('Whisker Haven'), findsOneWidget);
      expect(find.text('100 Paw Lane'), findsOneWidget);
      expect(find.text('503-555-0101'), findsOneWidget);
      expect(find.text('View Pet Store'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);
    });

    testWidgets('Renders Pet Owner Preview Card accurately', (tester) async {
      final now = DateTime.now();
      final owner = UserModel(
        id: 'owner-1',
        name: 'Eleanor Vance',
        email: 'eleanor@example.com',
        role: UserRole.petOwner,
        location: 'Portland, OR',
        createdAt: now,
      );

      final item = SelectedMapItem(
        type: MapItemType.owner,
        owner: owner,
        coordinates: const LatLng(45.5152, -122.6784),
        title: owner.name,
        subtitle: owner.location!,
        associatedPets: [
          PetModel(
            id: 'p-1',
            name: 'Bruno',
            animalType: AnimalType.dog,
            breed: 'Golden Retriever',
            ageValue: 3,
            ageUnit: AgeUnit.months,
            lifeStage: LifeStage.baby,
            gender: Gender.male,
            description: '',
            location: 'Portland, OR',
            createdAt: now,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapMarkerCard(
              item: item,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pet Owner'), findsOneWidget);
      expect(find.text('Eleanor Vance'), findsOneWidget);
      expect(find.text('eleanor@example.com'), findsOneWidget);
      expect(find.text('1 pets up for adoption'), findsOneWidget);
      expect(find.text('View Owner\'s Pets'), findsOneWidget);
    });

    testWidgets('Renders Chosen Pet Preview Card accurately', (tester) async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'pet-bruno',
        name: 'Bruno',
        animalType: AnimalType.dog,
        breed: 'Golden Retriever',
        ageValue: 3,
        ageUnit: AgeUnit.months,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Puppy',
        gender: Gender.male,
        description: 'Cheerful puppy',
        adoptionFee: 250.0,
        location: 'Portland, OR',
        createdAt: now,
      );

      final item = SelectedMapItem(
        type: MapItemType.pet,
        pet: pet,
        coordinates: const LatLng(45.5240, -122.6850),
        title: pet.name,
        subtitle: '${pet.displayYoungName} • ${pet.breed}',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapMarkerCard(
              item: item,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('🐾 Chosen Pet'), findsOneWidget);
      expect(find.text('Bruno'), findsOneWidget);
      expect(find.text('Puppy • Golden Retriever'), findsOneWidget);
      expect(find.text('3 months'), findsOneWidget);
      expect(find.text('\$250'), findsOneWidget);
      expect(find.text('View Pet'), findsOneWidget);
    });
  });

  group('MapScreen Integrated Widget Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;
    late AuthService authService;
    late AuthProvider authProvider;
    late MapProvider mapProvider;

    setUp(() async {
      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);
      await DatabaseSeeder.seedIfEmpty(repository);
      authService = AuthService(repository: repository);
      authProvider = AuthProvider(authService: authService);
      mapProvider = MapProvider(repository: repository);
      await mapProvider.loadMapData();
    });

    tearDown(() async {
      await dbService.close();
    });

    Widget createTestApp({String? initialPetId}) {
      final router = GoRouter(
        initialLocation: '/map',
        routes: [
          GoRoute(
            path: '/map',
            builder: (context, state) => MapScreen(
              initialPetId: initialPetId,
              enableTileLayer: false,
            ),
          ),
          GoRoute(
            path: '/pets',
            builder: (context, state) => const Scaffold(body: Text('Pets Page')),
          ),
          GoRoute(
            path: '/stores',
            builder: (context, state) => const Scaffold(body: Text('Stores Page')),
          ),
        ],
      );

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => PetProvider(repository: repository)),
          ChangeNotifierProvider(create: (_) => StoreProvider(repository: repository)),
          ChangeNotifierProvider(create: (_) => AdoptionProvider(repository: repository)),
          ChangeNotifierProvider(create: (_) => FavoriteProvider(repository: repository)),
          ChangeNotifierProvider.value(value: mapProvider),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('MapScreen renders search bar, filter tabs, and pet selector in router', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search stores, owners, pets, or cities...'), findsOneWidget);

      expect(find.text('All Locations'), findsOneWidget);
      expect(find.text('Pet Stores'), findsWidgets);
      expect(find.text('Pet Owners'), findsOneWidget);
      expect(find.text('Chosen Pet'), findsOneWidget);

      expect(find.text('Choose Pet'), findsOneWidget);
    });

    testWidgets('MapScreen highlights chosen pet when initialPetId is provided in route', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await mapProvider.loadMapData(initialPetId: 'pet-bruno');

      await tester.pumpWidget(createTestApp(initialPetId: 'pet-bruno'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Bruno'), findsWidgets);
      expect(find.textContaining('Chosen Companion: Bruno'), findsOneWidget);
      expect(find.textContaining('Located at store: Whisker Haven'), findsOneWidget);
      expect(find.textContaining('Pet Owner: Eleanor Vance'), findsOneWidget);
    });
  });
}
