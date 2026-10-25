import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/navigation/app_routes.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/widgets/in_hercue_icon.dart';
import 'package:frontend/widgets/primary_button.dart';

void main() {
  Widget buildTestableWidget({
    VoidCallback? onBeginJourney,
    VoidCallback? onExploreDemo,
    VoidCallback? onUrgent,
    Size surfaceSize = const Size(390, 844),
  }) {
    return MediaQuery(
      data: MediaQueryData(size: surfaceSize),
      child: MaterialApp(
        routes: {
          AppRoutes.auth: (context) => const DestinationPlaceholderScreen(
            title: 'Authentication',
            routeName: AppRoutes.auth,
          ),
          AppRoutes.home: (context) => const DestinationPlaceholderScreen(
            title: 'Home Dashboard',
            routeName: AppRoutes.home,
          ),
          AppRoutes.urgent: (context) => const DestinationPlaceholderScreen(
            title: 'Urgent Help',
            routeName: AppRoutes.urgent,
          ),
        },
        home: WelcomeScreen(
          onBeginJourney: onBeginJourney,
          onExploreDemo: onExploreDemo,
          onUrgent: onUrgent,
        ),
      ),
    );
  }

  group('WelcomeScreen UI & Layout Tests', () {
    testWidgets('renders all Figma-specified copy and brand elements', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      // Kicker
      expect(find.text(AppStrings.welcomeKicker), findsOneWidget);

      // Headline
      expect(find.text(AppStrings.welcomeHeadline), findsOneWidget);

      // Subtitle
      expect(find.text(AppStrings.welcomeSubtitle), findsOneWidget);

      // Primary Button & Arrow
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.text(AppStrings.beginJourney), findsOneWidget);
      expect(find.text('→'), findsOneWidget);

      // Text button
      expect(find.text(AppStrings.exploreDemo), findsOneWidget);

      // Safety tagline
      expect(find.text(AppStrings.safetyTagline), findsOneWidget);

      // Urgent help CTA
      expect(find.text(AppStrings.urgentHelp), findsOneWidget);

      // Logo mark with heart icon
      expect(find.byType(InHercueIcon), findsOneWidget);
      final iconFinder = find.byWidgetPredicate(
        (widget) =>
            widget is InHercueIcon && widget.icon == InHercueIconType.heart,
      );
      expect(iconFinder, findsOneWidget);

      // Background decorative botanicals
      expect(find.text('✦'), findsOneWidget);
      expect(find.text('☾'), findsOneWidget);
    });

    testWidgets('respects 470px max-width container on wide screens', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(surfaceSize: const Size(1200, 800)),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      final has470Constraint = constrainedBoxes.any(
        (box) => box.constraints.maxWidth == 470.0,
      );
      expect(has470Constraint, isTrue);
    });

    testWidgets('scrolls smoothly on compact screens without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(surfaceSize: const Size(320, 568)),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text(AppStrings.welcomeHeadline), findsOneWidget);
    });
  });

  group('WelcomeScreen Interaction & Callback Tests', () {
    testWidgets(
      'triggers onBeginJourney callback when primary button is tapped',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          buildTestableWidget(onBeginJourney: () => tapped = true),
        );

        await tester.tap(find.text(AppStrings.beginJourney));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'triggers onExploreDemo callback when demo text button is tapped',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          buildTestableWidget(onExploreDemo: () => tapped = true),
        );

        await tester.tap(find.text(AppStrings.exploreDemo));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      },
    );

    testWidgets('triggers onUrgent callback when urgent help link is tapped', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(onUrgent: () => tapped = true),
      );

      await tester.tap(find.text(AppStrings.urgentHelp));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('WelcomeScreen Default Route Navigation Tests', () {
    testWidgets('navigates to /auth when onBeginJourney is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text(AppStrings.beginJourney));
      await tester.pumpAndSettle();

      // Destination placeholder for /auth should now be displayed
      expect(find.text('Authentication'), findsAtLeast(1));
      expect(find.textContaining('/auth'), findsOneWidget);
    });

    testWidgets('navigates to /home when onExploreDemo is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text(AppStrings.exploreDemo));
      await tester.pumpAndSettle();

      // Destination placeholder for /home should now be displayed
      expect(find.text('Home Dashboard'), findsAtLeast(1));
      expect(find.textContaining('/home'), findsOneWidget);
    });

    testWidgets('navigates to /urgent when onUrgent is null', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text(AppStrings.urgentHelp));
      await tester.pumpAndSettle();

      // Destination placeholder for /urgent should now be displayed
      expect(find.text('Urgent Help'), findsAtLeast(1));
      expect(find.textContaining('/urgent'), findsOneWidget);
    });

    testWidgets(
      'AppRoutes.routes maps / to WelcomeScreen when using initialRoute',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            initialRoute: AppRoutes.welcome,
            routes: AppRoutes.routes,
          ),
        );

        expect(find.byType(WelcomeScreen), findsOneWidget);
        expect(find.text(AppStrings.welcomeHeadline), findsOneWidget);
      },
    );
  });

  group('WelcomeScreen Accessibility Tests', () {
    testWidgets(
      'satisfies 44px minimum touch target for urgent help and text button',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final urgentFinder = find.ancestor(
          of: find.text(AppStrings.urgentHelp),
          matching: find.byType(ConstrainedBox),
        );
        expect(urgentFinder, findsWidgets);
        final urgentBox = tester.widget<ConstrainedBox>(urgentFinder.first);
        expect(urgentBox.constraints.minHeight, greaterThanOrEqualTo(44.0));
        expect(urgentBox.constraints.minWidth, greaterThanOrEqualTo(44.0));

        final demoFinder = find.ancestor(
          of: find.text(AppStrings.exploreDemo),
          matching: find.byType(ConstrainedBox),
        );
        expect(demoFinder, findsWidgets);
        final demoBox = tester.widget<ConstrainedBox>(demoFinder.first);
        expect(demoBox.constraints.minHeight, greaterThanOrEqualTo(44.0));
        expect(demoBox.constraints.minWidth, greaterThanOrEqualTo(44.0));
      },
    );
  });
}
