import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
abstract class Wallet with _$Wallet {
  const factory Wallet({
    required String id,
    required String type,
    required double balance,
    @Default('THB') String currency,
    String? cardHolder,
    String? last4,
    String? cardBrand,
    @Default('emerald') String auroraAccent,
    @Default(true) bool isActive,
    String? businessId,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(json);
    if (json['ui'] is Map<String, dynamic>) {
      final ui = json['ui'] as Map<String, dynamic>;
      normalized['auroraAccent'] ??= ui['aurora_accent'] ?? ui['auroraAccent'];
      normalized['cardHolder'] ??= ui['card_holder'] ?? ui['cardHolder'];
      normalized['last4'] ??= ui['last4'];
      normalized['cardBrand'] ??= ui['card_brand'] ?? ui['cardBrand'];
    }
    normalized['businessId'] ??= json['business_id'];
    normalized['isActive'] ??= json['is_active'];
    return _$WalletFromJson(normalized);
  }
}
