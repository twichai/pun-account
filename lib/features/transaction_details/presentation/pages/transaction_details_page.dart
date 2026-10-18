import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../categories/presentation/providers/services_provider.dart';
import '../../../dashboard/presentation/widgets/transaction_row.dart';
import '../../../dashboard/presentation/widgets/transactions_empty_view.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/presentation/send_request_modal.dart';
import '../../../wallets/domain/models/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

/// Transaction Details page displaying wallet info, period filters (This Month, This Year, All),
/// sorting (by Date or Amount), daily spending bar chart, category breakdown, and full transaction list.
class TransactionDetailsPage extends ConsumerStatefulWidget {
  const TransactionDetailsPage({
    super.key,
    this.walletId,
    this.title = 'Transaction Details',
    this.initialPeriod = 'This Month',
    this.initialSort = 'Date',
    this.spentAmount,
    this.percentageChange = -12.0,
    this.onViewAllCategories,
  });

  final String? walletId;
  final String title;
  final String initialPeriod;
  final String initialSort;
  final double? spentAmount;
  final double percentageChange;
  final VoidCallback? onViewAllCategories;

  @override
  ConsumerState<TransactionDetailsPage> createState() =>
      _TransactionDetailsPageState();
}

class _TransactionDetailsPageState
    extends ConsumerState<TransactionDetailsPage> {
  late String _selectedPeriod;
  late String _selectedSort;

  final List<String> _periods = const ['This Month', 'This Year', 'All'];

  // Fallback spending data for days 1 to 31 when no live transactions exist yet
  final Map<int, double> _fallbackDailySpending = const {
    1: 95.0,
    2: 0.0,
    3: 110.0,
    4: 70.0,
    5: 0.0,
    6: 70.0,
    7: 70.0,
    8: 200.0,
    9: 0.0,
    10: 55.0,
    11: 0.0,
    12: 45.0,
    13: 0.0,
    14: 110.0,
    15: 0.0,
    16: 35.0,
    17: 40.0,
    18: 0.0,
    19: 40.0,
    20: 0.0,
    21: 155.0,
    22: 0.0,
    23: 70.0,
    24: 60.0,
    25: 60.0,
    26: 115.0,
    27: 0.0,
    28: 60.0,
    29: 40.0,
    30: 0.0,
    31: 40.0,
  };

  int? _hoveredDay;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
    _selectedSort = widget.initialSort;
  }

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '\$$integerPart.${parts[1]}';
  }

  String _currentMonthLabel() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final Color bgColor = isDark
        ? const Color(0xFF090D16) // Rich dark obsidian
        : const Color(0xFFF8FAFC);
    final Color cardBg = isDark
        ? const Color(0xFF131926) // Elevated card background
        : Colors.white;
    final Color cardBorder = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color textMuted = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    // 1. Resolve Active Wallet
    final walletsState = ref.watch(walletsProvider);
    final wallets = walletsState.wallets;
    Wallet? activeWallet;
    for (final w in wallets) {
      if (w.id == widget.walletId) {
        activeWallet = w;
        break;
      }
    }
    if (activeWallet == null && wallets.isNotEmpty) {
      activeWallet = wallets.first;
    }

    // 2. Fetch Transactions for this Wallet
    final transactionsState = ref.watch(transactionsProvider);
    final allTransactions = transactionsState.transactions;
    final walletTransactions = allTransactions.where((t) {
      if (widget.walletId != null && widget.walletId!.isNotEmpty) {
        return t.walletId == widget.walletId;
      }
      if (activeWallet != null) {
        return t.walletId == activeWallet.id;
      }
      return true;
    }).toList();

    // 3. Filter by Time Period: This Month, This Year, All
    final now = DateTime.now();
    final List<TransactionModel> filteredTransactions = walletTransactions
        .where((t) {
          if (_selectedPeriod == 'This Month' || _selectedPeriod == 'Month') {
            return t.transactionDate.year == now.year &&
                t.transactionDate.month == now.month;
          } else if (_selectedPeriod == 'This Year' ||
              _selectedPeriod == 'Year') {
            return t.transactionDate.year == now.year;
          }
          return true;
        })
        .toList();

    // 4. Sort: by Date or by Amount
    if (_selectedSort == 'Amount') {
      filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
    } else {
      filteredTransactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );
    }

    // 5. Calculate Totals
    double totalSpent = 0.0;
    for (final t in filteredTransactions) {
      if (t.type.toLowerCase() == 'expense') {
        totalSpent += t.amount;
      }
    }

    final double displaySpent =
        widget.spentAmount ??
        (filteredTransactions.isNotEmpty ? totalSpent : 356.00);

    // 6. Compute Daily Spending for Chart
    final Map<int, double> dailySpendingMap = {};
    for (final t in filteredTransactions) {
      if (t.type.toLowerCase() == 'expense') {
        final day = t.transactionDate.day;
        dailySpendingMap[day] = (dailySpendingMap[day] ?? 0.0) + t.amount;
      }
    }
    final effectiveDailySpending = dailySpendingMap.isNotEmpty
        ? dailySpendingMap
        : _fallbackDailySpending;

    return Scaffold(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Top App Bar: Back button, Title, Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.ghost(
                    density: ButtonDensity.compact,
                    icon: Icon(
                      LucideIcons.arrowLeft,
                      size: 20,
                      color: textPrimary,
                    ),
                    onPressed: () {
                      final router = GoRouter.maybeOf(context);
                      if (router != null && router.canPop()) {
                        router.pop();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      if (activeWallet != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              activeWallet.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  IconButton.ghost(
                    density: ButtonDensity.compact,
                    icon: Icon(
                      LucideIcons.ellipsis,
                      size: 20,
                      color: textPrimary,
                    ),
                    onPressed: () {
                      showToast(
                        context: context,
                        builder: (context, overlay) {
                          return const SurfaceCard(
                            child: Basic(
                              leading: Icon(LucideIcons.info, size: 20),
                              title: Text('Wallet Filter Options'),
                              subtitle: Text(
                                'Export CSV or adjust budget rules.',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Period Filter Tabs: This Month, This Year, All
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161E2E)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: _periods.map((period) {
                          final isSelected = _selectedPeriod == period;
                          return Expanded(
                            child: GestureDetector(
                              key: ValueKey('filter_period_$period'),
                              onTap: () {
                                setState(() {
                                  _selectedPeriod = period;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  period,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? theme.colorScheme.primaryForeground
                                        : textMuted,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Month/Period Label: "October 2026 v"
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedPeriod == 'This Month'
                              ? _currentMonthLabel()
                              : (_selectedPeriod == 'This Year'
                                    ? '${now.year}'
                                    : 'All Time'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronDown,
                          size: 15,
                          color: textMuted,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Main Total Spending: e.g. "$356.00"
                    Text(
                      _formatCurrency(displaySpent),
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.0,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle / Trend Badge
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.arrowDown,
                          size: 14,
                          color: Color(0xFF22C55E), // Emerald green
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.percentageChange.abs().toInt()}% from last month',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Sort Controls Row: Date vs Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sort by:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSortChip(
                              key: const ValueKey('sort_date'),
                              label: 'Date',
                              icon: LucideIcons.calendar,
                              isSelected: _selectedSort == 'Date',
                              primaryColor: primaryColor,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              isDark: isDark,
                              onTap: () {
                                setState(() {
                                  _selectedSort = 'Date';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildSortChip(
                              key: const ValueKey('sort_amount'),
                              label: 'Amount',
                              icon: LucideIcons.arrowUpDown,
                              isSelected: _selectedSort == 'Amount',
                              primaryColor: primaryColor,
                              textPrimary: textPrimary,
                              textMuted: textMuted,
                              isDark: isDark,
                              onTap: () {
                                setState(() {
                                  _selectedSort = 'Amount';
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Daily Spending Bar Chart
                    _buildBarChart(
                      context: context,
                      theme: theme,
                      primaryColor: primaryColor,
                      textMuted: textMuted,
                      isDark: isDark,
                      dailyData: effectiveDailySpending,
                    ),

                    const SizedBox(height: 28),

                    // Category Breakdown Card
                    _buildCategoryBreakdownCard(
                      context: context,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      primaryColor: primaryColor,
                      textPrimary: textPrimary,
                      textMuted: textMuted,
                      isDark: isDark,
                      transactions: filteredTransactions,
                      totalSpent: totalSpent > 0 ? totalSpent : displaySpent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip({
    required Key key,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color primaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.18)
              : (isDark ? const Color(0xFF161E2E) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? primaryColor : textMuted),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart({
    required BuildContext context,
    required ThemeData theme,
    required Color primaryColor,
    required Color textMuted,
    required bool isDark,
    required Map<int, double> dailyData,
  }) {
    const double maxChartValue = 200.0;
    const double chartHeight = 150.0;
    final gridLineColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.5)
        : const Color(0xFFE2E8F0);

    return SizedBox(
      height: chartHeight + 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-Axis labels: 200, 100, 0
          SizedBox(
            width: 32,
            height: chartHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '200',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
                Text(
                  '100',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Bars container and X-Axis labels
          Expanded(
            child: Column(
              children: [
                // Chart Plot Area
                SizedBox(
                  height: chartHeight,
                  child: Stack(
                    children: [
                      // Grid line at 100
                      Positioned(
                        left: 0,
                        right: 0,
                        top: chartHeight * 0.5,
                        child: Container(height: 1, color: gridLineColor),
                      ),
                      // Baseline at 0
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(height: 1, color: gridLineColor),
                      ),

                      // Bars row across days 1..31
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth;
                            final barWidth = (totalWidth / 35).clamp(4.0, 8.0);

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(31, (index) {
                                final day = index + 1;
                                final val = dailyData[day] ?? 0.0;
                                final barHeight =
                                    (val / maxChartValue * chartHeight).clamp(
                                      val > 0 ? 6.0 : 0.0,
                                      chartHeight,
                                    );
                                final isHovered = _hoveredDay == day;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _hoveredDay = day;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    width: barWidth,
                                    height: chartHeight,
                                    alignment: Alignment.bottomCenter,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      width: barWidth,
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            isHovered
                                                ? primaryColor
                                                : primaryColor.withValues(
                                                    alpha: val > 150
                                                        ? 1.0
                                                        : 0.85,
                                                  ),
                                            primaryColor.withValues(
                                              alpha: 0.55,
                                            ),
                                          ],
                                        ),
                                        boxShadow: isHovered
                                            ? [
                                                BoxShadow(
                                                  color: primaryColor
                                                      .withValues(alpha: 0.5),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, -2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // X-Axis labels: 1, 8, 15, 22, 31
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '8',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '15',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '22',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '31',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard({
    required BuildContext context,
    required Color cardBg,
    required Color cardBorder,
    required Color primaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
    required List<TransactionModel> transactions,
    required double totalSpent,
  }) {
    final trackBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Category Breakdown',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  if (transactions.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${transactions.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: TransactionsEmptyView(),
            )
          else ...[
            for (int i = 0; i < transactions.length; i++) ...[
              if (i > 0) const SizedBox(height: 18),
              _buildCategoryRow(
                context: context,
                item: transactions[i],
                totalSpent: totalSpent,
                primaryColor: primaryColor,
                trackBg: trackBg,
                textPrimary: textPrimary,
                textMuted: textMuted,
                isDark: isDark,
              ),
            ],
          ],

          const SizedBox(height: 24),

          // Footer: "View all categories >"
          GestureDetector(
            onTap: () {
              if (widget.onViewAllCategories != null) {
                widget.onViewAllCategories!();
              } else {
                ref
                    .read(servicesProvider.notifier)
                    .fetchCategoriesAndServices();
                showToast(
                  context: context,
                  builder: (context, overlay) {
                    return const SurfaceCard(
                      child: Basic(
                        leading: Icon(LucideIcons.listFilter, size: 20),
                        title: Text('Categories'),
                        subtitle: Text(
                          'Opening category breakdown and recipients...',
                        ),
                      ),
                    );
                  },
                );
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View all categories',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: 16, color: textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow({
    required BuildContext context,
    required TransactionModel item,
    required double totalSpent,
    required Color primaryColor,
    required Color trackBg,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    final percent = totalSpent > 0
        ? ((item.amount / totalSpent) * 100).round()
        : 0;
    final icon = TransactionRow.resolveIcon(item.serviceIcon);
    final color = TransactionRow.resolveColor(item.serviceColor);
    final name =
        item.serviceName ??
        item.description ??
        (item.type.toLowerCase() == 'income' ? 'Income' : 'Expense');

    return GestureDetector(
      onTap: () {
        SendRequestModal.show(
          context,
          mode: TransferMode.send,
          recipientName: item.serviceName ?? name,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Circular Service Icon or Network Image
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF27272A)
                  : color.withValues(alpha: 0.15),
            ),
            alignment: Alignment.center,
            child:
                item.serviceImageUrl != null && item.serviceImageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: CachedNetworkImage(
                      imageUrl: item.serviceImageUrl!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, err) =>
                          Icon(icon, size: 20, color: color),
                      placeholder: (context, url) =>
                          Icon(icon, size: 20, color: color),
                    ),
                  )
                : Icon(icon, size: 20, color: color),
          ),

          const SizedBox(width: 14),

          // Name and Progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 6,
                    width: double.infinity,
                    color: trackBg,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percent > 0
                          ? (percent / 100.0).clamp(0.02, 1.0)
                          : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Right: Percent & Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(item.amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Backwards compatibility aliases
typedef TransactionDetailsScreen = TransactionDetailsPage;
typedef SpendingScreen = TransactionDetailsPage;
