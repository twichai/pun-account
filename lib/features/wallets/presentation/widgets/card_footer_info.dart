import 'package:flutter/material.dart';

import '../../domain/models/wallet.dart';

/// Bottom info row displaying Card/Wallet type and current Balance
class CardFooterInfo extends StatelessWidget {
  const CardFooterInfo({
    super.key,
    required this.wallet,
    this.showBalance = true,
  });

  final Wallet wallet;
  final bool showBalance;

  @override
  Widget build(BuildContext context) {
    final holderText = wallet.cardHolder?.isNotEmpty == true
        ? wallet.cardHolder!.toUpperCase()
        : (wallet.type == 'cash' ? 'CASH IN HAND' : 'BUSINESS ACCOUNT');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Left Column: Card Holder or Wallet Label
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                wallet.type == 'cash' ? 'WALLET TYPE' : 'CARD HOLDER',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                holderText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Right Column: Balance Snapshot
        if (showBalance)
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BALANCE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${wallet.currency} ${wallet.balance.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
