import '../models/wallet.dart';
import '../repositories/wallets_repository.dart';

/// Use case for retrieving a single wallet by its ID
class GetWalletByIdUseCase {
  const GetWalletByIdUseCase(this._repository);

  final WalletsRepository _repository;

  Future<Wallet> call(String id) {
    return _repository.getWalletById(id);
  }
}
