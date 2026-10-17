import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

enum TransferMode { send, request }

/// Modal for sending or requesting money with a calculator-style keypad,
/// inspired by modern fintech UX and styled with shadcn_flutter.
class SendRequestModal extends StatefulWidget {
  const SendRequestModal({
    super.key,
    this.initialMode = TransferMode.send,
    this.recipientName,
    this.initialAmount = '1',
  });

  final TransferMode initialMode;
  final String? recipientName;
  final String initialAmount;

  static Future<void> show(
    BuildContext context, {
    TransferMode mode = TransferMode.send,
    String? recipientName,
  }) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return showOverlay(
      context,
      DrawerConfiguration(
        position: OverlayPosition.bottom,
        showDragHandle: false,
        surfaceOpacity: 0,
        constraints: BoxConstraints(
          minHeight: screenHeight * 0.95,
          maxHeight: screenHeight * 0.95,
        ),
      ),
      builder: (context) =>
          SendRequestModal(initialMode: mode, recipientName: recipientName),
    ).future;
  }

  @override
  State<SendRequestModal> createState() => _SendRequestModalState();
}

class _SendRequestModalState extends State<SendRequestModal> {
  late TransferMode _mode;
  late String _amountStr;
  String _selectedAccount = 'Pavlo • 7642 USD';
  String? _operator;
  double? _firstOperand;

