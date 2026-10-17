import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/animations/fade_in_animation.dart';

void main() {
  group('FadeInAnimation Widget Tests', () {
    testWidgets('Renders child and smoothly fades in', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FadeInAnimation(child: Text('Cards')),
        ),
      );

      expect(find.text('Cards'), findsOneWidget);

      // Fast-forward animation to settle
      await tester.pumpAndSettle();
      expect(find.text('Cards'), findsOneWidget);
    });

    testWidgets('Smoothly fades out when trigger becomes false', (
      tester,
    ) async {
      bool active = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: FadeInAnimation(
                trigger: active,
                child: const Text('Cards'),
              ),
            );
          },
        ),
      );

      // Finish fade in
      await tester.pumpAndSettle();
      expect(find.text('Cards'), findsOneWidget);

      // Switch to inactive
      active = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FadeInAnimation(trigger: active, child: const Text('Cards')),
        ),
      );

      // Animate fade out
      await tester.pumpAndSettle();
      expect(find.text('Cards'), findsOneWidget);
    });
  });
}
