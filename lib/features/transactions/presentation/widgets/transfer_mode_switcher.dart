import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../send_request_modal.dart';

/// Segmented tab switcher between one-time ('ครั้งเดียว') and recurring ('รายเดือน') transfers.
class TransferModeSwitcher extends StatelessWidget {
  const TransferModeSwitcher({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    required this.toastContext,
    required this.modalBg,
    required this.modalFg,
    required this.modalMutedBg,
    required this.modalMutedFg,
  });

  final TransferMode selectedMode;
  final ValueChanged<TransferMode> onModeChanged;
  final BuildContext toastContext;
  final Color modalBg;
  final Color modalFg;
  final Color modalMutedBg;
  final Color modalMutedFg;

  Widget _buildTab(String label, TransferMode mode) {
    final isSelected = selectedMode == mode;
    return GestureDetector(
      onTap: () {
        if (mode == TransferMode.request) {
          showToast(
            context: toastContext,
            location: ToastLocation.topCenter,
            showDuration: const Duration(seconds: 3),
            builder: (context, overlay) {
              return SurfaceCard(
                child: Basic(
                  leading: const Icon(LucideIcons.sparkles, size: 18),
                  title: const Text('กำลังพัฒนา'),
                  subtitle: const Text(
                    'ฟังก์ชันรายเดือนกำลังอยู่ระหว่างการพัฒนา',
                  ),
                ),
              );
            },
          );
          return;
        }
        onModeChanged(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? modalBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? modalFg : modalMutedFg,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: modalMutedBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTab('ครั้งเดียว', TransferMode.send),
          _buildTab('รายเดือน', TransferMode.request),
        ],
      ),
    );
  }
}
