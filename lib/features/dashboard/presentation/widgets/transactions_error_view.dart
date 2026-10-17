import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Error banner displayed when transaction fetching fails.
class TransactionsErrorView extends StatelessWidget {
  const TransactionsErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              'ไม่สามารถโหลดรายการได้: $errorMessage',
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
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
