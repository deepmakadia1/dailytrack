// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'security_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SecurityState {

 bool get lockOn; BiometricAvailability get biometric; bool get biometricEnabled; int get lockAfterSeconds; bool get hideInRecents;
/// Create a copy of SecurityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SecurityStateCopyWith<SecurityState> get copyWith => _$SecurityStateCopyWithImpl<SecurityState>(this as SecurityState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SecurityState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SecurityState&&(identical(other.lockOn, _this.lockOn) || other.lockOn == _this.lockOn)&&(identical(other.biometric, _this.biometric) || other.biometric == _this.biometric)&&(identical(other.biometricEnabled, _this.biometricEnabled) || other.biometricEnabled == _this.biometricEnabled)&&(identical(other.lockAfterSeconds, _this.lockAfterSeconds) || other.lockAfterSeconds == _this.lockAfterSeconds)&&(identical(other.hideInRecents, _this.hideInRecents) || other.hideInRecents == _this.hideInRecents));
}


@override
int get hashCode {
  final _this = this as SecurityState;
  return Object.hash(runtimeType,_this.lockOn,_this.biometric,_this.biometricEnabled,_this.lockAfterSeconds,_this.hideInRecents);
}

@override
String toString() {
  final _this = this as SecurityState;
  return 'SecurityState(lockOn: ${_this.lockOn}, biometric: ${_this.biometric}, biometricEnabled: ${_this.biometricEnabled}, lockAfterSeconds: ${_this.lockAfterSeconds}, hideInRecents: ${_this.hideInRecents})';
}


}

/// @nodoc
abstract mixin class $SecurityStateCopyWith<$Res>  {
  factory $SecurityStateCopyWith(SecurityState value, $Res Function(SecurityState) _then) = _$SecurityStateCopyWithImpl;
@useResult
$Res call({
 bool lockOn, BiometricAvailability biometric, bool biometricEnabled, int lockAfterSeconds, bool hideInRecents
});




}
/// @nodoc
class _$SecurityStateCopyWithImpl<$Res>
    implements $SecurityStateCopyWith<$Res> {
  _$SecurityStateCopyWithImpl(this._self, this._then);

  final SecurityState _self;
  final $Res Function(SecurityState) _then;

/// Create a copy of SecurityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lockOn = null,Object? biometric = null,Object? biometricEnabled = null,Object? lockAfterSeconds = null,Object? hideInRecents = null,}) {
  return _then(SecurityState(
lockOn: null == lockOn ? _self.lockOn : lockOn // ignore: cast_nullable_to_non_nullable
as bool,biometric: null == biometric ? _self.biometric : biometric // ignore: cast_nullable_to_non_nullable
as BiometricAvailability,biometricEnabled: null == biometricEnabled ? _self.biometricEnabled : biometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,lockAfterSeconds: null == lockAfterSeconds ? _self.lockAfterSeconds : lockAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,hideInRecents: null == hideInRecents ? _self.hideInRecents : hideInRecents // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SecurityState].
extension SecurityStatePatterns on SecurityState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SecurityState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SecurityState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SecurityState value)  $default,){
final _that = this;
switch (_that) {
case _SecurityState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SecurityState value)?  $default,){
final _that = this;
switch (_that) {
case _SecurityState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool lockOn,  BiometricAvailability biometric,  bool biometricEnabled,  int lockAfterSeconds,  bool hideInRecents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SecurityState() when $default != null:
return $default(_that.lockOn,_that.biometric,_that.biometricEnabled,_that.lockAfterSeconds,_that.hideInRecents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool lockOn,  BiometricAvailability biometric,  bool biometricEnabled,  int lockAfterSeconds,  bool hideInRecents)  $default,) {final _that = this;
switch (_that) {
case _SecurityState():
return $default(_that.lockOn,_that.biometric,_that.biometricEnabled,_that.lockAfterSeconds,_that.hideInRecents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool lockOn,  BiometricAvailability biometric,  bool biometricEnabled,  int lockAfterSeconds,  bool hideInRecents)?  $default,) {final _that = this;
switch (_that) {
case _SecurityState() when $default != null:
return $default(_that.lockOn,_that.biometric,_that.biometricEnabled,_that.lockAfterSeconds,_that.hideInRecents);case _:
  return null;

}
}

}

/// @nodoc


class _SecurityState implements SecurityState {
  const _SecurityState({required this.lockOn, required this.biometric, required this.biometricEnabled, required this.lockAfterSeconds, required this.hideInRecents});
  

@override final  bool lockOn;
@override final  BiometricAvailability biometric;
@override final  bool biometricEnabled;
@override final  int lockAfterSeconds;
@override final  bool hideInRecents;

/// Create a copy of SecurityState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SecurityStateCopyWith<_SecurityState> get copyWith => __$SecurityStateCopyWithImpl<_SecurityState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SecurityState&&(identical(other.lockOn, lockOn) || other.lockOn == lockOn)&&(identical(other.biometric, biometric) || other.biometric == biometric)&&(identical(other.biometricEnabled, biometricEnabled) || other.biometricEnabled == biometricEnabled)&&(identical(other.lockAfterSeconds, lockAfterSeconds) || other.lockAfterSeconds == lockAfterSeconds)&&(identical(other.hideInRecents, hideInRecents) || other.hideInRecents == hideInRecents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lockOn,biometric,biometricEnabled,lockAfterSeconds,hideInRecents);
}

@override
String toString() {
    return 'SecurityState(lockOn: $lockOn, biometric: $biometric, biometricEnabled: $biometricEnabled, lockAfterSeconds: $lockAfterSeconds, hideInRecents: $hideInRecents)';
}


}

/// @nodoc
abstract mixin class _$SecurityStateCopyWith<$Res> implements $SecurityStateCopyWith<$Res> {
  factory _$SecurityStateCopyWith(_SecurityState value, $Res Function(_SecurityState) _then) = __$SecurityStateCopyWithImpl;
@override @useResult
$Res call({
 bool lockOn, BiometricAvailability biometric, bool biometricEnabled, int lockAfterSeconds, bool hideInRecents
});




}
/// @nodoc
class __$SecurityStateCopyWithImpl<$Res>
    implements _$SecurityStateCopyWith<$Res> {
  __$SecurityStateCopyWithImpl(this._self, this._then);

  final _SecurityState _self;
  final $Res Function(_SecurityState) _then;

/// Create a copy of SecurityState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lockOn = null,Object? biometric = null,Object? biometricEnabled = null,Object? lockAfterSeconds = null,Object? hideInRecents = null,}) {
  return _then(_SecurityState(
lockOn: null == lockOn ? _self.lockOn : lockOn // ignore: cast_nullable_to_non_nullable
as bool,biometric: null == biometric ? _self.biometric : biometric // ignore: cast_nullable_to_non_nullable
as BiometricAvailability,biometricEnabled: null == biometricEnabled ? _self.biometricEnabled : biometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,lockAfterSeconds: null == lockAfterSeconds ? _self.lockAfterSeconds : lockAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,hideInRecents: null == hideInRecents ? _self.hideInRecents : hideInRecents // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
