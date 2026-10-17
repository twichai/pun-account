import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/wallets/data/wallets_repository.dart';
import 'package:pun_account/features/wallets/domain/models/wallet.dart';
import 'package:pun_account/features/wallets/domain/usecases/wallets_usecases.dart';
import 'package:pun_account/features/wallets/presentation/providers/add_card_form_provider.dart';
import 'package:pun_account/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:pun_account/features/wallets/presentation/wallets_screen.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeWalletsRepository implements WalletsRepository {
  List<Wallet> items = [];

  @override
  Future<List<Wallet>> getWallets({required String businessId}) async => items;

  @override
  Future<Wallet> getWalletById(String id) async =>
      items.firstWhere((w) => w.id == id);

  @override
  Future<Wallet> createWallet({
    required String businessId,
    required Wallet wallet,
    String? name,
  }) async {
    items = [...items, wallet];
    return wallet;
  }

  @override
  Future<Wallet> updateWallet({
    required String id,
    required Wallet wallet,
    String? name,
  }) async {
    items = items.map((w) => w.id == id ? wallet : w).toList();
    return wallet;
  }

  @override
  Future<void> deleteWallet(String id) async {
    items = items.where((w) => w.id != id).toList();
  }
}

class FailingCreateWalletUseCase extends CreateWalletUseCase {
  FailingCreateWalletUseCase() : super(FakeWalletsRepository());

  @override
  Future<Wallet> call({
    required String businessId,
    required Wallet wallet,
    String? name,
  }) async {
    throw Exception('Network unreachable');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('AddCardFormProvider Unit Tests', () {
    test('initial state has sensible defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(addCardFormProvider);
      expect(state.cardHolder, isEmpty);
      expect(state.cardBrand, 'visa');
      expect(state.auroraAccent, 'cyan');
      expect(state.balance, 25000.0);
      expect(state.currency, 'THB');
      expect(state.last4, '7642');
    });

    test('updates cardholder and auto-detects brand from card number', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(addCardFormProvider.notifier);
      notifier.updateCardHolder('Alice Smith');
      expect(container.read(addCardFormProvider).cardHolder, 'Alice Smith');

      // 5... auto-detects Mastercard
      notifier.updateCardNumber('5412 7512 3412 9999');
      expect(container.read(addCardFormProvider).cardBrand, 'mastercard');
      expect(container.read(addCardFormProvider).last4, '9999');

      // 4... auto-detects Visa
      notifier.updateCardNumber('4111 2222 3333 4444');
      expect(container.read(addCardFormProvider).cardBrand, 'visa');
      expect(container.read(addCardFormProvider).last4, '4444');
    });

    test('validation fails when cardholder is empty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(addCardFormProvider.notifier);
      final success = await notifier.submit();

      expect(success, isFalse);
      expect(
        container.read(addCardFormProvider).errorMessage,
        'Please enter cardholder name',
      );
    });

    test('successful submission appends new card to walletsProvider', () async {
      final fakeRepo = FakeWalletsRepository();
      final container = ProviderContainer(
        overrides: [
          walletsRepositoryProvider.overrideWithValue(fakeRepo),
          createWalletUseCaseProvider
              .overrideWithValue(CreateWalletUseCase(fakeRepo)),
        ],
      );
      addTearDown(container.dispose);

      final initialWalletsCount = container.read(walletsProvider).wallets.length;

      final notifier = container.read(addCardFormProvider.notifier);
      notifier.updateCardHolder('NOAH DEV');
      notifier.updateCardNumber('4532 9999 8888 1234');
      notifier.updateAuroraAccent('violet');
      notifier.updateBalance(50000.0);

      final success = await notifier.submit();
      expect(success, isTrue);

      final updatedWallets = container.read(walletsProvider).wallets;
      expect(updatedWallets.length, initialWalletsCount + 1);

      final newCard = updatedWallets.last;
      expect(newCard.cardHolder, 'NOAH DEV');
      expect(newCard.last4, '1234');
      expect(newCard.cardBrand, 'visa');
      expect(newCard.auroraAccent, 'violet');
      expect(newCard.balance, 50000.0);
    });

    test('failure during submission sets errorMessage and stops submitting', () async {
      final container = ProviderContainer(
        overrides: [
          createWalletUseCaseProvider.overrideWithValue(
            FailingCreateWalletUseCase(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(addCardFormProvider.notifier);
      notifier.updateCardHolder('FAIL TEST');

      final success = await notifier.submit();
      expect(success, isFalse);

      final state = container.read(addCardFormProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('Network unreachable'));
    });
  });

  group('AddCardDrawer Widget Tests', () {
    testWidgets('Tapping "Add Card" on WalletsScreen opens drawer form', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ShadcnApp(
            home: Scaffold(
              child: WalletsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure "Add Card" button is present
      final addCardBtn = find.text('Add Card');
      expect(addCardBtn, findsOneWidget);

      // Tap on "Add Card"
      await tester.tap(addCardBtn);
      await tester.pumpAndSettle();

      // Drawer should now be visible with form titles and preview
      expect(find.text('Add Digital Card'), findsOneWidget);
      expect(find.text('Cardholder Name'), findsOneWidget);
      expect(find.text('Card Number / Digits'), findsOneWidget);
      expect(find.text('Aurora Glow Accent'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
