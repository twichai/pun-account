import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../transactions/presentation/send_request_modal.dart';

/// Spending This Month card with budget progress and subscriptions breakdown.
class SpendingSummaryCard extends StatelessWidget {
  const SpendingSummaryCard({
    super.key,
    this.monthLabel = 'Oct 2026',
    this.spentAmount = 356.00,
    this.budgetAmount = 2500.00,
    this.onMonthPressed,
    this.onItemPressed,
  });

  final String monthLabel;
  final double spentAmount;
  final double budgetAmount;
  final VoidCallback? onMonthPressed;
  final ValueChanged<String>? onItemPressed;

  String _formatCurrency(double amount) {
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

    final percentage = budgetAmount > 0
        ? ((spentAmount / budgetAmount) * 100).clamp(0, 100).toInt()
        : 0;

    final Color cardBg = isDark
        ? const Color(0xFF1E293B) // slate-800
        : Colors.white;
    final Color borderColor = isDark
        ? const Color(0xFF334155) // slate-700
        : const Color(0xFFE2E8F0); // slate-200
    final Color trackBg = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.6)
        : const Color(0xFFE2E8F0);
    final Color primaryAccent = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
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
          // Header: "Spending This Month" & "Oct 2026 >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending This Month',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: onMonthPressed,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      monthLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
            ],
          ),

          const SizedBox(height: 14),

          // Spending Balance: "$356.00"
          Text(
            _formatCurrency(spentAmount),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'of ${_formatCurrency(budgetAmount)} budget',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 16),

          // Main Budget Progress Bar + "14%"
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 8,
                    color: trackBg,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (percentage / 100.0).clamp(0.01, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Subscriptions & Spending breakdown items
          _buildItem(
            context: context,
            name: 'GitHub Copilot',
            amount: 256.00,
            percent: 72,
            icon: LucideIcons.code,
            iconBg: const Color(0xFF24292F),
            iconColor: Colors.white,
            primaryAccent: primaryAccent,
            trackBg: trackBg,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildItem(
            context: context,
            name: 'YouTube Premium',
            amount: 99.00,
            percent: 28,
            icon: LucideIcons.play,
            iconBg: const Color(0xFFFF0000),
            iconColor: Colors.white,
            primaryAccent: primaryAccent,
            trackBg: trackBg,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildItem(
            context: context,
            name: 'OpenAI ChatGPT Plus',
            amount: 1.00,
            percent: 0,
            icon: LucideIcons.sparkles,
            iconBg: isDark ? Colors.white : const Color(0xFF10A37F),
            iconColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            primaryAccent: primaryAccent,
            trackBg: trackBg,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required String name,
    required double amount,
    required int percent,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color primaryAccent,
    required Color trackBg,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        if (onItemPressed != null) {
          onItemPressed!(name);
        } else {
          SendRequestModal.show(
            context,
            mode: TransferMode.send,
            recipientName: name,
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Circular Service Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
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
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 5,
                    width: double.infinity,
                    color: trackBg,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percent > 0
                          ? (percent / 100.0).clamp(0.02, 1.0)
                          : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Right Percent & Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
