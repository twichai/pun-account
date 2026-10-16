import 'package:shadcn_flutter/shadcn_flutter.dart';

enum TransactionType { expense, income, transfer }

/// Quick add transaction modal.
class QuickAddModal extends StatefulWidget {
  const QuickAddModal({super.key});

  static Future<void> show(BuildContext context) {
    return showOverlay(
      context,
      const DialogConfiguration(),
      builder: (context) => const QuickAddModal(),
    ).future;
  }

  @override
  State<QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends State<QuickAddModal> {
  TransactionType _type = TransactionType.expense;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'อาหารและเครื่องดื่ม';
  String _selectedWallet = 'บัญชีธนาคาร (KBank)';

  final List<String> _expenseCategories = [
    'อาหารและเครื่องดื่ม',
    'เดินทาง',
    'ค่าเช่า / เซิร์ฟเวอร์',
    'อุปกรณ์ / ซอฟต์แวร์',
    'การตลาด / โฆษณา',
    'เบ็ดเตล็ด',
  ];

  final List<String> _incomeCategories = [
    'รายได้จากงานฟรีแลนซ์',
    'ขายสินค้าออนไลน์',
    'ค่าที่ปรึกษา',
    'ผลตอบแทนจากการลงทุน',
  ];

  final List<String> _wallets = [
    'บัญชีธนาคาร (KBank)',
    'เงินสดสำรอง (Cash)',
    'บัญชีสำรองภาษี (Tax Reserve)',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.income
        ? _incomeCategories
        : _expenseCategories;

    if (!categories.contains(_selectedCategory) &&
        _type != TransactionType.transfer) {
      _selectedCategory = categories.first;
    }

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.plus, size: 20),
              const SizedBox(width: 8),
              const Text('บันทึกรายการใหม่').h4(),
            ],
          ),
          IconButton.ghost(
            density: ButtonDensity.icon,
            icon: const Icon(LucideIcons.x, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Transaction type selector
              Row(
                children: [
                  Expanded(
                    child: Button(
                      style: _type == TransactionType.expense
                          ? const ButtonStyle.destructive()
                          : const ButtonStyle.outline(),
                      onPressed: () {
                        setState(() {
                          _type = TransactionType.expense;
                        });
                      },
                      child: const Text('รายจ่าย'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Button(
                      style: _type == TransactionType.income
                          ? const ButtonStyle.primary()
                          : const ButtonStyle.outline(),
                      onPressed: () {
                        setState(() {
                          _type = TransactionType.income;
                        });
                      },
                      child: const Text('รายรับ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Button(
                      style: _type == TransactionType.transfer
                          ? const ButtonStyle.secondary()
                          : const ButtonStyle.outline(),
                      onPressed: () {
                        setState(() {
                          _type = TransactionType.transfer;
                        });
                      },
                      child: const Text('โอนย้าย'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount input
              const Text('จำนวนเงิน (บาท)').small(),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                placeholder: const Text('฿ 0.00'),
              ),
              const SizedBox(height: 16),

              // Wallet Selector
              const Text('กระเป๋าเงิน / บัญชี').small(),
              const SizedBox(height: 6),
              Select<String>(
                value: _selectedWallet,
                itemBuilder: (context, item) => Text(item),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedWallet = val;
                    });
                  }
                },
                popup: SelectPopup(
                  items: SelectItemList(
                    children: [
                      for (final wallet in _wallets)
                        SelectItemButton(
                          value: wallet,
                          child: Text(wallet),
                        ),
                    ],
                  ),
                ).call,
              ),
              const SizedBox(height: 16),

              // Category (if not transfer)
              if (_type != TransactionType.transfer) ...[
                const Text('หมวดหมู่').small(),
                const SizedBox(height: 6),
                Select<String>(
                  value: _selectedCategory,
                  itemBuilder: (context, item) => Text(item),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                  popup: SelectPopup(
                    items: SelectItemList(
                      children: [
                        for (final cat in categories)
                          SelectItemButton(
                            value: cat,
                            child: Text(cat),
                          ),
                      ],
                    ),
                  ).call,
                ),
                const SizedBox(height: 16),
              ],

              // Note
              const Text('บันทึกช่วยจำ (ถ้ามี)').small(),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                placeholder: const Text('เช่น ค่าอาหารกลางวัน, ค่ากาแฟคุยงาน'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlineButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        PrimaryButton(
          onPressed: () {
            // Save transaction logic (mocked)
            Navigator.of(context).pop();
          },
          leading: const Icon(LucideIcons.check, size: 16),
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}
