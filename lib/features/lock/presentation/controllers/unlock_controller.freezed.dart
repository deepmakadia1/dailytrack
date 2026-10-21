// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unlock_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UnlockState {

/// Null while loading.
 LockStatus? get status; int get entered; UnlockError get error; int? get attemptsLeft;/// After a lockout has ended: what the next wrong PIN locks for.
 Duration? get nextLockout; Duration get lockoutRemaining; int get shakeCount; bool get busy;/// Biometric unlock is on and usable: the key shows and the prompt
/// opens on its own once.
 bool get biometricReady;/// Set on success; the screen leaves with it.
 bool get unlocked;
/// Create a copy of UnlockState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnlockStateCopyWith<UnlockState> get copyWith => _$UnlockStateCopyWithImpl<UnlockState>(this as UnlockState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UnlockState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnlockState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.entered, _this.entered) || other.entered == _this.entered)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.attemptsLeft, _this.attemptsLeft) || other.attemptsLeft == _this.attemptsLeft)&&(identical(other.nextLockout, _this.nextLockout) || other.nextLockout == _this.nextLockout)&&(identical(other.lockoutRemaining, _this.lockoutRemaining) || other.lockoutRemaining == _this.lockoutRemaining)&&(identical(other.shakeCount, _this.shakeCount) || other.shakeCount == _this.shakeCount)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.biometricReady, _this.biometricReady) || other.biometricReady == _this.biometricReady)&&(identical(other.unlocked, _this.unlocked) || other.unlocked == _this.unlocked));
}


@override
int get hashCode {
  final _this = this as UnlockState;
  return Object.hash(runtimeType,_this.status,_this.entered,_this.error,_this.attemptsLeft,_this.nextLockout,_this.lockoutRemaining,_this.shakeCount,_this.busy,_this.biometricReady,_this.unlocked);
}

@override
String toString() {
  final _this = this as UnlockState;
  return 'UnlockState(status: ${_this.status}, entered: ${_this.entered}, error: ${_this.error}, attemptsLeft: ${_this.attemptsLeft}, nextLockout: ${_this.nextLockout}, lockoutRemaining: ${_this.lockoutRemaining}, shakeCount: ${_this.shakeCount}, busy: ${_this.busy}, biometricReady: ${_this.biometricReady}, unlocked: ${_this.unlocked})';
}


}

