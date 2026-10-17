// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServiceTrack {

 String get id; String get key; String get name; String get description; IconData get icon; Color get color; List<ServiceCategoryItem> get services;
/// Create a copy of ServiceTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceTrackCopyWith<ServiceTrack> get copyWith => _$ServiceTrackCopyWithImpl<ServiceTrack>(this as ServiceTrack, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ServiceTrack;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceTrack&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&const DeepCollectionEquality().equals(other.services, _this.services));
}


@override
int get hashCode {
  final _this = this as ServiceTrack;
  return Object.hash(runtimeType,_this.id,_this.key,_this.name,_this.description,_this.icon,_this.color,const DeepCollectionEquality().hash(_this.services));
}

@override
String toString() {
  final _this = this as ServiceTrack;
  return 'ServiceTrack(id: ${_this.id}, key: ${_this.key}, name: ${_this.name}, description: ${_this.description}, icon: ${_this.icon}, color: ${_this.color}, services: ${_this.services})';
}


}

/// @nodoc
abstract mixin class $ServiceTrackCopyWith<$Res>  {
  factory $ServiceTrackCopyWith(ServiceTrack value, $Res Function(ServiceTrack) _then) = _$ServiceTrackCopyWithImpl;
@useResult
$Res call({
 String id, String key, String name, String description, IconData icon, Color color, List<ServiceCategoryItem> services
});




}
/// @nodoc
class _$ServiceTrackCopyWithImpl<$Res>
    implements $ServiceTrackCopyWith<$Res> {
  _$ServiceTrackCopyWithImpl(this._self, this._then);

  final ServiceTrack _self;
  final $Res Function(ServiceTrack) _then;

/// Create a copy of ServiceTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? name = null,Object? description = null,Object? icon = null,Object? color = null,Object? services = null,}) {
  return _then(ServiceTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceCategoryItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceTrack].
extension ServiceTrackPatterns on ServiceTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceTrack value)  $default,){
final _that = this;
switch (_that) {
case _ServiceTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceTrack value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String key,  String name,  String description,  IconData icon,  Color color,  List<ServiceCategoryItem> services)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceTrack() when $default != null:
return $default(_that.id,_that.key,_that.name,_that.description,_that.icon,_that.color,_that.services);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String key,  String name,  String description,  IconData icon,  Color color,  List<ServiceCategoryItem> services)  $default,) {final _that = this;
switch (_that) {
case _ServiceTrack():
return $default(_that.id,_that.key,_that.name,_that.description,_that.icon,_that.color,_that.services);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String key,  String name,  String description,  IconData icon,  Color color,  List<ServiceCategoryItem> services)?  $default,) {final _that = this;
switch (_that) {
case _ServiceTrack() when $default != null:
return $default(_that.id,_that.key,_that.name,_that.description,_that.icon,_that.color,_that.services);case _:
  return null;

}
}

}

/// @nodoc


class _ServiceTrack implements ServiceTrack {
  const _ServiceTrack({required this.id, required this.key, required this.name, required this.description, required this.icon, required this.color,  List<ServiceCategoryItem> services = const []}): _services = services;
  

@override final  String id;
@override final  String key;
@override final  String name;
@override final  String description;
@override final  IconData icon;
@override final  Color color;
 final  List<ServiceCategoryItem> _services;
@override@JsonKey() List<ServiceCategoryItem> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}


/// Create a copy of ServiceTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceTrackCopyWith<_ServiceTrack> get copyWith => __$ServiceTrackCopyWithImpl<_ServiceTrack>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.services, _services));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,key,name,description,icon,color,const DeepCollectionEquality().hash(_services));
}

@override
String toString() {
    return 'ServiceTrack(id: $id, key: $key, name: $name, description: $description, icon: $icon, color: $color, services: $services)';
}


}

/// @nodoc
abstract mixin class _$ServiceTrackCopyWith<$Res> implements $ServiceTrackCopyWith<$Res> {
  factory _$ServiceTrackCopyWith(_ServiceTrack value, $Res Function(_ServiceTrack) _then) = __$ServiceTrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String key, String name, String description, IconData icon, Color color, List<ServiceCategoryItem> services
});




}
/// @nodoc
class __$ServiceTrackCopyWithImpl<$Res>
    implements _$ServiceTrackCopyWith<$Res> {
  __$ServiceTrackCopyWithImpl(this._self, this._then);

  final _ServiceTrack _self;
  final $Res Function(_ServiceTrack) _then;

/// Create a copy of ServiceTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? name = null,Object? description = null,Object? icon = null,Object? color = null,Object? services = null,}) {
  return _then(_ServiceTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceCategoryItem>,
  ));
}


}

// dart format on
