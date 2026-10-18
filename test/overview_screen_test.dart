import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/dashboard/presentation/overview_screen.dart';
import 'package:pun_account/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:pun_account/features/wallets/domain/models/wallet.dart';
import 'package:pun_account/features/wallets/presentation/providers/wallets_provider.dart';
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
  testWidgets(
    'OverviewScreen has a single Global Top RefreshTrigger and keeps exact UI',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const sampleWallets = [
        Wallet(
          id: 'w-1',
          type: 'credit_card',
          balance: 25000.0,
          cardHolder: 'PAVLO D.',
          last4: '1234',
          cardBrand: 'visa',
          auroraAccent: 'cyan',
        ),
      ];

      final sampleTransactions = [
        TransactionModel(
          id: 'tx-1',
          businessId: 'biz-1',
          walletId: 'w-1',
          serviceId: 'srv-1',
          type: 'expense',
          amount: 120.0,
          transactionDate: DateTime(2026, 10, 18),
          description: 'Hosting',
          serviceName: 'AWS',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletsProvider.overrideWith(
              () => FakeWalletsNotifier(sampleWallets),
            ),
            transactionsProvider.overrideWith(
              () => FakeTransactionsNotifier(sampleTransactions),
            ),
          ],
          child: const ShadcnApp(home: Scaffold(child: OverviewScreen())),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that there is EXACTLY ONE RefreshTrigger (at top level, old inner one removed)
      expect(find.byType(RefreshTrigger), findsOneWidget);

      // Verify that all original UI components exist intact
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.text('\$25,000.00'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('wallet_cards_pageview')),
        findsOneWidget,
      );
      expect(find.byType(DotIndicator), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('PAVLO D.'), findsAtLeastNWidgets(1));
      expect(find.text('AWS'), findsOneWidget);
      expect(find.text('-\$120.00'), findsOneWidget);

      // Verify reload button triggers without crash
      final reloadButtons = find.byIcon(LucideIcons.refreshCw);
      expect(reloadButtons, findsAtLeastNWidgets(1));
      await tester.tap(reloadButtons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
    },
  );
}
