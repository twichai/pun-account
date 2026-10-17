import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/features/wallets/domain/models/wallet.dart';

void main() {
  group('Wallet Model', () {
    test('deserializes JSON with nested ui payload from Go backend', () {
      final backendJson = {
        'id': '01927500-0001-7000-8000-000000000001',
        'business_id': '01927500-0000-7000-8000-000000000001',
        'name': 'Corporate Visa Card',
        'type': 'credit_card',
        'currency': 'THB',
        'balance': 145250.00,
        'is_active': true,
        'ui': {
          'aurora_accent': 'cyan',
          'card_holder': 'PAVLO D.',
          'last4': '7642',
          'card_brand': 'visa',
        },
      };

      final wallet = Wallet.fromJson(backendJson);

      expect(wallet.id, '01927500-0001-7000-8000-000000000001');
      expect(wallet.businessId, '01927500-0000-7000-8000-000000000001');
      expect(wallet.type, 'credit_card');
      expect(wallet.balance, 145250.00);
      expect(wallet.currency, 'THB');
      expect(wallet.auroraAccent, 'cyan');
      expect(wallet.cardHolder, 'PAVLO D.');
      expect(wallet.last4, '7642');
      expect(wallet.cardBrand, 'visa');
      expect(wallet.isActive, true);
    });

    test('deserializes legacy flat JSON payload', () {
      final flatJson = {
        'id': 'wallet-cash-1',
        'type': 'cash',
        'balance': 18500.00,
        'currency': 'THB',
        'auroraAccent': 'emerald',
        'isActive': true,
      };

      final wallet = Wallet.fromJson(flatJson);

      expect(wallet.id, 'wallet-cash-1');
      expect(wallet.type, 'cash');
      expect(wallet.balance, 18500.00);
      expect(wallet.auroraAccent, 'emerald');
      expect(wallet.isActive, true);
    });
  });
}
