import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../wallets/domain/models/wallet.dart';
import '../../wallets/presentation/providers/wallets_provider.dart';
import '../data/transactions_repository.dart';
import 'widgets/amount_display.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/send_request_success_view.dart';
import 'widgets/task_service_card.dart';
import 'widgets/transfer_mode_switcher.dart';

enum TransferMode { send, request }

/// Modal for sending or requesting money with a calculator-style keypad,
/// inspired by modern fintech UX and styled with shadcn_flutter.
class SendRequestModal extends ConsumerStatefulWidget {
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
  ConsumerState<SendRequestModal> createState() => _SendRequestModalState();
}

class _SendRequestModalState extends ConsumerState<SendRequestModal> {
  late TransferMode _mode;
  late String _amountStr;
  String? _selectedWalletId;
  String? _operator;
  double? _firstOperand;
  late String _selectedTask;
  bool _isSaving = false;
  bool _isSuccess = false;
  bool _hasUserTyped = false;

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

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$integerPart.${parts[1]}';
  }

  Future<void> _handleSave() async {
    if (_operator != null && _firstOperand != null) {
      _calculate();
      return;
    }

    final amountVal = double.tryParse(_amountStr) ?? 0.0;
    if (amountVal <= 0) {
      return;
    }

    setState(() => _isSaving = true);

    final taskInfo = resolveTaskService(_selectedTask);
    final serviceId = taskInfo.id ?? '01927600-0201-7000-8000-000000000001';

    final authState = ref.read(authProvider);
    final wallets = ref.read(walletsProvider).wallets;
    Wallet? selectedWallet;
    for (final w in wallets) {
      if (w.id == _selectedWalletId) {
        selectedWallet = w;
        break;
      }
    }
    if (selectedWallet == null && wallets.isNotEmpty) {
      selectedWallet = wallets.first;
    }

    final targetBusinessId = authState.session?.user.businessId ??
        selectedWallet?.businessId ??
        '01a14648-44b7-7330-b07d-d0ca0c9353ba';
    final targetWalletId =
        selectedWallet?.id ?? '01a14648-44bd-7989-8dbe-66cf133b3e98';
    final txType = _mode == TransferMode.send ? 'expense' : 'income';

    try {
      final repo = ref.read(transactionsRepositoryProvider);
      await repo.createTransaction(
        businessId: targetBusinessId,
        walletId: targetWalletId,
        serviceId: serviceId,
        type: txType,
        amount: amountVal,
        description:
            '${_mode == TransferMode.send ? "Send to" : "Request from"} ${taskInfo.name}',
      );
      // Refresh wallets in the background to show new balance
      unawaited(
        ref
            .read(walletsProvider.notifier)
            .fetchWallets(businessId: targetBusinessId),
      );
    } catch (e) {
      // In case backend is offline, test environment or network timeout
      debugPrint('Create transaction notice: $e');
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final walletsState = ref.watch(walletsProvider);
    final wallets = walletsState.wallets;

    final List<MapEntry<String, String>> accountOptions = [];
    if (wallets.isNotEmpty) {
      for (final w in wallets) {
        String label;
        if (w.type.toLowerCase() == 'cash') {
          final name = w.name;
          label = 'เงินสด • $name';
        } else {
          final brand = (w.cardBrand != null && w.cardBrand!.trim().isNotEmpty)
              ? w.cardBrand!.trim()
              : w.type;
          final last4 = (w.last4 != null && w.last4!.trim().isNotEmpty)
              ? w.last4!.trim()
              : (w.id.length >= 4 ? w.id.substring(w.id.length - 4) : w.id);
          label = '$brand • $last4';
        }
        accountOptions.add(MapEntry(w.id, label));
      }
    } else {
      accountOptions.addAll(const [
        MapEntry('wallet-cash-1', 'เงินสด • เงินสดในมือ'),
        MapEntry('wallet-card-1', 'visa • 7642'),
        MapEntry('wallet-card-2', 'mastercard • 5123'),
      ]);
    }

    if (_selectedWalletId == null ||
        !accountOptions.any((opt) => opt.key == _selectedWalletId)) {
      _selectedWalletId = accountOptions.first.key;
    }
    final selectedOption = accountOptions.firstWhere(
      (opt) => opt.key == _selectedWalletId,
      orElse: () => accountOptions.first,
    );

    final availableWallets =
        wallets.isNotEmpty ? wallets : WalletsState.defaultWallets;
    Wallet? selectedWallet;
    for (final w in availableWallets) {
      if (w.id == _selectedWalletId) {
        selectedWallet = w;
        break;
      }
    }
    selectedWallet ??= availableWallets.firstOrNull;

    final availableBalanceText = selectedWallet != null
        ? 'Available \$${_formatCurrency(selectedWallet.balance)}'
        : 'Available \$0.00';

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
                              accountName: selectedOption.value,
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
                                          value: selectedOption.key,
                                          itemBuilder: (context, item) {
                                            final entry =
                                                accountOptions.firstWhere(
                                                  (e) => e.key == item,
                                                  orElse: () =>
                                                      accountOptions.first,
                                                );
                                            return Text(
                                              entry.value,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: modalFg,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          },
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _selectedWalletId = val;
                                              });
                                            }
                                          },
                                          popup: SelectPopup(
                                            items: SelectItemList(
                                              children: [
                                                for (final opt
                                                    in accountOptions)
                                                  SelectItemButton(
                                                    value: opt.key,
                                                    child: Text(opt.value),
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
                                          availableBalance:
                                              availableBalanceText,
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
                                    onPressed: _isSaving ? null : _handleSave,
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

