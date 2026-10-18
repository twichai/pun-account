import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../transactions/domain/models/transaction.dart';

/// Single transaction item row displaying service icon/image, name, date, and amount.
class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.item, this.onTap});

  final TransactionModel item;
  final VoidCallback? onTap;

  static IconData resolveIcon(String? iconName) {
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

  static Color resolveColor(String? hexString) {
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

  static String formatDate(DateTime date) {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPositive = item.type.toLowerCase() == 'income';
    final icon = resolveIcon(item.serviceIcon);
    final color = resolveColor(item.serviceColor);
    final title =
        item.serviceName ??
        item.description ??
        (isPositive ? 'Income' : 'Expense');
    final subtitle = item.description != null && item.description != title
        ? '${item.description!} • ${formatDate(item.transactionDate)}'
        : '${item.type.toUpperCase()} • ${formatDate(item.transactionDate)}';
    final amountText =
        '${isPositive ? "+" : "-"}\$${item.amount.toStringAsFixed(2)}';

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Logo Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
              shape: BoxShape.circle,
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

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
