import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Information about a subscription or cloud service payee.
class TaskServiceInfo {
  final String name;
  final String category;
  final String subtitle;
  final String? lastCost;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  const TaskServiceInfo({
    required this.name,
    required this.category,
    required this.subtitle,
    this.lastCost,
    required this.icon,
    required this.color,
    this.imageUrl,
  });
}

/// In-memory preset of services with past payment costs.
final Map<String, TaskServiceInfo> taskServicesDb = {
  'AWS Cloud': const TaskServiceInfo(
    name: 'AWS Cloud',
    category: 'Cloud Infrastructure',
    subtitle: 'Cloud Infrastructure • @aws.billing',
    lastCost: '345.50',
    icon: LucideIcons.cloud,
    color: Color(0xFFF59E0B),
    imageUrl: 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4',
  ),
  'AWS Infrastructure': const TaskServiceInfo(
    name: 'AWS Infrastructure',
    category: 'Cloud Infrastructure',
    subtitle: 'Cloud Infrastructure • @aws.billing',
    lastCost: '345.50',
    icon: LucideIcons.cloud,
    color: Color(0xFFF59E0B),
    imageUrl: 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4',
  ),
  'OpenAI': const TaskServiceInfo(
    name: 'OpenAI API & ChatGPT',
    category: 'AI Services',
    subtitle: 'AI & Intelligence • @openai.api',
    lastCost: '120.00',
    icon: LucideIcons.sparkles,
    color: Color(0xFF10B981),
    imageUrl: 'https://avatars.githubusercontent.com/u/14957082?s=200&v=4',
  ),
  'OpenAI API & ChatGPT': const TaskServiceInfo(
    name: 'OpenAI API & ChatGPT',
    category: 'AI Services',
    subtitle: 'AI & Intelligence • @openai.api',
    lastCost: '120.00',
    icon: LucideIcons.sparkles,
    color: Color(0xFF10B981),
    imageUrl: 'https://avatars.githubusercontent.com/u/14957082?s=200&v=4',
  ),
  'Figma': const TaskServiceInfo(
    name: 'Figma Enterprise',
    category: 'Design Tools',
    subtitle: 'UI/UX Design Platform • @figma.team',
    lastCost: '45.00',
    icon: LucideIcons.palette,
    color: Color(0xFFA855F7),
    imageUrl: 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4',
  ),
  'Apple': const TaskServiceInfo(
    name: 'Apple Developer Account',
    category: 'Developer Services',
    subtitle: 'Services & Subscriptions • @apple.services',
    lastCost: '60.00',
    icon: LucideIcons.laptop,
    color: Color(0xFF0EA5E9),
    imageUrl: 'https://avatars.githubusercontent.com/u/10639145?s=200&v=4',
  ),
  'Google Cloud': const TaskServiceInfo(
    name: 'Google Cloud Platform',
    category: 'Cloud Hosting',
    subtitle: 'Hosting & Compute • @google.cloud',
    lastCost: '89.00',
    icon: LucideIcons.globe,
    color: Color(0xFFEF4444),
    imageUrl: 'https://avatars.githubusercontent.com/u/1342004?s=200&v=4',
  ),
  'GitHub': const TaskServiceInfo(
    name: 'GitHub Enterprise',
    category: 'Developer Tools',
    subtitle: 'Code & CI/CD • @github.dev',
    lastCost: '21.00',
    icon: LucideIcons.code,
    color: Color(0xFF6366F1),
    imageUrl: 'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
  ),
  'Supabase Database': const TaskServiceInfo(
    name: 'Supabase Database',
    category: 'Backend & DB',
    subtitle: 'Managed PostgreSQL • @supabase.io',
    lastCost: '25.00',
    icon: LucideIcons.database,
    color: Color(0xFF22C55E),
    imageUrl: 'https://avatars.githubusercontent.com/u/54469796?s=200&v=4',
  ),
  'Vercel Pro': const TaskServiceInfo(
    name: 'Vercel Pro',
    category: 'Deployment & CDN',
    subtitle: 'Edge Network • @vercel.app',
    lastCost: '20.00',
    icon: LucideIcons.triangle,
    color: Color(0xFF64748B),
    imageUrl: 'https://avatars.githubusercontent.com/u/14985020?s=200&v=4',
  ),
  'New Service': const TaskServiceInfo(
    name: 'New Service (No History)',
    category: 'Custom Service',
    subtitle: 'No previous payments in database',
    lastCost: null,
    icon: LucideIcons.circleDashed,
    color: Color(0xFF71717A),
  ),
};

/// Resolves task info by exact name or substring matching.
TaskServiceInfo resolveTaskService(String taskName) {
  if (taskServicesDb.containsKey(taskName)) {
    return taskServicesDb[taskName]!;
  }
  for (final entry in taskServicesDb.entries) {
    if (entry.key.toLowerCase() == taskName.toLowerCase() ||
        taskName.toLowerCase().contains(entry.key.toLowerCase()) ||
        entry.key.toLowerCase().contains(taskName.toLowerCase())) {
      return entry.value;
    }
  }
  return TaskServiceInfo(
    name: taskName,
    category: 'Service / Payee',
    subtitle: 'Custom payee • @${taskName.toLowerCase().replaceAll(' ', '')}',
    lastCost: null,
    icon: LucideIcons.cloud,
    color: const Color(0xFFF59E0B),
  );
}

/// Card showing recipient/service information and a quick 'Use last cost' button.
class TaskServiceCard extends StatelessWidget {
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
                'ไม่พบประวัติยอดชำระในระบบสำหรับ $resolvedName (Not found cost paid last time)',
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskInfo = resolveTaskService(taskName);
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
