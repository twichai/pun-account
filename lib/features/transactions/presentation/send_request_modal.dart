import 'dart:math';

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

  void _onKeyPress(String key) {
    setState(() {
      if (key == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr = '$_amountStr.';
        }
      } else {
        if (_amountStr == '0' ||
            _amountStr == '1' &&
                widget.initialAmount == '1' &&
                _amountStr.length == 1) {
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
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

                              const SizedBox(height: 16),

                              // Spacer pushes Send button to the very bottom neatly
                              const Spacer(),
                              // Math Operators Row (+, -, ×, ÷)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildOperatorButton(
                                    '+',
                                    modalBg,
                                    modalFg,
                                    modalMutedBg,
                                    modalMutedFg,
                                    modalBorder,
                                  ),
                                  _buildOperatorButton(
                                    '-',
                                    modalBg,
                                    modalFg,
                                    modalMutedBg,
                                    modalMutedFg,
                                    modalBorder,
                                  ),
                                  _buildOperatorButton(
                                    '×',
                                    modalBg,
                                    modalFg,
                                    modalMutedBg,
                                    modalMutedFg,
                                    modalBorder,
                                  ),
                                  _buildOperatorButton(
                                    '÷',
                                    modalBg,
                                    modalFg,
                                    modalMutedBg,
                                    modalMutedFg,
                                    modalBorder,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // Keypad Grid
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildKeypadButton('1', modalFg),
                                      _buildKeypadButton('2', modalFg),
                                      _buildKeypadButton('3', modalFg),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildKeypadButton('4', modalFg),
                                      _buildKeypadButton('5', modalFg),
                                      _buildKeypadButton('6', modalFg),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildKeypadButton('7', modalFg),
                                      _buildKeypadButton('8', modalFg),
                                      _buildKeypadButton('9', modalFg),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildKeypadButton('.', modalFg),
                                      _buildKeypadButton('0', modalFg),
                                      _buildBackspaceButton(modalFg),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Action Button pinned at the very bottom
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: PrimaryButton(
                                  onPressed: () {
                                    if (_operator != null &&
                                        _firstOperand != null) {
                                      _calculate();
                                      return;
                                    }
                                    closeOverlay(context);
                                  },
                                  child: Text(
                                    _mode == TransferMode.send
                                        ? 'Send \$$_amountStr'
                                        : 'Request \$$_amountStr',
                                    style: const TextStyle(
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
                  );
                },
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

  Widget _buildKeypadButton(String label, Color modalFg) {
    return SizedBox(
      width: 76,
      height: 56,
      child: Button(
        style: ButtonStyle.ghost(
          density: ButtonDensity.compact,
          shape: ButtonShape.circle,
        ),
        onPressed: () => _onKeyPress(label),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: modalFg,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(Color modalFg) {
    return SizedBox(
      width: 76,
      height: 56,
      child: Button(
        style: ButtonStyle.ghost(
          density: ButtonDensity.compact,
          shape: ButtonShape.circle,
        ),
        onPressed: _onBackspace,
        child: Icon(LucideIcons.delete, size: 22, color: modalFg),
      ),
    );
  }
}
