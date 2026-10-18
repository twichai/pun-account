import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../auth/controllers/auth_controller.dart';

/// Fixed top header displaying profile avatar (from user.avatarUrl) and notification icon button with red badge.
class OverviewHeader extends ConsumerWidget {
  const OverviewHeader({
    super.key,
    this.avatarUrl,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  final String? avatarUrl;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = ref.watch(authProvider).session?.user;
    final effectiveAvatarUrl = avatarUrl ?? user?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: onProfilePressed,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFE2E8F0),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: effectiveAvatarUrl != null && effectiveAvatarUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: CachedNetworkImage(
                        imageUrl: effectiveAvatarUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, err) => const Center(
                          child: Text(
                            'P',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => const Center(
                          child: Text(
                            'P',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'P',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),

          // Notification Bell Button with Red Dot Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton.ghost(
                density: ButtonDensity.icon,
                icon: Icon(
                  LucideIcons.bell,
                  size: 20,
                  color: isDark
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF64748B),
                ),
                onPressed: onNotificationPressed ?? () {},
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
