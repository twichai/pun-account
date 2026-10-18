import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../categories/presentation/providers/services_provider.dart';
import '../../transactions/presentation/providers/transactions_provider.dart';
import '../../transactions/presentation/send_request_modal.dart';
import '../../wallets/domain/models/wallet.dart';
import '../../wallets/presentation/providers/wallets_provider.dart';
import '../../wallets/presentation/widgets/dark_obsidian_wallet_card.dart';
import 'widgets/overview_header.dart';
import 'widgets/transaction_row.dart';
import 'widgets/transactions_empty_view.dart';
import 'widgets/transactions_error_view.dart';

export 'widgets/overview_header.dart';
export 'widgets/overview_transactions_sheet.dart';
export 'widgets/quick_actions_row.dart';
export 'widgets/quick_transfer_buttons.dart';
export 'widgets/spending_summary_card.dart';
export 'widgets/total_balance_card.dart';
export 'widgets/transaction_row.dart';
export 'widgets/transactions_empty_view.dart';
export 'widgets/transactions_error_view.dart';
export 'widgets/transactions_sheet_header.dart';

/// Redesigned Home Overview screen featuring a swipeable carousel of wallet cards
/// (wallet แต่ละใบ) synced with DotIndicator and dynamically filtering transactions below.
class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({
    super.key,
    this.onNavigateToWallets,
    this.onNavigateToServices,
    this.onAddTransaction,
  });

  final VoidCallback? onNavigateToWallets;
  final VoidCallback? onNavigateToServices;
  final VoidCallback? onAddTransaction;

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  late final PageController _pageController;
  int _index = 0;

  // A GlobalKey lets us access the RefreshTrigger's state so we can
  // trigger a programmatic refresh (via a button) in addition to pull-to-refresh.
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  /// Reload all core data: wallets, transactions, categories & services
  Future<void> _reloadEverything() async {
    await Future.wait([
      ref.read(walletsProvider.notifier).fetchWallets(),
      ref.read(transactionsProvider.notifier).fetchTransactions(),
      ref.read(servicesProvider.notifier).fetchCategoriesAndServices(),
      Future.delayed(const Duration(milliseconds: 600)),
    ]);
  }

  void _triggerReload() {
    if (_refreshTriggerKey.currentState != null) {
      _refreshTriggerKey.currentState!.refresh();
    } else {
      _reloadEverything();
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '\$$integerPart.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final walletsState = ref.watch(walletsProvider);
    final wallets = walletsState.wallets;

    // Fallback wallets if user has no wallets configured
    final List<Wallet> displayWallets = wallets.isNotEmpty
        ? wallets
        : const [
            Wallet(
              id: 'demo-cash',
              type: 'cash',
              balance: 18500.0,
              cardHolder: 'เงินสดในมือ',
              auroraAccent: 'emerald',
            ),
            Wallet(
              id: 'demo-card-1',
              type: 'credit_card',
              balance: 145250.0,
              cardHolder: 'PAVLO D.',
              last4: '7642',
              cardBrand: 'visa',
              auroraAccent: 'cyan',
            ),
          ];

    double totalBalance = 0.0;
    for (final w in displayWallets) {
      totalBalance += w.balance;
    }

    final safeIndex = _index.clamp(
      0,
      displayWallets.isEmpty ? 0 : displayWallets.length - 1,
    );
    final activeWallet = displayWallets[safeIndex];

    final transactionsState = ref.watch(transactionsProvider);
    final allTransactions = transactionsState.transactions;
    // Filter transactions specifically belonging to the active wallet, capped at 10 items
    final walletTransactions = allTransactions
        .where((t) => t.walletId == activeWallet.id)
        .take(10)
        .toList();

    return SafeArea(
      bottom: false,
      child: RefreshTrigger(
        key: _refreshTriggerKey,
        onRefresh: _reloadEverything,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Profile Avatar & Actions
            OverviewHeader(
              onReloadPressed: _triggerReload,
              onProfilePressed: () {
                // Could navigate to profile or account sheet
              },
              onNotificationPressed: () {
                showToast(
                  context: context,
                  builder: (context, overlay) {
                    return const SurfaceCard(
                      child: Basic(
                        leading: Icon(LucideIcons.bell, size: 20),
                        title: Text('Notifications'),
                        subtitle: Text('No unread notifications at this time.'),
                      ),
                    );
                  },
                );
              },
            ),

            // Total Balance Summary Header (Fixed at top)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatAmount(totalBalance),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  if (widget.onNavigateToWallets != null)
                    GestureDetector(
                      onTap: widget.onNavigateToWallets,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Cards',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Wallet Cards Carousel: PageView of wallet cards (wallet แต่ละใบ)
            SizedBox(
              height: 236,
              child: PageView.builder(
                key: const ValueKey('wallet_cards_pageview'),
                controller: _pageController,
                itemCount: displayWallets.length,
                onPageChanged: (index) {
                  setState(() {
                    _index = index;
                  });
                },
                itemBuilder: (context, index) {
                  final wallet = displayWallets[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DarkObsidianWalletCard(
                      wallet: wallet,
                      onTap: widget.onNavigateToWallets,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Pager-like DotIndicator syncing with the current wallet card
            Center(
              child: DotIndicator(
                index: safeIndex,
                length: displayWallets.length,
                onChanged: (index) {
                  setState(() {
                    _index = index;
                  });
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Transactions Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          activeWallet.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.onAddTransaction != null)
                    IconButton.ghost(
                      density: ButtonDensity.compact,
                      icon: const Icon(LucideIcons.plus, size: 18),
                      onPressed: widget.onAddTransaction,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Transactions List: capped at 10 items for active wallet
            Expanded(
              child: transactionsState.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : transactionsState.errorMessage != null
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: TransactionsErrorView(
                                errorMessage: transactionsState.errorMessage!,
                                onRetry: _triggerReload,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : walletTransactions.isEmpty
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: const Center(child: TransactionsEmptyView()),
                          ),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: walletTransactions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        return TransactionRow(
                          item: walletTransactions[i],
                          onTap: () {
                            SendRequestModal.show(
                              context,
                              mode: TransferMode.send,
                              recipientName: walletTransactions[i].serviceName,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
