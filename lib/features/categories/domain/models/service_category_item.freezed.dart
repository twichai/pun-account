// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_category_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServiceCategoryItem {

 String get id; String get name; String get accountNumber; IconData get icon; Color get color; String? get badge; String? get imageUrl; String? get serviceCategoryId; String? get categoryTrack; bool get isMyAccount; bool get isQuick;
/// Create a copy of ServiceCategoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceCategoryItemCopyWith<ServiceCategoryItem> get copyWith => _$ServiceCategoryItemCopyWithImpl<ServiceCategoryItem>(this as ServiceCategoryItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServiceCategoryItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceCategoryItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.accountNumber, _this.accountNumber) || other.accountNumber == _this.accountNumber)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.badge, _this.badge) || other.badge == _this.badge)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.serviceCategoryId, _this.serviceCategoryId) || other.serviceCategoryId == _this.serviceCategoryId)&&(identical(other.categoryTrack, _this.categoryTrack) || other.categoryTrack == _this.categoryTrack)&&(identical(other.isMyAccount, _this.isMyAccount) || other.isMyAccount == _this.isMyAccount)&&(identical(other.isQuick, _this.isQuick) || other.isQuick == _this.isQuick));
}


@override
int get hashCode {
  final _this = this as ServiceCategoryItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.accountNumber,_this.icon,_this.color,_this.badge,_this.imageUrl,_this.serviceCategoryId,_this.categoryTrack,_this.isMyAccount,_this.isQuick);
}

@override
String toString() {
  final _this = this as ServiceCategoryItem;
  return 'ServiceCategoryItem(id: ${_this.id}, name: ${_this.name}, accountNumber: ${_this.accountNumber}, icon: ${_this.icon}, color: ${_this.color}, badge: ${_this.badge}, imageUrl: ${_this.imageUrl}, serviceCategoryId: ${_this.serviceCategoryId}, categoryTrack: ${_this.categoryTrack}, isMyAccount: ${_this.isMyAccount}, isQuick: ${_this.isQuick})';
}


}

/// @nodoc
abstract mixin class $ServiceCategoryItemCopyWith<$Res>  {
  factory $ServiceCategoryItemCopyWith(ServiceCategoryItem value, $Res Function(ServiceCategoryItem) _then) = _$ServiceCategoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String accountNumber, IconData icon, Color color, String? badge, String? imageUrl, String? serviceCategoryId, String? categoryTrack, bool isMyAccount, bool isQuick
});




}
/// @nodoc
class _$ServiceCategoryItemCopyWithImpl<$Res>
    implements $ServiceCategoryItemCopyWith<$Res> {
  _$ServiceCategoryItemCopyWithImpl(this._self, this._then);

  final ServiceCategoryItem _self;
  final $Res Function(ServiceCategoryItem) _then;

/// Create a copy of ServiceCategoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? accountNumber = null,Object? icon = null,Object? color = null,Object? badge = freezed,Object? imageUrl = freezed,Object? serviceCategoryId = freezed,Object? categoryTrack = freezed,Object? isMyAccount = null,Object? isQuick = null,}) {
  return _then(ServiceCategoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,serviceCategoryId: freezed == serviceCategoryId ? _self.serviceCategoryId : serviceCategoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryTrack: freezed == categoryTrack ? _self.categoryTrack : categoryTrack // ignore: cast_nullable_to_non_nullable
as String?,isMyAccount: null == isMyAccount ? _self.isMyAccount : isMyAccount // ignore: cast_nullable_to_non_nullable
as bool,isQuick: null == isQuick ? _self.isQuick : isQuick // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceCategoryItem].
extension ServiceCategoryItemPatterns on ServiceCategoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceCategoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceCategoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceCategoryItem value)  $default,){
final _that = this;
switch (_that) {
case _ServiceCategoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceCategoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceCategoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String accountNumber,  IconData icon,  Color color,  String? badge,  String? imageUrl,  String? serviceCategoryId,  String? categoryTrack,  bool isMyAccount,  bool isQuick)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceCategoryItem() when $default != null:
return $default(_that.id,_that.name,_that.accountNumber,_that.icon,_that.color,_that.badge,_that.imageUrl,_that.serviceCategoryId,_that.categoryTrack,_that.isMyAccount,_that.isQuick);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String accountNumber,  IconData icon,  Color color,  String? badge,  String? imageUrl,  String? serviceCategoryId,  String? categoryTrack,  bool isMyAccount,  bool isQuick)  $default,) {final _that = this;
switch (_that) {
case _ServiceCategoryItem():
return $default(_that.id,_that.name,_that.accountNumber,_that.icon,_that.color,_that.badge,_that.imageUrl,_that.serviceCategoryId,_that.categoryTrack,_that.isMyAccount,_that.isQuick);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String accountNumber,  IconData icon,  Color color,  String? badge,  String? imageUrl,  String? serviceCategoryId,  String? categoryTrack,  bool isMyAccount,  bool isQuick)?  $default,) {final _that = this;
switch (_that) {
case _ServiceCategoryItem() when $default != null:
return $default(_that.id,_that.name,_that.accountNumber,_that.icon,_that.color,_that.badge,_that.imageUrl,_that.serviceCategoryId,_that.categoryTrack,_that.isMyAccount,_that.isQuick);case _:
  return null;

}
}

}

