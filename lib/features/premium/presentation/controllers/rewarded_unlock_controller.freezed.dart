// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rewarded_unlock_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RewardedUnlockState {

 RewardedPhase get phase;/// The last ad was closed before the reward (clarification Q5).
 bool get closedEarly;/// Set in [RewardedPhase.done]: whether the reward was earned (or Pro
/// was bought meanwhile).
 bool? get result;
/// Create a copy of RewardedUnlockState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RewardedUnlockStateCopyWith<RewardedUnlockState> get copyWith => _$RewardedUnlockStateCopyWithImpl<RewardedUnlockState>(this as RewardedUnlockState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RewardedUnlockState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RewardedUnlockState&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.closedEarly, _this.closedEarly) || other.closedEarly == _this.closedEarly)&&(identical(other.result, _this.result) || other.result == _this.result));
}


@override
int get hashCode {
  final _this = this as RewardedUnlockState;
  return Object.hash(runtimeType,_this.phase,_this.closedEarly,_this.result);
}

@override
String toString() {
  final _this = this as RewardedUnlockState;
  return 'RewardedUnlockState(phase: ${_this.phase}, closedEarly: ${_this.closedEarly}, result: ${_this.result})';
}


}

/// @nodoc
abstract mixin class $RewardedUnlockStateCopyWith<$Res>  {
  factory $RewardedUnlockStateCopyWith(RewardedUnlockState value, $Res Function(RewardedUnlockState) _then) = _$RewardedUnlockStateCopyWithImpl;
@useResult
$Res call({
 RewardedPhase phase, bool closedEarly, bool? result
});




}
/// @nodoc
class _$RewardedUnlockStateCopyWithImpl<$Res>
    implements $RewardedUnlockStateCopyWith<$Res> {
  _$RewardedUnlockStateCopyWithImpl(this._self, this._then);

  final RewardedUnlockState _self;
  final $Res Function(RewardedUnlockState) _then;

/// Create a copy of RewardedUnlockState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? closedEarly = null,Object? result = freezed,}) {
  return _then(RewardedUnlockState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as RewardedPhase,closedEarly: null == closedEarly ? _self.closedEarly : closedEarly // ignore: cast_nullable_to_non_nullable
as bool,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [RewardedUnlockState].
extension RewardedUnlockStatePatterns on RewardedUnlockState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RewardedUnlockState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RewardedUnlockState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RewardedUnlockState value)  $default,){
final _that = this;
switch (_that) {
case _RewardedUnlockState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RewardedUnlockState value)?  $default,){
final _that = this;
switch (_that) {
case _RewardedUnlockState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RewardedPhase phase,  bool closedEarly,  bool? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RewardedUnlockState() when $default != null:
return $default(_that.phase,_that.closedEarly,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RewardedPhase phase,  bool closedEarly,  bool? result)  $default,) {final _that = this;
switch (_that) {
case _RewardedUnlockState():
return $default(_that.phase,_that.closedEarly,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RewardedPhase phase,  bool closedEarly,  bool? result)?  $default,) {final _that = this;
switch (_that) {
case _RewardedUnlockState() when $default != null:
return $default(_that.phase,_that.closedEarly,_that.result);case _:
  return null;

}
}

}

/// @nodoc


class _RewardedUnlockState implements RewardedUnlockState {
  const _RewardedUnlockState({this.phase = RewardedPhase.loading, this.closedEarly = false, this.result});
  

@override@JsonKey() final  RewardedPhase phase;
/// The last ad was closed before the reward (clarification Q5).
@override@JsonKey() final  bool closedEarly;
/// Set in [RewardedPhase.done]: whether the reward was earned (or Pro
/// was bought meanwhile).
@override final  bool? result;

/// Create a copy of RewardedUnlockState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RewardedUnlockStateCopyWith<_RewardedUnlockState> get copyWith => __$RewardedUnlockStateCopyWithImpl<_RewardedUnlockState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RewardedUnlockState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.closedEarly, closedEarly) || other.closedEarly == closedEarly)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phase,closedEarly,result);
}

@override
String toString() {
    return 'RewardedUnlockState(phase: $phase, closedEarly: $closedEarly, result: $result)';
}


}

/// @nodoc
abstract mixin class _$RewardedUnlockStateCopyWith<$Res> implements $RewardedUnlockStateCopyWith<$Res> {
  factory _$RewardedUnlockStateCopyWith(_RewardedUnlockState value, $Res Function(_RewardedUnlockState) _then) = __$RewardedUnlockStateCopyWithImpl;
@override @useResult
$Res call({
 RewardedPhase phase, bool closedEarly, bool? result
});




}
/// @nodoc
class __$RewardedUnlockStateCopyWithImpl<$Res>
    implements _$RewardedUnlockStateCopyWith<$Res> {
  __$RewardedUnlockStateCopyWithImpl(this._self, this._then);

  final _RewardedUnlockState _self;
  final $Res Function(_RewardedUnlockState) _then;

/// Create a copy of RewardedUnlockState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? closedEarly = null,Object? result = freezed,}) {
  return _then(_RewardedUnlockState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as RewardedPhase,closedEarly: null == closedEarly ? _self.closedEarly : closedEarly // ignore: cast_nullable_to_non_nullable
as bool,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
