import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A keypad button wrapper that provides immediate tactile feedback:
/// - Instant haptic vibration on pointer down
/// - Snappy spring-scale compression and bounce-back
/// - Zero gesture delay by listening directly to pointer events
class BouncingKeypadButton extends StatefulWidget {
  const BouncingKeypadButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  State<BouncingKeypadButton> createState() => _BouncingKeypadButtonState();
}

class _BouncingKeypadButtonState extends State<BouncingKeypadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) {
    HapticFeedback.lightImpact();
    widget.onPressed();
    _controller.forward(from: 0.0);
  }

  void _onPointerUp(PointerUpEvent _) {
    _controller.reverse();
  }

  void _onPointerCancel(PointerCancelEvent _) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: SizedBox(
            height: 54,
            child: IgnorePointer(
              child: SecondaryButton(
                alignment: Alignment.center,
                onPressed: () {},
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
