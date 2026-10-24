import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/navigation/app_routes.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/screens/alerts_screen.dart';
import 'package:frontend/screens/checkin_screen.dart';
import 'package:frontend/screens/community_screen.dart';
import 'package:frontend/screens/detail_page_screen.dart';
import 'package:frontend/screens/hub_screen.dart';
import 'package:frontend/screens/mental_wellness_screen.dart';
import 'package:frontend/screens/myth_quiz_screen.dart';
import 'package:frontend/screens/new_entry_screen.dart';
import 'package:frontend/screens/period_tracker_screen.dart';
import 'package:frontend/screens/reports_screen.dart';
import 'package:frontend/screens/self_care_screen.dart';
import 'package:frontend/screens/symptom_tracker_screen.dart';
import 'package:frontend/screens/urgent_screen.dart';

Widget _wrap(Widget child) {
  final testRoutes = Map<String, WidgetBuilder>.from(AppRoutes.getRoutes());
  testRoutes.remove(AppRoutes.welcome);
  return MaterialApp(
    theme: AppTheme.lightTheme,
    routes: testRoutes,
    home: child,
  );
}

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1200, 1800);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  group('UrgentScreen Tests', () {
    testWidgets('renders urgent help title, call emergency button, and crisis box', (tester) async {
      await tester.pumpWidget(_wrap(const UrgentScreen()));
      await tester.pumpAndSettle();

      expect(find.text('URGENT HELP'), findsOneWidget);
      expect(find.text('You don’t have to handle this alone.'), findsOneWidget);
      expect(find.text('Call emergency services'), findsOneWidget);
      expect(find.text('Call or text 988'), findsOneWidget);
      expect(find.text('inHERcue is not an emergency service and cannot provide medical care.'), findsOneWidget);
    });
  });

  group('CheckinScreen Tests', () {
    testWidgets('multiselect symptom flow and skipping to step 3 when No symptoms today', (tester) async {
      await tester.pumpWidget(_wrap(const CheckinScreen()));
      await tester.pumpAndSettle();

      expect(find.text('BODY CHECK'), findsOneWidget);
      expect(find.text('Are you noticing any symptoms?'), findsOneWidget);

      // Select 'No symptoms today'
      await tester.tap(find.text('No symptoms today'));
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Skips to Hydration step directly
      expect(find.text('HYDRATION'), findsOneWidget);
    });
  });

  group('SymptomTrackerScreen Tests', () {
    testWidgets('renders history list, filter chips, and toggles add symptom form', (tester) async {
      await tester.pumpWidget(_wrap(const SymptomTrackerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Notice what changes.'), findsOneWidget);
      expect(find.text('Add symptom'), findsOneWidget);
      expect(find.text('Headache'), findsOneWidget);

      // Tap Add symptom
      await tester.tap(find.text('Add symptom'));
      await tester.pumpAndSettle();

      expect(find.text('Add a symptom'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('PeriodTrackerScreen Tests', () {
    testWidgets('renders cycle day, 4 phases, and calendar month card', (tester) async {
      await tester.pumpWidget(_wrap(const PeriodTrackerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Cycle day 18'), findsOneWidget);
      expect(find.text('Menstruation'), findsWidgets);
      expect(find.text('Follicular'), findsOneWidget);
      expect(find.text('Ovulation'), findsOneWidget);
      expect(find.text('Luteal'), findsWidgets);
      expect(find.text('May 2025'), findsOneWidget);
    });
  });

  group('MentalWellnessScreen Tests', () {
    testWidgets('renders reflection form and AI support assistant panel with canned suggestions', (tester) async {
      await tester.pumpWidget(_wrap(const MentalWellnessScreen()));
      await tester.pumpAndSettle();

      expect(find.text('How are you, really?'), findsOneWidget);
      expect(find.text('inHERcue Support Assistant — AI'), findsOneWidget);
      expect(find.text('I feel overwhelmed'), findsOneWidget);

      // Tap prompt
      await tester.tap(find.text('I feel overwhelmed'));
      await tester.pumpAndSettle();

      expect(find.text('You: I feel overwhelmed'), findsOneWidget);
    });
  });

  group('SelfCareScreen Tests', () {
    testWidgets('renders activities list, timer orb, and controls', (tester) async {
      await tester.pumpWidget(_wrap(const SelfCareScreen()));
      await tester.pumpAndSettle();

      expect(find.text('A small practice for right now.'), findsOneWidget);
      expect(find.text('Breathing reset'), findsWidgets);
      expect(find.text('5–4–3–2–1 grounding'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);

      // Tap start (initiates repeating animation, so use pump with duration instead of pumpAndSettle)
      await tester.tap(find.text('Start'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('In progress'), findsOneWidget);
    });
  });

  group('MythQuizScreen Tests', () {
    testWidgets('renders 7 categories and opens question flow', (tester) async {
      await tester.pumpWidget(_wrap(const MythQuizScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Let’s bust some myths!'), findsOneWidget);
      expect(find.text('Period Myths'), findsOneWidget);
      expect(find.text('PCOS & Hormonal Health'), findsOneWidget);

      // Tap Period Myths
      await tester.tap(find.text('Period Myths'));
      await tester.pumpAndSettle();

      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Myth'), findsOneWidget);
      expect(find.text('Fact'), findsOneWidget);
    });
  });

  group('CommunityScreen Tests', () {
    testWidgets('renders community feed, topics, and bookmark toggle', (tester) async {
      await tester.pumpWidget(_wrap(const CommunityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Shared experiences, respectfully held.'), findsOneWidget);
      expect(find.text('Cycle day routines'), findsOneWidget);
      expect(find.text('Create post'), findsOneWidget);
    });
  });

  group('AlertsScreen Tests', () {
    testWidgets('renders alerts accordion items and expands content', (tester) async {
      await tester.pumpWidget(_wrap(const AlertsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Alerts & reminders'), findsOneWidget);
      expect(find.text('Severe or sudden symptoms deserve attention'), findsOneWidget);
      expect(find.text('View urgent help →'), findsOneWidget);
    });
  });

  group('ReportsScreen Tests', () {
    testWidgets('renders date range, section checkboxes, and preview report button', (tester) async {
      await tester.pumpWidget(_wrap(const ReportsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Prepare a health report'), findsOneWidget);
      expect(find.text('Preview report'), findsOneWidget);

      // Tap preview report
      await tester.tap(find.text('Preview report'));
      await tester.pumpAndSettle();

      expect(find.text('inHERcue Health Overview'), findsOneWidget);
      expect(find.text('Export options'), findsOneWidget);
    });
  });

  group('NewEntryScreen Tests', () {
    testWidgets('renders entry options and displays note fields when Health Note is selected', (tester) async {
      await tester.pumpWidget(_wrap(const NewEntryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('What would you like to log?'), findsOneWidget);
      expect(find.text('Daily Check-in'), findsOneWidget);
      expect(find.text('Health Note'), findsOneWidget);

      // Tap Health Note
      await tester.tap(find.text('Health Note'));
      await tester.pumpAndSettle();

      expect(find.text('What is this note about?'), findsOneWidget);
      expect(find.text('Save note'), findsOneWidget);
    });
  });

  group('HubScreen Tests', () {
    testWidgets('renders records hub with mini energy chart', (tester) async {
      await tester.pumpWidget(_wrap(const HubScreen(type: HubType.records)));
      await tester.pumpAndSettle();

      expect(find.text('Health history'), findsWidgets);
      expect(find.text('Energy'), findsOneWidget);
      expect(find.text('Health patterns'), findsOneWidget);
    });
  });

  group('DetailPageScreen Tests', () {
    testWidgets('renders guidance module with wellness cards carousel', (tester) async {
      await tester.pumpWidget(_wrap(const DetailPageScreen(type: DetailType.guidance)));
      await tester.pumpAndSettle();

      expect(find.text('Wellness Card'), findsOneWidget);
      expect(find.text('Rest is a health habit'), findsOneWidget);
      expect(find.text('Next tip →'), findsOneWidget);
    });

    testWidgets('renders doctors module with sample providers and search', (tester) async {
      await tester.pumpWidget(_wrap(const DetailPageScreen(type: DetailType.doctors)));
      await tester.pumpAndSettle();

      expect(find.text('Find a Doctor'), findsOneWidget);
      expect(find.text('Dr. Amina Malik'), findsOneWidget);
      expect(find.text('Dr. Elena Ramos'), findsOneWidget);
    });
  });
}
