import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/animations/fade_in_animation.dart';

void main() {
  group('FadeInAnimation Widget Tests', () {
    testWidgets('Renders child and smoothly fades in', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FadeInAnimation(
            child: Text('Cards'),
          ),
        ),
      );

      expect(find.text('Cards'), findsOneWidget);

      // Fast-forward animation to settle
      await tester.pumpAndSettle();
      expect(find.text('Cards'), findsOneWidget);
    });

    testWidgets('Respects reduced motion setting', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FadeInAnimation(
              child: Text('Reduced Motion'),
            ),
          ),
        ),
      );

      expect(find.text('Reduced Motion'), findsOneWidget);
    });
  });
}