  final List<String> _accounts = [
    'Pavlo • 7642 USD',
    'Main KBank • 1234 THB',
    'Digital Card • 5123 USD',
    'Business Reserve • 3413 USD',
  ];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _amountStr = widget.initialAmount;
  }

  bool _hasUserTyped = false;

  void _onKeyPress(String key) {
    setState(() {
      if (!_hasUserTyped) {
        _hasUserTyped = true;
        if (key == '.') {
          _amountStr = '0.';
        } else {
          _amountStr = key;
        }
        return;
      }

      if (key == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr = '$_amountStr.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else {
          // Limit to 2 decimals if decimal exists
          if (_amountStr.contains('.')) {
            final parts = _amountStr.split('.');
            if (parts.length > 1 && parts[1].length >= 2) {
              return;
            }
          }
          if (_amountStr.length < 9) {
            _amountStr += key;
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _hasUserTyped = true;
      if (_amountStr.length > 1) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      } else {
        _amountStr = '0';
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      final currentVal = double.tryParse(_amountStr) ?? 0.0;
      if (_firstOperand != null && _operator != null) {
        // Calculate intermediate result
        _calculate();
      } else {
        _firstOperand = currentVal;
      }
      _operator = op;
      _amountStr = '0';
    });
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null) return;
    final secondOperand = double.tryParse(_amountStr) ?? 0.0;
    double result = 0.0;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        result = secondOperand == 0 ? 0 : _firstOperand! / secondOperand;
        break;
    }
    _firstOperand = null;
    _operator = null;
    _amountStr = result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Convert background to foreground code, and foreground to bg
    final Color modalBg = theme.colorScheme.foreground;
    final Color modalFg = theme.colorScheme.background;
    final Color modalMutedBg = isDark
        ? const Color(0xFFF4F4F5)
        : const Color(0xFF27272A);
    final Color modalMutedFg = isDark
        ? const Color(0xFF71717A)
        : const Color(0xFFA1A1AA);
    final Color modalBorder = isDark
        ? const Color(0xFFE4E4E7)
        : const Color(0xFF3F3F46);

    final invertedColorScheme = isDark
        ? ColorSchemes.lightSlate.yellow
        : ColorSchemes.darkSlate.yellow;
    final modalTheme = isDark
        ? ThemeData(
            colorScheme: invertedColorScheme,
            radius: theme.radius,
            typography: theme.typography,
          )
        : ThemeData.dark(
            colorScheme: invertedColorScheme,
            radius: theme.radius,
            typography: theme.typography,
          );

    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Theme(
      data: modalTheme,
      child: Container(
        height: screenHeight * 0.95,
        width: double.infinity,
        decoration: BoxDecoration(
          color: modalBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: modalBorder, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  max(16.0, bottomPadding + 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: modalMutedFg.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Top flexible area (scrolls only if screen is very short, without affecting keypad)
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Mode Switcher (Send / Request)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: modalMutedBg,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildModeTab(
                                      'Send',
                                      TransferMode.send,
                                      modalBg,
                                      modalFg,
                                      modalMutedFg,
                                    ),
                                    _buildModeTab(
                                      'Request',
                                      TransferMode.request,
                                      modalBg,
                                      modalFg,
                                      modalMutedFg,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Account Selector dropdown
                              Select<String>(
                                value: _selectedAccount,
                                itemBuilder: (context, item) => Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: modalFg,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedAccount = val);
                                  }
                                },
                                popup: SelectPopup(
                                  items: SelectItemList(
                                    children: [
                                      for (final acc in _accounts)
                                        SelectItemButton(
                                          value: acc,
                                          child: Text(acc),
                                        ),
                                    ],
                                  ),
                                ).call,
                              ),

                              if (widget.recipientName != null) ...[
                                const SizedBox(height: 6),
                                SecondaryBadge(
                                  child: Text('To: ${widget.recipientName}'),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Amount Display
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    r'$',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: modalMutedFg,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _amountStr,
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w800,
                                      color: modalFg,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Available \$7,854.43',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: modalMutedFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Keypad Grid (completely outside scroll view for instant gesture response)
                    Column(
                      children: [
                        Row(
                          children: [
                            _buildKeypadButton('1'),
                            const SizedBox(width: 8),
                            _buildKeypadButton('2'),
                            const SizedBox(width: 8),
                            _buildKeypadButton('3'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildKeypadButton('4'),
                            const SizedBox(width: 8),
                            _buildKeypadButton('5'),
                            const SizedBox(width: 8),
                            _buildKeypadButton('6'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildKeypadButton('7'),
                            const SizedBox(width: 8),
                            _buildKeypadButton('8'),
                            const SizedBox(width: 8),
                            _buildKeypadButton('9'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildKeypadButton('.'),
                            const SizedBox(width: 8),
                            _buildKeypadButton('0'),
                            const SizedBox(width: 8),
                            _buildBackspaceButton(),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: PrimaryButton(
                        alignment: Alignment.center,
                        onPressed: () {
                          if (_operator != null &&
                              _firstOperand != null) {
                            _calculate();
                            return;
                          }
                          closeOverlay(context);
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(
    String label,
    TransferMode mode,
    Color modalBg,
    Color modalFg,
    Color modalMutedFg,
  ) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? modalBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? modalFg : modalMutedFg,
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildOperatorButton(
    String op,
    Color modalBg,
    Color modalFg,
    Color modalMutedBg,
    Color modalMutedFg,
    Color modalBorder,
  ) {
    final isActive = _operator == op;
    return GestureDetector(
      onTap: () => _onOperator(op),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? modalFg : modalMutedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? modalFg : modalBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          op,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isActive ? modalBg : modalMutedFg,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String label) {
    return _BouncingKeypadButton(
      onPressed: () => _onKeyPress(label),
      child: Text(
        label,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return _BouncingKeypadButton(
      onPressed: _onBackspace,
      child: const Icon(LucideIcons.delete, size: 20),
    );
  }
}

/// A keypad button wrapper that provides immediate tactile feedback:
/// - Instant haptic vibration on pointer down
/// - Snappy spring-scale compression and bounce-back
/// - Zero gesture delay by listening directly to pointer events
class _BouncingKeypadButton extends StatefulWidget {
  const _BouncingKeypadButton({
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  State<_BouncingKeypadButton> createState() => _BouncingKeypadButtonState();
}

class _BouncingKeypadButtonState extends State<_BouncingKeypadButton>
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
    // Fire immediately on touch down: zero delay, 100% reliable for rapid taps
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
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
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
