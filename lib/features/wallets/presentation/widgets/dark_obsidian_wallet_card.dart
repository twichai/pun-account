import 'package:flutter/material.dart';

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
    this.height = 230.0,
  });

  final Wallet wallet;
  final VoidCallback? onTap;
  final VoidCallback? onShowDetails;
  final bool showActions;
  final double height;

  @override
  Widget build(BuildContext context) {
    // If it's a cash wallet, render the specialized CashWalletCard
    if (wallet.type == 'cash') {
      return CashWalletCard(
        wallet: wallet,
        onTap: onTap,
        onShowDetails: onShowDetails,
        showActions: showActions,
        height: height,
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
            height: height,
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
        ],
      ),
    );
  }
}
