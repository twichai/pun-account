import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/google_logo.dart';

/// Ultra-minimalist dark-only SignInScreen:
/// - Pure black background
/// - Centered bold app title ("Pun Account")
/// - Bottom white pill button ("Continue with Google")
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key, this.onToggleTheme, this.onSignInSuccess});

  final VoidCallback? onToggleTheme;
  final VoidCallback? onSignInSuccess;

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(authProvider.notifier)
        .signInWithGoogleAccount();
    if (success && context.mounted) {
      onSignInSuccess?.call();
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Center: Large Bold Title
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pun Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                      if (authState.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Alert.destructive(
                          title: const Text('Authentication Error'),
                          content: Text(authState.errorMessage!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Area: White Pill Button only (Ultra-clean)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: GestureDetector(
                      onTap: authState.isLoading
                          ? null
                          : () => _handleGoogleSignIn(context, ref),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GoogleLogo(size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
