import 'package:shadcn_flutter/shadcn_flutter.dart';

class DigitalCardData {
  DigitalCardData({
    required this.id,
    required this.last4,
    required this.cardHolder,
    required this.expiry,
    required this.cvv,
    required this.gradientColors,
    required this.textColor,
    this.isFrozen = false,
    this.isActive = true,
  });

  final String id;
  final String last4;
  final String cardHolder;
  final String expiry;
  final String cvv;
  final List<Color> gradientColors;
  final Color textColor;
  bool isFrozen;
  bool isActive;
}

/// Cards screen redesign matching Screenshot 1 using shadcn_flutter aesthetics.
class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key, this.onAddTransaction});

  final VoidCallback? onAddTransaction;

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  final List<DigitalCardData> _cards = [
    DigitalCardData(
      id: '1',
      last4: '7642',
      cardHolder: 'PAVLO D.',
      expiry: '09/28',
      cvv: '842',
      gradientColors: [const Color(0xFFFFE033), const Color(0xFFF59E0B)],
      textColor: const Color(0xFF1C1917),
    ),
    DigitalCardData(
      id: '2',
      last4: '5123',
      cardHolder: 'PAVLO D.',
      expiry: '11/29',
      cvv: '319',
      gradientColors: [const Color(0xFF2DD4BF), const Color(0xFF0D9488)],
      textColor: const Color(0xFF0F172A),
    ),
    DigitalCardData(
      id: '3',
      last4: '3413',
      cardHolder: 'PAVLO D.',
      expiry: '04/27',
      cvv: '561',
      gradientColors: [const Color(0xFF38BDF8), const Color(0xFF0284C7)],
      textColor: const Color(0xFF0F172A),
    ),
  ];

  void _showCardDetails(DigitalCardData card) {
    showOverlay(
      context,
      const DialogConfiguration(),
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(LucideIcons.creditCard, size: 20),
              const SizedBox(width: 8),
              Text('Digital Card •••• ${card.last4}').h4(),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Card Number').small().muted(),
                const SizedBox(height: 2),
                Text('4532 •••• •••• ${card.last4}').semiBold(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expires').small().muted(),
                          const SizedBox(height: 2),
                          Text(card.expiry).semiBold(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CVV').small().muted(),
                          const SizedBox(height: 2),
                          Text(card.cvv).semiBold(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Cardholder').small().muted(),
                const SizedBox(height: 2),
                Text(card.cardHolder).semiBold(),
              ],
            ),
          ),
          actions: [
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderCardModal() {
    showOverlay(
      context,
      const DialogConfiguration(),
      builder: (context) {
        return AlertDialog(
          title: const Text('Order a new card').h4(),
          content: const SizedBox(
            width: 320,
            child: Text(
              'Select whether you would like an instant virtual card or a physical metallic card delivered to your business address.',
            ),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () {
                setState(() {
                  _cards.add(
                    DigitalCardData(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      last4: '9841',
                      cardHolder: 'PAVLO D.',
                      expiry: '10/30',
                      cvv: '912',
                      gradientColors: [
                        const Color(0xFFA855F7),
                        const Color(0xFF7C3AED),
                      ],
                      textColor: Colors.white,
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('Create Digital Card'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Title & "Order a card" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Cards',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              PrimaryButton(
                density: ButtonDensity.compact,
                onPressed: _showOrderCardModal,
                child: const Text(
                  'Order a card',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Digital Cards Stack
          for (final card in _cards) ...[
            _buildCardWidget(card),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildCardWidget(DigitalCardData card) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: card.isFrozen ? 0.6 : 1.0,
      child: Container(
        height: 195,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: card.gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              // Subtle background curved light shape
              Positioned(
                right: -40,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: "Digital card" + "•••• 7642"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Digital card',
                          style: TextStyle(
                            color: card.textColor.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '•••• ${card.last4}',
                          style: TextStyle(
                            color: card.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    // Bottom Row: Action buttons + circles logo + toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left action buttons: Snowflake, Card details, Settings
                        Row(
                          children: [
                            _buildFrostedButton(
                              icon: card.isFrozen
                                  ? LucideIcons.lock
                                  : LucideIcons.snowflake,
                              isActive: card.isFrozen,
                              textColor: card.textColor,
                              onTap: () {
                                setState(() {
                                  card.isFrozen = !card.isFrozen;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFrostedButton(
                              icon: LucideIcons.creditCard,
                              textColor: card.textColor,
                              onTap: () => _showCardDetails(card),
                            ),
                            const SizedBox(width: 8),
                            _buildFrostedButton(
                              icon: LucideIcons.settings,
                              textColor: card.textColor,
                              onTap: () => _showCardDetails(card),
                            ),
                          ],
                        ),

                        // Right: Card Brand Circles & Switch Toggle
                        Row(
                          children: [
                            // Interlocking Mastercard Circles
                            SizedBox(
                              width: 36,
                              height: 24,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: card.textColor.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: card.textColor.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Switch toggle
                            Switch(
                              value: card.isActive,
                              onChanged: (val) {
                                setState(() {
                                  card.isActive = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrostedButton({
    required IconData icon,
    required Color textColor,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? textColor.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: isActive ? Colors.white : textColor),
      ),
    );
  }
}
