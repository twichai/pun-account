import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../transactions/presentation/send_request_modal.dart';

/// 4 quick circular action buttons: Recipients, Scan, Top up, More.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    this.onRecipientsPressed,
    this.onScanPressed,
    this.onTopUpPressed,
    this.onMorePressed,
  });

  final VoidCallback? onRecipientsPressed;
  final VoidCallback? onScanPressed;
  final VoidCallback? onTopUpPressed;
  final VoidCallback? onMorePressed;

  void _handleScan(BuildContext context) {
    if (onScanPressed != null) {
      onScanPressed!();
    } else {
      showToast(
        context: context,
        builder: (context, overlay) {
          return const SurfaceCard(
            child: Basic(
              leading: Icon(LucideIcons.scanLine, size: 20),
              title: Text('Scan QR Code'),
              subtitle: Text(
                'Camera scanner ready for merchant & recipient QR',
              ),
            ),
          );
        },
      );
    }
  }

  void _handleTopUp(BuildContext context) {
    if (onTopUpPressed != null) {
      onTopUpPressed!();
    } else {
      SendRequestModal.show(context, mode: TransferMode.request);
    }
  }

  void _handleMore(BuildContext context) {
    if (onMorePressed != null) {
      onMorePressed!();
    } else {
      showToast(
        context: context,
        builder: (context, overlay) {
          return const SurfaceCard(
            child: Basic(
              leading: Icon(LucideIcons.ellipsis, size: 20),
              title: Text('More Features'),
              subtitle: Text('Account statements, export & analytics'),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color buttonBg = isDark
        ? const Color(0xFF1E293B) // slate-800
        : const Color(0xFFF1F5F9); // slate-100
    final Color borderColor = isDark
        ? const Color(0xFF334155) // slate-700
        : const Color(0xFFE2E8F0); // slate-200
    final Color iconColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color textColor = isDark
        ? const Color(0xFF94A3B8) // slate-400
        : const Color(0xFF64748B); // slate-500

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          icon: LucideIcons.users,
          label: 'Recipients',
          buttonBg: buttonBg,
          borderColor: borderColor,
          iconColor: iconColor,
          textColor: textColor,
          onTap: onRecipientsPressed ?? () {},
        ),
        _buildActionItem(
          icon: LucideIcons.scanLine,
          label: 'Scan',
          buttonBg: buttonBg,
          borderColor: borderColor,
          iconColor: iconColor,
          textColor: textColor,
          onTap: () => _handleScan(context),
        ),
        _buildActionItem(
          icon: LucideIcons.plus,
          label: 'Top up',
          buttonBg: buttonBg,
          borderColor: borderColor,
          iconColor: iconColor,
          textColor: textColor,
          onTap: () => _handleTopUp(context),
        ),
        _buildActionItem(
          icon: LucideIcons.ellipsis,
          label: 'More',
          buttonBg: buttonBg,
          borderColor: borderColor,
          iconColor: iconColor,
          textColor: textColor,
          onTap: () => _handleMore(context),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color buttonBg,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonBg,
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
