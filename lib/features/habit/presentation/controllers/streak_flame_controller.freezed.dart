// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_flame_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StreakFlameData {

 int get current; StreakUnit get unit;
/// Create a copy of StreakFlameData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakFlameDataCopyWith<StreakFlameData> get copyWith => _$StreakFlameDataCopyWithImpl<StreakFlameData>(this as StreakFlameData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StreakFlameData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakFlameData&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}


@override
int get hashCode {
  final _this = this as StreakFlameData;
  return Object.hash(runtimeType,_this.current,_this.unit);
}

@override
String toString() {
  final _this = this as StreakFlameData;
  return 'StreakFlameData(current: ${_this.current}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $StreakFlameDataCopyWith<$Res>  {
  factory $StreakFlameDataCopyWith(StreakFlameData value, $Res Function(StreakFlameData) _then) = _$StreakFlameDataCopyWithImpl;
@useResult
$Res call({
 int current, StreakUnit unit
});




}
/// @nodoc
class _$StreakFlameDataCopyWithImpl<$Res>
    implements $StreakFlameDataCopyWith<$Res> {
  _$StreakFlameDataCopyWithImpl(this._self, this._then);

  final StreakFlameData _self;
  final $Res Function(StreakFlameData) _then;

/// Create a copy of StreakFlameData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? unit = null,}) {
  return _then(StreakFlameData(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as StreakUnit,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakFlameData].
extension StreakFlameDataPatterns on StreakFlameData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakFlameData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakFlameData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakFlameData value)  $default,){
final _that = this;
switch (_that) {
case _StreakFlameData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakFlameData value)?  $default,){
final _that = this;
switch (_that) {
case _StreakFlameData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  StreakUnit unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakFlameData() when $default != null:
return $default(_that.current,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  StreakUnit unit)  $default,) {final _that = this;
switch (_that) {
case _StreakFlameData():
return $default(_that.current,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  StreakUnit unit)?  $default,) {final _that = this;
switch (_that) {
case _StreakFlameData() when $default != null:
return $default(_that.current,_that.unit);case _:
  return null;

}
}

}

/// @nodoc


class _StreakFlameData implements StreakFlameData {
  const _StreakFlameData({required this.current, required this.unit});
  

@override final  int current;
@override final  StreakUnit unit;

/// Create a copy of StreakFlameData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakFlameDataCopyWith<_StreakFlameData> get copyWith => __$StreakFlameDataCopyWithImpl<_StreakFlameData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakFlameData&&(identical(other.current, current) || other.current == current)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,current,unit);
}

@override
String toString() {
    return 'StreakFlameData(current: $current, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$StreakFlameDataCopyWith<$Res> implements $StreakFlameDataCopyWith<$Res> {
  factory _$StreakFlameDataCopyWith(_StreakFlameData value, $Res Function(_StreakFlameData) _then) = __$StreakFlameDataCopyWithImpl;
@override @useResult
$Res call({
 int current, StreakUnit unit
});




}
/// @nodoc
class __$StreakFlameDataCopyWithImpl<$Res>
    implements _$StreakFlameDataCopyWith<$Res> {
  __$StreakFlameDataCopyWithImpl(this._self, this._then);

  final _StreakFlameData _self;
  final $Res Function(_StreakFlameData) _then;

/// Create a copy of StreakFlameData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? unit = null,}) {
  return _then(_StreakFlameData(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as StreakUnit,
  ));
}


}

// dart format on
