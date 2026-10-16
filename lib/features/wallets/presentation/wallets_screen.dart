import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../domain/models/wallet.dart';
import 'providers/wallets_provider.dart';
import 'widgets/dark_obsidian_wallet_card.dart';

/// WalletsScreen presenting Dark Obsidian Mesh / Aurora cards and Cash wallets
class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key, this.onAddTransaction});

  final VoidCallback? onAddTransaction;

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen> {
  void _showWalletDetails(Wallet wallet) {
    final isCash = wallet.type == 'cash';

    showOverlay(
      context,
      const DialogConfiguration(),
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isCash ? LucideIcons.banknote : LucideIcons.creditCard,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(isCash ? 'Cash Wallet' : 'Digital Card').h4(),
            ],
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCash) ...[
                  const Text('Card Number').small().muted(),
                  const SizedBox(height: 2),
                  Text('4532 •••• •••• ${wallet.last4 ?? "7642"}').semiBold(),
                  const SizedBox(height: 12),
                  const Text('Cardholder').small().muted(),
                  const SizedBox(height: 2),
                  Text(wallet.cardHolder?.toUpperCase() ?? 'PAVLO D.')
                      .semiBold(),
                  const SizedBox(height: 12),
                ] else ...[
                  const Text('Wallet Category').small().muted(),
                  const SizedBox(height: 2),
                  const Text('Physical Currency / เงินสดในมือ').semiBold(),
                  const SizedBox(height: 12),
                ],
                const Text('Available Balance').small().muted(),
                const SizedBox(height: 2),
                Text('${wallet.currency} ${wallet.balance.toStringAsFixed(2)}')
                    .semiBold(),
                const SizedBox(height: 12),
                const Text('Status').small().muted(),
                const SizedBox(height: 2),
                Text(wallet.isActive ? 'Active' : 'Inactive').semiBold(),
              ],
            ),
          ),
          actions: [
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddWalletModal() {
    showOverlay(
      context,
      const DialogConfiguration(),
      builder: (context) {
        return AlertDialog(
          title: const Text('Add new wallet or card').h4(),
          content: const SizedBox(
            width: 320,
            child: Text(
              'Choose whether to add a new Cash Wallet (เงินสด) or issue a Digital Card.',
            ),
          ),
          actions: [
            OutlineButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            OutlineButton(
              onPressed: () {
                final newId = DateTime.now().millisecondsSinceEpoch.toString();
                ref
                    .read(walletsProvider.notifier)
                    .addWallet(
                      Wallet(
                        id: newId,
                        type: 'cash',
                        balance: 5000.00,
                        currency: 'THB',
                        auroraAccent: 'emerald',
                      ),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Add Cash Wallet'),
            ),
            PrimaryButton(
              onPressed: () {
                final newId = DateTime.now().millisecondsSinceEpoch.toString();
                final accents = ['cyan', 'violet', 'amber'];
                final pickedAccent =
                    accents[DateTime.now().second % accents.length];

                ref
                    .read(walletsProvider.notifier)
                    .addWallet(
                      Wallet(
                        id: newId,
                        type: 'credit_card',
                        balance: 30000.00,
                        currency: 'THB',
                        cardHolder: 'PAVLO D.',
                        last4: '${1000 + DateTime.now().millisecond % 9000}',
                        cardBrand: 'visa',
                        auroraAccent: pickedAccent,
                      ),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Add Digital Card'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Title & "Order a card" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Cards',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              PrimaryButton(
                density: ButtonDensity.compact,
                onPressed: _showAddWalletModal,
                child: const Text(
                  'Order a card',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Digital Cards & Wallets Stack
          for (final wallet in wallets) ...[
            DarkObsidianWalletCard(
              wallet: wallet,
              onTap: () => _showWalletDetails(wallet),
              onShowDetails: () => _showWalletDetails(wallet),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
