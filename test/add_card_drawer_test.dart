import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/wallets/presentation/providers/add_card_form_provider.dart';
import 'package:pun_account/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:pun_account/features/wallets/presentation/wallets_screen.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    test('validation fails when cardholder is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(addCardFormProvider.notifier);
      final success = notifier.submit();

      expect(success, isFalse);
      expect(
        container.read(addCardFormProvider).errorMessage,
        'Please enter cardholder name',
      );
    });

    test('successful submission appends new card to walletsProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialWalletsCount = container.read(walletsProvider).wallets.length;

      final notifier = container.read(addCardFormProvider.notifier);
      notifier.updateCardHolder('NOAH DEV');
      notifier.updateCardNumber('4532 9999 8888 1234');
      notifier.updateAuroraAccent('violet');
      notifier.updateBalance(50000.0);

      final success = notifier.submit();
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
