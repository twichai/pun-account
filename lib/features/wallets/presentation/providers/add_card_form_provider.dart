import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/wallet.dart';
import 'wallets_provider.dart';

/// Form state for creating a new card
class AddCardFormState {
  const AddCardFormState({
    this.cardHolder = '',
    this.cardNumber = '',
    this.cardBrand = 'visa',
    this.auroraAccent = 'cyan',
    this.balance = 25000.0,
    this.currency = 'THB',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String cardHolder;
  final String cardNumber;
  final String cardBrand;
  final String auroraAccent;
  final double balance;
  final String currency;
  final bool isSubmitting;
  final String? errorMessage;

  /// Extract last 4 digits from cardNumber, or fallback to default
  String get last4 {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      return digits.substring(digits.length - 4);
    }
    return digits.isNotEmpty ? digits.padLeft(4, '0') : '7642';
  }

  /// Convert state into a temporary Wallet instance for live UI preview
  Wallet toPreviewWallet() {
    return Wallet(
      id: 'preview-card',
      type: 'credit_card',
      balance: balance,
      currency: currency,
      cardHolder:
          cardHolder.trim().isEmpty ? 'CARDHOLDER NAME' : cardHolder.trim().toUpperCase(),
      last4: last4,
      cardBrand: cardBrand,
      auroraAccent: auroraAccent,
      isActive: true,
    );
  }

  AddCardFormState copyWith({
    String? cardHolder,
    String? cardNumber,
    String? cardBrand,
    String? auroraAccent,
    double? balance,
    String? currency,
    bool? isSubmitting,
    String? Function()? errorMessage,
  }) {
    return AddCardFormState(
      cardHolder: cardHolder ?? this.cardHolder,
      cardNumber: cardNumber ?? this.cardNumber,
      cardBrand: cardBrand ?? this.cardBrand,
      auroraAccent: auroraAccent ?? this.auroraAccent,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// Notifier managing Add Card form actions and validation
class AddCardFormNotifier extends Notifier<AddCardFormState> {
  @override
  AddCardFormState build() {
    return const AddCardFormState();
  }

  void updateCardHolder(String holder) {
    state = state.copyWith(cardHolder: holder, errorMessage: () => null);
  }

  void updateCardNumber(String number) {
    final cleanDigits = number.replaceAll(RegExp(r'\D'), '');
    String brand = state.cardBrand;
    if (cleanDigits.startsWith('4')) {
      brand = 'visa';
    } else if (cleanDigits.startsWith('5')) {
      brand = 'mastercard';
    }
    state = state.copyWith(
      cardNumber: number,
      cardBrand: brand,
      errorMessage: () => null,
    );
  }

  void updateCardBrand(String brand) {
    state = state.copyWith(cardBrand: brand);
  }

  void updateAuroraAccent(String accent) {
    state = state.copyWith(auroraAccent: accent);
  }

  void updateBalance(double balance) {
    state = state.copyWith(balance: balance);
  }

  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
  }

  void reset() {
    state = const AddCardFormState();
  }

  /// Validate and submit the form, adding the new card to walletsProvider
  bool submit() {
    if (state.cardHolder.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: () => 'Please enter cardholder name',
      );
      return false;
    }

    final newId = 'wallet-card-${DateTime.now().millisecondsSinceEpoch}';
    final newWallet = Wallet(
      id: newId,
      type: 'credit_card',
      balance: state.balance,
      currency: state.currency,
      cardHolder: state.cardHolder.trim().toUpperCase(),
      last4: state.last4,
      cardBrand: state.cardBrand,
      auroraAccent: state.auroraAccent,
      isActive: true,
    );

    ref.read(walletsProvider.notifier).addWallet(newWallet);
    reset();
    return true;
  }
}

final addCardFormProvider =
    NotifierProvider<AddCardFormNotifier, AddCardFormState>(() {
  return AddCardFormNotifier();
});
