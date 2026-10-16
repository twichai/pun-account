// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Wallet {

 String get id; String get type; double get balance; String get currency; String? get cardHolder; String? get last4; String? get cardBrand; String get auroraAccent; bool get isActive; String? get businessId;
/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletCopyWith<Wallet> get copyWith => _$WalletCopyWithImpl<Wallet>(this as Wallet, _$identity);

  /// Serializes this Wallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Wallet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Wallet&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.cardHolder, _this.cardHolder) || other.cardHolder == _this.cardHolder)&&(identical(other.last4, _this.last4) || other.last4 == _this.last4)&&(identical(other.cardBrand, _this.cardBrand) || other.cardBrand == _this.cardBrand)&&(identical(other.auroraAccent, _this.auroraAccent) || other.auroraAccent == _this.auroraAccent)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.businessId, _this.businessId) || other.businessId == _this.businessId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Wallet;
  return Object.hash(runtimeType,_this.id,_this.type,_this.balance,_this.currency,_this.cardHolder,_this.last4,_this.cardBrand,_this.auroraAccent,_this.isActive,_this.businessId);
}

@override
String toString() {
  final _this = this as Wallet;
  return 'Wallet(id: ${_this.id}, type: ${_this.type}, balance: ${_this.balance}, currency: ${_this.currency}, cardHolder: ${_this.cardHolder}, last4: ${_this.last4}, cardBrand: ${_this.cardBrand}, auroraAccent: ${_this.auroraAccent}, isActive: ${_this.isActive}, businessId: ${_this.businessId})';
}


}

/// @nodoc
abstract mixin class $WalletCopyWith<$Res>  {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) _then) = _$WalletCopyWithImpl;
@useResult
$Res call({
 String id, String type, double balance, String currency, String? cardHolder, String? last4, String? cardBrand, String auroraAccent, bool isActive, String? businessId
});




}
/// @nodoc
class _$WalletCopyWithImpl<$Res>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._self, this._then);

  final Wallet _self;
  final $Res Function(Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? balance = null,Object? currency = null,Object? cardHolder = freezed,Object? last4 = freezed,Object? cardBrand = freezed,Object? auroraAccent = null,Object? isActive = null,Object? businessId = freezed,}) {
  return _then(Wallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,cardHolder: freezed == cardHolder ? _self.cardHolder : cardHolder // ignore: cast_nullable_to_non_nullable
as String?,last4: freezed == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String?,cardBrand: freezed == cardBrand ? _self.cardBrand : cardBrand // ignore: cast_nullable_to_non_nullable
as String?,auroraAccent: null == auroraAccent ? _self.auroraAccent : auroraAccent // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,businessId: freezed == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Wallet].
extension WalletPatterns on Wallet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Wallet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Wallet value)  $default,){
final _that = this;
switch (_that) {
case _Wallet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Wallet value)?  $default,){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  double balance,  String currency,  String? cardHolder,  String? last4,  String? cardBrand,  String auroraAccent,  bool isActive,  String? businessId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.id,_that.type,_that.balance,_that.currency,_that.cardHolder,_that.last4,_that.cardBrand,_that.auroraAccent,_that.isActive,_that.businessId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  double balance,  String currency,  String? cardHolder,  String? last4,  String? cardBrand,  String auroraAccent,  bool isActive,  String? businessId)  $default,) {final _that = this;
switch (_that) {
case _Wallet():
return $default(_that.id,_that.type,_that.balance,_that.currency,_that.cardHolder,_that.last4,_that.cardBrand,_that.auroraAccent,_that.isActive,_that.businessId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  double balance,  String currency,  String? cardHolder,  String? last4,  String? cardBrand,  String auroraAccent,  bool isActive,  String? businessId)?  $default,) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.id,_that.type,_that.balance,_that.currency,_that.cardHolder,_that.last4,_that.cardBrand,_that.auroraAccent,_that.isActive,_that.businessId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Wallet implements Wallet {
  const _Wallet({required this.id, required this.type, required this.balance, this.currency = 'THB', this.cardHolder, this.last4, this.cardBrand, this.auroraAccent = 'emerald', this.isActive = true, this.businessId});
  factory _Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

@override final  String id;
@override final  String type;
@override final  double balance;
@override@JsonKey() final  String currency;
@override final  String? cardHolder;
@override final  String? last4;
@override final  String? cardBrand;
@override@JsonKey() final  String auroraAccent;
@override@JsonKey() final  bool isActive;
@override final  String? businessId;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletCopyWith<_Wallet> get copyWith => __$WalletCopyWithImpl<_Wallet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Wallet&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.cardHolder, cardHolder) || other.cardHolder == cardHolder)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.cardBrand, cardBrand) || other.cardBrand == cardBrand)&&(identical(other.auroraAccent, auroraAccent) || other.auroraAccent == auroraAccent)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.businessId, businessId) || other.businessId == businessId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,balance,currency,cardHolder,last4,cardBrand,auroraAccent,isActive,businessId);
}

@override
String toString() {
    return 'Wallet(id: $id, type: $type, balance: $balance, currency: $currency, cardHolder: $cardHolder, last4: $last4, cardBrand: $cardBrand, auroraAccent: $auroraAccent, isActive: $isActive, businessId: $businessId)';
}


}

/// @nodoc
abstract mixin class _$WalletCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$WalletCopyWith(_Wallet value, $Res Function(_Wallet) _then) = __$WalletCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, double balance, String currency, String? cardHolder, String? last4, String? cardBrand, String auroraAccent, bool isActive, String? businessId
});




}
/// @nodoc
class __$WalletCopyWithImpl<$Res>
    implements _$WalletCopyWith<$Res> {
  __$WalletCopyWithImpl(this._self, this._then);

  final _Wallet _self;
  final $Res Function(_Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? balance = null,Object? currency = null,Object? cardHolder = freezed,Object? last4 = freezed,Object? cardBrand = freezed,Object? auroraAccent = null,Object? isActive = null,Object? businessId = freezed,}) {
  return _then(_Wallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,cardHolder: freezed == cardHolder ? _self.cardHolder : cardHolder // ignore: cast_nullable_to_non_nullable
as String?,last4: freezed == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String?,cardBrand: freezed == cardBrand ? _self.cardBrand : cardBrand // ignore: cast_nullable_to_non_nullable
as String?,auroraAccent: null == auroraAccent ? _self.auroraAccent : auroraAccent // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,businessId: freezed == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
