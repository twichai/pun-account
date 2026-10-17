import '../models/wallet.dart';
import '../repositories/wallets_repository.dart';

/// Use case for retrieving all wallets for a business
class GetWalletsUseCase {
  const GetWalletsUseCase(this._repository);

  final WalletsRepository _repository;

  Future<List<Wallet>> call({required String businessId}) {
    return _repository.getWallets(businessId: businessId);
  }
}
