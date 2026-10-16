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
    return showOverlay(
      context,
      const DrawerConfiguration(
        position: OverlayPosition.bottom,
        showDragHandle: true,
      ),
      builder: (context) => SendRequestModal(
        initialMode: mode,
        recipientName: recipientName,
      ),
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
        if (_amountStr == '0' || _amountStr == '1' && widget.initialAmount == '1' && _amountStr.length == 1) {
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
    _amountStr = result % 1 == 0 ? result.toInt().toString() : result.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mode Switcher (Send / Request)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeTab('Send', TransferMode.send, isDark),
                      _buildModeTab('Request', TransferMode.request, isDark),
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
                      color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
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
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF71717A) : const Color(0xFFA1A1AA),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _amountStr,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF09090B),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Available \$7,854.43').muted().small(),

                const SizedBox(height: 20),

                // Math Operators Row (+, -, ×, ÷)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOperatorButton('+', isDark),
                    _buildOperatorButton('-', isDark),
                    _buildOperatorButton('×', isDark),
                    _buildOperatorButton('÷', isDark),
                  ],
                ),

                const SizedBox(height: 16),

                // Keypad Grid
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton('1', isDark),
                        _buildKeypadButton('2', isDark),
                        _buildKeypadButton('3', isDark),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton('4', isDark),
                        _buildKeypadButton('5', isDark),
                        _buildKeypadButton('6', isDark),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton('7', isDark),
                        _buildKeypadButton('8', isDark),
                        _buildKeypadButton('9', isDark),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadButton('.', isDark),
                        _buildKeypadButton('0', isDark),
                        _buildBackspaceButton(isDark),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: PrimaryButton(
                    onPressed: () {
                      if (_operator != null && _firstOperand != null) {
                        _calculate();
                        return;
                      }
                      closeOverlay(context);
                    },
                    child: Text(
                      _mode == TransferMode.send
                          ? 'Send \$$_amountStr'
                          : 'Request \$$_amountStr',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, TransferMode mode, bool isDark) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF3F3F46) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF09090B))
                : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A)),
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorButton(String op, bool isDark) {
    final isActive = _operator == op;
    return GestureDetector(
      onTap: () => _onOperator(op),
      child: Container(
        width: 44,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? Colors.white : const Color(0xFF09090B))
              : (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          op,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isActive
                ? (isDark ? const Color(0xFF09090B) : Colors.white)
                : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A)),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String label, bool isDark) {
    return SizedBox(
      width: 72,
      height: 52,
      child: Button(
        style: ButtonStyle.ghost(
          density: ButtonDensity.compact,
          shape: ButtonShape.circle,
        ),
        onPressed: () => _onKeyPress(label),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF09090B),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton(bool isDark) {
    return SizedBox(
      width: 72,
      height: 52,
      child: Button(
        style: ButtonStyle.ghost(
          density: ButtonDensity.compact,
          shape: ButtonShape.circle,
        ),
        onPressed: _onBackspace,
        child: Icon(
          LucideIcons.delete,
          size: 20,
          color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
        ),
      ),
    );
  }
}
