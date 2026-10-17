import 'dart:async';
import 'dart:math';

import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'widgets/amount_display.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/send_request_success_view.dart';
import 'widgets/task_service_card.dart';
import 'widgets/transfer_mode_switcher.dart';

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
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
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
  late String _selectedTask;
  bool _isSaving = false;
  bool _isSuccess = false;
  bool _hasUserTyped = false;

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
    _selectedTask = widget.recipientName ?? 'AWS Cloud';
  }

  void _closeModal() {
    if (mounted) {
      closeOverlay(context);
    }
  }

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
      child: ToastLayer(
        maxStackedEntries: 1,
        padding: const EdgeInsets.only(top: 20),
        child: Builder(
          builder: (modalContext) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: screenHeight * 0.95,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isSuccess ? const Color(0xFF059669) : modalBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: _isSuccess ? Colors.transparent : modalBorder,
                    width: 0.5,
                  ),
                ),
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
                      child: _isSuccess
                          ? SendRequestSuccessView(
                              amount: _amountStr,
                              recipientName: resolveTaskService(_selectedTask)
                                  .name,
                              accountName: _selectedAccount,
                              onClose: _closeModal,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Drag Handle
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: modalMutedFg.withValues(
                                        alpha: 0.35,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),

                                // Top flexible area (scrolls only if screen is very short, without affecting keypad)
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Mode Switcher (Send / Request)
                                        TransferModeSwitcher(
                                          selectedMode: _mode,
                                          onModeChanged: (mode) {
                                            setState(() => _mode = mode);
                                          },
                                          toastContext: modalContext,
                                          modalBg: modalBg,
                                          modalFg: modalFg,
                                          modalMutedBg: modalMutedBg,
                                          modalMutedFg: modalMutedFg,
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
                                              setState(() {
                                                _selectedAccount = val;
                                              });
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
                                            child: Text(
                                              'To: ${widget.recipientName}',
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 16),

                                        // Amount Display
                                        AmountDisplay(
                                          amount: _amountStr,
                                          modalFg: modalFg,
                                          modalMutedFg: modalMutedFg,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Card for the task (defaults to AWS Cloud, displays last paid cost)
                                TaskServiceCard(
                                  taskName: _selectedTask,
                                  onSelectLastCost: (cost) {
                                    setState(() {
                                      _amountStr = cost;
                                      _firstOperand = null;
                                      _operator = null;
                                      _hasUserTyped = true;
                                    });
                                  },
                                  toastContext: modalContext,
                                  modalFg: modalFg,
                                  modalMutedBg: modalMutedBg,
                                  modalMutedFg: modalMutedFg,
                                  modalBorder: modalBorder,
                                ),

                                const SizedBox(height: 14),

                                // Keypad Grid (completely outside scroll view for instant gesture response)
                                NumericKeypad(
                                  onKeyPress: _onKeyPress,
                                  onBackspace: _onBackspace,
                                ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: PrimaryButton(
                                    alignment: Alignment.center,
                                    onPressed: _isSaving
                                        ? null
                                        : () async {
                                            if (_operator != null &&
                                                _firstOperand != null) {
                                              _calculate();
                                              return;
                                            }
                                            setState(() => _isSaving = true);
                                            await Future.delayed(
                                              const Duration(milliseconds: 600),
                                            );
                                            if (!context.mounted) return;
                                            setState(() {
                                              _isSaving = false;
                                              _isSuccess = true;
                                            });
                                          },
                                    child: _isSaving
                                        ? const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Saving...',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'Save \$$_amountStr',
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
              ),
            );
          },
        ),
      ),
    );
  }
}
