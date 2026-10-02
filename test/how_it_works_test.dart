import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisker_world/database/database_service.dart';
import 'package:whisker_world/providers/auth_provider.dart';
import 'package:whisker_world/providers/theme_provider.dart';
import 'package:whisker_world/repositories/database_repository_impl.dart';
import 'package:whisker_world/screens/home_screen.dart';
import 'package:whisker_world/screens/how_it_works_screen.dart';
import 'package:whisker_world/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({required Widget homeWidget, GoRouter? router}) {
    final dbService = DatabaseService();
    final repo = DatabaseRepositoryImpl(dbService: dbService);
    final authService = AuthService(repository: repo);
    final authProvider = AuthProvider(authService: authService);
    final themeProvider = ThemeProvider();

    if (router != null) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: MaterialApp(
        home: homeWidget,
      ),
    );
  }

  group('HowItWorksScreen Tests', () {
    testWidgets('Renders How It Works screen titles and core pillars', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(homeWidget: const HowItWorksScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('How Whisker World Works'), findsOneWidget);
      expect(find.text('Built on Trust, Care, and Transparency'), findsOneWidget);
      expect(find.text('100% Verified Caregivers'), findsOneWidget);
      expect(find.text('Certified Health Passports'), findsOneWidget);
      expect(find.text('Live Discovery Map'), findsOneWidget);
    });

    testWidgets('Toggling role tabs switches between Adopter and Caregiver workflows', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(homeWidget: const HowItWorksScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Default is adopter
      expect(find.text('Discover & Filter Companions'), findsOneWidget);

      // Switch to Caregiver tab
      final caregiverTab = find.text('For Pet Stores & Caregivers');
      expect(caregiverTab, findsOneWidget);
      await tester.tap(caregiverTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now caregiver steps should appear
      expect(find.text('Register Verified Store Profile'), findsOneWidget);
      expect(find.text('List Newborn & Young Companions'), findsOneWidget);
      expect(find.text('Maintain Digital Vaccine Passports'), findsOneWidget);
    });

    testWidgets('Renders "Tap Home to See Demo Video" buttons and triggers navigation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      String navigatedLocation = '';

      final testRouter = GoRouter(
        initialLocation: '/how-it-works',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              navigatedLocation = state.uri.toString();
              return const Scaffold(body: Text('Home Screen Destination'));
            },
          ),
          GoRoute(
            path: '/how-it-works',
            builder: (context, state) => const HowItWorksScreen(),
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp(homeWidget: const SizedBox(), router: testRouter));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find the hero "Tap Home to See Demo Video" button
      final demoButtons = find.widgetWithText(ElevatedButton, 'Tap Home to See Demo Video');
      expect(demoButtons, findsWidgets);

      await tester.tap(demoButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(navigatedLocation, equals('/?scrollTo=demo'));
      expect(find.text('Home Screen Destination'), findsOneWidget);
    });

    testWidgets('Renders FAQ items and expands on tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 6500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(homeWidget: const HowItWorksScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final faqTitle = find.text('Frequently Asked Questions');
      expect(faqTitle, findsOneWidget);
      final faqItem = find.text('How does Whisker World verify pet stores and breeders?');
      expect(faqItem, findsOneWidget);

      await tester.tap(faqItem);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Every listing entity must provide certified commercial registration'), findsOneWidget);
    });

    testWidgets('HomeScreen accepts scrollToSection and initializes gracefully', (tester) async {
      final home = HomeScreen(scrollToSection: 'demo');
      expect(home.scrollToSection, equals('demo'));
    });
  });
}
