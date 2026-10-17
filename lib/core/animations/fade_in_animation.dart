import 'package:flutter/widgets.dart';

/// A gentle, clean Fade-In entrance animation with a subtle slide offset.
/// Provides a natural, non-distracting transition for screen elements.
class FadeInAnimation extends StatefulWidget {
  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 320),
    this.delay = Duration.zero,
    this.offset = const Offset(0, 10),
    this.curve = Curves.easeOutCubic,
    this.trigger,
  });

  /// The widget to animate
  final Widget child;

  /// Duration of the fade-in (default 320ms)
  final Duration duration;

  /// Delay before animating (useful for subtle staggering)
  final Duration delay;

  /// Subtle initial offset (default 10px downward for gentle rise)
  final Offset offset;

  /// Easing curve (default Curves.easeOutCubic)
  final Curve curve;

  /// Optional trigger to replay the fade (e.g. tab switch)
  final dynamic trigger;

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
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
    if (disableAnimations) {
      return widget.child;
    }

    if (!_hasStarted && widget.delay > Duration.zero) {
      return Opacity(
        opacity: 0.0,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
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
