import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../domain/models/wallet.dart';
import 'aurora_mesh_background.dart';
import 'card_brand_badge.dart';
import 'card_chip.dart';
import 'card_contactless.dart';
import 'card_footer_info.dart';
import 'card_number_display.dart';
import 'cash_wallet_card.dart';

/// Dark Obsidian Mesh / Aurora modern Credit/Wallet Card widget
class DarkObsidianWalletCard extends StatelessWidget {
  const DarkObsidianWalletCard({
    super.key,
    required this.wallet,
    this.onTap,
    this.onShowDetails,
    this.showActions = true,
  });

  final Wallet wallet;
  final VoidCallback? onTap;
  final VoidCallback? onShowDetails;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    // If it's a cash wallet, render the specialized CashWalletCard
    if (wallet.type == 'cash') {
      return CashWalletCard(
        wallet: wallet,
        onTap: onTap,
        onShowDetails: onShowDetails,
        showActions: showActions,
      );
    }

    return GestureDetector(
      onTap: onTap ?? onShowDetails,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The Card itself with Aurora Mesh Background
          AuroraMeshBackground(
            wallet: wallet,
            height: 205,
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: EMV Chip + Contactless + Brand Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CardChip(wallet: wallet),
                          const SizedBox(width: 14),
                          CardContactless(wallet: wallet),
                        ],
                      ),
                      CardBrandBadge(wallet: wallet),
                    ],
                  ),

                  // Middle: Card Number with masked digits
                  CardNumberDisplay(wallet: wallet),

                  // Bottom Row: Card Holder & Balance
                  CardFooterInfo(wallet: wallet),
                ],
              ),
            ),
          ),

          // Optional Quick Control Action Bar (Frosted buttons below card)
          if (showActions) ...[
            const SizedBox(height: 10),
            _buildActionBar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionPill(
          icon: shadcn.LucideIcons.creditCard,
          label: 'Card Details',
          onTap: onShowDetails,
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
