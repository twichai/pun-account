import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/animations/grid_wave_animation.dart';

void main() {
  group('GridWaveMotion Specifications', () {
    test('Matches Klik-anim Motion Atlas spec', () {
      expect(GridWaveMotion.defaultDuration, const Duration(milliseconds: 900));
      expect(GridWaveMotion.curve, const Cubic(0.33, 1.0, 0.68, 1.0));
      expect(GridWaveMotion.stepDelay, const Duration(milliseconds: 55));
      expect(GridWaveMotion.defaultStartY, 18.0);
      expect(GridWaveMotion.defaultStartScale, 0.78);
    });

    test('Diagonal wavefront delay calculation (row + col) * 55ms', () {
      // Top-left item (0, 0)
      expect(GridWaveMotion.delayFor(0, 0), Duration.zero);

      // 1st diagonal wave: (0, 1) and (1, 0)
      expect(
        GridWaveMotion.delayFor(0, 1),
        const Duration(milliseconds: 55),
      );
      expect(
        GridWaveMotion.delayFor(1, 0),
        const Duration(milliseconds: 55),
      );

      // 2nd diagonal wave: (0, 2) and (1, 1) and (2, 0)
      expect(
        GridWaveMotion.delayFor(0, 2),
        const Duration(milliseconds: 110),
      );
      expect(
        GridWaveMotion.delayFor(1, 1),
        const Duration(milliseconds: 110),
      );
      expect(
        GridWaveMotion.delayFor(2, 0),
        const Duration(milliseconds: 110),
      );

      // Bottom-right item for 2x3 grid: (1, 2)
      expect(
        GridWaveMotion.delayFor(1, 2),
        const Duration(milliseconds: 165),
      );
    });

    test('easeOutCubic progression curve characteristics', () {
      // Smooth deceleration curve
      final p0 = GridWaveMotion.curve.transform(0.0);
      final p025 = GridWaveMotion.curve.transform(0.25);
      final p05 = GridWaveMotion.curve.transform(0.5);
      final p1 = GridWaveMotion.curve.transform(1.0);

      expect(p0, 0.0);
      expect(p025, greaterThan(0.5)); // Rapid early movement
      expect(p05, greaterThan(0.8)); // Soft deceleration in second half
      expect(p1, 1.0);
    });
  });

  group('GridWaveAnimation Widget Tests', () {
    testWidgets('Renders child and executes animation through completion', (
      tester,
    ) async {
      bool completed = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GridWaveAnimation.indexed(
            index: 0,
            crossAxisCount: 3,
            onCompleted: () => completed = true,
            child: const Text('OpenAI'),
          ),
        ),
      );

      expect(find.text('OpenAI'), findsOneWidget);
      expect(completed, isFalse);

      await tester.pump(const Duration(milliseconds: 450));
      expect(completed, isFalse);

      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });

    testWidgets(
      'Diagonal delay staggers items appropriately for (row 1, col 2)',
      (tester) async {
        bool completed = false;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GridWaveAnimation.indexed(
              index: 5, // row 1, col 2 -> delay = 3 * 55ms = 165ms
              crossAxisCount: 3,
              onCompleted: () => completed = true,
              child: const Text('GitHub'),
            ),
          ),
        );

        // Before 165ms delay finishes, item is waiting
        await tester.pump(const Duration(milliseconds: 100));
        expect(completed, isFalse);

        // Fast forward through the rest of 165ms + 900ms
        await tester.pumpAndSettle();
        expect(completed, isTrue);
      },
    );

    testWidgets('Respects reduced motion by skipping movement and delay', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: GridWaveAnimation.indexed(
              index: 4,
              child: const Text('Accessible Item'),
            ),
          ),
        ),
      );

      expect(find.text('Accessible Item'), findsOneWidget);
      // No AnimatedBuilder or Transform should wrap it under reduced motion
      expect(find.byType(Transform), findsNothing);
    });
  });
}
