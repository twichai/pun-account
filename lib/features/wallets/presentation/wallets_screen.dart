import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'providers/wallets_provider.dart';
import 'widgets/add_card_drawer.dart';
import 'widgets/dark_obsidian_wallet_card.dart';

/// WalletsScreen presenting Dark Obsidian Mesh / Aurora cards and Cash wallets
class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key, this.onAddTransaction});

  final VoidCallback? onAddTransaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsState = ref.watch(walletsProvider);
    final wallets = walletsState.wallets;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Title & "Add Card" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Cards',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              PrimaryButton(
                onPressed: () => AddCardDrawer.show(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Card',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Digital Cards & Wallets Stack
          for (final wallet in wallets) ...[
            DarkObsidianWalletCard(
              wallet: wallet,
              onTap: () => AddCardDrawer.show(context, wallet: wallet),
              onShowDetails: () => AddCardDrawer.show(context, wallet: wallet),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
