import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../transactions/presentation/send_request_modal.dart';

/// Send and Request action buttons row matching the reference design layout.
class QuickTransferButtons extends StatelessWidget {
  const QuickTransferButtons({
    super.key,
    this.onSendPressed,
    this.onRequestPressed,
  });

  final VoidCallback? onSendPressed;
  final VoidCallback? onRequestPressed;

  void _handleSend(BuildContext context) {
    if (onSendPressed != null) {
      onSendPressed!();
    } else {
      SendRequestModal.show(context, mode: TransferMode.send);
    }
  }

  void _handleRequest(BuildContext context) {
    if (onRequestPressed != null) {
      onRequestPressed!();
    } else {
      SendRequestModal.show(context, mode: TransferMode.request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color cardBg = isDark
        ? const Color(0xFF1E293B) // slate-800
        : const Color(0xFFF8FAFC); // slate-50
    final Color borderColor = isDark
        ? const Color(0xFF334155) // slate-700
        : const Color(0xFFE2E8F0); // slate-200
    final Color circleBg = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.8)
        : const Color(0xFFE2E8F0);
    final Color fgColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Row(
      children: [
        // Send Button
        Expanded(
          child: _buildButton(
            context: context,
            icon: LucideIcons.arrowUp,
            label: 'Send',
            cardBg: cardBg,
            borderColor: borderColor,
            circleBg: circleBg,
            fgColor: fgColor,
            onTap: () => _handleSend(context),
          ),
        ),

        const SizedBox(width: 14),

        // Request Button
        Expanded(
          child: _buildButton(
            context: context,
            icon: LucideIcons.arrowDown,
            label: 'Request',
            cardBg: cardBg,
            borderColor: borderColor,
            circleBg: circleBg,
            fgColor: fgColor,
            onTap: () => _handleRequest(context),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color cardBg,
    required Color borderColor,
    required Color circleBg,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 94,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleBg,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: fgColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
