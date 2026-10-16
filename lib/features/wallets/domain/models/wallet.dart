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

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}
