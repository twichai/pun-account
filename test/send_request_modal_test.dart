import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:pun_account/features/transactions/presentation/send_request_modal.dart';

void main() {
  Widget createTestWidget({String? recipientName}) {
    return ShadcnApp(
      theme: ThemeData(
        colorScheme: ColorSchemes.lightSlate,
      ),
      home: Scaffold(
        child: SendRequestModal(
          recipientName: recipientName,
        ),
      ),
    );
  }

  group('SendRequestModal Task Card Tests', () {
    testWidgets('renders AWS Cloud task card by default with last cost button', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(450, 900));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify AWS Cloud task card elements
      expect(find.text('AWS Cloud'), findsOneWidget);
      expect(find.text('Cloud Infrastructure • @aws.billing'), findsOneWidget);
      expect(find.text('Use \$345.50'), findsOneWidget);

      // Verify initial save button amount
      expect(find.text('Save \$1'), findsOneWidget);

      // Tap 'Use $345.50'
      await tester.tap(find.text('Use \$345.50'));
      await tester.pump();

      // Amount should now be updated to 345.50
      expect(find.text('345.50'), findsOneWidget);
      expect(find.text('Save \$345.50'), findsOneWidget);
      // Toast message should appear
      expect(find.text('ใช้ยอดล่าสุดแล้ว'), findsOneWidget);

      // Tap Save button to verify saving state
      await tester.tap(find.text('Save \$345.50'));
      await tester.pump();
      expect(find.text('Saving...'), findsOneWidget);

      // Allow saving delay to transition to green success page
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('บันทึกสำเร็จ'), findsOneWidget);
      expect(find.text('345.50'), findsOneWidget);
      expect(find.text('ปิด'), findsOneWidget);

      // Test 3s auto-redirect
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('success page close button triggers immediate redirect', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(450, 900));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Save $1
      await tester.tap(find.text('Save \$1'));
      await tester.pump();
      expect(find.text('Saving...'), findsOneWidget);

      // Transition to success page
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('บันทึกสำเร็จ'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Tap Close button for immediate redirect
      await tester.tap(find.text('ปิด'));
      await tester.pumpAndSettle();
    });

    testWidgets(
      'renders custom recipient with no previous payment and shows not found toast',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(450, 900));
        await tester.pumpWidget(createTestWidget(recipientName: 'New Freelancer'));
        await tester.pumpAndSettle();

        // Verify custom task name and button
        expect(find.text('New Freelancer'), findsOneWidget);
        expect(find.text('Use last cost'), findsOneWidget);

        // Tap 'Use last cost'
        await tester.tap(find.text('Use last cost'));
        await tester.pump();

        // Toast message should indicate cost not found
        expect(find.text('ไม่พบยอดชำระล่าสุด'), findsOneWidget);

        // Drain toast timer
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });
}
