import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Floating pill navigation bar designed after the modern fintech app screenshots,
/// built natively with shadcn_flutter aesthetics and tokens.
class PunNavigationBar extends StatelessWidget {
  const PunNavigationBar({
    super.key,
    required this.selectedKey,
    required this.onSelected,
    this.onAddPressed,
    this.alignment = NavigationBarAlignment.spaceAround,
    this.labelType = NavigationLabelType.none,
    this.customButtonStyle = true,
    this.expanded = false,
  });

  /// Currently selected item key (e.g. [ValueKey(0)], [ValueKey(1)], [ValueKey(2)]).
  final Key? selectedKey;

  /// Callback when a navigation item is selected.
  final ValueChanged<Key?> onSelected;

  /// Callback when the add action button is triggered.
  final VoidCallback? onAddPressed;

  final NavigationBarAlignment alignment;
  final NavigationLabelType labelType;
  final bool customButtonStyle;
  final bool expanded;

  int get _currentIndex {
    if (selectedKey is ValueKey<int>) {
      return (selectedKey as ValueKey<int>).value;
    }
    return 1; // Default to Home
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181B) : const Color(0xFF18181B), // Sleek dark pill capsule in both themes
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFF3F3F46),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Services / Categories Tab (Left)
            _buildNavItem(
              index: 0,
              icon: LucideIcons.users,
              label: 'Services',
              key: const ValueKey(0),
            ),
            const SizedBox(width: 6),

            // 2. Home Tab (Center)
            _buildNavItem(
              index: 1,
              icon: LucideIcons.house,
              label: 'Home',
              key: const ValueKey(1),
            ),
            const SizedBox(width: 6),

            // 3. Cards Tab (Right)
            _buildNavItem(
              index: 2,
              icon: LucideIcons.walletCards,
              label: 'Cards',
              key: const ValueKey(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Key key,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      key: key,
      onTap: () => onSelected(ValueKey(index)),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 22 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF09090B) : const Color(0xFFA1A1AA),
        ),
      ),
    );
  }
}
