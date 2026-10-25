import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/main.dart';
import 'package:frontend/state/auth_state.dart';

void main() {
  testWidgets('InHercueApp root app launch and Welcome-to-Auth smoke test', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Create isolated AuthState so no real network requests are attempted during smoke test
    final authState = AuthState();

    // Build the root application
    await tester.pumpWidget(InHercueApp(authState: authState));
    await tester.pumpAndSettle();

    // 1. Initial screen should be WelcomeScreen
    expect(find.text(AppStrings.welcomeKicker), findsOneWidget);
    expect(find.text(AppStrings.welcomeHeadline), findsOneWidget);
    expect(find.text(AppStrings.beginJourney), findsOneWidget);
    expect(find.text(AppStrings.exploreDemo), findsOneWidget);

    // 2. Tap "Begin your journey" -> navigates to AuthScreen
    await tester.tap(find.text(AppStrings.beginJourney));
    await tester.pumpAndSettle();

    // AuthScreen should now be visible
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);

    // 3. Tap back arrow -> returns to WelcomeScreen
    await tester.tap(find.bySemanticsLabel('Go back'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.welcomeHeadline), findsOneWidget);

    // 4. Tap "Explore with demo data" -> navigates to Demo Home
    await tester.ensureVisible(find.text(AppStrings.exploreDemo));
    await tester.tap(find.text(AppStrings.exploreDemo));
    await tester.pumpAndSettle();

    expect(
      find.text('DEMO MODE • SAMPLE DATA ONLY • NO ACCOUNT LINKED'),
      findsOneWidget,
    );
    expect(find.text('Good morning, Maya.'), findsOneWidget);
    expect(find.text('Five minutes for you.'), findsOneWidget);
  });
}
