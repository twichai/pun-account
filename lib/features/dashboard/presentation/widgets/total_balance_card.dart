import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../wallets/domain/models/wallet.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

/// Total Balance Card matching the reference design layout with our theme tokens.
class TotalBalanceCard extends ConsumerStatefulWidget {
  const TotalBalanceCard({super.key, this.onTapCard});

  final VoidCallback? onTapCard;

  @override
  ConsumerState<TotalBalanceCard> createState() => _TotalBalanceCardState();
}

class _TotalBalanceCardState extends ConsumerState<TotalBalanceCard> {
  bool _isBalanceVisible = true;
  int _index = 0;

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

    double calculatedBalance = 0.0;
    if (wallets.isNotEmpty) {
      for (final w in wallets) {
        calculatedBalance += w.balance;
      }
    }
    // If no wallets or empty, show demo $2,500.00 as in the design reference
    final double displayBalance = wallets.isNotEmpty
        ? calculatedBalance
        : 2500.00;

    // Items for each of the 5 indicator steps ("เเต่ละอัน")
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Total Balance',
        'balance': displayBalance,
        'change': '+\$240.00 this month',
        'isPositive': true,
        'badgeIcon': LucideIcons.sparkles,
      },
      {
        'title': wallets.isNotEmpty ? wallets[0].name : 'Primary Account',
        'balance': wallets.isNotEmpty
            ? wallets[0].balance
            : displayBalance * 0.65,
        'change': '+\$180.50 this month',
        'isPositive': true,
        'badgeIcon': LucideIcons.creditCard,
      },
      {
        'title': wallets.length > 1 ? wallets[1].name : 'Cash Wallet',
        'balance': wallets.length > 1 ? wallets[1].balance : 18500.00,
        'change': '+\$50.00 this week',
        'isPositive': true,
        'badgeIcon': LucideIcons.banknote,
      },
      {
        'title': wallets.length > 2 ? wallets[2].name : 'Tax Reserve',
        'balance': wallets.length > 2
            ? wallets[2].balance
            : displayBalance * 0.20,
        'change': '-\$120.00 last month',
        'isPositive': false,
        'badgeIcon': LucideIcons.shieldCheck,
      },
      {
        'title': wallets.length > 3 ? wallets[3].name : 'Savings & Growth',
        'balance': wallets.length > 3
            ? wallets[3].balance
            : displayBalance * 0.15,
        'change': '+\$10.00 interest earned',
        'isPositive': true,
        'badgeIcon': LucideIcons.trendingUp,
      },
    ];

    final currentItem = items[_index.clamp(0, items.length - 1)];
    final currentTitle = currentItem['title'] as String;
    final currentBalance = currentItem['balance'] as double;
    final currentChange = currentItem['change'] as String;
    final isPositive = currentItem['isPositive'] as bool;
    final badgeIcon = currentItem['badgeIcon'] as IconData;

    return GestureDetector(
      onTap: widget.onTapCard,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -100 && _index < items.length - 1) {
            setState(() {
              _index++;
            });
          } else if (details.primaryVelocity! > 100 && _index > 0) {
            setState(() {
              _index--;
            });
          }
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E293B), // slate-800
                    const Color(0xFF0F172A), // slate-900
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF1F5F9), // slate-100
                  ],
          ),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155) // slate-700
                : const Color(0xFFE2E8F0), // slate-200
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative background glow with theme primary tint
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Title + Eye Toggle & Decorative mini-card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              currentTitle,
                              key: ValueKey(currentTitle),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF94A3B8) // slate-400
                                    : const Color(0xFF64748B), // slate-500
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isBalanceVisible = !_isBalanceVisible;
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                _isBalanceVisible
                                    ? LucideIcons.eye
                                    : LucideIcons.eyeOff,
                                size: 16,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Decorative right badge / card icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155).withValues(alpha: 0.6)
                              : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            badgeIcon,
                            key: ValueKey(badgeIcon),
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Large Balance Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _isBalanceVisible
                          ? _formatAmount(currentBalance)
                          : '••••••••',
                      key: ValueKey('$_isBalanceVisible-$_index'),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle change & DotIndicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? LucideIcons.arrowUp
                                : LucideIcons.arrowDown,
                            size: 14,
                            color: isPositive
                                ? const Color(0xFF22C55E) // emerald-500
                                : const Color(0xFFEF4444), // red-500
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentChange,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isPositive
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),

                      // A simple pager-like dot indicator with 5 steps.
                      // Tap/click updates the current index via onChanged.
                      DotIndicator(
                        index: _index,
                        length: 5,
                        onChanged: (index) {
                          setState(() {
                            _index = index;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
