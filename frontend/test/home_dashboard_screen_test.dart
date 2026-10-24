import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/navigation/app_routes.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/screens/home_dashboard_screen.dart';
import 'package:frontend/state/auth_state.dart';
import 'package:frontend/widgets/in_hercue_topbar.dart';

class _FakeAuthenticatedStorageSession extends AuthState {
  final UserModel _mockUser;
  _FakeAuthenticatedStorageSession(this._mockUser);

  @override
  UserModel? get currentUser => _mockUser;

  @override
  bool get isAuthenticated => true;
}

void main() {
  Widget buildTestableDashboard({
    AuthState? authState,
    bool? isDemo,
    String? dateString = 'MONDAY, 26 MAY',
    void Function(String)? onNavigate,
  }) {
    return MaterialApp(
      home: HomeDashboardScreen(
        authState: authState,
        isDemo: isDemo,
        dateString: dateString,
        onNavigate: onNavigate,
      ),
      onGenerateRoute: (settings) {
        final routes = AppRoutes.getRoutes(authState);
        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }
        return null;
      },
    );
  }

  group('HomeDashboardScreen UI & Essential Content Tests', () {
    testWidgets('renders all Figma-specified dashboard sections and copy in demo mode', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableDashboard(isDemo: true));
      await tester.pumpAndSettle();

      // 1. Topbar elements
      expect(find.byType(InHercueTopbar), findsOneWidget);
      expect(find.text('Urgent help'), findsOneWidget);
      expect(find.text('2'), findsAtLeast(1)); // alerts count badge

      // 2. Demo banner
      expect(find.text('DEMO MODE • SAMPLE DATA ONLY • NO ACCOUNT LINKED'), findsOneWidget);

      // 3. Greeting
      expect(find.text('MONDAY, 26 MAY'), findsOneWidget);
      expect(find.textContaining('Maya.'), findsOneWidget);
      expect(find.text('How are you arriving today?'), findsOneWidget);
      expect(find.text('M'), findsOneWidget); // avatar initial

      // 4. Checkin Card
      expect(find.text("TODAY'S MOMENT"), findsOneWidget);
      expect(find.text('Five minutes for you.'), findsOneWidget);
      expect(find.text('Check in with your body, mind and daily experiences.'), findsOneWidget);
      expect(find.text('About 5 minutes • Skip any optional question'), findsOneWidget);
      expect(find.text("Start today's check-in →"), findsOneWidget);

      // 5. Section Heading 1
      expect(find.text('YOUR WELLBEING'), findsOneWidget);
      expect(find.text('Explore your health'), findsOneWidget);
      expect(find.text('Demo data'), findsOneWidget);

      // 6. Daily Actions
      expect(find.text('Symptom Tracker'), findsOneWidget);
      expect(find.text('Log or review symptoms'), findsOneWidget);
      expect(find.text('Period Tracker'), findsAtLeast(1));
      expect(find.text('Alerts'), findsOneWidget);

      // 7. Feature Grid (4 modules)
      expect(find.text('Physical Health'), findsOneWidget);
      expect(find.text('Track symptoms & energy'), findsOneWidget);
      expect(find.text('Mental Wellness'), findsOneWidget);
      expect(find.text('Mood, stress & reflection'), findsOneWidget);
      expect(find.text('Health Patterns'), findsOneWidget);
      expect(find.text('See trends across your wellbeing'), findsOneWidget);

      // 8. Botanical Wellness Note Card
      expect(find.text('WELLNESS NOTE'), findsOneWidget);
      expect(find.text("Your body isn't asking for perfection."), findsOneWidget);
      expect(
        find.text("It's asking to be heard. Explore gentle guidance for restorative sleep."),
        findsOneWidget,
      );
      expect(find.text("Read today's note →"), findsOneWidget);

      // 9. Section Heading 2 & Horizontal Resource Cards
      expect(find.text('JUST FOR YOU'), findsOneWidget);
      expect(find.text('Care for your whole self'), findsOneWidget);
      expect(find.text('Self-Care Studio'), findsOneWidget);
      expect(find.text('3-minute reset'), findsOneWidget);
      expect(find.text('Myth vs Fact'), findsOneWidget);
      expect(find.text('Find a Doctor'), findsOneWidget);
      expect(find.text('Health History'), findsOneWidget);
      expect(find.text('Health Reports'), findsOneWidget);
      expect(find.text('Health Passport'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);

      // 10. Urgent Medical Card
      expect(find.text('Need medical help right now?'), findsOneWidget);
      expect(find.text('Get urgent help'), findsOneWidget);

      // 11. Bottom Navigation
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Records'), findsOneWidget);
      expect(find.text('New entry'), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });
  });

  group('Authenticated vs Demo Presentation Tests', () {
    testWidgets('renders authenticated user banner, name, avatar, and active status', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockUser = UserModel(
        userId: 'usr-101',
        email: 'priya.sharma@example.com',
        name: 'Priya Sharma',
        onboardingCompleted: true,
      );
      final authState = _FakeAuthenticatedStorageSession(mockUser);

      await tester.pumpWidget(buildTestableDashboard(
        authState: authState,
        isDemo: false,
      ));
      await tester.pumpAndSettle();

      // Authenticated banner
      expect(find.text('PRIVATE SESSION • PRIYA.SHARMA@EXAMPLE.COM'), findsOneWidget);
      expect(find.text('DEMO MODE • SAMPLE DATA ONLY • NO ACCOUNT LINKED'), findsNothing);

      // Greeting should use authenticated first name
      expect(find.textContaining('Priya.'), findsOneWidget);
      expect(find.text('P'), findsOneWidget); // avatar initial

      // Heading badge should be Active record, not Demo data
      expect(find.text('Active record'), findsOneWidget);
      expect(find.text('Demo data'), findsNothing);

      // Period tracker should show generic/tracking label instead of hardcoded Maya sample day
      expect(find.text('Track your cycle & phases'), findsOneWidget);
    });
  });

  group('Responsive Layout Tests', () {
    testWidgets('renders cleanly at narrow 360px mobile viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestableDashboard(isDemo: true));
      await tester.pumpAndSettle();

      // Essential elements present
      expect(find.text('Five minutes for you.'), findsOneWidget);
      expect(find.text('Explore your health'), findsOneWidget);
      expect(find.text('Symptom Tracker'), findsOneWidget);
      expect(find.text('Physical Health'), findsOneWidget);
      expect(find.text('Self-Care Studio'), findsOneWidget);
      expect(find.text('Need medical help right now?'), findsOneWidget);

      // Verify no assertion / overflow errors occurred during render
      expect(tester.takeException(), isNull);
    });
  });

  group('Dashboard Navigation & Route Integration Tests', () {
    testWidgets('tapping daily checkin navigates to checkin route', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? navigatedRoute;
      await tester.pumpWidget(buildTestableDashboard(
        isDemo: true,
        onNavigate: (route) => navigatedRoute = route,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Five minutes for you.'));
      await tester.pump();

      expect(navigatedRoute, equals(AppRoutes.checkin));
    });

    testWidgets('tapping symptom tracker card navigates to symptoms route', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? navigatedRoute;
      await tester.pumpWidget(buildTestableDashboard(
        isDemo: true,
        onNavigate: (route) => navigatedRoute = route,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Symptom Tracker'));
      await tester.pump();

      expect(navigatedRoute, equals(AppRoutes.symptoms));
    });

    testWidgets('tapping alerts card navigates to alerts route', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? navigatedRoute;
      await tester.pumpWidget(buildTestableDashboard(
        isDemo: true,
        onNavigate: (route) => navigatedRoute = route,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alerts'));
      await tester.pump();

      expect(navigatedRoute, equals(AppRoutes.alerts));
    });

    testWidgets('tapping physical health module navigates to physical route', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? navigatedRoute;
      await tester.pumpWidget(buildTestableDashboard(
        isDemo: true,
        onNavigate: (route) => navigatedRoute = route,
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Physical Health'));
      await tester.tap(find.text('Physical Health'));
      await tester.pump();

      expect(navigatedRoute, equals(AppRoutes.physical));
    });

    testWidgets('tapping self-care studio card navigates to selfcare route', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? navigatedRoute;
      await tester.pumpWidget(buildTestableDashboard(
        isDemo: true,
        onNavigate: (route) => navigatedRoute = route,
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Self-Care Studio'));
      await tester.tap(find.text('Self-Care Studio'));
      await tester.pump();

      expect(navigatedRoute, equals(AppRoutes.selfcare));
    });

    testWidgets('tapping urgent medical button navigates to urgent route', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? navigatedRoute;
      await tester.pumpWidget(buildTestableDashboard(
        isDemo: true,
        onNavigate: (route) => navigatedRoute = route,
      ));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Get urgent help'));
      await tester.tap(find.text('Get urgent help'));
      await tester.pump();

      expect(navigatedRoute, equals(AppRoutes.urgent));
    });

    testWidgets('tapping bottom nav records and new entry triggers navigation', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? navigatedRoute;
      await tester.pumpWidget(buildTestableDashboard(
        isDemo: true,
        onNavigate: (route) => navigatedRoute = route,
      ));
      await tester.pumpAndSettle();

      // Tap Records
      await tester.tap(find.text('Records'));
      await tester.pump();
      expect(navigatedRoute, equals(AppRoutes.records));

      // Tap elevated New Entry
      await tester.tap(find.text('New entry'));
      await tester.pump();
      expect(navigatedRoute, equals(AppRoutes.entry));
    });
  });
}
