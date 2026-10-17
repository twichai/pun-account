import 'package:flutter/widgets.dart';

/// Large display for the active input amount and available account balance.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    this.currencySymbol = r'$',
    this.availableBalance = 'Available \$0.00',
    required this.modalFg,
    required this.modalMutedFg,
  });

  final String amount;
  final String currencySymbol;
  final String availableBalance;
  final Color modalFg;
  final Color modalMutedFg;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              currencySymbol,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: modalMutedFg,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              amount,
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
          availableBalance,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: modalMutedFg,
          ),
        ),
      ],
    );
  }
}
