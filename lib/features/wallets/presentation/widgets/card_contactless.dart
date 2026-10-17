import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/wallet.dart';

/// Contactless payment wave indicator
class CardContactless extends StatelessWidget {
  const CardContactless({
    super.key,
    required this.wallet,
    this.size = 20,
    this.color,
  });

  final Wallet wallet;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 90 * math.pi / 180,
      child: Icon(
        Icons.wifi,
        color: color ?? Colors.white.withValues(alpha: 0.8),
        size: size,
      ),
    );
  }
}
