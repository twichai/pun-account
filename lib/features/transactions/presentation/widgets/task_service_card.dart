import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../categories/domain/models/service_category_item.dart';
import '../../../categories/presentation/providers/services_provider.dart';
import '../providers/transactions_provider.dart';

/// Information about a subscription or cloud service payee.
class TaskServiceInfo {
  final String? id;
  final String name;
  final String category;
  final String subtitle;
  final String? lastCost;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  const TaskServiceInfo({
    this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    this.lastCost,
    required this.icon,
    required this.color,
    this.imageUrl,
  });
}

/// Resolves task/service info from real backend services and transaction history.
TaskServiceInfo resolveTaskServiceFromState({
  required String taskName,
  required List<ServiceCategoryItem> services,
  required List<TransactionModel> transactions,
}) {
  ServiceCategoryItem? matched;

  // 1. Try matching by exact ID or name
  for (final s in services) {
    if (s.id == taskName || s.name.toLowerCase() == taskName.toLowerCase()) {
      matched = s;
      break;
    }
  }

  // 2. Try substring matching
  if (matched == null) {
    for (final s in services) {
      if (s.name.toLowerCase().contains(taskName.toLowerCase()) ||
          taskName.toLowerCase().contains(s.name.toLowerCase())) {
        matched = s;
        break;
      }
    }
  }

  if (matched != null) {
    // Find latest cost from real transaction history
    String? latestCost;
    for (final tx in transactions) {
      if (tx.serviceId == matched.id && tx.amount > 0) {
        latestCost = tx.amount.toStringAsFixed(2);
        break;
      }
    }

    final categoryName = matched.categoryTrack ?? 'Service';
    final subtitle = matched.accountNumber.isNotEmpty
        ? '$categoryName • ${matched.accountNumber}'
        : categoryName;

    return TaskServiceInfo(
      id: matched.id,
      name: matched.name,
      category: categoryName,
      subtitle: subtitle,
      lastCost: latestCost,
      icon: matched.icon,
      color: matched.color,
      imageUrl: matched.imageUrl,
    );
  }

  // If not found in services list, create dynamic info without mock data
  return TaskServiceInfo(
    id: null,
    name: taskName,
    category: 'Service / Payee',
    subtitle: 'Payee • @${taskName.toLowerCase().replaceAll(' ', '')}',
    lastCost: null,
    icon: LucideIcons.cloud,
    color: const Color(0xFFF59E0B),
  );
}

/// Card showing recipient/service information and a quick 'Use last cost' button.
class TaskServiceCard extends ConsumerWidget {
  const TaskServiceCard({
    super.key,
    required this.taskName,
    required this.onSelectLastCost,
    required this.toastContext,
    required this.modalFg,
    required this.modalMutedBg,
    required this.modalMutedFg,
    required this.modalBorder,
  });

  final String taskName;
  final ValueChanged<String> onSelectLastCost;
  final BuildContext toastContext;
  final Color modalFg;
  final Color modalMutedBg;
  final Color modalMutedFg;
  final Color modalBorder;

  void _handleUseLastCost(String? lastCost, String resolvedName) {
    if (lastCost != null && lastCost.isNotEmpty) {
      onSelectLastCost(lastCost);
      HapticFeedback.lightImpact();
      showToast(
        context: toastContext,
        location: ToastLocation.topCenter,
        showDuration: const Duration(seconds: 2),
        builder: (context, overlay) {
          return SurfaceCard(
            child: Basic(
              leading: const Icon(
                LucideIcons.check,
                size: 18,
                color: Color(0xFF10B981),
              ),
              title: const Text('ใช้ยอดล่าสุดแล้ว'),
              subtitle: Text(
                'กำหนดยอดชำระ \$$lastCost สำหรับ $resolvedName เรียบร้อยแล้ว',
              ),
            ),
          );
        },
      );
    } else {
      HapticFeedback.heavyImpact();
      showToast(
        context: toastContext,
        location: ToastLocation.topCenter,
        showDuration: const Duration(seconds: 3),
        builder: (context, overlay) {
          return SurfaceCard(
            child: Basic(
              leading: const Icon(
                LucideIcons.circleAlert,
                size: 18,
                color: Color(0xFFEF4444),
              ),
              title: const Text('ไม่พบยอดชำระล่าสุด'),
              subtitle: Text(
                'ไม่พบประวัติยอดชำระจริงในระบบสำหรับ $resolvedName',
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);
    final transactionsState = ref.watch(transactionsProvider);

    final taskInfo = resolveTaskServiceFromState(
      taskName: taskName,
      services: servicesState.allAccounts,
      transactions: transactionsState.transactions,
    );
    final lastCost = taskInfo.lastCost;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: modalMutedBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: modalBorder.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Image / Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  taskInfo.color.withValues(alpha: 0.85),
                  taskInfo.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: taskInfo.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: taskInfo.imageUrl != null && taskInfo.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: taskInfo.imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Icon(taskInfo.icon, size: 20, color: Colors.white),
                      errorWidget: (context, url, error) =>
                          Icon(taskInfo.icon, size: 20, color: Colors.white),
                    ),
                  )
                : Icon(taskInfo.icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  taskInfo.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: modalFg,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  taskInfo.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: modalMutedFg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action button
          OutlineButton(
            density: ButtonDensity.compact,
            onPressed: () => _handleUseLastCost(lastCost, taskInfo.name),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.history, size: 13),
                const SizedBox(width: 5),
                Text(
                  lastCost != null ? 'Use \$$lastCost' : 'Use last cost',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
