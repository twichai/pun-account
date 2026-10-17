import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'widgets/overview_header.dart';
import 'widgets/overview_transactions_sheet.dart';

export 'widgets/overview_header.dart';
export 'widgets/overview_transactions_sheet.dart';
export 'widgets/transaction_row.dart';
export 'widgets/transactions_empty_view.dart';
export 'widgets/transactions_error_view.dart';
export 'widgets/transactions_sheet_header.dart';

/// Redesigned Home Overview screen connecting header, overview summary, and draggable transactions sheet.
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({
    super.key,
    this.onNavigateToWallets,
    this.onNavigateToServices,
    this.onAddTransaction,
  });

  final VoidCallback? onNavigateToWallets;
  final VoidCallback? onNavigateToServices;
  final VoidCallback? onAddTransaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Fixed Top Header: Avatar & Notification Bell
        const OverviewHeader(),

        // Main Body: Overview summary behind + Draggable Bottom Sheet in front
        Expanded(
          child: Stack(
            children: [
              // Balance, Quick Actions, Spending Card
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(),
              ),

              // Bottom Sheet: DraggableScrollableSheet
              const OverviewTransactionsSheet(),
            ],
          ),
        ),
      ],
    );
  }
}
