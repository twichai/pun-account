import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/animations/fade_in_animation.dart';
import 'providers/wallets_provider.dart';
import 'widgets/add_card_drawer.dart';
import 'widgets/dark_obsidian_wallet_card.dart';

/// WalletsScreen presenting Dark Obsidian Mesh / Aurora cards and Cash wallets
class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key, this.onAddTransaction, this.isActive = true});

  final VoidCallback? onAddTransaction;
  final bool isActive;

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen> {
  // A GlobalKey lets us access the RefreshTrigger's state so we can
  // trigger a programmatic refresh (via a button) in addition to pull-to-refresh.
  final GlobalKey<RefreshTriggerState> _refreshTriggerKey =
      GlobalKey<RefreshTriggerState>();

  @override
  Widget build(BuildContext context) {
    final walletsState = ref.watch(walletsProvider);
    final wallets = walletsState.wallets;

    return RefreshTrigger(
      key: _refreshTriggerKey,
      // Called when the user pulls down far enough or when we call .refresh().
      // Triggers wallet refetch from backend / repository with smooth delay.
      onRefresh: () async {
        await Future.wait([
          ref.read(walletsProvider.notifier).fetchWallets(),
          Future.delayed(const Duration(seconds: 1)),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Title & Action buttons with subtle fade
            FadeInAnimation(
              trigger: widget.isActive,
              offset: const Offset(0, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Cards',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Digital Cards & Wallets Stack with gentle fade-in
            for (int i = 0; i < wallets.length; i++) ...[
              FadeInAnimation(
                trigger: widget.isActive,
                delay: Duration(milliseconds: 40 + (i * 35)),
                offset: const Offset(0, 10),
                child: DarkObsidianWalletCard(
                  wallet: wallets[i],
                  onTap: () => AddCardDrawer.show(context, wallet: wallets[i]),
                  onShowDetails: () =>
                      AddCardDrawer.show(context, wallet: wallets[i]),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
