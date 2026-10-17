import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/animations/whip_animation.dart';

void main() {
  group('WhipMotion Specifications', () {
    test('Curve and duration match klik-anim Motion Atlas spec', () {
      expect(WhipMotion.defaultDuration, const Duration(milliseconds: 500));
      expect(WhipMotion.curve, const Cubic(0.9, 0.0, 0.1, 1.0));
      expect(
        WhipMotion.reducedMotionDuration,
        const Duration(milliseconds: 250),
      );
    });

    test('Whip curve produces near-vertical velocity peak in the middle', () {
      // At t = 0.2, progress should be very small
      final p02 = WhipMotion.curve.transform(0.2);
      expect(p02, lessThan(0.05));

      // At t = 0.8, progress should be nearly finished
      final p08 = WhipMotion.curve.transform(0.8);
      expect(p08, greaterThan(0.95));

      // The middle delta (from 0.3 to 0.7) should cover > 85% of total movement
      final p03 = WhipMotion.curve.transform(0.3);
      final p07 = WhipMotion.curve.transform(0.7);
      expect(p07 - p03, greaterThan(0.85));
    });
  });

  group('WhipAnimation Widget Tests', () {
    testWidgets('Renders child and completes 500ms animation', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WhipAnimation(
            onCompleted: () => completed = true,
            child: const Text('Cards'),
          ),
        ),
      );

      expect(find.text('Cards'), findsOneWidget);
      expect(completed, isFalse);

      // Fast-forward animation to settle
      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });

    testWidgets('Respects reduced motion by skipping smear and translating', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: WhipAnimation(child: Text('Reduced Motion')),
          ),
        ),
      );

      expect(find.text('Reduced Motion'), findsOneWidget);
      // No ImageFiltered widget should be rendered under reduced motion
      expect(find.byType(ImageFiltered), findsNothing);
    });
  });
}
