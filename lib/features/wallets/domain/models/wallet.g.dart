// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Wallet _$WalletFromJson(Map<String, dynamic> json) => _Wallet(
  id: json['id'] as String,
  type: json['type'] as String,
  balance: (json['balance'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'THB',
  cardHolder: json['cardHolder'] as String?,
  last4: json['last4'] as String?,
  cardBrand: json['cardBrand'] as String?,
  auroraAccent: json['auroraAccent'] as String? ?? 'emerald',
  isActive: json['isActive'] as bool? ?? true,
  businessId: json['businessId'] as String?,
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'balance': instance.balance,
  'currency': instance.currency,
  'cardHolder': instance.cardHolder,
  'last4': instance.last4,
  'cardBrand': instance.cardBrand,
  'auroraAccent': instance.auroraAccent,
  'isActive': instance.isActive,
  'businessId': instance.businessId,
};
