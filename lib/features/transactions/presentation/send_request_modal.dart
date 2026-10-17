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
        showDragHandle: true,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      ),
      builder: (context) =>
          SendRequestModal(initialMode: mode, recipientName: recipientName),
    ).future;
  }

  @override
  State<SendRequestModal> createState() => _SendRequestModalState();
}

class _TaskServiceInfo {
  final String name;
  final String category;
  final String subtitle;
  final String? lastCost;
  final IconData icon;
  final Color color;

  const _TaskServiceInfo({
    required this.name,
    required this.category,
    required this.subtitle,
    this.lastCost,
    required this.icon,
    required this.color,
  });
}

class _SendRequestModalState extends State<SendRequestModal> {
  late TransferMode _mode;
  late String _amountStr;
  String _selectedAccount = 'Pavlo • 7642 USD';
  String? _operator;
  double? _firstOperand;
  late String _selectedTask;
  bool _isSaving = false;

  static final Map<String, _TaskServiceInfo> _taskDb = {
    'AWS Cloud': const _TaskServiceInfo(
      name: 'AWS Cloud',
      category: 'Cloud Infrastructure',
      subtitle: 'Cloud Infrastructure • @aws.billing',
      lastCost: '345.50',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
    ),
    'AWS Infrastructure': const _TaskServiceInfo(
      name: 'AWS Infrastructure',
      category: 'Cloud Infrastructure',
      subtitle: 'Cloud Infrastructure • @aws.billing',
      lastCost: '345.50',
      icon: LucideIcons.cloud,
      color: Color(0xFFF59E0B),
    ),
    'OpenAI': const _TaskServiceInfo(
      name: 'OpenAI API & ChatGPT',
      category: 'AI Services',
      subtitle: 'AI & Intelligence • @openai.api',
      lastCost: '120.00',
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
    ),
    'OpenAI API & ChatGPT': const _TaskServiceInfo(
      name: 'OpenAI API & ChatGPT',
      category: 'AI Services',
      subtitle: 'AI & Intelligence • @openai.api',
      lastCost: '120.00',
      icon: LucideIcons.sparkles,
      color: Color(0xFF10B981),
    ),
    'Figma': const _TaskServiceInfo(
      name: 'Figma Enterprise',
      category: 'Design Tools',
      subtitle: 'UI/UX Design Platform • @figma.team',
      lastCost: '45.00',
      icon: LucideIcons.palette,
      color: Color(0xFFA855F7),
    ),
    'Apple': const _TaskServiceInfo(
      name: 'Apple Developer Account',
      category: 'Developer Services',
      subtitle: 'Services & Subscriptions • @apple.services',
      lastCost: '60.00',
      icon: LucideIcons.laptop,
      color: Color(0xFF0EA5E9),
    ),
    'Google Cloud': const _TaskServiceInfo(
      name: 'Google Cloud Platform',
      category: 'Cloud Hosting',
      subtitle: 'Hosting & Compute • @google.cloud',
      lastCost: '89.00',
      icon: LucideIcons.globe,
      color: Color(0xFFEF4444),
    ),
    'GitHub': const _TaskServiceInfo(
      name: 'GitHub Enterprise',
      category: 'Developer Tools',
      subtitle: 'Code & CI/CD • @github.dev',
      lastCost: '21.00',
      icon: LucideIcons.code,
      color: Color(0xFF6366F1),
    ),
    'Supabase Database': const _TaskServiceInfo(
      name: 'Supabase Database',
      category: 'Backend & DB',
      subtitle: 'Managed PostgreSQL • @supabase.io',
      lastCost: '25.00',
      icon: LucideIcons.database,
      color: Color(0xFF22C55E),
    ),
    'Vercel Pro': const _TaskServiceInfo(
      name: 'Vercel Pro',
      category: 'Deployment & CDN',
      subtitle: 'Edge Network • @vercel.app',
      lastCost: '20.00',
      icon: LucideIcons.triangle,
      color: Color(0xFF64748B),
    ),
    'New Service': const _TaskServiceInfo(
      name: 'New Service (No History)',
      category: 'Custom Service',
      subtitle: 'No previous payments in database',
      lastCost: null,
      icon: LucideIcons.circleDashed,
      color: Color(0xFF71717A),
    ),
  };

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
      child: ToastLayer(
        maxStackedEntries: 1,
        padding: const EdgeInsets.only(top: 20),
        child: Builder(
          builder: (modalContext) {
            return Container(
              height: screenHeight * 0.95,
              width: double.infinity,
              decoration: BoxDecoration(
                color: modalBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
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
                                          'ครั้งเดียว',
                                          TransferMode.send,
                                          modalBg,
                                          modalFg,
                                          modalMutedFg,
                                          modalContext,
                                        ),
                                        _buildModeTab(
                                          'รายเดือน',
                                          TransferMode.request,
                                          modalBg,
                                          modalFg,
                                          modalMutedFg,
                                          modalContext,
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
                                      child: Text(
                                        'To: ${widget.recipientName}',
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  // Amount Display
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
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

                          // Card for the task (defaults to AWS Cloud, displays last paid cost)
                          _buildTaskCard(
                            modalContext,
                            modalBg,
                            modalFg,
                            modalMutedBg,
                            modalMutedFg,
                            modalBorder,
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
                                      closeOverlay(context);
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
                                          child: CircularProgressIndicator(
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

  Widget _buildModeTab(
    String label,
    TransferMode mode,
    Color modalBg,
    Color modalFg,
    Color modalMutedFg,
    BuildContext toastContext,
  ) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        if (mode == TransferMode.request) {
          showToast(
            context: toastContext,
            location: ToastLocation.topCenter,
            showDuration: const Duration(seconds: 3),
            builder: (context, overlay) {
              return SurfaceCard(
                child: Basic(
                  leading: const Icon(LucideIcons.sparkles, size: 18),
                  title: const Text('กำลังพัฒนา'),
                  subtitle: const Text(
                    'ฟังก์ชันรายเดือนกำลังอยู่ระหว่างการพัฒนา',
                  ),
                ),
              );
            },
          );
          return;
        }
        setState(() => _mode = mode);
      },
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

  _TaskServiceInfo _getTaskInfo(String taskName) {
    if (_taskDb.containsKey(taskName)) {
      return _taskDb[taskName]!;
    }
    for (final entry in _taskDb.entries) {
      if (entry.key.toLowerCase() == taskName.toLowerCase() ||
          taskName.toLowerCase().contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(taskName.toLowerCase())) {
        return entry.value;
      }
    }
    return _TaskServiceInfo(
      name: taskName,
      category: 'Service / Payee',
      subtitle: 'Custom payee • @${taskName.toLowerCase().replaceAll(' ', '')}',
      lastCost: null,
      icon: LucideIcons.cloud,
      color: const Color(0xFFF59E0B),
    );
  }

  void _onUseLastCost(BuildContext context, String? lastCost, String taskName) {
    if (lastCost != null && lastCost.isNotEmpty) {
      setState(() {
        _amountStr = lastCost;
        _firstOperand = null;
        _operator = null;
        _hasUserTyped = true;
      });
      HapticFeedback.lightImpact();
      showToast(
        context: context,
        location: ToastLocation.topCenter,
        showDuration: const Duration(seconds: 2),
        builder: (context, overlay) {
          return SurfaceCard(
            child: Basic(
              leading: const Icon(
                LucideIcons.check,
                size: 18,
                color: Color(0xFF10B981),
              ),
              title: const Text('ใช้ยอดล่าสุดแล้ว'),
              subtitle: Text(
                'กำหนดยอดชำระ \$$lastCost สำหรับ $taskName เรียบร้อยแล้ว',
              ),
            ),
          );
        },
      );
    } else {
      HapticFeedback.heavyImpact();
      showToast(
        context: context,
        location: ToastLocation.topCenter,
        showDuration: const Duration(seconds: 3),
        builder: (context, overlay) {
          return SurfaceCard(
            child: Basic(
              leading: const Icon(
                LucideIcons.circleAlert,
                size: 18,
                color: Color(0xFFEF4444),
              ),
              title: const Text('ไม่พบยอดชำระล่าสุด'),
              subtitle: Text(
                'ไม่พบประวัติยอดชำระในระบบสำหรับ $taskName (Not found cost paid last time)',
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildTaskCard(
    BuildContext modalContext,
    Color modalBg,
    Color modalFg,
    Color modalMutedBg,
    Color modalMutedFg,
    Color modalBorder,
  ) {
    final taskInfo = _getTaskInfo(_selectedTask);
    final lastCost = taskInfo.lastCost;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: modalMutedBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: modalBorder.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // images / logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  taskInfo.color.withValues(alpha: 0.85),
                  taskInfo.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: taskInfo.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(taskInfo.icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),

          // title & subtitle
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          taskInfo.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: modalFg,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    taskInfo.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: modalMutedFg,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // btn use last cost if user is exists in db paid last time
          // else use toast not found cost paid last time
          OutlineButton(
            density: ButtonDensity.compact,
            onPressed: () =>
                _onUseLastCost(modalContext, lastCost, taskInfo.name),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.history, size: 13),
                const SizedBox(width: 5),
                Text(
                  lastCost != null ? 'Use \$$lastCost' : 'Use last cost',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A keypad button wrapper that provides immediate tactile feedback:
/// - Instant haptic vibration on pointer down
/// - Snappy spring-scale compression and bounce-back
/// - Zero gesture delay by listening directly to pointer events
class _BouncingKeypadButton extends StatefulWidget {
  const _BouncingKeypadButton({required this.child, required this.onPressed});

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
