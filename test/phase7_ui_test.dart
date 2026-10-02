import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisker_world/app/theme.dart';
import 'package:whisker_world/models/enums.dart';
import 'package:whisker_world/models/pet_model.dart';
import 'package:whisker_world/providers/theme_provider.dart';
import 'package:whisker_world/widgets/dashboard_stat_card.dart';
import 'package:whisker_world/widgets/empty_state.dart';
import 'package:whisker_world/widgets/pet_card.dart';
import 'package:whisker_world/widgets/status_badge.dart';
import 'package:whisker_world/widgets/whisker_search_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 7: Theming & Dark Mode Tests', () {
    test('AppTheme defines consistent Light and Dark Palette tokens', () {
      expect(AppTheme.primaryCoral, equals(const Color(0xFFFF6B4A)));
      expect(AppTheme.warmCream, equals(const Color(0xFFFAF7F2)));
      expect(AppTheme.charcoal, equals(const Color(0xFF22252A)));
      expect(AppTheme.darkBackground, equals(const Color(0xFF141619)));
      expect(AppTheme.darkCardBg, equals(const Color(0xFF242830)));
    });

    test('ThemeProvider toggles between Light and Dark mode', () async {
      final themeProvider = ThemeProvider();
      expect(themeProvider.themeMode, equals(ThemeMode.light));
      expect(themeProvider.isDarkMode, isFalse);

      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(themeProvider.isDarkMode, isTrue);

      await themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.light));
      expect(themeProvider.isDarkMode, isFalse);
    });
  });

  group('Phase 7: Design System Components Widget Tests', () {
    testWidgets('StatusBadge renders for PetAvailabilityStatus and AdoptionRequestStatus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge.forPet(PetAvailabilityStatus.available),
                StatusBadge.forPet(PetAvailabilityStatus.pending),
                StatusBadge.forPet(PetAvailabilityStatus.adopted),
                StatusBadge.forRequest(AdoptionRequestStatus.pending),
                StatusBadge.forRequest(AdoptionRequestStatus.approved),
                StatusBadge.forRequest(AdoptionRequestStatus.completed),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Pending Adoption'), findsOneWidget);
      expect(find.text('Adopted'), findsOneWidget);
      expect(find.text('Pending Review'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Finalized / Adopted'), findsOneWidget);
    });

    testWidgets('DashboardStatCard renders title, value, icon, and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardStatCard(
              title: 'Saved Companions',
              value: '12',
              icon: Icons.favorite_rounded,
              iconColor: Colors.pink,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Saved Companions'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      await tester.tap(find.byType(DashboardStatCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('EmptyState renders custom title, description, and action button', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'No Companions',
              description: 'Try adjusting filters to see more results.',
              emoji: '🐾',
              actionLabel: 'Reset Criteria',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('No Companions'), findsOneWidget);
      expect(find.text('Try adjusting filters to see more results.'), findsOneWidget);
      expect(find.text('🐾'), findsOneWidget);
      expect(find.text('Reset Criteria'), findsOneWidget);

      await tester.tap(find.text('Reset Criteria'));
      await tester.pump();
      expect(actionTriggered, isTrue);
    });

    testWidgets('WhiskerSearchBar triggers submit callback and clears input', (tester) async {
      final controller = TextEditingController(text: 'Kitten');
      String submittedVal = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WhiskerSearchBar(
              controller: controller,
              onSubmitted: (val) => submittedVal = val,
            ),
          ),
        ),
      );

      expect(find.text('Kitten'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap clear icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(controller.text, isEmpty);

      await tester.enterText(find.byType(TextField), 'Puppy');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submittedVal, equals('Puppy'));
    });

    testWidgets('PetCard renders formatted age, breed tagline, and formatted fee', (tester) async {
      final now = DateTime.now();
      final pet = PetModel(
        id: 'test_luna',
        name: 'Luna',
        animalType: AnimalType.cat,
        breed: 'Persian',
        ageValue: 7,
        ageUnit: AgeUnit.weeks,
        lifeStage: LifeStage.baby,
        youngAnimalName: 'Kitten',
        gender: Gender.female,
        description: 'Gentle docile kitten.',
        personality: 'Cuddly',
        color: 'White',
        size: 'Small',
        weight: 1.2,
        healthInformation: 'Healthy',
        vaccinationStatus: 'Vaccinated',
        dewormingStatus: 'Dewormed',
        veterinaryCheck: 'Checked',
        isNeutered: false,
        adoptionFee: 8000.0,
        location: 'Hyderabad',
        availabilityStatus: PetAvailabilityStatus.available,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetCard(
              pet: pet,
              isFavorite: false,
            ),
          ),
        ),
      );

      // Verify name, breed, young animal, clear age, location, and formatted fee (₹8,000)
      expect(find.text('Luna'), findsOneWidget);
      expect(find.text('Persian'), findsOneWidget);
      expect(find.text('Kitten'), findsOneWidget);
      expect(find.text('7 weeks old'), findsOneWidget);
      expect(find.text('Hyderabad'), findsOneWidget);
      expect(find.text('₹8,000'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
    });
  });
}
