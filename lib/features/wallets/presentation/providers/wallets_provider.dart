import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/controllers/auth_controller.dart';
import '../../domain/models/wallet.dart';
import '../../domain/usecases/wallets_usecases.dart';

/// State representation for Wallets feature
class WalletsState {
  const WalletsState({
    this.wallets = defaultWallets,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Wallet> wallets;
  final bool isLoading;
  final String? errorMessage;

  static const List<Wallet> defaultWallets = [
    // 1. Mockup Cash Wallet (เงินสดในมือ / Petty Cash)
    Wallet(
      id: 'wallet-cash-1',
      type: 'cash',
      balance: 18500.00,
      currency: 'THB',
      auroraAccent: 'emerald',
    ),
    // 2. Visa Business Card
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
    // 3. Mastercard Operating Card
    Wallet(
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

  WalletsState copyWith({
    List<Wallet>? wallets,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return WalletsState(
      wallets: wallets ?? this.wallets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// Notifier managing the list of Wallets using Riverpod and domain usecases
class WalletsNotifier extends Notifier<WalletsState> {
  static const String defaultBusinessId =
      '018f3a20-0000-7000-8000-000000000001';

  @override
  WalletsState build() {
    final authState = ref.watch(authProvider);
    final businessId = authState.session?.user.businessId;

    if (authState.isAuthenticated && businessId != null && businessId.isNotEmpty) {
      // Trigger API fetch for the authenticated user's business
      Future.microtask(() => fetchWallets(businessId: businessId));
      return const WalletsState(isLoading: true);
    }

    return const WalletsState();
  }

  /// Fetch wallets from backend via GetWalletsUseCase using auth session
  Future<void> fetchWallets({String? businessId}) async {
    final authState = ref.read(authProvider);
    final targetBusinessId = businessId ??
        authState.session?.user.businessId ??
        defaultBusinessId;

    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final useCase = ref.read(getWalletsUseCaseProvider);
      final list = await useCase(businessId: targetBusinessId);
      state = state.copyWith(
        wallets: list,
        isLoading: false,
      );
    } catch (e) {
      // If API fails (e.g. offline dev mode or network error), fallback to defaultWallets
      state = state.copyWith(
        wallets: state.wallets.isNotEmpty ? state.wallets : WalletsState.defaultWallets,
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  /// Create a new wallet/card via CreateWalletUseCase and update local state
  Future<bool> createWallet(
    Wallet wallet, {
    String? businessId,
    String? name,
  }) async {
    final authState = ref.read(authProvider);
    final targetBusinessId = businessId ??
        authState.session?.user.businessId ??
        defaultBusinessId;

    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final useCase = ref.read(createWalletUseCaseProvider);
      final created = await useCase(
        businessId: targetBusinessId,
        wallet: wallet,
        name: name,
      );
      state = state.copyWith(
        wallets: [...state.wallets, created],
        isLoading: false,
      );
      return true;
    } catch (e) {
      // Optimistic fallback for offline dev/mock environments
      state = state.copyWith(
        wallets: [...state.wallets, wallet],
        isLoading: false,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  /// Update an existing wallet via UpdateWalletUseCase
  Future<bool> updateWallet(
    String id,
    Wallet wallet, {
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final useCase = ref.read(updateWalletUseCaseProvider);
      final updated = await useCase(id: id, wallet: wallet, name: name);
      state = state.copyWith(
        wallets: state.wallets.map((w) => w.id == id ? updated : w).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        wallets: state.wallets.map((w) => w.id == id ? wallet : w).toList(),
        isLoading: false,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  /// Delete a wallet via DeleteWalletUseCase
  Future<bool> deleteWallet(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final useCase = ref.read(deleteWalletUseCaseProvider);
      await useCase(id);
      state = state.copyWith(
        wallets: state.wallets.where((w) => w.id != id).toList(),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        wallets: state.wallets.where((w) => w.id != id).toList(),
        isLoading: false,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  /// Add a newly created wallet or card locally
  void addWallet(Wallet wallet) {
    state = state.copyWith(wallets: [...state.wallets, wallet]);
  }

  /// Delete a card/wallet locally
  void removeWallet(String id) {
    state = state.copyWith(
      wallets: state.wallets.where((w) => w.id != id).toList(),
    );
  }
}

final walletsProvider = NotifierProvider<WalletsNotifier, WalletsState>(() {
  return WalletsNotifier();
});
