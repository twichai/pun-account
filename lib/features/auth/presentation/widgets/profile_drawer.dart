import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../controllers/auth_controller.dart';

/// Bottom Drawer presenting Solopreneur profile details and secure logout action.
class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  /// Opens the Profile Drawer from the bottom, responsive to screen height
  static Future<void> show(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return showOverlay(
      context,
      DrawerConfiguration(
        position: OverlayPosition.bottom,
        showDragHandle: true,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
        ),
      ),
      builder: (context) => const ProfileDrawer(),
    ).future;
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog before logging out
    final shouldLogout = await showOverlay<bool>(
      context,
      DialogConfiguration(),
      builder: (dialogContext) {
        return AlertDialog(
          leading: const Icon(
            LucideIcons.logOut,
            size: 24,
            color: Color(0xFFEF4444),
          ),
          title: const Text('Log Out'),
          content: const Text(
            'Are you sure you want to log out of your Pun Account on this device?',
          ),
          actions: [
            OutlineButton(
              child: const Text('Cancel'),
              onPressed: () => closeOverlay(dialogContext, false),
            ),
            DestructiveButton(
              child: const Text('Log Out'),
              onPressed: () => closeOverlay(dialogContext, true),
            ),
          ],
        );
      },
    ).future;

    if (shouldLogout == true && context.mounted) {
      // Close the profile drawer
      await closeOverlay(context);

      // Perform auth sign out
      await ref.read(authProvider.notifier).signOut();

      // Ensure root navigation to home (AuthGate will show SignInScreen)
      if (context.mounted) {
        try {
          context.go(AppRoutes.signIn);
        } catch (_) {}

        showToast(
          context: context,
          builder: (toastContext, overlay) {
            return const SurfaceCard(
              child: Basic(
                leading: Icon(LucideIcons.checkCheck, size: 20),
                title: Text('Logged Out'),
                subtitle: Text('You have safely signed out of your account.'),
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final authState = ref.watch(authProvider);
    final user = authState.session?.user;

    final displayName = user?.name.isNotEmpty == true ? user!.name : 'Solopreneur';
    final email = user?.email.isNotEmpty == true ? user!.email : 'solopreneur@pun.app';
    final avatarUrl = user?.avatarUrl;
    final businessName = user?.businessName?.isNotEmpty == true
        ? user!.businessName!
        : 'One-Person Company';
    final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P';

    return Center(
      heightFactor: 1.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            4,
            24,
            28 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Row with Title and Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Account Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => closeOverlay(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Center Profile Avatar & Identifiers
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                          border: Border.all(
                            color: const Color(0xFFEAB308).withValues(alpha: 0.6),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEAB308).withValues(
                                alpha: isDark ? 0.2 : 0.1,
                              ),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(38),
                                child: CachedNetworkImage(
                                  imageUrl: avatarUrl,
                                  width: 76,
                                  height: 76,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, err) => Center(
                                    child: Text(
                                      initialLetter,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Center(
                                    child: Text(
                                      initialLetter,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  initialLetter,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Solopreneur Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAB308).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFEAB308).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.sparkles,
                              size: 13,
                              color: Color(0xFFEAB308),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              businessName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEAB308),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Details Card
                SurfaceCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoRow(
                          icon: LucideIcons.shieldCheck,
                          iconColor: const Color(0xFF10B981),
                          label: 'Authentication',
                          value: 'Google Verified',
                          isDark: isDark,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(),
                        ),
                        _buildInfoRow(
                          icon: LucideIcons.briefcase,
                          iconColor: const Color(0xFF38BDF8),
                          label: 'Account Role',
                          value: 'Founder / Solopreneur',
                          isDark: isDark,
                        ),
                        if (user != null && user.id.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(),
                          ),
                          _buildInfoRow(
                            icon: LucideIcons.fingerprint,
                            iconColor: const Color(0xFFA855F7),
                            label: 'User ID',
                            value: user.id.length > 12
                                ? '${user.id.substring(0, min(8, user.id.length))}...'
                                : user.id,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Action Button
                DestructiveButton(
                  onPressed: () => _handleLogout(context, ref),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.logOut, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Cancel / Close Button
                OutlineButton(
                  onPressed: () => closeOverlay(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
