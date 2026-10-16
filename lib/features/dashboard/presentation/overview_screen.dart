import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../transactions/presentation/send_request_modal.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
    required this.statusColor,
    required this.date,
  });

  final String id;
  final String title;
  final String category;
  final String amount;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;
  final Color statusColor;
  final String date;
}

/// Redesigned Home Overview screen matching Screenshot 3 using shadcn_flutter.
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({
    super.key,
    this.onNavigateToWallets,
    this.onNavigateToServices,
    this.onAddTransaction,
  });

  final VoidCallback? onNavigateToWallets;
  final VoidCallback? onNavigateToServices;
  final VoidCallback? onAddTransaction;

  final List<TransactionItem> _transactions = const [
    TransactionItem(
      id: '1',
      title: 'Apple',
      category: 'Subscription',
      amount: '-60 \$',
      isPositive: false,
      icon: LucideIcons.laptop,
      iconColor: Color(0xFF0F172A),
      statusColor: Color(0xFF10B981), // Emerald
      date: 'Today 13:45',
    ),
    TransactionItem(
      id: '2',
      title: 'Threads',
      category: 'Marketing Ads',
      amount: '-300 \$',
      isPositive: false,
      icon: LucideIcons.atSign,
      iconColor: Color(0xFF0F172A),
      statusColor: Color(0xFFF59E0B), // Yellow
      date: 'Today 11:20',
    ),
    TransactionItem(
      id: '3',
      title: 'Apple',
      category: 'Client Consulting',
      amount: '2 000 \$',
      isPositive: true,
      icon: LucideIcons.laptop,
      iconColor: Color(0xFF0F172A),
      statusColor: Color(0xFF38BDF8), // Blue
      date: 'Yesterday',
    ),
    TransactionItem(
      id: '4',
      title: 'Exoplan',
      category: 'Cloud Hosting',
      amount: '-20 \$',
      isPositive: false,
      icon: LucideIcons.calendar,
      iconColor: Color(0xFF10B981),
      statusColor: Color(0xFF2DD4BF),
      date: '14 Oct',
    ),
    TransactionItem(
      id: '5',
      title: 'Circuit',
      category: 'SaaS Software',
      amount: '-140 \$',
      isPositive: false,
      icon: LucideIcons.disc,
      iconColor: Color(0xFFF97316),
      statusColor: Color(0xFF2DD4BF),
      date: '12 Oct',
    ),
  ];

  void _onOpenSendModal(BuildContext context, TransferMode mode) {
    SendRequestModal.show(context, mode: mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Dark Header Area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar & Notification Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Avatar
                    Container(
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
                    // Notification Bell Button
                    IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: const Icon(
                        LucideIcons.bell,
                        size: 20,
                        color: Color(0xFFA1A1AA),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Balance Row with Stacked Cards graphic on the right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Balance Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA1A1AA),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              '\$ 7,854',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '.43',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFA1A1AA).withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Stacked Cards Visual Teaser (Right side)
                    GestureDetector(
                      onTap: onNavigateToWallets,
                      child: SizedBox(
                        width: 72,
                        height: 90,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Blue Card edge
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: 32,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(14),
                                    right: Radius.circular(4),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Mint Card edge
                            Positioned(
                              right: 14,
                              top: 6,
                              bottom: 6,
                              width: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(14),
                                    right: Radius.circular(4),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                                  ),
                                ),
                              ),
                            ),
                            // Yellow Card edge
                            Positioned(
                              right: 28,
                              top: 12,
                              bottom: 12,
                              width: 28,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(14),
                                    right: Radius.circular(4),
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFE033), Color(0xFFF59E0B)],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Quick Action Buttons: Send & Request
                Row(
                  children: [
                    // Send Button
                    GestureDetector(
                      onTap: () => _onOpenSendModal(context, TransferMode.send),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white : const Color(0xFF09090B),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                LucideIcons.arrowLeft,
                                size: 12,
                                color: isDark ? const Color(0xFF09090B) : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Send',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Request Button
                    GestureDetector(
                      onTap: () => _onOpenSendModal(context, TransferMode.request),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                          ),
                        ),
                        child: const Text(
                          'Request',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // "Spending" Card with overlapping brand avatars
                GestureDetector(
                  onTap: onNavigateToServices,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Label & Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spending',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA1A1AA),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$1,385',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Right: Overlapping circular avatars / logos
                        SizedBox(
                          height: 44,
                          width: 150,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerRight,
                            children: [
                              // +2 badge
                              Positioned(
                                right: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF18181B) : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '+2',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              // Avatar 4: Apple
                              Positioned(
                                right: 24,
                                child: _buildSmallLogoAvatar(
                                  LucideIcons.laptop,
                                  const Color(0xFF0F172A),
                                  Colors.white,
                                  isDark,
                                ),
                              ),
                              // Avatar 3: Threads
                              Positioned(
                                right: 48,
                                child: _buildSmallLogoAvatar(
                                  LucideIcons.atSign,
                                  Colors.white,
                                  const Color(0xFF0F172A),
                                  isDark,
                                ),
                              ),
                              // Avatar 2: Orange/Chrome
                              Positioned(
                                right: 72,
                                child: _buildSmallLogoAvatar(
                                  LucideIcons.disc,
                                  Colors.white,
                                  const Color(0xFFF97316),
                                  isDark,
                                ),
                              ),
                              // Avatar 1: Calendar / Exoplan
                              Positioned(
                                right: 96,
                                child: _buildSmallLogoAvatar(
                                  LucideIcons.calendar,
                                  Colors.white,
                                  const Color(0xFF10B981),
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet: White / Contrasting surface
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top grab handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header: Filter, "Transactions", Search
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: Icon(
                        LucideIcons.slidersHorizontal,
                        size: 18,
                        color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                      ),
                      onPressed: () {},
                    ),
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton.ghost(
                      density: ButtonDensity.icon,
                      icon: Icon(
                        LucideIcons.search,
                        size: 18,
                        color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Transactions List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = _transactions[index];
                    return _buildTransactionRow(item, isDark);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLogoAvatar(
    IconData icon,
    Color iconColor,
    Color bgColor,
    bool isDark,
  ) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 16, color: iconColor),
    );
  }

  Widget _buildTransactionRow(TransactionItem item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Logo Avatar with colored status dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, size: 20, color: item.iconColor),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF18181B) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Title & Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF09090B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category} • ${item.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71717A),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            item.amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: item.isPositive
                  ? const Color(0xFF10B981) // Emerald Green
                  : (isDark ? Colors.white : const Color(0xFF09090B)),
            ),
          ),
        ],
      ),
    );
  }
}
