import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Empty state displayed when no transactions are found.
class TransactionsEmptyView extends StatelessWidget {
  const TransactionsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
              color: isDark ? Colors.white : const Color(0xFF09090B),
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
    );
  }
}
