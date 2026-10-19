import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/google_logo.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    required this.onToggleTheme,
    this.onSignInSuccess,
  });

  final VoidCallback onToggleTheme;
  final VoidCallback? onSignInSuccess;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _showCustomDevInputs = false;
  final TextEditingController _emailController = TextEditingController(
    text: 'alex.maker@indie.co',
  );
  final TextEditingController _nameController = TextEditingController(
    text: 'Alex Maker',
  );
  final TextEditingController _tokenController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    // If the developer opened custom simulator and typed specific credentials, use simulator
    if (_showCustomDevInputs && _emailController.text.trim().isNotEmpty) {
      final success = await ref
          .read(authProvider.notifier)
          .signInWithGoogle(
            idToken: _tokenController.text.trim().isNotEmpty
                ? _tokenController.text.trim()
                : null,
            email: _emailController.text.trim(),
            name: _nameController.text.trim().isNotEmpty
                ? _nameController.text.trim()
                : 'Solopreneur',
            googleId: 'g-${DateTime.now().millisecondsSinceEpoch}',
          );

      if (success && mounted) {
        widget.onSignInSuccess?.call();
        context.go(AppRoutes.home);
      }
      return;
    }

    // Standard flow: Opens the real native Google account selector dialog (Choose Gmail)
    final success = await ref
        .read(authProvider.notifier)
        .signInWithGoogleAccount();
    if (success && mounted) {
      widget.onSignInSuccess?.call();
      context.go(AppRoutes.home);
    }
  }

  Future<void> _handleDemoSignIn(String preset) async {
    final success = await ref.read(authProvider.notifier).signInDemo(preset);
    if (success && mounted) {
      widget.onSignInSuccess?.call();
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      headers: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🐣', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const Text(
                      'Pun Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                IconButton.ghost(
                  density: ButtonDensity.icon,
                  icon: Icon(
                    isDark ? LucideIcons.sun : LucideIcons.moon,
                    size: 18,
                  ),
                  onPressed: widget.onToggleTheme,
                ),
              ],
            ),
          ),
        ),
      ],
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Brand Badge & Aurora Ambient Card
                Card(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Mascot Avatar Pill
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.2),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('🐣', style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'Welcome to Pun (ปั้น)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'Financial clarity for One-Person Companies, indie makers & freelancers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Feature Pills
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFeaturePill(
                            icon: LucideIcons.wallet,
                            label: 'Multi-Wallet',
                            isDark: isDark,
                          ),
                          _buildFeaturePill(
                            icon: LucideIcons.shieldCheck,
                            label: 'UUIDv7 Ledger',
                            isDark: isDark,
                          ),
                          _buildFeaturePill(
                            icon: LucideIcons.trendingUp,
                            label: 'P&L Insight',
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Error Alert if any
                      if (authState.errorMessage != null) ...[
                        Alert.destructive(
                          title: const Text('Authentication Error'),
                          content: Text(authState.errorMessage!),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Main Call to Action: Sign In With Google
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlineButton(
                          onPressed: authState.isLoading
                              ? null
                              : _handleGoogleSignIn,
                          leading: authState.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const GoogleLogo(size: 20),
                          child: Text(
                            authState.isLoading
                                ? 'Connecting to Google...'
                                : 'Sign in with Google',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quick Demo Sign In Presets
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR TRY INSTANT DEMO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Preset Solopreneur 1: Alex Maker
                      SizedBox(
                        width: double.infinity,
                        child: GhostButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => _handleDemoSignIn('alex'),
                          leading: const Text(
                            '🚀',
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(
                            LucideIcons.arrowRight,
                            size: 14,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alex Maker',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Indie Solopreneur (THB)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Preset Solopreneur 2: Sarah Design
                      SizedBox(
                        width: double.infinity,
                        child: GhostButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => _handleDemoSignIn('sarah'),
                          leading: const Text(
                            '🎨',
                            style: TextStyle(fontSize: 16),
                          ),
                          trailing: const Icon(
                            LucideIcons.arrowRight,
                            size: 14,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sarah Design',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Freelance Studio (THB)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Toggle Advanced Developer Input
                      LinkButton(
                        onPressed: () {
                          setState(() {
                            _showCustomDevInputs = !_showCustomDevInputs;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showCustomDevInputs
                                  ? LucideIcons.chevronUp
                                  : LucideIcons.slidersHorizontal,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _showCustomDevInputs
                                  ? 'Hide custom auth fields'
                                  : 'Custom ID Token / Dev Credentials',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      if (_showCustomDevInputs) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Developer OAuth Simulator',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                placeholder: const Text(
                                  'Email (e.g. solopreneur@maker.dev)',
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                placeholder: const Text('Full Name'),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _tokenController,
                                placeholder: const Text(
                                  'Google ID Token (Optional)',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Privacy and Terms footer
                Text(
                  'By signing in, you agree to isolated tenant data encryption and audit integrity.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
