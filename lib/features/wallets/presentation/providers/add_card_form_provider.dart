import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/controllers/auth_controller.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/wallet.dart';
import '../../domain/usecases/wallets_usecases.dart';
import 'wallets_provider.dart';

/// Form state for creating or editing a wallet / card
class AddCardFormState {
  const AddCardFormState({
    this.walletId,
    this.isEdit = false,
    this.walletType = 'credit_card',
    this.cardHolder = '',
    this.cardNumber = '',
    this.cardBrand = 'visa',
    this.auroraAccent = 'cyan',
    this.balance = 25000.0,
    this.currency = 'THB',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String? walletId;
  final bool isEdit;
  final String walletType;
  final String cardHolder;
  final String cardNumber;
  final String cardBrand;
  final String auroraAccent;
  final double balance;
  final String currency;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isCashWallet => walletType == 'cash';

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
      id: walletId ?? 'preview-card',
      type: walletType,
      balance: balance,
      currency: currency,
      cardHolder: cardHolder.trim().isEmpty
          ? (isCashWallet ? 'CASH WALLET' : 'CARDHOLDER NAME')
          : cardHolder.trim().toUpperCase(),
      last4: isCashWallet ? null : last4,
      cardBrand: isCashWallet ? null : cardBrand,
      auroraAccent: auroraAccent,
      isActive: true,
    );
  }

  AddCardFormState copyWith({
    String? walletId,
    bool? isEdit,
    String? walletType,
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
      walletId: walletId ?? this.walletId,
      isEdit: isEdit ?? this.isEdit,
      walletType: walletType ?? this.walletType,
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

/// Notifier managing Add and Edit Card form actions and validation
class AddCardFormNotifier extends Notifier<AddCardFormState> {
  @override
  AddCardFormState build() {
    return const AddCardFormState();
  }

  /// Initialize form for adding a new card
  void initForCreate() {
    state = const AddCardFormState();
  }

  /// Initialize form with existing wallet data for editing
  void initForEdit(Wallet wallet) {
    state = AddCardFormState(
      walletId: wallet.id,
      isEdit: true,
      walletType: wallet.type,
      cardHolder: wallet.cardHolder ?? (wallet.type == 'cash' ? 'Cash Wallet' : ''),
      cardNumber: wallet.last4 != null ? '•••• •••• •••• ${wallet.last4}' : '',
      cardBrand: wallet.cardBrand ?? 'visa',
      auroraAccent: wallet.auroraAccent,
      balance: wallet.balance,
      currency: wallet.currency,
    );
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

  /// Validate and submit the form (either Create or Update wallet)
  Future<bool> submit({String? businessId}) async {
    if (!state.isCashWallet && state.cardHolder.trim().isEmpty) {
      state = state.copyWith(
        errorMessage: () => 'Please enter cardholder name',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: () => null);

    // Edit existing wallet flow
    if (state.isEdit && state.walletId != null) {
      final updatedWallet = Wallet(
        id: state.walletId!,
        type: state.walletType,
        balance: state.balance,
        currency: state.currency,
        cardHolder: state.isCashWallet
            ? (state.cardHolder.trim().isEmpty ? 'Cash Wallet' : state.cardHolder.trim())
            : state.cardHolder.trim().toUpperCase(),
        last4: state.isCashWallet ? null : state.last4,
        cardBrand: state.isCashWallet ? null : state.cardBrand,
        auroraAccent: state.auroraAccent,
        isActive: true,
      );

      try {
        final updateWalletUseCase = ref.read(updateWalletUseCaseProvider);
        final result = await updateWalletUseCase(
          id: state.walletId!,
          wallet: updatedWallet,
          name: updatedWallet.cardHolder,
        );

        ref.read(walletsProvider.notifier).updateWalletItem(result);
        state = state.copyWith(isSubmitting: false);
        reset();
        return true;
      } on ApiException catch (e) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: () => e.message,
        );
        return false;
      } catch (e) {
        // Fallback optimistic update for offline/mock environments
        ref.read(walletsProvider.notifier).updateWalletItem(updatedWallet);
        state = state.copyWith(isSubmitting: false);
        reset();
        return true;
      }
    }

    // Create new wallet flow
    final newId = 'wallet-card-${DateTime.now().millisecondsSinceEpoch}';
    final newWallet = Wallet(
      id: newId,
      type: state.walletType,
      balance: state.balance,
      currency: state.currency,
      cardHolder: state.cardHolder.trim().toUpperCase(),
      last4: state.last4,
      cardBrand: state.cardBrand,
      auroraAccent: state.auroraAccent,
      isActive: true,
    );

    final authState = ref.read(authProvider);
    final targetBusinessId = businessId ??
        authState.session?.user.businessId ??
        WalletsNotifier.defaultBusinessId;

    try {
      final createWalletUseCase = ref.read(createWalletUseCaseProvider);
      final createdWallet = await createWalletUseCase(
        businessId: targetBusinessId,
        wallet: newWallet,
        name: state.cardHolder.trim().toUpperCase(),
      );

      ref.read(walletsProvider.notifier).addWallet(createdWallet);
      state = state.copyWith(isSubmitting: false);
      reset();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: () => e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  /// Delete the currently edited wallet
  Future<bool> deleteCurrentWallet() async {
    if (state.walletId == null) return false;
    state = state.copyWith(isSubmitting: true, errorMessage: () => null);
    try {
      final deleteUseCase = ref.read(deleteWalletUseCaseProvider);
      await deleteUseCase(state.walletId!);
      ref.read(walletsProvider.notifier).removeWallet(state.walletId!);
      state = state.copyWith(isSubmitting: false);
      reset();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: () => e.message,
      );
      return false;
    } catch (e) {
      ref.read(walletsProvider.notifier).removeWallet(state.walletId!);
      state = state.copyWith(isSubmitting: false);
      reset();
      return true;
    }
  }
}

final addCardFormProvider =
    NotifierProvider<AddCardFormNotifier, AddCardFormState>(() {
  return AddCardFormNotifier();
});
