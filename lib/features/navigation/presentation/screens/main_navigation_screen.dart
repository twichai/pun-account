import 'package:shadcn_flutter/shadcn_flutter.dart';

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
class MainNavigationScreen extends StatefulWidget {
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
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Default to Tab 1 (Home)
  Key? _selected = const ValueKey(1);

  void _onOpenSendModal() {
    SendRequestModal.show(context, mode: TransferMode.send);
  }

  void _onOpenAddTransaction() {
    QuickAddModal.show(context);
  }

  Widget _buildContent() {
    final selectedInt = _selected is ValueKey<int>
        ? (_selected as ValueKey<int>).value
        : 1;

    switch (selectedInt) {
      case 0:
        return const ServicesScreen();
      case 1:
        return OverviewScreen(
          onNavigateToWallets: () {
            setState(() {
              _selected = const ValueKey(2);
            });
          },
          onNavigateToServices: () {
            setState(() {
              _selected = const ValueKey(0);
            });
          },
          onAddTransaction: _onOpenAddTransaction,
        );
      case 2:
        return WalletsScreen(onAddTransaction: _onOpenAddTransaction);
      default:
        return OverviewScreen(
          onNavigateToWallets: () {
            setState(() {
              _selected = const ValueKey(2);
            });
          },
          onNavigateToServices: () {
            setState(() {
              _selected = const ValueKey(0);
            });
          },
          onAddTransaction: _onOpenAddTransaction,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          // Screen Content
          Positioned.fill(child: _buildContent()),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PunNavigationBar(
              selectedKey: _selected,
              onSelected: (key) {
                setState(() {
                  _selected = key;
                });
              },
              onAddPressed: _onOpenSendModal,
            ),
          ),
        ],
      ),
    );
  }
}
