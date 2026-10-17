import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/wallets_repository.dart';
import 'create_wallet_usecase.dart';
import 'delete_wallet_usecase.dart';
import 'get_wallet_by_id_usecase.dart';
import 'get_wallets_usecase.dart';
import 'update_wallet_usecase.dart';

export 'create_wallet_usecase.dart';
export 'delete_wallet_usecase.dart';
export 'get_wallet_by_id_usecase.dart';
export 'get_wallets_usecase.dart';
export 'update_wallet_usecase.dart';

/// Provider for GetWalletsUseCase
final getWalletsUseCaseProvider = Provider<GetWalletsUseCase>((ref) {
  return GetWalletsUseCase(ref.watch(walletsRepositoryProvider));
});

/// Provider for GetWalletByIdUseCase
final getWalletByIdUseCaseProvider = Provider<GetWalletByIdUseCase>((ref) {
  return GetWalletByIdUseCase(ref.watch(walletsRepositoryProvider));
});

/// Provider for CreateWalletUseCase
final createWalletUseCaseProvider = Provider<CreateWalletUseCase>((ref) {
  return CreateWalletUseCase(ref.watch(walletsRepositoryProvider));
});

/// Provider for UpdateWalletUseCase
final updateWalletUseCaseProvider = Provider<UpdateWalletUseCase>((ref) {
  return UpdateWalletUseCase(ref.watch(walletsRepositoryProvider));
});

/// Provider for DeleteWalletUseCase
final deleteWalletUseCaseProvider = Provider<DeleteWalletUseCase>((ref) {
  return DeleteWalletUseCase(ref.watch(walletsRepositoryProvider));
});
