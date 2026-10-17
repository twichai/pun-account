import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../providers/add_card_form_provider.dart';
import 'dark_obsidian_wallet_card.dart';

/// Bottom Drawer Form for adding a new digital Obsidian card
class AddCardDrawer extends ConsumerStatefulWidget {
  const AddCardDrawer({super.key});

  /// Opens the Add Card Drawer from the bottom
  static Future<void> show(BuildContext context) {
    return showOverlay(
      context,
      const DrawerConfiguration(
        position: OverlayPosition.bottom,
        showDragHandle: true,
      ),
      builder: (context) => const AddCardDrawer(),
    ).future;
  }

  @override
  ConsumerState<AddCardDrawer> createState() => _AddCardDrawerState();
}

class _AddCardDrawerState extends ConsumerState<AddCardDrawer> {
  late final TextEditingController _cardHolderController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _balanceController;

  final List<({String key, String label, Color color})> _auroraOptions = const [
    (key: 'cyan', label: 'Cyber Cyan', color: Color(0xFF06B6D4)),
    (key: 'violet', label: 'Neon Violet', color: Color(0xFFA855F7)),
    (key: 'amber', label: 'Liquid Amber', color: Color(0xFFF59E0B)),
    (key: 'emerald', label: 'Emerald Mint', color: Color(0xFF10B981)),
  ];

  @override
  void initState() {
    super.initState();
    final formState = ref.read(addCardFormProvider);
    _cardHolderController = TextEditingController(text: formState.cardHolder);
    _cardNumberController = TextEditingController(text: formState.cardNumber);
    _balanceController = TextEditingController(
      text: formState.balance > 0 ? formState.balance.toStringAsFixed(0) : '25000',
    );
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _onBrandChanged(String brand) {
    ref.read(addCardFormProvider.notifier).updateCardBrand(brand);
  }

  void _onAccentChanged(String accent) {
    ref.read(addCardFormProvider.notifier).updateAuroraAccent(accent);
  }

  void _submit() {
    final notifier = ref.read(addCardFormProvider.notifier);
    final balanceVal = double.tryParse(_balanceController.text.trim()) ?? 25000.0;
    notifier.updateBalance(balanceVal);

    final success = notifier.submit();
    if (success) {
      closeOverlay(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(addCardFormProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with title, subtitle & close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add Digital Card').h4(),
                        const SizedBox(height: 2),
                        const Text(
                          'Issue and configure a new obsidian business card',
                        ).small().muted(),
                      ],
                    ),
                    IconButton.ghost(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => closeOverlay(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Card Preview
                DarkObsidianWalletCard(
                  wallet: formState.toPreviewWallet(),
                  showActions: false,
                ),
                const SizedBox(height: 20),

                // Error message if any
                if (formState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.circleAlert,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formState.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Cardholder Name Field
                const Text('Cardholder Name').small().semiBold(),
                const SizedBox(height: 6),
                TextField(
                  controller: _cardHolderController,
                  placeholder: const Text('e.g. PAVLO D.'),
                  onChanged: (val) {
                    ref.read(addCardFormProvider.notifier).updateCardHolder(val);
                  },
                ),
                const SizedBox(height: 14),

                // Card Number Field
                const Text('Card Number / Digits').small().semiBold(),
                const SizedBox(height: 6),
                TextField(
                  controller: _cardNumberController,
                  placeholder: const Text('4532 •••• •••• 7642'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    ref.read(addCardFormProvider.notifier).updateCardNumber(val);
                  },
                ),
                const SizedBox(height: 14),

                // Card Brand Selection (Visa / Mastercard)
                const Text('Card Network / Brand').small().semiBold(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onBrandChanged('visa'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: formState.cardBrand == 'visa'
                                ? (isDark
                                    ? const Color(0xFF27272A)
                                    : const Color(0xFFF4F4F5))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: formState.cardBrand == 'visa'
                                  ? theme.colorScheme.primary
                                  : (isDark
                                      ? const Color(0xFF3F3F46)
                                      : const Color(0xFFE4E4E7)),
                              width: formState.cardBrand == 'visa' ? 1.5 : 1.0,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'VISA',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onBrandChanged('mastercard'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: formState.cardBrand == 'mastercard'
                                ? (isDark
                                    ? const Color(0xFF27272A)
                                    : const Color(0xFFF4F4F5))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: formState.cardBrand == 'mastercard'
                                  ? theme.colorScheme.primary
                                  : (isDark
                                      ? const Color(0xFF3F3F46)
                                      : const Color(0xFFE4E4E7)),
                              width:
                                  formState.cardBrand == 'mastercard' ? 1.5 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 16,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEB001B),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF79E1B)
                                                .withValues(alpha: 0.9),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Mastercard',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Aurora Mesh Theme Selector
                const Text('Aurora Glow Accent').small().semiBold(),
                const SizedBox(height: 8),
                Row(
                  children: _auroraOptions.map((opt) {
                    final isSelected = formState.auroraAccent == opt.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onAccentChanged(opt.key),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? opt.color.withValues(alpha: 0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? opt.color
                                  : (isDark
                                      ? const Color(0xFF3F3F46)
                                      : const Color(0xFFE4E4E7)),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: opt.color,
                                  shape: BoxShape.circle,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: opt.color.withValues(alpha: 0.6),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt.key[0].toUpperCase() + opt.key.substring(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? Colors.white : Colors.black)
                                      : (isDark
                                          ? const Color(0xFFA1A1AA)
                                          : const Color(0xFF71717A)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Initial Balance / Credit Limit Field
                const Text('Initial Limit / Balance (THB)').small().semiBold(),
                const SizedBox(height: 6),
                TextField(
                  controller: _balanceController,
                  placeholder: const Text('25000'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final d = double.tryParse(val) ?? 0.0;
                    ref.read(addCardFormProvider.notifier).updateBalance(d);
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons: Cancel and Add Card
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        onPressed: () => closeOverlay(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        onPressed: _submit,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.plus, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Add Card',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
