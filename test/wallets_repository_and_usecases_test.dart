import 'package:flutter_test/flutter_test.dart';
import 'package:pun_account/core/network/api_client.dart';
import 'package:pun_account/features/wallets/data/wallets_repository.dart';
import 'package:pun_account/features/wallets/domain/models/wallet.dart';
import 'package:pun_account/features/wallets/domain/usecases/wallets_usecases.dart';

class MockWalletsRepository implements WalletsRepository {
  final Map<String, Wallet> _store = {};

  @override
  Future<List<Wallet>> getWallets({required String businessId}) async {
    return _store.values.toList();
  }

  @override
  Future<Wallet> getWalletById(String id) async {
    final wallet = _store[id];
    if (wallet == null) {
      throw const ApiException(statusCode: 404, message: 'Wallet not found');
    }
    return wallet;
  }

  @override
  Future<Wallet> createWallet({
    required String businessId,
    required Wallet wallet,
    String? name,
  }) async {
    _store[wallet.id] = wallet;
    return wallet;
  }

  @override
  Future<Wallet> updateWallet({
    required String id,
    required Wallet wallet,
    String? name,
  }) async {
    if (!_store.containsKey(id)) {
      throw const ApiException(statusCode: 404, message: 'Wallet not found');
    }
    _store[id] = wallet;
    return wallet;
  }

  @override
  Future<void> deleteWallet(String id) async {
    if (!_store.containsKey(id)) {
      throw const ApiException(statusCode: 404, message: 'Wallet not found');
    }
    _store.remove(id);
  }
}

void main() {
  group('Wallets CRUD UseCases Tests', () {
    late MockWalletsRepository repo;
    late GetWalletsUseCase getWalletsUseCase;
    late GetWalletByIdUseCase getWalletByIdUseCase;
    late CreateWalletUseCase createWalletUseCase;
    late UpdateWalletUseCase updateWalletUseCase;
    late DeleteWalletUseCase deleteWalletUseCase;

    setUp(() {
      repo = MockWalletsRepository();
      getWalletsUseCase = GetWalletsUseCase(repo);
      getWalletByIdUseCase = GetWalletByIdUseCase(repo);
      createWalletUseCase = CreateWalletUseCase(repo);
      updateWalletUseCase = UpdateWalletUseCase(repo);
      deleteWalletUseCase = DeleteWalletUseCase(repo);
    });

    test('Full CRUD lifecycle: create, get, list, update, delete', () async {
      const businessId = 'biz-uuid-1';
      const initialWallet = Wallet(
        id: 'wallet-1',
        type: 'credit_card',
        balance: 20000.0,
        currency: 'THB',
        cardHolder: 'PAVLO D.',
        last4: '7642',
        cardBrand: 'visa',
        auroraAccent: 'cyan',
      );

      // 1. Create Wallet
      final created = await createWalletUseCase(
        businessId: businessId,
        wallet: initialWallet,
      );
      expect(created.id, 'wallet-1');
      expect(created.cardHolder, 'PAVLO D.');
      expect(created.balance, 20000.0);

      // 2. Get Wallet by ID
      final fetched = await getWalletByIdUseCase('wallet-1');
      expect(fetched.id, 'wallet-1');
      expect(fetched.last4, '7642');

      // 3. List Wallets
      final list = await getWalletsUseCase(businessId: businessId);
      expect(list.length, 1);
      expect(list.first.cardHolder, 'PAVLO D.');

      // 4. Update Wallet
      final updatedWallet = initialWallet.copyWith(
        cardHolder: 'PAVLO UPDATED',
        auroraAccent: 'violet',
      );
      final updated = await updateWalletUseCase(
        id: 'wallet-1',
        wallet: updatedWallet,
      );
      expect(updated.cardHolder, 'PAVLO UPDATED');
      expect(updated.auroraAccent, 'violet');

      // 5. Delete Wallet
      await deleteWalletUseCase('wallet-1');
      final listAfterDelete = await getWalletsUseCase(businessId: businessId);
      expect(listAfterDelete, isEmpty);
      expect(
        () => getWalletByIdUseCase('wallet-1'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
