import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:frontend/widgets/secondary_button.dart';
import 'package:frontend/widgets/urgent_card.dart';

void main() {
  Widget wrapWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('PrimaryButton Widget Tests', () {
    testWidgets('renders label and triggers onPressed callback', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWidget(
          PrimaryButton(label: 'Continue', onPressed: () => tapped = true),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('→'), findsNothing);

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows arrow when showArrow is true', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          PrimaryButton(
            label: 'Begin your journey',
            showArrow: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Begin your journey'), findsOneWidget);
      expect(find.text('→'), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const PrimaryButton(label: 'Submit', onPressed: null)),
      );

      expect(find.text('Submit'), findsOneWidget);
      // Tapping should not crash or trigger anything
      await tester.tap(find.text('Submit'));
      await tester.pump();
    });

    testWidgets('displays CircularProgressIndicator when isLoading is true', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWidget(
          PrimaryButton(
            label: 'Saving',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving'), findsNothing);

      // Tap during loading does not invoke callback
      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('satisfies min-height 54px touch target constraint', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWidget(PrimaryButton(label: 'Action', onPressed: () {})),
      );

      final buttonFinder = find.byType(PrimaryButton);
      final size = tester.getSize(buttonFinder);
      expect(size.height, greaterThanOrEqualTo(54.0));
    });
  });

  group('SecondaryButton Widget Tests', () {
    testWidgets('renders label, outline border, and invokes callback', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWidget(
          SecondaryButton(label: 'Cancel', onPressed: () => tapped = true),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const SecondaryButton(label: 'Disabled', onPressed: null)),
      );

      expect(find.text('Disabled'), findsOneWidget);
      await tester.tap(find.text('Disabled'));
      await tester.pump();
    });

    testWidgets('satisfies min-height 54px constraint', (tester) async {
      await tester.pumpWidget(
        wrapWidget(SecondaryButton(label: 'Back', onPressed: () {})),
      );

      final size = tester.getSize(find.byType(SecondaryButton));
      expect(size.height, greaterThanOrEqualTo(54.0));
    });
  });

  group('UrgentCard Widget Tests', () {
    testWidgets('renders title, description, and triggers onUrgent callback', (
      tester,
    ) async {
      bool urgentTapped = false;

      await tester.pumpWidget(
        wrapWidget(UrgentCard(onUrgent: () => urgentTapped = true)),
      );

      expect(find.text('Need medical help right now?'), findsOneWidget);
      expect(
        find.text(
          'Do not wait for your next check-in if symptoms are severe or alarming.',
        ),
        findsOneWidget,
      );
      expect(find.text('Get urgent help'), findsOneWidget);

      await tester.tap(find.text('Get urgent help'));
      await tester.pump();

      expect(urgentTapped, isTrue);
    });

    testWidgets('adapts responsively on narrow screens', (tester) async {
      // Set tester surface size to narrow mobile width
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrapWidget(UrgentCard(onUrgent: () {})));

      expect(find.text('Get urgent help'), findsOneWidget);
      final cardSize = tester.getSize(find.byType(UrgentCard));
      expect(cardSize.width, equals(360.0));
    });
  });
}
