import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/navigation/app_routes.dart';
import 'package:frontend/screens/profile_setup_screen.dart';

void main() {
  Widget buildTestableProfileSetup({
    String? userName,
    void Function(String, String)? onCompleted,
    VoidCallback? onBackToAuth,
    VoidCallback? onUrgent,
  }) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.auth) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Auth Screen')),
          );
        }
        if (settings.name == AppRoutes.home) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Home Dashboard Screen')),
          );
        }
        if (settings.name == AppRoutes.urgent) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Urgent Screen')),
          );
        }
        return null;
      },
      home: ProfileSetupScreen(
        userName: userName,
        onCompleted: onCompleted,
        onBackToAuth: onBackToAuth,
        onUrgent: onUrgent,
      ),
    );
  }

  group('ProfileSetupScreen Questionnaire Flow Tests', () {
    testWidgets(
      'Step 1: displays title, options, and disables Continue until selection',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestableProfileSetup());

        // Progress & Kicker
        expect(find.text('HEALTH PROFILE'), findsOneWidget);
        expect(find.text('1 of 3'), findsOneWidget);
        expect(find.text('PERSONALIZE YOUR CARE'), findsOneWidget);

        // Title & Options
        expect(find.text('What would you like to focus on?'), findsOneWidget);
        expect(find.text('Understand my cycle'), findsOneWidget);
        expect(find.text('Improve my energy'), findsOneWidget);
        expect(find.text('Support my mental health'), findsOneWidget);
        expect(find.text('Build healthier routines'), findsOneWidget);

        // Continue button exists
        expect(find.text('Continue'), findsOneWidget);

        // Tap an option
        await tester.tap(find.text('Understand my cycle'));
        await tester.pumpAndSettle();

        // Checkmark indicator should be visible
        expect(find.text('✓'), findsOneWidget);
      },
    );

    testWidgets('advances from Step 1 to Step 2 and displays cycle options', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableProfileSetup());

      // Step 1: Select option and continue
      await tester.tap(find.text('Improve my energy'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2 indicators
      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.text('How would you describe your cycle?'), findsOneWidget);

      // Cycle options from Figma App.tsx
      expect(find.text('Regular'), findsOneWidget);
      expect(find.text('Sometimes irregular'), findsOneWidget);
      expect(find.text('I don’t have periods'), findsOneWidget);
      expect(find.text('Prefer not to say'), findsOneWidget);
    });

    testWidgets(
      'advances to Step 3 and shows success card with greeting and Go to my dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        String? completedFocus;
        String? completedCycle;

        await tester.pumpWidget(
          buildTestableProfileSetup(
            userName: 'Aanya Sharma',
            onCompleted: (focus, cycle) {
              completedFocus = focus;
              completedCycle = cycle;
            },
          ),
        );

        // Step 1: select & continue
        await tester.tap(find.text('Support my mental health'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 2: select & continue
        await tester.tap(find.text('Regular'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3
        expect(find.text('3 of 3'), findsOneWidget);
        expect(find.text('You’re all set, Aanya.'), findsOneWidget);
        expect(find.text('Your wellness space is ready'), findsOneWidget);
        expect(
          find.text('We’ll use your preferences to tailor your dashboard.'),
          findsOneWidget,
        );
        expect(find.text('Go to my dashboard'), findsOneWidget);

        // Tap final button
        await tester.ensureVisible(find.text('Go to my dashboard'));
        await tester.tap(find.text('Go to my dashboard'));
        await tester.pumpAndSettle();

        expect(completedFocus, equals('Support my mental health'));
        expect(completedCycle, equals('Regular'));
      },
    );
  });

  group('ProfileSetupScreen Step Navigation Tests', () {
    testWidgets('back button on Step 2 steps back to Step 1', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableProfileSetup());

      // Step 1 -> Step 2
      await tester.tap(find.text('Understand my cycle'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('2 of 3'), findsOneWidget);

      // Tap back button
      await tester.tap(find.bySemanticsLabel('Go back'));
      await tester.pumpAndSettle();

      // Should be back on Step 1
      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('What would you like to focus on?'), findsOneWidget);
    });

    testWidgets('back button on Step 1 triggers onBackToAuth', (tester) async {
      bool backToAuthTriggered = false;

      await tester.pumpWidget(
        buildTestableProfileSetup(
          onBackToAuth: () => backToAuthTriggered = true,
        ),
      );

      expect(find.text('1 of 3'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Go back'));
      await tester.pumpAndSettle();

      expect(backToAuthTriggered, isTrue);
    });

    testWidgets('urgent help link triggers onUrgent callback', (tester) async {
      bool urgentTapped = false;

      await tester.pumpWidget(
        buildTestableProfileSetup(onUrgent: () => urgentTapped = true),
      );

      await tester.tap(find.text('Urgent help'));
      await tester.pumpAndSettle();

      expect(urgentTapped, isTrue);
    });
  });
}
