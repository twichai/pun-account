import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:pun_account/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:pun_account/features/wallets/domain/models/wallet.dart';
import 'package:pun_account/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:pun_account/main.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class FakeWalletsNotifier extends WalletsNotifier {
  final List<Wallet> initialWallets;
  FakeWalletsNotifier(this.initialWallets);

  @override
  WalletsState build() => WalletsState(wallets: initialWallets);
}

class FakeTransactionsNotifier extends TransactionsNotifier {
  final List<TransactionModel> initialTransactions;
  FakeTransactionsNotifier(this.initialTransactions);

  @override
  TransactionsState build() =>
      TransactionsState(transactions: initialTransactions);
}

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

    const sampleWallets = [
      Wallet(
        id: 'wallet-cash-1',
        type: 'cash',
        balance: 18500.00,
        currency: 'THB',
        cardHolder: 'เงินสดในมือ',
        auroraAccent: 'emerald',
      ),
      Wallet(
        id: 'wallet-card-1',
        type: 'credit_card',
        balance: 145250.00,
        currency: 'THB',
        cardHolder: 'PAVLO D.',
        last4: '7642',
        cardBrand: 'visa',
        auroraAccent: 'cyan',
      ),
    ];

    final sampleTransactions = [
      TransactionModel(
        id: 'tx-1',
        businessId: 'biz-1',
        walletId: 'wallet-card-1',
        serviceId: 'srv-1',
        type: 'expense',
        amount: 60.0,
        transactionDate: DateTime(2026, 10, 17, 13, 45),
        description: 'Send to Apple',
        serviceName: 'Apple',
      ),
    ];

    // Pump MyApp directly into MainNavigationScreen with mocked providers for smoke test
    await tester.pumpWidget(
      MyApp(
        overrides: [
          walletsProvider.overrideWith(
            () => FakeWalletsNotifier(sampleWallets),
          ),
          transactionsProvider.overrideWith(
            () => FakeTransactionsNotifier(sampleTransactions),
          ),
        ],
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
    expect(find.text('\$ 163,750'), findsOneWidget);
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

    // Tap on Tab 1 (Home)
    await tester.tap(find.byKey(const ValueKey(1)));
    await tester.pumpAndSettle();
    expect(find.text('Total balance'), findsOneWidget);

    // Tap on 'Send' button on Home
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    // Verify SendRequestModal is opened with keypad
    expect(find.text('Available \$18,500.00'), findsOneWidget);
    expect(find.text('เงินสด • เงินสดในมือ'), findsOneWidget);
    expect(find.text('Save \$1'), findsOneWidget);
  });
}
