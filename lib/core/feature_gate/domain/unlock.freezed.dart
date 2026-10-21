// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unlock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Unlock {

 String get id; FeatureKey get featureKey; UnlockSource get source;/// UTC.
 DateTime get createdAt;/// UTC. Null = permanent.
 DateTime? get expiresAt;
/// Create a copy of Unlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnlockCopyWith<Unlock> get copyWith => _$UnlockCopyWithImpl<Unlock>(this as Unlock, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Unlock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unlock&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.featureKey, _this.featureKey) || other.featureKey == _this.featureKey)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}


@override
int get hashCode {
  final _this = this as Unlock;
  return Object.hash(runtimeType,_this.id,_this.featureKey,_this.source,_this.createdAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as Unlock;
  return 'Unlock(id: ${_this.id}, featureKey: ${_this.featureKey}, source: ${_this.source}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $UnlockCopyWith<$Res>  {
  factory $UnlockCopyWith(Unlock value, $Res Function(Unlock) _then) = _$UnlockCopyWithImpl;
@useResult
$Res call({
 String id, FeatureKey featureKey, UnlockSource source, DateTime createdAt, DateTime? expiresAt
});




}
/// @nodoc
class _$UnlockCopyWithImpl<$Res>
    implements $UnlockCopyWith<$Res> {
  _$UnlockCopyWithImpl(this._self, this._then);

  final Unlock _self;
  final $Res Function(Unlock) _then;

/// Create a copy of Unlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? featureKey = null,Object? source = null,Object? createdAt = null,Object? expiresAt = freezed,}) {
  return _then(Unlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,featureKey: null == featureKey ? _self.featureKey : featureKey // ignore: cast_nullable_to_non_nullable
as FeatureKey,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as UnlockSource,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Unlock].
extension UnlockPatterns on Unlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Unlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Unlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Unlock value)  $default,){
final _that = this;
switch (_that) {
case _Unlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Unlock value)?  $default,){
final _that = this;
switch (_that) {
case _Unlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  FeatureKey featureKey,  UnlockSource source,  DateTime createdAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Unlock() when $default != null:
return $default(_that.id,_that.featureKey,_that.source,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  FeatureKey featureKey,  UnlockSource source,  DateTime createdAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Unlock():
return $default(_that.id,_that.featureKey,_that.source,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  FeatureKey featureKey,  UnlockSource source,  DateTime createdAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Unlock() when $default != null:
return $default(_that.id,_that.featureKey,_that.source,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _Unlock implements Unlock {
  const _Unlock({required this.id, required this.featureKey, required this.source, required this.createdAt, this.expiresAt});
  

@override final  String id;
@override final  FeatureKey featureKey;
@override final  UnlockSource source;
/// UTC.
@override final  DateTime createdAt;
/// UTC. Null = permanent.
@override final  DateTime? expiresAt;

/// Create a copy of Unlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnlockCopyWith<_Unlock> get copyWith => __$UnlockCopyWithImpl<_Unlock>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unlock&&(identical(other.id, id) || other.id == id)&&(identical(other.featureKey, featureKey) || other.featureKey == featureKey)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,featureKey,source,createdAt,expiresAt);
}

@override
String toString() {
    return 'Unlock(id: $id, featureKey: $featureKey, source: $source, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$UnlockCopyWith<$Res> implements $UnlockCopyWith<$Res> {
  factory _$UnlockCopyWith(_Unlock value, $Res Function(_Unlock) _then) = __$UnlockCopyWithImpl;
@override @useResult
$Res call({
 String id, FeatureKey featureKey, UnlockSource source, DateTime createdAt, DateTime? expiresAt
});




}
/// @nodoc
class __$UnlockCopyWithImpl<$Res>
    implements _$UnlockCopyWith<$Res> {
  __$UnlockCopyWithImpl(this._self, this._then);

  final _Unlock _self;
  final $Res Function(_Unlock) _then;

/// Create a copy of Unlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? featureKey = null,Object? source = null,Object? createdAt = null,Object? expiresAt = freezed,}) {
  return _then(_Unlock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,featureKey: null == featureKey ? _self.featureKey : featureKey // ignore: cast_nullable_to_non_nullable
as FeatureKey,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as UnlockSource,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
