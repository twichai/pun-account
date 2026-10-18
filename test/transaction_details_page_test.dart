import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/router/app_router.dart';
import 'package:pun_account/features/transaction_details/transaction_details.dart';
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
    'TransactionDetailsPage renders filters (This Month, This Year, All), sort (Date, Amount), and wallet transactions',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const sampleWallets = [
        Wallet(
          id: 'wallet-1',
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
          walletId: 'wallet-1',
          serviceId: 'srv-1',
          type: 'expense',
          amount: 50.0,
          transactionDate: DateTime(2026, 10, 10),
          description: 'Hosting',
          serviceName: 'AWS',
        ),
        TransactionModel(
          id: 'tx-2',
          businessId: 'biz-1',
          walletId: 'wallet-1',
          serviceId: 'srv-2',
          type: 'expense',
          amount: 200.0,
          transactionDate: DateTime(2026, 10, 15),
          description: 'Design Tool',
          serviceName: 'Figma',
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
          child: const ShadcnApp(
            home: TransactionDetailsPage(walletId: 'wallet-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title, wallet badge, and top navigation
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('PAVLO D.'), findsOneWidget);
      expect(find.byIcon(LucideIcons.arrowLeft), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);

      // Verify Period Filter Tabs: This Month, This Year, All
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);

      // Verify Sort Controls
      expect(find.text('Sort by:'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);

      // Verify Total Expense for this wallet in This Month (50 + 200 = 250)
      expect(find.text('\$250.00'), findsOneWidget);

      // Verify transactions list items rendered in Category Breakdown
      expect(find.text('AWS'), findsOneWidget);
      expect(find.text('Figma'), findsOneWidget);
      expect(find.text('Category Breakdown'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Tap on Sort by Amount
      await tester.tap(find.byKey(const ValueKey('sort_amount')));
      await tester.pumpAndSettle();

      // Tap on 'This Year' filter
      await tester.tap(find.text('This Year'));
      await tester.pumpAndSettle();

      // Tap on 'All' filter
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'GoRouter navigates to /transaction-details/:walletId with path parameter',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const sampleWallets = [
        Wallet(
          id: 'card-999',
          type: 'credit_card',
          balance: 10000.0,
          cardHolder: 'JANE DOE',
        ),
      ];

      final sampleTransactions = [
        TransactionModel(
          id: 'tx-99',
          businessId: 'biz-1',
          walletId: 'card-999',
          serviceId: 'srv-99',
          type: 'expense',
          amount: 88.0,
          transactionDate: DateTime(2026, 10, 18),
          description: 'Coffee Subscription',
          serviceName: 'Starbucks',
        ),
      ];

      final router = createAppRouter(
        initialLocation: '/transaction-details/card-999',
      );

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
          child: ShadcnApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('JANE DOE'), findsOneWidget);
      expect(find.text('Starbucks'), findsOneWidget);
      // Appears in total spent header and in Category Breakdown row
      expect(find.text('\$88.00'), findsNWidgets(2));
    },
  );
}
