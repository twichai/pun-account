import '../models/wallet.dart';
import '../repositories/wallets_repository.dart';

/// Use case for updating an existing wallet
class UpdateWalletUseCase {
  const UpdateWalletUseCase(this._repository);

  final WalletsRepository _repository;

  Future<Wallet> call({
    required String id,
    required Wallet wallet,
    String? name,
  }) {
    return _repository.updateWallet(
      id: id,
      wallet: wallet,
      name: name,
    );
  }
}
