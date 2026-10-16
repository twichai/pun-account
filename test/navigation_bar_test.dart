import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/navigation/presentation/widgets/pun_navigation_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  testWidgets('PunNavigationBar renders 3 items and responds to selection', (tester) async {
    Key? selected = const ValueKey(1);

    await tester.pumpWidget(
      ShadcnApp(
        theme: ThemeData(
          colorScheme: ColorSchemes.lightSlate.yellow,
        ),
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              child: Stack(
                children: [
                  Center(
                    child: Text('Selected: $selected'),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: PunNavigationBar(
                      selectedKey: selected,
                      onSelected: (key) {
                        setState(() {
                          selected = key;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all 3 nav items are present by key
    expect(find.byKey(const ValueKey(0)), findsOneWidget);
    expect(find.byKey(const ValueKey(1)), findsOneWidget);
    expect(find.byKey(const ValueKey(2)), findsOneWidget);

    // Tap on Tab 0 (Services)
    await tester.tap(find.byKey(const ValueKey(0)));
    await tester.pumpAndSettle();
    expect(selected, const ValueKey(0));

    // Tap on Tab 2 (Cards)
    await tester.tap(find.byKey(const ValueKey(2)));
    await tester.pumpAndSettle();
    expect(selected, const ValueKey(2));

    // Tap on Tab 1 (Home)
    await tester.tap(find.byKey(const ValueKey(1)));
    await tester.pumpAndSettle();
    expect(selected, const ValueKey(1));
  });
}
