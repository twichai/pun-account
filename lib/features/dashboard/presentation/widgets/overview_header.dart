import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../auth/controllers/auth_controller.dart';

/// Fixed top header displaying profile avatar (from user.avatarUrl) and notification icon button.
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
    final user = ref.watch(authProvider).session?.user;
    final effectiveAvatarUrl = avatarUrl ?? user?.avatarUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                color: const Color(0xFF27272A),
                border: Border.all(color: const Color(0xFF3F3F46), width: 1.5),
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
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        placeholder: (context, url) => const Center(
                          child: Text(
                            'P',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'P',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
            ),
          ),
          // Notification Bell Button
          IconButton.ghost(
            density: ButtonDensity.icon,
            icon: const Icon(
              LucideIcons.bell,
              size: 20,
              color: Color(0xFFA1A1AA),
            ),
            onPressed: onNotificationPressed ?? () {},
          ),
        ],
      ),
    );
  }
}
