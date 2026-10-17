import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'bouncing_keypad_button.dart';

/// Numeric keypad grid with snappy haptic feedback for calculator & financial inputs.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
  });

  final ValueChanged<String> onKeyPress;
  final VoidCallback onBackspace;

  Widget _buildKeypadButton(String label) {
    return BouncingKeypadButton(
      onPressed: () => onKeyPress(label),
      child: Text(
        label,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return BouncingKeypadButton(
      onPressed: onBackspace,
      child: const Icon(LucideIcons.delete, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}
