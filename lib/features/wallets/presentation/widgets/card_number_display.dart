import 'package:flutter/material.dart';

import '../../domain/models/wallet.dart';

/// Card/Wallet identification display with monospace typography
class CardNumberDisplay extends StatelessWidget {
  const CardNumberDisplay({
    super.key,
    required this.wallet,
    this.showFull = false,
  });

  final Wallet wallet;
  final bool showFull;

  @override
  Widget build(BuildContext context) {
    if (wallet.type == 'cash' || wallet.last4 == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PHYSICAL CASH',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Petty Cash / เงินสดในมือ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    final last4 = wallet.last4 ?? '••••';
    final displayText = showFull
        ? '4532 8920 1204 $last4'
        : '••••  ••••  ••••  $last4';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                wallet.type.toUpperCase().replaceAll('_', ' '),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          displayText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4,
            shadows: [
              Shadow(
                color: Colors.black54,
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
