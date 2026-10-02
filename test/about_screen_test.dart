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
import 'package:whisker_world/screens/about_screen.dart';
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

  group('AboutScreen Tests', () {
    testWidgets('Renders About screen headline, badge, and impact stats', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(homeWidget: const AboutScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ABOUT WHISKER WORLD • OFFICIAL APPLICATION'), findsOneWidget);
      expect(find.text('Every Paw Deserves a Loving Home'), findsWidgets);
      expect(find.text('1,250+'), findsOneWidget);
      expect(find.text('Loving Adoptions'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Vet Certified Passports'), findsOneWidget);
    });

    testWidgets('Renders mission, core values, and platform capabilities', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(homeWidget: const AboutScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Our Mission & Founding Story'), findsOneWidget);
      expect(find.text('The Challenge We Addressed'), findsOneWidget);
      expect(find.text('The Whisker World Solution'), findsOneWidget);

      expect(find.text('Certified Health First'), findsOneWidget);
      expect(find.text('Zero Tolerance for Mills'), findsOneWidget);

      expect(find.text('What the Official Web Application Delivers'), findsOneWidget);
      expect(find.text('Smart Companion Search'), findsOneWidget);
      expect(find.text('Interactive Pet Discovery Map'), findsOneWidget);
    });

    testWidgets('Renders leadership team and 5-point guarantee', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestApp(homeWidget: const AboutScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Leadership & Veterinary Advisory Board'), findsOneWidget);
      expect(find.text('Dr. Evelyn Harper, DVM'), findsOneWidget);
      expect(find.text('Marcus Sterling'), findsOneWidget);

      expect(find.text('The Whisker World 5-Point Ethical Guarantee'), findsOneWidget);
      expect(find.textContaining('1. Minimum 8-Week Mother Bond'), findsOneWidget);
      expect(find.textContaining('2. Up-to-Date Core Immunizations'), findsOneWidget);
    });

    testWidgets('Tapping demo video CTA triggers navigation to home with scrollTo=demo', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 4000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      String navigatedLocation = '';

      final testRouter = GoRouter(
        initialLocation: '/about',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              navigatedLocation = state.uri.toString();
              return const Scaffold(body: Text('Home Target Screen'));
            },
          ),
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      );

      await tester.pumpWidget(buildTestApp(homeWidget: const SizedBox(), router: testRouter));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final demoBtn = find.text('Watch Platform Demo');
      expect(demoBtn, findsOneWidget);

      await tester.tap(demoBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(navigatedLocation, equals('/?scrollTo=demo'));
      expect(find.text('Home Target Screen'), findsOneWidget);
    });
  });
}
