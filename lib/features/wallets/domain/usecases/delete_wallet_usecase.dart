import '../repositories/wallets_repository.dart';

/// Use case for deleting a wallet by its ID
class DeleteWalletUseCase {
  const DeleteWalletUseCase(this._repository);

  final WalletsRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteWallet(id);
  }
}
