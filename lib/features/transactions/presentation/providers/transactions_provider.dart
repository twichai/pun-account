import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/controllers/auth_controller.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../data/transactions_repository.dart';
import '../../domain/models/transaction.dart';

export '../../data/transactions_repository.dart';
export '../../domain/models/transaction.dart';

/// State representation for transactions feature
class TransactionsState {
  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

/// Notifier managing transactions fetched from the Go backend API
class TransactionsNotifier extends Notifier<TransactionsState> {
  @override
  TransactionsState build() {
    final authState = ref.watch(authProvider);
    final walletsState = ref.watch(walletsProvider);
    final businessId = authState.session?.user.businessId ??
        (walletsState.wallets.isNotEmpty
            ? walletsState.wallets.first.businessId
            : null);

    if (businessId != null && businessId.isNotEmpty) {
      Future.microtask(() => fetchTransactions(businessId: businessId));
      return const TransactionsState(isLoading: true);
    }

    return const TransactionsState();
  }

  /// Fetches transactions from the backend for the current business
  Future<void> fetchTransactions({String? businessId}) async {
    final authState = ref.read(authProvider);
    final wallets = ref.read(walletsProvider).wallets;

    String? targetBusinessId = businessId ?? authState.session?.user.businessId;
    if (targetBusinessId == null || targetBusinessId.isEmpty) {
      if (wallets.isNotEmpty &&
          wallets.first.businessId != null &&
          wallets.first.businessId!.isNotEmpty) {
        targetBusinessId = wallets.first.businessId!;
      }
    }

    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final repo = ref.read(transactionsRepositoryProvider);
      final list = await repo.getTransactions(
        businessId: targetBusinessId,
      );

      state = state.copyWith(
        transactions: list,
        isLoading: false,
        errorMessage: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.toString(),
      );
    }
  }

  /// Refresh transactions list
  Future<void> refresh() async {
    await fetchTransactions();
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, TransactionsState>(() {
  return TransactionsNotifier();
});
