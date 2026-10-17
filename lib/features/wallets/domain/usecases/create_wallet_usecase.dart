import '../models/wallet.dart';
import '../repositories/wallets_repository.dart';

/// Use case for creating a new wallet
class CreateWalletUseCase {
  const CreateWalletUseCase(this._repository);

  final WalletsRepository _repository;

  Future<Wallet> call({
    required String businessId,
    required Wallet wallet,
    String? name,
  }) {
    return _repository.createWallet(
      businessId: businessId,
      wallet: wallet,
      name: name,
    );
  }
}
