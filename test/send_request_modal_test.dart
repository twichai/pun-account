import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/categories/domain/models/service_category_item.dart';
import 'package:pun_account/features/categories/presentation/providers/services_provider.dart';
import 'package:pun_account/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:pun_account/features/transactions/presentation/send_request_modal.dart';
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

class FakeServicesNotifier extends ServicesNotifier {
  final List<ServiceCategoryItem> initialServices;
  FakeServicesNotifier(this.initialServices);

  @override
  ServicesState build() => ServicesState(allAccounts: initialServices);
}

class FakeTransactionsRepository implements TransactionsRepository {
  @override
  Future<TransactionModel> createTransaction({
    required String businessId,
    required String walletId,
    required String serviceId,
    String? categoryId,
    required String type,
    required double amount,
    DateTime? transactionDate,
    String? description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return TransactionModel(
      id: 'tx-new',
      businessId: businessId,
      walletId: walletId,
      serviceId: serviceId,
      type: type,
      amount: amount,
      transactionDate: transactionDate ?? DateTime.now(),
      description: description,
    );
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    String? businessId,
    String? walletId,
    String? serviceId,
    String? categoryId,
    String? type,
    int? limit,
    int? offset,
  }) async {
    return [];
  }
}

void main() {
  final defaultTestWallets = [
    const Wallet(
      id: 'wallet-cash-1',
      businessId: 'biz-1',
      type: 'cash',
      balance: 18500.00,
      currency: 'THB',
      cardHolder: 'เงินสดในมือ',
      auroraAccent: 'emerald',
    ),
    const Wallet(
      id: 'wallet-card-1',
      businessId: 'biz-1',
      type: 'credit_card',
      balance: 145250.00,
      currency: 'THB',
      cardHolder: 'PAVLO D.',
      last4: '7642',
      cardBrand: 'visa',
      auroraAccent: 'cyan',
    ),
    const Wallet(
      id: 'wallet-card-2',
      businessId: 'biz-1',
      type: 'credit_card',
      balance: 42800.50,
      currency: 'THB',
      cardHolder: 'PAVLO D.',
      last4: '5123',
      cardBrand: 'mastercard',
      auroraAccent: 'violet',
    ),
  ];

  const defaultTestServices = [
    ServiceCategoryItem(
      id: 'srv-aws',
      name: 'AWS Cloud',
      accountNumber: 'aws.billing',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
      categoryTrack: 'Cloud Infrastructure',
    ),
  ];

  final defaultTestTransactions = [
    TransactionModel(
      id: 'tx-1',
      businessId: 'biz-1',
      walletId: 'wallet-card-1',
      serviceId: 'srv-aws',
      type: 'expense',
      amount: 345.50,
      transactionDate: DateTime(2026, 10, 17),
      description: 'Send to AWS Cloud',
      serviceName: 'AWS Cloud',
    ),
  ];

  Widget createTestWidget({String? recipientName}) {
    return ProviderScope(
      overrides: [
        walletsProvider.overrideWith(
          () => FakeWalletsNotifier(defaultTestWallets),
        ),
        transactionsProvider.overrideWith(
          () => FakeTransactionsNotifier(defaultTestTransactions),
        ),
        servicesProvider.overrideWith(
          () => FakeServicesNotifier(defaultTestServices),
        ),
        transactionsRepositoryProvider.overrideWithValue(
          FakeTransactionsRepository(),
        ),
      ],
      child: ShadcnApp(
        theme: ThemeData(
          colorScheme: ColorSchemes.lightSlate,
        ),
        home: Scaffold(
          child: SendRequestModal(
            recipientName: recipientName,
          ),
        ),
      ),
    );
  }

  group('SendRequestModal Task Card Tests', () {
    testWidgets('renders AWS Cloud task card by default with last cost button', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(450, 900));
      await tester.pumpWidget(createTestWidget(recipientName: 'AWS Cloud'));
      await tester.pumpAndSettle();

      // Verify AWS Cloud task card elements
      expect(find.text('AWS Cloud'), findsOneWidget);
      expect(find.text('Cloud Infrastructure • aws.billing'), findsOneWidget);
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

      // Test auto-redirect
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('success page close button triggers immediate redirect', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(450, 900));
      await tester.pumpWidget(createTestWidget(recipientName: 'AWS Cloud'));
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

    testWidgets(
      'renders correct account selector labels for cash (เงินสด • :name) and cards (:card_brand • :last4)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(450, 900));
        await tester.pumpWidget(createTestWidget(recipientName: 'AWS Cloud'));
        await tester.pumpAndSettle();

        // Default selected wallet is the first wallet (cash): 'เงินสด • เงินสดในมือ'
        expect(find.text('เงินสด • เงินสดในมือ'), findsOneWidget);
        expect(find.text('Available \$18,500.00'), findsOneWidget);

        // Open account selector dropdown
        await tester.tap(find.text('เงินสด • เงินสดในมือ'));
        await tester.pumpAndSettle();

        // Check options inside popup:
        // 1. Cash: 'เงินสด • เงินสดในมือ'
        // 2. Visa: 'visa • 7642'
        // 3. Mastercard: 'mastercard • 5123'
        expect(find.text('visa • 7642'), findsOneWidget);
        expect(find.text('mastercard • 5123'), findsOneWidget);

        // Select the visa card
        await tester.tap(find.text('visa • 7642'));
        await tester.pumpAndSettle();

        // The selected value should now display 'visa • 7642' and update available balance
        expect(find.text('visa • 7642'), findsOneWidget);
        expect(find.text('Available \$145,250.00'), findsOneWidget);

        // Select mastercard
        await tester.tap(find.text('visa • 7642'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('mastercard • 5123'));
        await tester.pumpAndSettle();

        // Available balance updates to mastercard balance
        expect(find.text('mastercard • 5123'), findsOneWidget);
        expect(find.text('Available \$42,800.50'), findsOneWidget);
      },
    );
  });
}
