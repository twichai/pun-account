import 'dart:async';
import 'package:flutter/widgets.dart';

/// A gentle, clean Fade In/Out entrance and exit animation with a subtle slide offset.
/// Provides a natural, non-distracting transition for screen elements when appearing or exiting.
class FadeInAnimation extends StatefulWidget {
  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 200),
    this.delay = Duration.zero,
    this.offset = const Offset(0, 10),
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.trigger,
  });

  /// The widget to animate
  final Widget child;

  /// Duration of the fade-in (default 300ms)
  final Duration duration;

  /// Duration of the fade-out when exiting (default 200ms)
  final Duration reverseDuration;

  /// Delay before animating in (useful for subtle staggering)
  final Duration delay;

  /// Subtle initial offset (default 10px downward for gentle rise)
  final Offset offset;

  /// Easing curve when entering (default Curves.easeOutCubic)
  final Curve curve;

  /// Easing curve when exiting (default Curves.easeInCubic)
  final Curve reverseCurve;

  /// Trigger flag (e.g. isActive boolean).
  /// When true, it fades in; when false, it smoothly fades out.
  final dynamic trigger;

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  Timer? _delayTimer;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.reverseDuration,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(curvedAnimation);

    if (widget.trigger is! bool || (widget.trigger as bool)) {
      _schedulePlay();
    }
  }

  @override
  void didUpdateWidget(covariant FadeInAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      if (widget.trigger is bool && !(widget.trigger as bool)) {
        // Smoothly fade out when leaving the screen
        _delayTimer?.cancel();
        _controller.reverse();
      } else {
        // Fade in when entering the screen
        _schedulePlay();
      }
    }
  }

  void _schedulePlay() {
    _delayTimer?.cancel();
    if (widget.delay == Duration.zero) {
      if (mounted) {
        setState(() {
          _hasStarted = true;
        });
        _controller.forward();
      }
    } else {
      if (mounted) {
        setState(() {
          _hasStarted = false;
        });
      }
      _delayTimer = Timer(widget.delay, () {
        if (mounted) {
          setState(() {
            _hasStarted = true;
          });
          _controller.forward();
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
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      return widget.child;
    }

    if (!_hasStarted && _controller.value == 0.0 && widget.delay > Duration.zero) {
      return Opacity(
        opacity: 0.0,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: _slide.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
