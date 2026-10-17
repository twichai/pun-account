import 'package:flutter_riverpod/flutter_riverpod.dart';
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
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({
    super.key,
    this.title = 'Pun Account',
    this.themeMode,
    this.onToggleTheme,
  });

  final String title;
  final ThemeMode? themeMode;
  final VoidCallback? onToggleTheme;

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
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
    return Scaffold(
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
                  isActive: _selected == const ValueKey(2),
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
