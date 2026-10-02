import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whisker_world/app/routes.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/providers/adoption_provider.dart';
import 'package:whisker_world/providers/auth_provider.dart';
import 'package:whisker_world/providers/favorite_provider.dart';
import 'package:whisker_world/providers/pet_provider.dart';
import 'package:whisker_world/providers/store_provider.dart';
import 'package:whisker_world/providers/theme_provider.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';
import 'package:whisker_world/services/auth_service.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Role-Based Route Guarding & Navigation Tests', () {
    late DatabaseService dbService;
    late DatabaseRepositoryImpl repository;
    late AuthService authService;
    late AuthProvider authProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      dbService = DatabaseService();
      await dbService.init(inMemory: true);
      repository = DatabaseRepositoryImpl(dbService: dbService);
      authService = AuthService(repository: repository, prefs: prefs);
      authProvider = AuthProvider(authService: authService);
    });

    tearDown(() async {
      await dbService.close();
    });

    Widget createTestApp(GoRouter router) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => PetProvider(repository: repository)),
          ChangeNotifierProvider(create: (_) => StoreProvider(repository: repository)),
          ChangeNotifierProvider(create: (_) => AdoptionProvider(repository: repository)),
          ChangeNotifierProvider(create: (_) => FavoriteProvider(repository: repository)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('Unauthenticated user is redirected to /login from protected routes', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = AppRoutes.createRouter(authProvider);

      await tester.pumpWidget(createTestApp(router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Attempt navigating to owner dashboard
      router.go('/owner/dashboard');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/login');

      // Attempt navigating to adopter dashboard
      router.go('/adopter/dashboard');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/login');

      // Attempt navigating to profile
      router.go('/profile');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/login');

      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
    });

    testWidgets('Pet Owner can access /owner/dashboard and is redirected away from /adopter/dashboard', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.runAsync(() async {
        await authProvider.register(
          name: 'Oliver Owner',
          email: 'oliver@owner.com',
          password: 'Password123!',
          phone: '555-1111',
          role: UserRole.petOwner,
        );
      });

      final router = AppRoutes.createRouter(authProvider);
      await tester.pumpWidget(createTestApp(router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Can navigate to owner dashboard
      router.go('/owner/dashboard');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/owner/dashboard');

      // Trying to access adopter route redirects to owner dashboard
      router.go('/adopter/dashboard');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/owner/dashboard');

      // Trying to visit /login while authenticated redirects to owner dashboard
      router.go('/login');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/owner/dashboard');

      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
    });

    testWidgets('Pet Adopter can access /adopter/dashboard and is redirected away from /owner/dashboard', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.runAsync(() async {
        await authProvider.register(
          name: 'Amy Adopter',
          email: 'amy@adopter.com',
          password: 'Password123!',
          phone: '555-2222',
          role: UserRole.petAdopter,
        );
      });

      final router = AppRoutes.createRouter(authProvider);
      await tester.pumpWidget(createTestApp(router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Can navigate to adopter dashboard
      router.go('/adopter/dashboard');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/adopter/dashboard');

      // Trying to access owner route redirects to adopter dashboard
      router.go('/owner/dashboard');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/adopter/dashboard');

      // Trying to visit /register while authenticated redirects to adopter dashboard
      router.go('/register');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/adopter/dashboard');

      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
    });

    testWidgets('Public routes remain accessible to everyone', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = AppRoutes.createRouter(authProvider);
      await tester.pumpWidget(createTestApp(router));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      router.go('/pets');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/pets');

      router.go('/stores');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/stores');

      router.go('/about');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(router.state.matchedLocation, '/about');

      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 11));
    });
  });
}