/// @nodoc
abstract mixin class $UnlockStateCopyWith<$Res>  {
  factory $UnlockStateCopyWith(UnlockState value, $Res Function(UnlockState) _then) = _$UnlockStateCopyWithImpl;
@useResult
$Res call({
 LockStatus? status, int entered, UnlockError error, int? attemptsLeft, Duration? nextLockout, Duration lockoutRemaining, int shakeCount, bool busy, bool biometricReady, bool unlocked
});




}
/// @nodoc
class _$UnlockStateCopyWithImpl<$Res>
    implements $UnlockStateCopyWith<$Res> {
  _$UnlockStateCopyWithImpl(this._self, this._then);

  final UnlockState _self;
  final $Res Function(UnlockState) _then;

/// Create a copy of UnlockState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? entered = null,Object? error = null,Object? attemptsLeft = freezed,Object? nextLockout = freezed,Object? lockoutRemaining = null,Object? shakeCount = null,Object? busy = null,Object? biometricReady = null,Object? unlocked = null,}) {
  return _then(UnlockState(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LockStatus?,entered: null == entered ? _self.entered : entered // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as UnlockError,attemptsLeft: freezed == attemptsLeft ? _self.attemptsLeft : attemptsLeft // ignore: cast_nullable_to_non_nullable
as int?,nextLockout: freezed == nextLockout ? _self.nextLockout : nextLockout // ignore: cast_nullable_to_non_nullable
as Duration?,lockoutRemaining: null == lockoutRemaining ? _self.lockoutRemaining : lockoutRemaining // ignore: cast_nullable_to_non_nullable
as Duration,shakeCount: null == shakeCount ? _self.shakeCount : shakeCount // ignore: cast_nullable_to_non_nullable
as int,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,biometricReady: null == biometricReady ? _self.biometricReady : biometricReady // ignore: cast_nullable_to_non_nullable
as bool,unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UnlockState].
extension UnlockStatePatterns on UnlockState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnlockState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnlockState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnlockState value)  $default,){
final _that = this;
switch (_that) {
case _UnlockState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnlockState value)?  $default,){
final _that = this;
switch (_that) {
case _UnlockState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LockStatus? status,  int entered,  UnlockError error,  int? attemptsLeft,  Duration? nextLockout,  Duration lockoutRemaining,  int shakeCount,  bool busy,  bool biometricReady,  bool unlocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnlockState() when $default != null:
return $default(_that.status,_that.entered,_that.error,_that.attemptsLeft,_that.nextLockout,_that.lockoutRemaining,_that.shakeCount,_that.busy,_that.biometricReady,_that.unlocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LockStatus? status,  int entered,  UnlockError error,  int? attemptsLeft,  Duration? nextLockout,  Duration lockoutRemaining,  int shakeCount,  bool busy,  bool biometricReady,  bool unlocked)  $default,) {final _that = this;
switch (_that) {
case _UnlockState():
return $default(_that.status,_that.entered,_that.error,_that.attemptsLeft,_that.nextLockout,_that.lockoutRemaining,_that.shakeCount,_that.busy,_that.biometricReady,_that.unlocked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LockStatus? status,  int entered,  UnlockError error,  int? attemptsLeft,  Duration? nextLockout,  Duration lockoutRemaining,  int shakeCount,  bool busy,  bool biometricReady,  bool unlocked)?  $default,) {final _that = this;
switch (_that) {
case _UnlockState() when $default != null:
return $default(_that.status,_that.entered,_that.error,_that.attemptsLeft,_that.nextLockout,_that.lockoutRemaining,_that.shakeCount,_that.busy,_that.biometricReady,_that.unlocked);case _:
  return null;

}
}

}

/// @nodoc


class _UnlockState implements UnlockState {
  const _UnlockState({this.status, this.entered = 0, this.error = UnlockError.none, this.attemptsLeft, this.nextLockout, this.lockoutRemaining = Duration.zero, this.shakeCount = 0, this.busy = false, this.biometricReady = false, this.unlocked = false});
  

/// Null while loading.
@override final  LockStatus? status;
@override@JsonKey() final  int entered;
@override@JsonKey() final  UnlockError error;
@override final  int? attemptsLeft;
/// After a lockout has ended: what the next wrong PIN locks for.
@override final  Duration? nextLockout;
@override@JsonKey() final  Duration lockoutRemaining;
@override@JsonKey() final  int shakeCount;
@override@JsonKey() final  bool busy;
/// Biometric unlock is on and usable: the key shows and the prompt
/// opens on its own once.
@override@JsonKey() final  bool biometricReady;
/// Set on success; the screen leaves with it.
@override@JsonKey() final  bool unlocked;

/// Create a copy of UnlockState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnlockStateCopyWith<_UnlockState> get copyWith => __$UnlockStateCopyWithImpl<_UnlockState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnlockState&&(identical(other.status, status) || other.status == status)&&(identical(other.entered, entered) || other.entered == entered)&&(identical(other.error, error) || other.error == error)&&(identical(other.attemptsLeft, attemptsLeft) || other.attemptsLeft == attemptsLeft)&&(identical(other.nextLockout, nextLockout) || other.nextLockout == nextLockout)&&(identical(other.lockoutRemaining, lockoutRemaining) || other.lockoutRemaining == lockoutRemaining)&&(identical(other.shakeCount, shakeCount) || other.shakeCount == shakeCount)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.biometricReady, biometricReady) || other.biometricReady == biometricReady)&&(identical(other.unlocked, unlocked) || other.unlocked == unlocked));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,entered,error,attemptsLeft,nextLockout,lockoutRemaining,shakeCount,busy,biometricReady,unlocked);
}

@override
String toString() {
    return 'UnlockState(status: $status, entered: $entered, error: $error, attemptsLeft: $attemptsLeft, nextLockout: $nextLockout, lockoutRemaining: $lockoutRemaining, shakeCount: $shakeCount, busy: $busy, biometricReady: $biometricReady, unlocked: $unlocked)';
}


}

/// @nodoc
abstract mixin class _$UnlockStateCopyWith<$Res> implements $UnlockStateCopyWith<$Res> {
  factory _$UnlockStateCopyWith(_UnlockState value, $Res Function(_UnlockState) _then) = __$UnlockStateCopyWithImpl;
@override @useResult
$Res call({
 LockStatus? status, int entered, UnlockError error, int? attemptsLeft, Duration? nextLockout, Duration lockoutRemaining, int shakeCount, bool busy, bool biometricReady, bool unlocked
});




}
/// @nodoc
class __$UnlockStateCopyWithImpl<$Res>
    implements _$UnlockStateCopyWith<$Res> {
  __$UnlockStateCopyWithImpl(this._self, this._then);

  final _UnlockState _self;
  final $Res Function(_UnlockState) _then;

/// Create a copy of UnlockState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? entered = null,Object? error = null,Object? attemptsLeft = freezed,Object? nextLockout = freezed,Object? lockoutRemaining = null,Object? shakeCount = null,Object? busy = null,Object? biometricReady = null,Object? unlocked = null,}) {
  return _then(_UnlockState(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LockStatus?,entered: null == entered ? _self.entered : entered // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as UnlockError,attemptsLeft: freezed == attemptsLeft ? _self.attemptsLeft : attemptsLeft // ignore: cast_nullable_to_non_nullable
as int?,nextLockout: freezed == nextLockout ? _self.nextLockout : nextLockout // ignore: cast_nullable_to_non_nullable
as Duration?,lockoutRemaining: null == lockoutRemaining ? _self.lockoutRemaining : lockoutRemaining // ignore: cast_nullable_to_non_nullable
as Duration,shakeCount: null == shakeCount ? _self.shakeCount : shakeCount // ignore: cast_nullable_to_non_nullable
as int,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,biometricReady: null == biometricReady ? _self.biometricReady : biometricReady // ignore: cast_nullable_to_non_nullable
as bool,unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
