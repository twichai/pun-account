import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/wallet.dart';

/// Notifier managing the list of Wallets using Riverpod
class WalletsNotifier extends Notifier<List<Wallet>> {
  @override
  List<Wallet> build() {
    return [
      // 1. Mockup Cash Wallet (เงินสดในมือ / Petty Cash)
      const Wallet(
        id: 'wallet-cash-1',
        type: 'cash',
        balance: 18500.00,
        currency: 'THB',
        auroraAccent: 'emerald',
      ),
      // 2. Visa Business Card
      const Wallet(
        id: 'wallet-card-1',
        type: 'credit_card',
        balance: 145250.00,
        currency: 'THB',
        cardHolder: 'PAVLO D.',
        last4: '7642',
        cardBrand: 'visa',
        auroraAccent: 'cyan',
      ),
      // 3. Mastercard Operating Card
      const Wallet(
        id: 'wallet-card-2',
        type: 'credit_card',
        balance: 42800.50,
        currency: 'THB',
        cardHolder: 'PAVLO D.',
        last4: '5123',
        cardBrand: 'mastercard',
        auroraAccent: 'violet',
      ),
    ];
  }

  /// Add a newly created wallet or card
  void addWallet(Wallet wallet) {
    state = [...state, wallet];
  }

  /// Delete a card/wallet
  void removeWallet(String id) {
    state = state.where((wallet) => wallet.id != id).toList();
  }
}

final walletsProvider = NotifierProvider<WalletsNotifier, List<Wallet>>(() {
  return WalletsNotifier();
});
