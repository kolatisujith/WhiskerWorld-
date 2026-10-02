import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/widgets/animations/floating_widget.dart';
import 'package:whisker_world/widgets/animations/hover_card.dart';
import 'package:whisker_world/widgets/animations/scroll_fade_slide.dart';
import 'package:whisker_world/widgets/home/demo_video_showcase.dart';

void main() {
  group('Animations Component Tests', () {
    testWidgets('FloatingWidget renders child and animates sine wave', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingWidget(
              verticalDistance: 12,
              child: Text('Floating Badge'),
            ),
          ),
        ),
      );

      expect(find.text('Floating Badge'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Floating Badge'), findsOneWidget);
    });

    testWidgets('ScrollFadeSlide renders and transitions child smoothly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScrollFadeSlide(
              duration: Duration(milliseconds: 300),
              child: Text('Sliding In Content'),
            ),
          ),
        ),
      );

      expect(find.text('Sliding In Content'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Sliding In Content'), findsOneWidget);
    });

    testWidgets('HoverCard renders child and triggers onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HoverCard(
              onTap: () => tapped = true,
              child: const Text('Hover Me'),
            ),
          ),
        ),
      );

      expect(find.text('Hover Me'), findsOneWidget);
      await tester.tap(find.text('Hover Me'));
      expect(tapped, isTrue);
    });
  });

  group('DemoVideoShowcase Interactive Tests', () {
    testWidgets('Renders video controls, timecode, resolution badge and scenes', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DemoVideoShowcase(),
            ),
          ),
        ),
      );

      // Verify header and status
      expect(find.text('WHISKERWORLD PRODUCT WALKTHROUGH'), findsOneWidget);
      expect(find.text('SCENE 1/4'), findsOneWidget);
      expect(find.text('4K UHD'), findsOneWidget);

      // Verify initial chapter title
      expect(find.text('Smart Companion Discovery'), findsOneWidget);
      expect(find.text('Pediatric Health & Verified Listings'), findsOneWidget);

      // Verify initial timecode
      expect(find.text('0:00 / 01:20'), findsOneWidget);

      // Verify chapter tabs
      expect(find.text('1. Discovery'), findsOneWidget);
      expect(find.text('2. Interactive Map'), findsOneWidget);
      expect(find.text('3. Application & Chat'), findsOneWidget);
      expect(find.text('4. Vet Passport'), findsOneWidget);
    });

    testWidgets('Tapping chapter tab jumps directly to that scene', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DemoVideoShowcase(),
            ),
          ),
        ),
      );

      // Tap on chapter 2 (Interactive Map)
      await tester.tap(find.text('2. Interactive Map'));
      await tester.pump(const Duration(milliseconds: 400));

      // Verify scene 2 is active
      expect(find.text('SCENE 2/4'), findsOneWidget);
      expect(find.text('Live Interactive Pet Map'), findsOneWidget);
      expect(find.text('Geolocate Stores, Owners & Chosen Pet'), findsOneWidget);
      expect(find.text('Active Route: Tracking Bruno (Puppy) -> Whisker Haven Sanctuary (1.4 mi)'), findsOneWidget);

      // Tap on chapter 4 (Vet Passport)
      await tester.tap(find.text('4. Vet Passport'));
      await tester.pump(const Duration(milliseconds: 400));

      // Verify scene 4 is active
      expect(find.text('SCENE 4/4'), findsOneWidget);
      expect(find.text('Certified Vet Passport & Homecoming'), findsOneWidget);
      expect(find.text('Official WhiskerWorld Adoption Passport #WW-89241'), findsOneWidget);
    });

    testWidgets('Play button toggles playback state', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DemoVideoShowcase(),
            ),
          ),
        ),
      );

      // Tap the center play button
      final playIcon = find.byIcon(Icons.play_arrow_rounded);
      expect(playIcon, findsWidgets);

      await tester.tap(playIcon.first);
      await tester.pump(const Duration(milliseconds: 500));

      // Pause button should now exist
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });
  });
}
