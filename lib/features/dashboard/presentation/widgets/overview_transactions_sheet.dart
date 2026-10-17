import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../transactions/presentation/providers/transactions_provider.dart';
import 'transaction_row.dart';
import 'transactions_empty_view.dart';
import 'transactions_error_view.dart';
import 'transactions_sheet_header.dart';

/// Draggable scrollable bottom sheet displaying transactions list, loading, error, and empty states.
class OverviewTransactionsSheet extends ConsumerWidget {
  const OverviewTransactionsSheet({
    super.key,
    this.initialChildSize = 0.60,
    this.minChildSize = 0.60,
    this.maxChildSize = 1.0,
    this.snapSizes = const [0.60, 1.0],
    this.onFilterPressed,
    this.onSearchPressed,
  });

  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final List<double> snapSizes;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSearchPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final transactionsState = ref.watch(transactionsProvider);
    final transactions = transactionsState.transactions;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: true,
      snapSizes: snapSizes,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF18181B) : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
              children: [
                // Top grab handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header: Filter, "Transactions", Search
                TransactionsSheetHeader(
                  onFilterPressed: onFilterPressed,
                  onSearchPressed: onSearchPressed,
                ),
                const SizedBox(height: 16),

                // Transactions List / States
                if (transactionsState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (transactionsState.errorMessage != null)
                  TransactionsErrorView(
                    errorMessage: transactionsState.errorMessage!,
                    onRetry: () => ref
                        .read(transactionsProvider.notifier)
                        .fetchTransactions(),
                  )
                else if (transactions.isEmpty)
                  const TransactionsEmptyView()
                else
                  for (int index = 0; index < transactions.length; index++) ...[
                    if (index > 0) const SizedBox(height: 14),
                    TransactionRow(item: transactions[index]),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}
