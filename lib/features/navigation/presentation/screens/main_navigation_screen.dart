import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../features/auth/controllers/auth_controller.dart';
import '../../../../features/categories/presentation/services_screen.dart';
import '../../../../features/dashboard/presentation/overview_screen.dart';
import '../../../../features/transactions/presentation/quick_add_modal.dart';
import '../../../../features/transactions/presentation/send_request_modal.dart';
import '../../../../features/wallets/presentation/wallets_screen.dart';
import '../widgets/pun_navigation_bar.dart';

/// Main scaffold hosting the 3 tabs matching the reference app:
/// Tab 0: Services & Categories (Recipients screen with category icons)
/// Tab 1: Home (Total balance, Send/Request, Spending, Transactions)
/// Tab 2: Cards (Digital cards stack with freeze, details, toggle)
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.title,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final String title;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  // Default to Tab 1 (Home)
  late final PageController _pageController;
  Key? _selected = const ValueKey(1);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onOpenSendModal() {
    SendRequestModal.show(context, mode: TransferMode.send);
  }

  void _onOpenAddTransaction() {
    QuickAddModal.show(context);
  }

  void _goToPage(int index) {
    setState(() {
      _selected = ValueKey(index);
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selected = ValueKey(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auth = ref.watch(authProvider);
    final user = auth.session?.user;

    return Scaffold(
      headers: [
        // Minimal top status bar with Pun branding & theme switch
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🐣', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (user != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 2),
                            IconButton.ghost(
                              density: ButtonDensity.icon,
                              icon: const Icon(LucideIcons.logOut, size: 14),
                              onPressed: () {
                                ref.read(authProvider.notifier).signOut();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                    ] else ...[
                      OutlineButton(
                        density: ButtonDensity.compact,
                        size: ButtonSize.small,
                        onPressed: () {
                          ref.read(authProvider.notifier).signOut();
                        },
                        child: const Text('Sign In'),
                      ),
                      const SizedBox(width: 4),
                    ],
                    IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: const Icon(LucideIcons.plus, size: 18),
                      onPressed: _onOpenSendModal,
                    ),
                    const SizedBox(width: 4),
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
              ],
            ),
          ),
        ),
      ],
      child: Stack(
        children: [
          // Screen Content with Swipeable PageView
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                const ServicesScreen(key: PageStorageKey('services_screen')),
                OverviewScreen(
                  key: const PageStorageKey('overview_screen'),
                  onNavigateToWallets: () => _goToPage(2),
                  onNavigateToServices: () => _goToPage(0),
                  onAddTransaction: _onOpenAddTransaction,
                ),
                WalletsScreen(
                  key: const PageStorageKey('wallets_screen'),
                  onAddTransaction: _onOpenAddTransaction,
                ),
              ],
            ),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PunNavigationBar(
              selectedKey: _selected,
              onSelected: (key) {
                if (key is ValueKey<int>) {
                  _goToPage(key.value);
                }
              },
              onAddPressed: _onOpenSendModal,
            ),
          ),
        ],
      ),
    );
  }
}
