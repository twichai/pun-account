class TransactionModel {
  final String id;
  final String businessId;
  final String walletId;
  final String serviceId;
  final String? categoryId;
  final String type;
  final double amount;
  final DateTime transactionDate;
  final String? description;

  const TransactionModel({
    required this.id,
    required this.businessId,
    required this.walletId,
    required this.serviceId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.transactionDate,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      businessId: (json['business_id'] ?? json['businessId']) as String? ?? '',
      walletId: (json['wallet_id'] ?? json['walletId']) as String? ?? '',
      serviceId: (json['service_id'] ?? json['serviceId']) as String? ?? '',
      categoryId: (json['category_id'] ?? json['categoryId']) as String?,
      type: json['type'] as String? ?? 'expense',
      amount:
          (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      transactionDate: json['transaction_date'] != null
          ? DateTime.tryParse(json['transaction_date'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'wallet_id': walletId,
      'service_id': serviceId,
      if (categoryId != null) 'category_id': categoryId,
      'type': type,
      'amount': amount,
      'transaction_date': transactionDate.toIso8601String(),
      if (description != null) 'description': description,
    };
  }
}
