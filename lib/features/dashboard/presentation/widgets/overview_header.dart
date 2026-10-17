import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Fixed top header displaying profile avatar and notification icon button.
class OverviewHeader extends StatelessWidget {
  const OverviewHeader({
    super.key,
    this.onNotificationPressed,
    this.onProfilePressed,
  });

  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  @override
  Widget build(BuildContext context) {
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
                border: Border.all(
                  color: const Color(0xFF3F3F46),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: const Text('🐣', style: TextStyle(fontSize: 22)),
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
