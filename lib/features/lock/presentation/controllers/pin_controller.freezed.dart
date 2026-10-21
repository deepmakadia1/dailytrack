// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pin_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PinState {

 PinFlowStep get step; int get entered; PinError get error; int? get attemptsLeft;/// Shakes the dots each time it changes.
 int get shakeCount; Duration get lockoutRemaining; bool get busy;/// Offered after a first-time set when the phone supports it.
 bool get biometricOn;/// Set once the flow is finished; the screen pops with it.
 PinOutcome? get outcome;
/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PinStateCopyWith<PinState> get copyWith => _$PinStateCopyWithImpl<PinState>(this as PinState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PinState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PinState&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.entered, _this.entered) || other.entered == _this.entered)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.attemptsLeft, _this.attemptsLeft) || other.attemptsLeft == _this.attemptsLeft)&&(identical(other.shakeCount, _this.shakeCount) || other.shakeCount == _this.shakeCount)&&(identical(other.lockoutRemaining, _this.lockoutRemaining) || other.lockoutRemaining == _this.lockoutRemaining)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.biometricOn, _this.biometricOn) || other.biometricOn == _this.biometricOn)&&(identical(other.outcome, _this.outcome) || other.outcome == _this.outcome));
}


@override
int get hashCode {
  final _this = this as PinState;
  return Object.hash(runtimeType,_this.step,_this.entered,_this.error,_this.attemptsLeft,_this.shakeCount,_this.lockoutRemaining,_this.busy,_this.biometricOn,_this.outcome);
}

@override
String toString() {
  final _this = this as PinState;
  return 'PinState(step: ${_this.step}, entered: ${_this.entered}, error: ${_this.error}, attemptsLeft: ${_this.attemptsLeft}, shakeCount: ${_this.shakeCount}, lockoutRemaining: ${_this.lockoutRemaining}, busy: ${_this.busy}, biometricOn: ${_this.biometricOn}, outcome: ${_this.outcome})';
}


}

/// @nodoc
abstract mixin class $PinStateCopyWith<$Res>  {
  factory $PinStateCopyWith(PinState value, $Res Function(PinState) _then) = _$PinStateCopyWithImpl;
@useResult
$Res call({
 PinFlowStep step, int entered, PinError error, int? attemptsLeft, int shakeCount, Duration lockoutRemaining, bool busy, bool biometricOn, PinOutcome? outcome
});




}
/// @nodoc
class _$PinStateCopyWithImpl<$Res>
    implements $PinStateCopyWith<$Res> {
  _$PinStateCopyWithImpl(this._self, this._then);

  final PinState _self;
  final $Res Function(PinState) _then;

/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? entered = null,Object? error = null,Object? attemptsLeft = freezed,Object? shakeCount = null,Object? lockoutRemaining = null,Object? busy = null,Object? biometricOn = null,Object? outcome = freezed,}) {
  return _then(PinState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as PinFlowStep,entered: null == entered ? _self.entered : entered // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as PinError,attemptsLeft: freezed == attemptsLeft ? _self.attemptsLeft : attemptsLeft // ignore: cast_nullable_to_non_nullable
as int?,shakeCount: null == shakeCount ? _self.shakeCount : shakeCount // ignore: cast_nullable_to_non_nullable
as int,lockoutRemaining: null == lockoutRemaining ? _self.lockoutRemaining : lockoutRemaining // ignore: cast_nullable_to_non_nullable
as Duration,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,biometricOn: null == biometricOn ? _self.biometricOn : biometricOn // ignore: cast_nullable_to_non_nullable
as bool,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as PinOutcome?,
  ));
}

}


/// Adds pattern-matching-related methods to [PinState].
extension PinStatePatterns on PinState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PinState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PinState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PinState value)  $default,){
final _that = this;
switch (_that) {
case _PinState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PinState value)?  $default,){
final _that = this;
switch (_that) {
case _PinState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PinFlowStep step,  int entered,  PinError error,  int? attemptsLeft,  int shakeCount,  Duration lockoutRemaining,  bool busy,  bool biometricOn,  PinOutcome? outcome)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PinState() when $default != null:
return $default(_that.step,_that.entered,_that.error,_that.attemptsLeft,_that.shakeCount,_that.lockoutRemaining,_that.busy,_that.biometricOn,_that.outcome);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PinFlowStep step,  int entered,  PinError error,  int? attemptsLeft,  int shakeCount,  Duration lockoutRemaining,  bool busy,  bool biometricOn,  PinOutcome? outcome)  $default,) {final _that = this;
switch (_that) {
case _PinState():
return $default(_that.step,_that.entered,_that.error,_that.attemptsLeft,_that.shakeCount,_that.lockoutRemaining,_that.busy,_that.biometricOn,_that.outcome);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PinFlowStep step,  int entered,  PinError error,  int? attemptsLeft,  int shakeCount,  Duration lockoutRemaining,  bool busy,  bool biometricOn,  PinOutcome? outcome)?  $default,) {final _that = this;
switch (_that) {
case _PinState() when $default != null:
return $default(_that.step,_that.entered,_that.error,_that.attemptsLeft,_that.shakeCount,_that.lockoutRemaining,_that.busy,_that.biometricOn,_that.outcome);case _:
  return null;

}
}

}

