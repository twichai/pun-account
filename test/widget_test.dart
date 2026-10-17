import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:pun_account/main.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  testWidgets('SignInScreen displays when unauthenticated', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Pump default MyApp
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify SignInScreen is rendered with branding and Google auth button
    expect(find.text('Welcome to Pun (ปั้น)'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Alex Maker'), findsOneWidget);
    expect(find.text('Sarah Design'), findsOneWidget);
  });

  testWidgets('MainNavigationScreen smoke and navigation test', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Pump MyApp directly into MainNavigationScreen
    await tester.pumpWidget(
      MyApp(
        home: MainNavigationScreen(
          title: 'Pun Account',
          themeMode: ThemeMode.dark,
          onToggleTheme: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial Home (Overview) screen is displayed
    expect(find.text('Total balance'), findsOneWidget);
    expect(find.text('\$ 7,854'), findsOneWidget);
    expect(find.text('Spending'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Apple'), findsAtLeastNWidgets(1));

    // Verify 3 navigation tabs are present
    expect(find.byKey(const ValueKey(0)), findsOneWidget);
    expect(find.byKey(const ValueKey(1)), findsOneWidget);
    expect(find.byKey(const ValueKey(2)), findsOneWidget);

    // Tap on Tab 2 (Cards)
    await tester.tap(find.byKey(const ValueKey(2)));
    await tester.pumpAndSettle();

    // Verify Cards screen is displayed
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Add Card'), findsOneWidget);
    expect(find.textContaining('7642'), findsAtLeastNWidgets(1));

    // Tap on Tab 0 (Recipients / Services)
    await tester.tap(find.byKey(const ValueKey(0)));
    await tester.pumpAndSettle();

    // Verify Services screen is displayed with category/service items
    expect(find.text('Recipients'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('OpenAI'), findsAtLeastNWidgets(1));
    expect(find.text('AWS Cloud'), findsAtLeastNWidgets(1));

    // Tap on Tab 1 (Home)
    await tester.tap(find.byKey(const ValueKey(1)));
    await tester.pumpAndSettle();
    expect(find.text('Total balance'), findsOneWidget);

    // Tap on 'Send' button on Home
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    // Verify SendRequestModal is opened with keypad
    expect(find.text('Available \$7,854.43'), findsOneWidget);
    expect(find.text('Pavlo • 7642 USD'), findsOneWidget);
    expect(find.text('Save \$1'), findsOneWidget);

    // Tap on keypad '5'
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    expect(find.text('Save \$5'), findsOneWidget);

    // Tap on 'Save $5' to submit and close modal
    await tester.tap(find.text('Save \$5'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Available \$7,854.43'), findsNothing);
  });
}
