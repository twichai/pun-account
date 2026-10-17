import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/controllers/auth_controller.dart';
import '../../domain/models/wallet.dart';
import '../../domain/usecases/wallets_usecases.dart';

/// State representation for Wallets feature
class WalletsState {
  const WalletsState({
    this.wallets = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Wallet> wallets;
  final bool isLoading;
  final String? errorMessage;

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
      '01a14818-3b9f-7f23-8f3c-488550adb5e4';

  @override
  WalletsState build() {
    final authState = ref.watch(authProvider);
    final businessId = authState.session?.user.businessId;

    if (authState.isAuthenticated &&
        businessId != null &&
        businessId.isNotEmpty) {
      // Trigger API fetch for the authenticated user's business
      Future.microtask(() => fetchWallets(businessId: businessId));
      return const WalletsState(isLoading: true);
    }

    return const WalletsState();
  }

  /// Fetch wallets from backend via GetWalletsUseCase using auth session
  Future<void> fetchWallets({String? businessId}) async {
    final authState = ref.read(authProvider);
    final targetBusinessId =
        businessId ?? authState.session?.user.businessId ?? defaultBusinessId;

    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final useCase = ref.read(getWalletsUseCaseProvider);
      final list = await useCase(businessId: targetBusinessId);
      state = state.copyWith(wallets: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
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
    final targetBusinessId =
        businessId ?? authState.session?.user.businessId ?? defaultBusinessId;

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
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  /// Update an existing wallet via UpdateWalletUseCase
  Future<bool> updateWallet(String id, Wallet wallet, {String? name}) async {
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

  /// Replace an updated wallet locally
  void updateWalletItem(Wallet updated) {
    state = state.copyWith(
      wallets: state.wallets
          .map((w) => w.id == updated.id ? updated : w)
          .toList(),
    );
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
