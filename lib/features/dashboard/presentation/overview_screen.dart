import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../transactions/presentation/providers/transactions_provider.dart';
import '../../transactions/presentation/send_request_modal.dart';
import '../../wallets/presentation/providers/wallets_provider.dart';

/// Redesigned Home Overview screen connected to real Wallets & Transactions
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({
    super.key,
    this.onNavigateToWallets,
    this.onNavigateToServices,
    this.onAddTransaction,
  });

  final VoidCallback? onNavigateToWallets;
  final VoidCallback? onNavigateToServices;
  final VoidCallback? onAddTransaction;

  void _onOpenSendModal(BuildContext context, TransferMode mode) {
    SendRequestModal.show(context, mode: mode);
  }

  IconData _resolveIcon(String? iconName) {
    switch (iconName) {
      case 'cloud':
        return LucideIcons.cloud;
      case 'sparkles':
        return LucideIcons.sparkles;
      case 'video':
        return LucideIcons.video;
      case 'palette':
        return LucideIcons.palette;
      case 'laptop':
        return LucideIcons.laptop;
      case 'code':
        return LucideIcons.code;
      case 'database':
        return LucideIcons.database;
      case 'triangle':
        return LucideIcons.triangle;
      case 'music':
        return LucideIcons.music;
      case 'play-circle':
        return LucideIcons.play;
      case 'book-open':
        return LucideIcons.bookOpen;
      case 'layers':
        return LucideIcons.layers;
      default:
        return LucideIcons.receipt;
    }
  }

  Color _resolveColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return const Color(0xFF6366F1);
    }
    final hex = hexString.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return const Color(0xFF6366F1);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0 && now.day == date.day) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return 'Today $hour:$minute';
    } else if (diff.inDays == 1 ||
        (diff.inHours < 48 && now.day - date.day == 1)) {
      return 'Yesterday';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(date.month - 1).clamp(0, 11)];
    return '${date.day} $m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final walletsState = ref.watch(walletsProvider);
    final wallets = walletsState.wallets;
    final totalBalance = wallets.fold<double>(0.0, (acc, w) => acc + w.balance);
    final balanceParts = totalBalance.toStringAsFixed(2).split('.');
    final balanceInt = balanceParts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    final balanceDec = balanceParts[1];

    final transactionsState = ref.watch(transactionsProvider);
    final transactions = transactionsState.transactions;
    final expenses = transactions
        .where((t) => t.type.toLowerCase() == 'expense')
        .toList();
    final totalSpending = expenses.fold<double>(
      0.0,
      (acc, t) => acc + t.amount,
    );
    final spendingFormatted = totalSpending.toStringAsFixed(2);
    final spendingInt = spendingFormatted
        .split('.')[0]
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    final recentExpenses = expenses.take(4).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Dark Header Area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar & Notification Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF27272A),
                        border: Border.all(
                          color: const Color(0xFF3F3F46),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🐣', style: TextStyle(fontSize: 22)),
                    ),
                    // Notification Bell Button
                    IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: const Icon(
                        LucideIcons.bell,
                        size: 20,
                        color: Color(0xFFA1A1AA),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Balance Row with Stacked Cards graphic on the right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Balance Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA1A1AA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$ $balanceInt',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '.$balanceDec',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFA1A1AA)
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Stacked Cards Visual Teaser (Right side)
                    GestureDetector(
                      onTap: onNavigateToWallets,
                      child: SizedBox(
                        width: 72,
                        height: 90,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Blue Card edge
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: 32,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(14),
                                    right: Radius.circular(4),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF38BDF8),
                                      Color(0xFF0284C7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Mint Card edge
                            Positioned(
                              right: 14,
                              top: 6,
                              bottom: 6,
                              width: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(14),
                                    right: Radius.circular(4),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2DD4BF),
                                      Color(0xFF0D9488),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Yellow Card edge
                            Positioned(
                              right: 28,
                              top: 12,
                              bottom: 12,
                              width: 28,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(14),
                                    right: Radius.circular(4),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFE033),
                                      Color(0xFFF59E0B),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Quick Action Buttons: Send & Request
                Row(
                  children: [
                    // Send Button
                    GestureDetector(
                      onTap: () => _onOpenSendModal(context, TransferMode.send),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF27272A)
                              : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3F3F46)
                                : const Color(0xFFE4E4E7),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF09090B),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                LucideIcons.arrowLeft,
                                size: 12,
                                color: isDark
                                    ? const Color(0xFF09090B)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Send',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Request Button
                    GestureDetector(
                      onTap: () =>
                          _onOpenSendModal(context, TransferMode.request),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF27272A)
                              : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3F3F46)
                                : const Color(0xFFE4E4E7),
                          ),
                        ),
                        child: const Text(
                          'Request',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // "Spending" Card with real transaction amount & icons
                GestureDetector(
                  onTap: onNavigateToServices,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF18181B)
                          : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF27272A)
                            : const Color(0xFFE4E4E7),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Label & Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spending',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA1A1AA),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$$spendingInt.${spendingFormatted.split(".")[1]}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Right: Overlapping circular avatars / logos from real expenses
                        if (recentExpenses.isNotEmpty)
                          SizedBox(
                            height: 44,
                            width: (recentExpenses.length * 24.0) + 24.0,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.centerRight,
                              children: [
                                for (
                                  int i = 0;
                                  i < recentExpenses.length;
                                  i++
                                ) ...[
                                  Positioned(
                                    right:
                                        (recentExpenses.length - 1 - i) * 24.0,
                                    child: _buildSmallLogoAvatar(
                                      recentExpenses[i],
                                      isDark,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        else
                          Icon(
                            LucideIcons.arrowRight,
                            size: 18,
                            color: isDark
                                ? const Color(0xFFA1A1AA)
                                : const Color(0xFF71717A),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet: White / Contrasting surface
          Container(
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: Icon(
                        LucideIcons.slidersHorizontal,
                        size: 18,
                        color: isDark
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                      ),
                      onPressed: () {},
                    ),
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: Icon(
                        LucideIcons.search,
                        size: 18,
                        color: isDark
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Transactions List
                if (transactionsState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (transactionsState.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.circleAlert,
                          color: Color(0xFFEF4444),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ไม่สามารถโหลดรายการได้: ${transactionsState.errorMessage}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        IconButton.ghost(
                          density: ButtonDensity.compact,
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          onPressed: () => ref
                              .read(transactionsProvider.notifier)
                              .fetchTransactions(),
                        ),
                      ],
                    ),
                  )
                else if (transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 20,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(
                          LucideIcons.receipt,
                          size: 40,
                          color: Color(0xFF71717A),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ยังไม่มีรายการธุรกรรม',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF09090B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'เริ่มทำรายการได้โดยกดปุ่ม Send หรือ Request ด้านบน',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF71717A),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      return _buildTransactionRow(item, isDark);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLogoAvatar(TransactionModel item, bool isDark) {
    final icon = _resolveIcon(item.serviceIcon);
    final color = _resolveColor(item.serviceColor);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: item.serviceImageUrl != null && item.serviceImageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: item.serviceImageUrl!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorWidget: (context, url, err) =>
                    Icon(icon, size: 16, color: color),
                placeholder: (context, url) =>
                    Icon(icon, size: 16, color: color),
              ),
            )
          : Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildTransactionRow(TransactionModel item, bool isDark) {
    final isPositive = item.type.toLowerCase() == 'income';
    final icon = _resolveIcon(item.serviceIcon);
    final color = _resolveColor(item.serviceColor);
    final title =
        item.serviceName ??
        item.description ??
        (isPositive ? 'Income' : 'Expense');
    final subtitle = item.description != null && item.description != title
        ? '${item.description!} • ${_formatDate(item.transactionDate)}'
        : '${item.type.toUpperCase()} • ${_formatDate(item.transactionDate)}';
    final amountText =
        '${isPositive ? "+" : "-"}\$${item.amount.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Logo Avatar with colored status dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFF4F4F5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child:
                    item.serviceImageUrl != null &&
                        item.serviceImageUrl!.isNotEmpty
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
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF18181B) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Title & Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF09090B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71717A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Amount
          Text(
            amountText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive
                  ? const Color(0xFF10B981) // Emerald Green
                  : (isDark ? Colors.white : const Color(0xFF09090B)),
            ),
          ),
        ],
      ),
    );
  }
}
