import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/categories/presentation/services_screen.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServicesScreen Widget Tests', () {
    testWidgets('renders DraggableScrollableSheet, header, and quick services', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ShadcnApp(home: Scaffold(child: ServicesScreen())),
        ),
      );
      await tester.pumpAndSettle();

      // Verify DraggableScrollableSheet is present in the tree
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);

      // Verify Header & Recipients text
      expect(find.text('Recipients'), findsOneWidget);

      // Verify Add button is present
      expect(find.text('Add'), findsOneWidget);

      // Verify Quick Services avatars are rendered
      expect(find.text('OpenAI'), findsWidgets);
      expect(find.text('AWS Cloud'), findsOneWidget);

      // Verify filter tabs in DraggableScrollableSheet
      expect(find.text('All'), findsOneWidget);
      expect(find.text('My accounts'), findsOneWidget);
    });
  });
}
