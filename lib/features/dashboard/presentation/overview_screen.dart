import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../transactions/presentation/providers/transactions_provider.dart';

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

    final transactionsState = ref.watch(transactionsProvider);
    final transactions = transactionsState.transactions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Top Header: Avatar & Notification Bell
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
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
        ),

        // Main Body: Overview summary behind + Draggable Bottom Sheet in front
        Expanded(
          child: Stack(
            children: [
              // Balance, Quick Actions, Spending Card
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(),
              ),

              // Bottom Sheet: DraggableScrollableSheet
              // maxChildSize = 1.0 reaches exactly to the top of Expanded (right under the Header)
              DraggableScrollableSheet(
                initialChildSize: 0.60,
                minChildSize: 0.60,
                maxChildSize: 1.0,
                snap: true,
                snapSizes: const [0.60, 1.0],
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
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
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
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.3),
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
                                    icon: const Icon(
                                      LucideIcons.refreshCw,
                                      size: 16,
                                    ),
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
                            for (
                              int index = 0;
                              index < transactions.length;
                              index++
                            ) ...[
                              if (index > 0) const SizedBox(height: 14),
                              _buildTransactionRow(transactions[index], isDark),
                            ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
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
