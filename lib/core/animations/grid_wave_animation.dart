import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Motion specifications from Motion Atlas / klik-anim for the "Grid Wave" animation:
/// - Raises grid items in a diagonal wave across the layout
/// - Motion length: 900ms
/// - Easing: easeOutCubic cubic-bezier(.33, 1, .68, 1)
/// - Feeling: Soft
/// - Values: Y +18 -> 0, scale 0.78 -> 1
/// - Delay: (row + col) * 55ms
/// - Reduced-motion alternative: Stop movement, flashing, and repetition; show a readable representative frame.
class GridWaveMotion {
  const GridWaveMotion._();

  /// Easing: easeOutCubic cubic-bezier(.33, 1, .68, 1)
  static const Curve curve = Cubic(0.33, 1.0, 0.68, 1.0);

  /// Motion length: 900ms
  static const Duration defaultDuration = Duration(milliseconds: 900);

  /// Delay step multiplier: 55ms per (row + col)
  static const Duration stepDelay = Duration(milliseconds: 55);

  /// Default start Y offset: +18.0
  static const double defaultStartY = 18.0;

  /// Default start scale: 0.78
  static const double defaultStartScale = 0.78;

  /// Calculates delay based on diagonal position: (row + col) * 55ms
  static Duration delayFor(int row, int col, {Duration step = stepDelay}) {
    return Duration(milliseconds: (row + col) * step.inMilliseconds);
  }
}

/// A Flutter widget implementing the "Grid Wave" motion design spec:
/// - Staggers grid items diagonally using (row + col) * 55ms
/// - Smoothly translates upward from Y = +18 to Y = 0
/// - Softly scales up from 0.78 to 1.0 with easeOutCubic (cubic-bezier(0.33, 1, 0.68, 1))
/// - Respects reduced-motion settings by rendering the final frame directly without movement
class GridWaveAnimation extends StatefulWidget {
  const GridWaveAnimation({
    super.key,
    required this.child,
    this.row = 0,
    this.col = 0,
    this.customDelay,
    this.duration = GridWaveMotion.defaultDuration,
    this.curve = GridWaveMotion.curve,
    this.startY = GridWaveMotion.defaultStartY,
    this.startScale = GridWaveMotion.defaultStartScale,
    this.fadeIn = true,
    this.trigger,
    this.onCompleted,
  });

  /// Factory constructor to compute row and column from a flat index and crossAxisCount.
  factory GridWaveAnimation.indexed({
    Key? key,
    required int index,
    int crossAxisCount = 3,
    required Widget child,
    Duration? customDelay,
    Duration duration = GridWaveMotion.defaultDuration,
    Curve curve = GridWaveMotion.curve,
    double startY = GridWaveMotion.defaultStartY,
    double startScale = GridWaveMotion.defaultStartScale,
    bool fadeIn = true,
    dynamic trigger,
    VoidCallback? onCompleted,
  }) {
    return GridWaveAnimation(
      key: key,
      row: index ~/ crossAxisCount,
      col: index % crossAxisCount,
      customDelay: customDelay,
      duration: duration,
      curve: curve,
      startY: startY,
      startScale: startScale,
      fadeIn: fadeIn,
      trigger: trigger,
      onCompleted: onCompleted,
      child: child,
    );
  }

  /// The widget to animate.
  final Widget child;

  /// 0-indexed row position in the grid.
  final int row;

  /// 0-indexed column position in the grid.
  final int col;

  /// Optional override for the delay. If null, computed as (row + col) * 55ms.
  final Duration? customDelay;

  /// Duration of the wave motion (default 900ms).
  final Duration duration;

  /// Easing curve (default easeOutCubic: Cubic(0.33, 1.0, 0.68, 1.0)).
  final Curve curve;

  /// Starting vertical translation in logical pixels (default +18.0).
  final double startY;

  /// Starting scale multiplier (default 0.78).
  final double startScale;

  /// Whether to smoothly fade in from opacity 0.0 to 1.0 during entrance.
  final bool fadeIn;

  /// Optional trigger value. When changed, the animation replays.
  final dynamic trigger;

  /// Callback fired when the animation completes.
  final VoidCallback? onCompleted;

  @override
  State<GridWaveAnimation> createState() => _GridWaveAnimationState();
}

class _GridWaveAnimationState extends State<GridWaveAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;
  bool _hasStarted = false;

  Duration get _effectiveDelay =>
      widget.customDelay ?? GridWaveMotion.delayFor(widget.row, widget.col);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted?.call();
        }
      });

    if (widget.trigger is! bool || (widget.trigger as bool)) {
      _schedulePlay();
    }
  }

  @override
  void didUpdateWidget(covariant GridWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.trigger != widget.trigger) {
      if (widget.trigger is bool && !(widget.trigger as bool)) {
        _delayTimer?.cancel();
        _controller.reset();
        if (mounted) {
          setState(() {
            _hasStarted = false;
          });
        }
      } else {
        _delayTimer?.cancel();
        _controller.reset();
        _schedulePlay();
      }
    }
  }

  void _schedulePlay() {
    _delayTimer?.cancel();
    final delay = _effectiveDelay;

    if (delay == Duration.zero) {
      if (mounted) {
        setState(() {
          _hasStarted = true;
        });
        _controller.forward(from: 0.0);
      }
    } else {
      _hasStarted = false;
      _delayTimer = Timer(delay, () {
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
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // Reduced-motion alternative: Stop movement, flashing, and repetition; show a readable representative frame.
    if (disableAnimations) {
      return widget.child;
    }

    // While waiting for diagonal wavefront delay, hide or render in initial state
    if (!_hasStarted && _effectiveDelay > Duration.zero) {
      if (widget.fadeIn) {
        return Opacity(opacity: 0.0, child: widget.child);
      }
      return Transform.translate(
        offset: Offset(0, widget.startY),
        child: Transform.scale(
          scale: widget.startScale,
          child: widget.child,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = widget.curve.transform(_controller.value);
        final currentY = ui.lerpDouble(widget.startY, 0.0, progress)!;
        final currentScale = ui.lerpDouble(widget.startScale, 1.0, progress)!;
        final opacity = widget.fadeIn ? progress.clamp(0.0, 1.0) : 1.0;

        Widget content = Transform.translate(
          offset: Offset(0, currentY),
          child: Transform.scale(
            scale: currentScale,
            child: child,
          ),
        );

        if (widget.fadeIn && opacity < 1.0) {
          content = Opacity(opacity: opacity, child: content);
        }

        return content;
      },
      child: widget.child,
    );
  }
}