/// @nodoc


class _ServiceCategoryItem implements ServiceCategoryItem {
  const _ServiceCategoryItem({required this.id, required this.name, required this.accountNumber, required this.icon, required this.color, this.badge, this.imageUrl, this.serviceCategoryId, this.categoryTrack, this.isMyAccount = false, this.isQuick = false});
  

@override final  String id;
@override final  String name;
@override final  String accountNumber;
@override final  IconData icon;
@override final  Color color;
@override final  String? badge;
@override final  String? imageUrl;
@override final  String? serviceCategoryId;
@override final  String? categoryTrack;
@override@JsonKey() final  bool isMyAccount;
@override@JsonKey() final  bool isQuick;

/// Create a copy of ServiceCategoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceCategoryItemCopyWith<_ServiceCategoryItem> get copyWith => __$ServiceCategoryItemCopyWithImpl<_ServiceCategoryItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceCategoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.badge, badge) || other.badge == badge)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.serviceCategoryId, serviceCategoryId) || other.serviceCategoryId == serviceCategoryId)&&(identical(other.categoryTrack, categoryTrack) || other.categoryTrack == categoryTrack)&&(identical(other.isMyAccount, isMyAccount) || other.isMyAccount == isMyAccount)&&(identical(other.isQuick, isQuick) || other.isQuick == isQuick));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,accountNumber,icon,color,badge,imageUrl,serviceCategoryId,categoryTrack,isMyAccount,isQuick);
}

@override
String toString() {
    return 'ServiceCategoryItem(id: $id, name: $name, accountNumber: $accountNumber, icon: $icon, color: $color, badge: $badge, imageUrl: $imageUrl, serviceCategoryId: $serviceCategoryId, categoryTrack: $categoryTrack, isMyAccount: $isMyAccount, isQuick: $isQuick)';
}


}

/// @nodoc
abstract mixin class _$ServiceCategoryItemCopyWith<$Res> implements $ServiceCategoryItemCopyWith<$Res> {
  factory _$ServiceCategoryItemCopyWith(_ServiceCategoryItem value, $Res Function(_ServiceCategoryItem) _then) = __$ServiceCategoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String accountNumber, IconData icon, Color color, String? badge, String? imageUrl, String? serviceCategoryId, String? categoryTrack, bool isMyAccount, bool isQuick
});




}
/// @nodoc
class __$ServiceCategoryItemCopyWithImpl<$Res>
    implements _$ServiceCategoryItemCopyWith<$Res> {
  __$ServiceCategoryItemCopyWithImpl(this._self, this._then);

  final _ServiceCategoryItem _self;
  final $Res Function(_ServiceCategoryItem) _then;

/// Create a copy of ServiceCategoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? accountNumber = null,Object? icon = null,Object? color = null,Object? badge = freezed,Object? imageUrl = freezed,Object? serviceCategoryId = freezed,Object? categoryTrack = freezed,Object? isMyAccount = null,Object? isQuick = null,}) {
  return _then(_ServiceCategoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,serviceCategoryId: freezed == serviceCategoryId ? _self.serviceCategoryId : serviceCategoryId // ignore: cast_nullable_to_non_nullable
as String?,categoryTrack: freezed == categoryTrack ? _self.categoryTrack : categoryTrack // ignore: cast_nullable_to_non_nullable
as String?,isMyAccount: null == isMyAccount ? _self.isMyAccount : isMyAccount // ignore: cast_nullable_to_non_nullable
as bool,isQuick: null == isQuick ? _self.isQuick : isQuick // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
