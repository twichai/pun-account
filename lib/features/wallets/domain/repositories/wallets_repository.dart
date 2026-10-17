import '../models/wallet.dart';

/// Contract for wallet data operations
abstract class WalletsRepository {
  /// Fetch all wallets belonging to a given business
  Future<List<Wallet>> getWallets({required String businessId});

  /// Fetch a single wallet by its unique ID
  Future<Wallet> getWalletById(String id);

  /// Create a new wallet
  Future<Wallet> createWallet({
    required String businessId,
    required Wallet wallet,
    String? name,
  });

  /// Update an existing wallet
  Future<Wallet> updateWallet({
    required String id,
    required Wallet wallet,
    String? name,
  });

  /// Delete a wallet by its unique ID
  Future<void> deleteWallet(String id);
}
