import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/models/transaction.dart';

/// Provider for TransactionsRepository
final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return ApiTransactionsRepository(client: ref.watch(apiClientProvider));
});

abstract class TransactionsRepository {
  Future<TransactionModel> createTransaction({
    required String businessId,
    required String walletId,
    required String serviceId,
    String? categoryId,
    required String type,
    required double amount,
    DateTime? transactionDate,
    String? description,
  });

  Future<List<TransactionModel>> getTransactions({
    String? businessId,
    String? walletId,
    String? serviceId,
    String? categoryId,
    String? type,
    int? limit,
    int? offset,
  });
}

class ApiTransactionsRepository implements TransactionsRepository {
  ApiTransactionsRepository({ApiClient? client})
    : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<TransactionModel> createTransaction({
    required String businessId,
    required String walletId,
    required String serviceId,
    String? categoryId,
    required String type,
    required double amount,
    DateTime? transactionDate,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'business_id': businessId,
      'wallet_id': walletId,
      'service_id': serviceId,
      if (categoryId != null && categoryId.isNotEmpty)
        'category_id': categoryId,
      'type': type,
      'amount': amount,
      if (transactionDate != null)
        'transaction_date': transactionDate.toIso8601String(),
      if (description != null && description.isNotEmpty)
        'description': description,
    };

    final response = await _client.post('/transactions/', body: body);

    if (response is Map) {
      return TransactionModel.fromJson(Map<String, dynamic>.from(response));
    }
    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected create transaction response format',
    );
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    String? businessId,
    String? walletId,
    String? serviceId,
    String? categoryId,
    String? type,
    int? limit,
    int? offset,
  }) async {
    final query = <String, dynamic>{};
    if (businessId != null && businessId.isNotEmpty) {
      query['business_id'] = businessId;
    }
    if (walletId != null && walletId.isNotEmpty) {
      query['wallet_id'] = walletId;
    }
    if (serviceId != null && serviceId.isNotEmpty) {
      query['service_id'] = serviceId;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query['category_id'] = categoryId;
    }
    if (type != null && type.isNotEmpty) {
      query['type'] = type;
    }
    if (limit != null) query['limit'] = limit;
    if (offset != null) query['offset'] = offset;

    final response = await _client.get(
      '/transactions/',
      queryParameters: query,
    );

    if (response is Map && response['data'] is List) {
      final list = response['data'] as List;
      return list
          .map(
            (item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } else if (response is List) {
      return response
          .map(
            (item) => TransactionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw const ApiException(
      statusCode: 500,
      message: 'Unexpected get transactions response format',
    );
  }
}