/// @nodoc


class _PinState implements PinState {
  const _PinState({required this.step, this.entered = 0, this.error = PinError.none, this.attemptsLeft, this.shakeCount = 0, this.lockoutRemaining = Duration.zero, this.busy = false, this.biometricOn = false, this.outcome});
  

@override final  PinFlowStep step;
@override@JsonKey() final  int entered;
@override@JsonKey() final  PinError error;
@override final  int? attemptsLeft;
/// Shakes the dots each time it changes.
@override@JsonKey() final  int shakeCount;
@override@JsonKey() final  Duration lockoutRemaining;
@override@JsonKey() final  bool busy;
/// Offered after a first-time set when the phone supports it.
@override@JsonKey() final  bool biometricOn;
/// Set once the flow is finished; the screen pops with it.
@override final  PinOutcome? outcome;

/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PinStateCopyWith<_PinState> get copyWith => __$PinStateCopyWithImpl<_PinState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PinState&&(identical(other.step, step) || other.step == step)&&(identical(other.entered, entered) || other.entered == entered)&&(identical(other.error, error) || other.error == error)&&(identical(other.attemptsLeft, attemptsLeft) || other.attemptsLeft == attemptsLeft)&&(identical(other.shakeCount, shakeCount) || other.shakeCount == shakeCount)&&(identical(other.lockoutRemaining, lockoutRemaining) || other.lockoutRemaining == lockoutRemaining)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.biometricOn, biometricOn) || other.biometricOn == biometricOn)&&(identical(other.outcome, outcome) || other.outcome == outcome));
}


@override
int get hashCode {
    return Object.hash(runtimeType,step,entered,error,attemptsLeft,shakeCount,lockoutRemaining,busy,biometricOn,outcome);
}

@override
String toString() {
    return 'PinState(step: $step, entered: $entered, error: $error, attemptsLeft: $attemptsLeft, shakeCount: $shakeCount, lockoutRemaining: $lockoutRemaining, busy: $busy, biometricOn: $biometricOn, outcome: $outcome)';
}


}

/// @nodoc
abstract mixin class _$PinStateCopyWith<$Res> implements $PinStateCopyWith<$Res> {
  factory _$PinStateCopyWith(_PinState value, $Res Function(_PinState) _then) = __$PinStateCopyWithImpl;
@override @useResult
$Res call({
 PinFlowStep step, int entered, PinError error, int? attemptsLeft, int shakeCount, Duration lockoutRemaining, bool busy, bool biometricOn, PinOutcome? outcome
});




}
/// @nodoc
class __$PinStateCopyWithImpl<$Res>
    implements _$PinStateCopyWith<$Res> {
  __$PinStateCopyWithImpl(this._self, this._then);

  final _PinState _self;
  final $Res Function(_PinState) _then;

/// Create a copy of PinState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? entered = null,Object? error = null,Object? attemptsLeft = freezed,Object? shakeCount = null,Object? lockoutRemaining = null,Object? busy = null,Object? biometricOn = null,Object? outcome = freezed,}) {
  return _then(_PinState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as PinFlowStep,entered: null == entered ? _self.entered : entered // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as PinError,attemptsLeft: freezed == attemptsLeft ? _self.attemptsLeft : attemptsLeft // ignore: cast_nullable_to_non_nullable
as int?,shakeCount: null == shakeCount ? _self.shakeCount : shakeCount // ignore: cast_nullable_to_non_nullable
as int,lockoutRemaining: null == lockoutRemaining ? _self.lockoutRemaining : lockoutRemaining // ignore: cast_nullable_to_non_nullable
as Duration,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,biometricOn: null == biometricOn ? _self.biometricOn : biometricOn // ignore: cast_nullable_to_non_nullable
as bool,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as PinOutcome?,
  ));
}


}

// dart format on
