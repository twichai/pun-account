import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../transactions/presentation/send_request_modal.dart';

class ServiceCategoryItem {
  const ServiceCategoryItem({
    required this.id,
    required this.name,
    required this.handle,
    required this.accountNumber,
    required this.amountInfo,
    required this.icon,
    required this.color,
    this.badge,
  });

  final String id;
  final String name;
  final String handle;
  final String accountNumber;
  final String amountInfo;
  final IconData icon;
  final Color color;
  final String? badge;
}

/// Services and Categories screen matching Screenshot 4 with category/service icons
/// instead of human portraits as requested by user.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    this.onAddCategory,
  });

  final VoidCallback? onAddCategory;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _selectedFilterIndex = 0; // 0 = All, 1 = My Accounts

  final List<ServiceCategoryItem> _quickServices = const [
    ServiceCategoryItem(
      id: '1',
      name: 'OpenAI',
      handle: '@openai.api',
      accountNumber: 'Chase 2983',
      amountInfo: '\$120 / mo',
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
    ),
    ServiceCategoryItem(
      id: '2',
      name: 'AWS Cloud',
      handle: '@aws.billing',
      accountNumber: 'Mastercard 9283',
      amountInfo: '\$345.50 / mo',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
    ),
    ServiceCategoryItem(
      id: '3',
      name: 'Figma',
      handle: '@figma.team',
      accountNumber: 'KBank 1234',
      amountInfo: '\$45 / mo',
      icon: LucideIcons.palette,
      color: Color(0xFFA855F7),
    ),
    ServiceCategoryItem(
      id: '4',
      name: 'Apple',
      handle: '@apple.services',
      accountNumber: 'Chase 2983',
      amountInfo: '\$60 / mo',
      icon: LucideIcons.laptop,
      color: Color(0xFF0EA5E9),
    ),
    ServiceCategoryItem(
      id: '5',
      name: 'Google Cloud',
      handle: '@google.cloud',
      accountNumber: 'Mastercard 9283',
      amountInfo: '\$89 / mo',
      icon: LucideIcons.globe,
      color: Color(0xFFEF4444),
    ),
    ServiceCategoryItem(
      id: '6',
      name: 'GitHub',
      handle: '@github.dev',
      accountNumber: 'Chase 2983',
      amountInfo: '\$21 / mo',
      icon: LucideIcons.code,
      color: Color(0xFF6366F1),
    ),
  ];

  final List<ServiceCategoryItem> _allAccounts = const [
    ServiceCategoryItem(
      id: '1',
      name: 'OpenAI API & ChatGPT',
      handle: '@openai.api',
      accountNumber: 'Chase 2983',
      amountInfo: '-\$120.00',
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
      badge: 'Active',
    ),
    ServiceCategoryItem(
      id: '2',
      name: 'AWS Infrastructure',
      handle: '@aws.billing',
      accountNumber: 'Mastercard 9283',
      amountInfo: '-\$345.50',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
      badge: 'Active',
    ),
    ServiceCategoryItem(
      id: '3',
      name: 'Figma Enterprise',
      handle: '@figma.team',
      accountNumber: 'KBank 1234',
      amountInfo: '-\$45.00',
      icon: LucideIcons.palette,
      color: Color(0xFFA855F7),
      badge: 'Active',
    ),
    ServiceCategoryItem(
      id: '4',
      name: 'Apple Developer Account',
      handle: '@apple.services',
      accountNumber: 'Chase 2983',
      amountInfo: '-\$99.00',
      icon: LucideIcons.laptop,
      color: Color(0xFF0EA5E9),
      badge: 'Annual',
    ),
    ServiceCategoryItem(
      id: '5',
      name: 'Supabase Database',
      handle: '@supabase.io',
      accountNumber: 'KBank 1234',
      amountInfo: '-\$25.00',
      icon: LucideIcons.database,
      color: Color(0xFF22C55E),
      badge: 'Active',
    ),
    ServiceCategoryItem(
      id: '6',
      name: 'Vercel Pro',
      handle: '@vercel.app',
      accountNumber: 'Chase 2983',
      amountInfo: '-\$20.00',
      icon: LucideIcons.triangle,
      color: Color(0xFF64748B),
      badge: 'Active',
    ),
  ];

  void _onPayService(ServiceCategoryItem service) {
    SendRequestModal.show(
      context,
      mode: TransferMode.send,
      recipientName: service.name,
    );
  }

  void _showAddServiceModal() {
    showOverlay(
      context,
      const DialogConfiguration(),
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Service / Category').h4(),
          content: const SizedBox(
            width: 320,
            child: Text(
              'Add a recurring cloud service, software subscription, or tax category to your payment list.',
            ),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Add Service'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Dark Area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Recipients / Services & "Add" button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recipients',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PrimaryButton(
                      density: ButtonDensity.compact,
                      onPressed: _showAddServiceModal,
                      child: const Text(
                        'Add',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2x3 Grid of Circular Category / Service Avatars
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 32) / 3;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 24,
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        for (final service in _quickServices)
                          _buildServiceAvatar(service, itemWidth),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Sheet: White / Light contrasting card
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
                // Pull handle
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

                // Filter tabs + Search button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildFilterPill('All', 0, isDark),
                        const SizedBox(width: 8),
                        _buildFilterPill('My accounts', 1, isDark),
                      ],
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

                // List of items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allAccounts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _allAccounts[index];
                    return _buildAccountTile(item, isDark);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceAvatar(ServiceCategoryItem service, double width) {
    return GestureDetector(
      onTap: () => _onPayService(service),
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            // Circular Avatar with Service Icon and status badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        service.color.withValues(alpha: 0.8),
                        service.color,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: service.color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    service.icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF111315),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              service.handle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFA1A1AA),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title, int index, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF09090B))
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? (isDark ? const Color(0xFF09090B) : Colors.white)
                : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A)),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(ServiceCategoryItem item, bool isDark) {
    return GestureDetector(
      onTap: () => _onPayService(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF27272A).withValues(alpha: 0.5) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF3F3F46).withValues(alpha: 0.4) : const Color(0xFFF4F4F5),
          ),
        ),
        child: Row(
          children: [
            // Service Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.color.withValues(alpha: 0.18),
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 20, color: item.color),
            ),
            const SizedBox(width: 14),

            // Name & Account info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF09090B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.accountNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),

            // Amount / Pay button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amountInfo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF09090B),
                  ),
                ),
                if (item.badge != null) ...[
                  const SizedBox(height: 2),
                  SecondaryBadge(
                    child: Text(item.badge!),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
