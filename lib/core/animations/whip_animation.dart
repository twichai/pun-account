import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Motion specifications from Motion Atlas / klik-anim for the "Whip" animation.
/// - Easing: cubic-bezier(0.9, 0, 0.1, 1)
/// - Motion length: 500ms (range: 400-600ms)
/// - Characteristic: Near-vertical velocity peak in the middle with a smear.
class WhipMotion {
  const WhipMotion._();

  /// Easing: cubic-bezier(0.9, 0, 0.1, 1)
  static const Curve curve = Cubic(0.9, 0.0, 0.1, 1.0);

  /// Default motion length: 500ms
  static const Duration defaultDuration = Duration(milliseconds: 500);

  /// Alternative reduced-motion crossfade duration
  static const Duration reducedMotionDuration = Duration(milliseconds: 250);
}

/// A Flutter widget implementing the "Whip" motion design spec from klik-anim:
/// - Near-vertical velocity peak for slams and transitions
/// - Dynamic smear (directional motion blur + velocity elongation stretch) during high-velocity frames
/// - Crisp landing with zero residual blur or distortion
/// - Automatic fallback to a short crossfade for reduced-motion accessibility
class WhipAnimation extends StatefulWidget {
  const WhipAnimation({
    super.key,
    required this.child,
    this.duration = WhipMotion.defaultDuration,
    this.delay = Duration.zero,
    this.startOffset = const Offset(0, 32),
    this.enableSmear = true,
    this.maxBlur = 5.0,
    this.maxStretch = 0.12,
    this.fadeIn = true,
    this.trigger,
    this.onCompleted,
  });

  /// The widget to animate (Logo, Text, Button, Card, etc.)
  final Widget child;

  /// Duration of the whip motion (defaults to 500ms)
  final Duration duration;

  /// Optional delay before starting the animation (ideal for staggered entrances)
  final Duration delay;

  /// The starting offset relative to the final position (e.g., Offset(0, 32) for an upward slam)
  final Offset startOffset;

  /// Whether to apply a smear effect (directional motion blur & velocity stretch) during fast frames
  final bool enableSmear;

  /// Maximum blur sigma applied during the peak velocity frame
  final double maxBlur;

  /// Maximum elongation stretch multiplier along the motion axis (e.g., 0.12 = 1.12x stretch)
  final double maxStretch;

  /// Whether to fade in from transparent to opaque
  final bool fadeIn;

  /// Optional trigger value. When changed, the animation replays
  final dynamic trigger;

  /// Callback fired when the animation completes
  final VoidCallback? onCompleted;

  @override
  State<WhipAnimation> createState() => _WhipAnimationState();
}

class _WhipAnimationState extends State<WhipAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted?.call();
        }
      });

    if (widget.trigger is! bool || (widget.trigger as bool)) {
      _schedulePlay();
    }
  }

  @override
  void didUpdateWidget(covariant WhipAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      if (widget.trigger is bool && !(widget.trigger as bool)) {
        _controller.reset();
        if (mounted) {
          setState(() {
            _hasStarted = false;
          });
        }
      } else {
        _controller.reset();
        _schedulePlay();
      }
    }
  }

  void _schedulePlay() {
    _hasStarted = false;
    if (widget.delay == Duration.zero) {
      if (mounted) {
        _hasStarted = true;
        _controller.forward(from: 0.0);
      }
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          setState(() {
            _hasStarted = true;
          });
          _controller.forward(from: 0.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // Reduced-motion alternative: Replace it with a short crossfade
    if (disableAnimations) {
      return AnimatedOpacity(
        opacity: _hasStarted ? 1.0 : 0.0,
        duration: WhipMotion.reducedMotionDuration,
        curve: Curves.easeOut,
        child: widget.child,
      );
    }

    // If waiting for delay, render invisible initially to prevent flash of content
    if (!_hasStarted && widget.delay > Duration.zero) {
      return Opacity(
        opacity: 0.0,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final progress = WhipMotion.curve.transform(t);

        // Opacity transition
        final opacity = widget.fadeIn
            ? (progress * 1.6).clamp(0.0, 1.0)
            : 1.0;

        // Position translation (slam into place)
        final currentOffset = Offset.lerp(widget.startOffset, Offset.zero, progress)!;

        // Smear calculation:
        // Calculate instantaneous velocity near current time t:
        // For cubic-bezier(0.9, 0, 0.1, 1), the derivative peaks sharply around t = 0.5.
        double smearFactor = 0.0;
        if (widget.enableSmear && t > 0.0 && t < 1.0) {
          const dt = 0.02;
          final t1 = (t - dt).clamp(0.0, 1.0);
          final t2 = (t + dt).clamp(0.0, 1.0);
          final dp = WhipMotion.curve.transform(t2) - WhipMotion.curve.transform(t1);
          final velocity = (dp / (t2 - t1)).abs();

          // Peak velocity is ~3.8. Smear activates when velocity > 0.8 and maxes out at ~3.5
          smearFactor = ((velocity - 0.8) / 2.7).clamp(0.0, 1.0);
        }

        // Determine motion orientation for directional smear
        final isMovingVertical = widget.startOffset.dy.abs() >= widget.startOffset.dx.abs();
        final double sigmaX = isMovingVertical ? 0.0 : widget.maxBlur * smearFactor;
        final double sigmaY = isMovingVertical ? widget.maxBlur * smearFactor : 0.0;

        // Directional squash and stretch
        final double scaleX = isMovingVertical
            ? 1.0 - (widget.maxStretch * 0.3 * smearFactor)
            : 1.0 + (widget.maxStretch * smearFactor);
        final double scaleY = isMovingVertical
            ? 1.0 + (widget.maxStretch * smearFactor)
            : 1.0 - (widget.maxStretch * 0.3 * smearFactor);

        Widget rendered = Transform.translate(
          offset: currentOffset,
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            alignment: isMovingVertical
                ? (widget.startOffset.dy > 0 ? Alignment.bottomCenter : Alignment.topCenter)
                : (widget.startOffset.dx > 0 ? Alignment.centerRight : Alignment.centerLeft),
            child: child,
          ),
        );

        // Apply directional blur filter only during the high-velocity smear frames
        if (widget.enableSmear && (sigmaX > 0.1 || sigmaY > 0.1)) {
          rendered = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: math.max(0.001, sigmaX),
              sigmaY: math.max(0.001, sigmaY),
            ),
            child: rendered,
          );
        }

        if (widget.fadeIn) {
          rendered = Opacity(
            opacity: opacity,
            child: rendered,
          );
        }

        return rendered;
      },
      child: widget.child,
    );
  }
}
