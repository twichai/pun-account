import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Header inside the transactions bottom sheet with filter, title, and search buttons.
class TransactionsSheetHeader extends StatelessWidget {
  const TransactionsSheetHeader({
    super.key,
    this.title = 'Transactions',
    this.onFilterPressed,
    this.onSearchPressed,
  });

  final String title;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor =
        isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton.ghost(
          density: ButtonDensity.icon,
          icon: Icon(
            LucideIcons.slidersHorizontal,
            size: 18,
            color: iconColor,
          ),
          onPressed: onFilterPressed ?? () {},
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton.ghost(
          density: ButtonDensity.icon,
          icon: Icon(
            LucideIcons.search,
            size: 18,
            color: iconColor,
          ),
          onPressed: onSearchPressed ?? () {},
        ),
      ],
    );
  }
}
