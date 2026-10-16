import 'package:flutter/material.dart';

import '../../domain/models/wallet.dart';

/// Dark Obsidian Mesh / Aurora gradient background container for Wallet cards
class AuroraMeshBackground extends StatelessWidget {
  const AuroraMeshBackground({
    super.key,
    required this.wallet,
    required this.child,
    this.borderRadius = 24.0,
    this.height = 210.0,
  });

  final Wallet wallet;
  final Widget child;
  final double borderRadius;
  final double height;

  // Aurora accent colors configured per wallet
  Color get _primaryAuroraColor {
    switch (wallet.auroraAccent.toLowerCase()) {
      case 'emerald':
        return const Color(0xFF10B981); // Emerald Mint
      case 'violet':
        return const Color(0xFFA855F7); // Neon Purple
      case 'amber':
        return const Color(0xFFF59E0B); // Liquid Gold
      case 'cyan':
      default:
        return const Color(0xFF06B6D4); // Cyber Cyan
    }
  }

  Color get _secondaryAuroraColor {
    switch (wallet.auroraAccent.toLowerCase()) {
      case 'emerald':
        return const Color(0xFF047857);
      case 'violet':
        return const Color(0xFF6366F1); // Indigo
      case 'amber':
        return const Color(0xFFEF4444); // Sunset Red
      case 'cyan':
      default:
        return const Color(0xFF3B82F6); // Electric Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryAurora = _primaryAuroraColor;
    final secondaryAurora = _secondaryAuroraColor;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: const Color(0xFF090D16), // Deep Obsidian Slate
        boxShadow: [
          // Ambient aurora drop glow
          BoxShadow(
            color: primaryAurora.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // Layer 1: Base Dark Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0E131F),
                      Color(0xFF0A0D15),
                      Color(0xFF05070B),
                    ],
                  ),
                ),
              ),
            ),

            // Layer 2: Top-right Primary Aurora Glow Orb (Mesh)
            Positioned(
              top: -60,
              right: -50,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryAurora.withValues(alpha: 0.55),
                      primaryAurora.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Layer 3: Bottom-left Secondary Aurora Glow Orb (Mesh)
            Positioned(
              bottom: -70,
              left: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      secondaryAurora.withValues(alpha: 0.45),
                      secondaryAurora.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Layer 4: Subtle Diagonal Light Sweep reflection
            Positioned(
              top: -120,
              left: -40,
              child: Transform.rotate(
                angle: -0.45,
                child: Container(
                  width: 320,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Layer 5: Card Content
            Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }
}
