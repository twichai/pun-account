import 'package:flutter/material.dart';

import '../../domain/models/wallet.dart';

/// Card brand logo badge (Visa, Mastercard, or Cash badge)
class CardBrandBadge extends StatelessWidget {
  const CardBrandBadge({super.key, required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    if (wallet.type == 'cash') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payments_outlined, size: 14, color: Color(0xFF34D399)),
            SizedBox(width: 4),
            Text(
              'CASH',
              style: TextStyle(
                color: Color(0xFF34D399),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      );
    }

    final brand = wallet.cardBrand?.toLowerCase() ?? 'visa';

    if (brand == 'mastercard') {
      return SizedBox(
        width: 44,
        height: 26,
        child: Stack(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default: VISA with sleek italic modern typography
    return const Text(
      'VISA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
    );
  }
}
