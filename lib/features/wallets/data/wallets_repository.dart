import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/models/wallet.dart';
import '../domain/repositories/wallets_repository.dart';

export '../domain/repositories/wallets_repository.dart';

/// Provider for WalletsRepository
final walletsRepositoryProvider = Provider<WalletsRepository>((ref) {
  return ApiWalletsRepository(client: ref.watch(apiClientProvider));
});

/// API implementation of WalletsRepository communicating with Go backend
class ApiWalletsRepository implements WalletsRepository {
  ApiWalletsRepository({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<List<Wallet>> getWallets({required String businessId}) async {
    final response = await _client.get(
      '/wallets/',
      queryParameters: {'business_id': businessId},
    );

    if (response is List) {
      return response
          .map(
            (item) => Wallet.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected list wallets response format',
    );
  }

  @override
  Future<Wallet> getWalletById(String id) async {
    final response = await _client.get('/wallets/$id');
    if (response is Map) {
      return Wallet.fromJson(Map<String, dynamic>.from(response));
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected get wallet response format',
    );
  }

  @override
  Future<Wallet> createWallet({
    required String businessId,
    required Wallet wallet,
    String? name,
  }) async {
    final walletName = name ??
        (wallet.cardHolder?.isNotEmpty == true
            ? wallet.cardHolder!
            : (wallet.type == 'cash' ? 'Cash Wallet' : 'Digital Card'));

    final payload = <String, dynamic>{
      'business_id': businessId,
      'name': walletName,
      'type': wallet.type,
      'currency': wallet.currency,
      'initial_balance': wallet.balance,
      'ui': {
        'aurora_accent': wallet.auroraAccent,
        'card_holder': wallet.cardHolder,
        'last4': wallet.last4,
        'card_brand': wallet.cardBrand,
      },
    };

    final response = await _client.post('/wallets/', body: payload);
    if (response is Map) {
      return Wallet.fromJson(Map<String, dynamic>.from(response));
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected create wallet response format',
    );
  }

  @override
  Future<Wallet> updateWallet({
    required String id,
    required Wallet wallet,
    String? name,
  }) async {
    final payload = <String, dynamic>{
      'name': ?name,
      'type': wallet.type,
      'currency': wallet.currency,
      'balance': wallet.balance,
      'is_active': wallet.isActive,
      'ui': {
        'aurora_accent': wallet.auroraAccent,
        'card_holder': wallet.cardHolder,
        'last4': wallet.last4,
        'card_brand': wallet.cardBrand,
      },
    };

    final response = await _client.put('/wallets/$id', body: payload);
    if (response is Map) {
      return Wallet.fromJson(Map<String, dynamic>.from(response));
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected update wallet response format',
    );
  }

  @override
  Future<void> deleteWallet(String id) async {
    await _client.delete('/wallets/$id');
  }
}
