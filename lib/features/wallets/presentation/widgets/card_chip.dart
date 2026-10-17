import 'package:flutter/material.dart';

import '../../domain/models/wallet.dart';

/// Metallic EMV Smart Chip with circuit traces
class CardChip extends StatelessWidget {
  const CardChip({
    super.key,
    required this.wallet,
    this.width = 44,
    this.height = 34,
  });

  final Wallet wallet;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE58F), Color(0xFFD4AF37), Color(0xFFA67C00)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(1, 1.5),
          ),
          BoxShadow(
            color: const Color(0xFFFFE58F).withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(-0.5, -0.5),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: width - 10,
          height: height - 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color(0xFF6B4E00).withValues(alpha: 0.5),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 0.8,
                color: const Color(0xFF6B4E00).withValues(alpha: 0.45),
              ),
              Container(
                width: 0.8,
                color: const Color(0xFF6B4E00).withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
