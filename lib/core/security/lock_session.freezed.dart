// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lock_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LockSessionState {

 bool get locked; LockMode get mode;/// Set when the app leaves the screen; cleared on resume.
 DateTime? get backgroundedAt;/// The next trip out of the app was started by the app itself.
 bool get externalActivity;/// A notification target that arrived while locked.
 String? get pendingLocation;/// The router location the resume overlay covers; the router keeps it
/// as it is while locked (redirect rule 4).
 String? get coveredLocation;
/// Create a copy of LockSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LockSessionStateCopyWith<LockSessionState> get copyWith => _$LockSessionStateCopyWithImpl<LockSessionState>(this as LockSessionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LockSessionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LockSessionState&&(identical(other.locked, _this.locked) || other.locked == _this.locked)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.backgroundedAt, _this.backgroundedAt) || other.backgroundedAt == _this.backgroundedAt)&&(identical(other.externalActivity, _this.externalActivity) || other.externalActivity == _this.externalActivity)&&(identical(other.pendingLocation, _this.pendingLocation) || other.pendingLocation == _this.pendingLocation)&&(identical(other.coveredLocation, _this.coveredLocation) || other.coveredLocation == _this.coveredLocation));
}


@override
int get hashCode {
  final _this = this as LockSessionState;
  return Object.hash(runtimeType,_this.locked,_this.mode,_this.backgroundedAt,_this.externalActivity,_this.pendingLocation,_this.coveredLocation);
}

@override
String toString() {
  final _this = this as LockSessionState;
  return 'LockSessionState(locked: ${_this.locked}, mode: ${_this.mode}, backgroundedAt: ${_this.backgroundedAt}, externalActivity: ${_this.externalActivity}, pendingLocation: ${_this.pendingLocation}, coveredLocation: ${_this.coveredLocation})';
}


}

/// @nodoc
abstract mixin class $LockSessionStateCopyWith<$Res>  {
  factory $LockSessionStateCopyWith(LockSessionState value, $Res Function(LockSessionState) _then) = _$LockSessionStateCopyWithImpl;
@useResult
$Res call({
 bool locked, LockMode mode, DateTime? backgroundedAt, bool externalActivity, String? pendingLocation, String? coveredLocation
});




}
/// @nodoc
class _$LockSessionStateCopyWithImpl<$Res>
    implements $LockSessionStateCopyWith<$Res> {
  _$LockSessionStateCopyWithImpl(this._self, this._then);

  final LockSessionState _self;
  final $Res Function(LockSessionState) _then;

/// Create a copy of LockSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locked = null,Object? mode = null,Object? backgroundedAt = freezed,Object? externalActivity = null,Object? pendingLocation = freezed,Object? coveredLocation = freezed,}) {
  return _then(LockSessionState(
locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as LockMode,backgroundedAt: freezed == backgroundedAt ? _self.backgroundedAt : backgroundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,externalActivity: null == externalActivity ? _self.externalActivity : externalActivity // ignore: cast_nullable_to_non_nullable
as bool,pendingLocation: freezed == pendingLocation ? _self.pendingLocation : pendingLocation // ignore: cast_nullable_to_non_nullable
as String?,coveredLocation: freezed == coveredLocation ? _self.coveredLocation : coveredLocation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LockSessionState].
extension LockSessionStatePatterns on LockSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LockSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LockSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LockSessionState value)  $default,){
final _that = this;
switch (_that) {
case _LockSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LockSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _LockSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool locked,  LockMode mode,  DateTime? backgroundedAt,  bool externalActivity,  String? pendingLocation,  String? coveredLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LockSessionState() when $default != null:
return $default(_that.locked,_that.mode,_that.backgroundedAt,_that.externalActivity,_that.pendingLocation,_that.coveredLocation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool locked,  LockMode mode,  DateTime? backgroundedAt,  bool externalActivity,  String? pendingLocation,  String? coveredLocation)  $default,) {final _that = this;
switch (_that) {
case _LockSessionState():
return $default(_that.locked,_that.mode,_that.backgroundedAt,_that.externalActivity,_that.pendingLocation,_that.coveredLocation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool locked,  LockMode mode,  DateTime? backgroundedAt,  bool externalActivity,  String? pendingLocation,  String? coveredLocation)?  $default,) {final _that = this;
switch (_that) {
case _LockSessionState() when $default != null:
return $default(_that.locked,_that.mode,_that.backgroundedAt,_that.externalActivity,_that.pendingLocation,_that.coveredLocation);case _:
  return null;

}
}

}

/// @nodoc


class _LockSessionState implements LockSessionState {
  const _LockSessionState({this.locked = false, this.mode = LockMode.route, this.backgroundedAt, this.externalActivity = false, this.pendingLocation, this.coveredLocation});
  

@override@JsonKey() final  bool locked;
@override@JsonKey() final  LockMode mode;
/// Set when the app leaves the screen; cleared on resume.
@override final  DateTime? backgroundedAt;
/// The next trip out of the app was started by the app itself.
@override@JsonKey() final  bool externalActivity;
/// A notification target that arrived while locked.
@override final  String? pendingLocation;
/// The router location the resume overlay covers; the router keeps it
/// as it is while locked (redirect rule 4).
@override final  String? coveredLocation;

/// Create a copy of LockSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LockSessionStateCopyWith<_LockSessionState> get copyWith => __$LockSessionStateCopyWithImpl<_LockSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LockSessionState&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.backgroundedAt, backgroundedAt) || other.backgroundedAt == backgroundedAt)&&(identical(other.externalActivity, externalActivity) || other.externalActivity == externalActivity)&&(identical(other.pendingLocation, pendingLocation) || other.pendingLocation == pendingLocation)&&(identical(other.coveredLocation, coveredLocation) || other.coveredLocation == coveredLocation));
}


@override
int get hashCode {
    return Object.hash(runtimeType,locked,mode,backgroundedAt,externalActivity,pendingLocation,coveredLocation);
}

@override
String toString() {
    return 'LockSessionState(locked: $locked, mode: $mode, backgroundedAt: $backgroundedAt, externalActivity: $externalActivity, pendingLocation: $pendingLocation, coveredLocation: $coveredLocation)';
}


}

/// @nodoc
abstract mixin class _$LockSessionStateCopyWith<$Res> implements $LockSessionStateCopyWith<$Res> {
  factory _$LockSessionStateCopyWith(_LockSessionState value, $Res Function(_LockSessionState) _then) = __$LockSessionStateCopyWithImpl;
@override @useResult
$Res call({
 bool locked, LockMode mode, DateTime? backgroundedAt, bool externalActivity, String? pendingLocation, String? coveredLocation
});




}
/// @nodoc
class __$LockSessionStateCopyWithImpl<$Res>
    implements _$LockSessionStateCopyWith<$Res> {
  __$LockSessionStateCopyWithImpl(this._self, this._then);

  final _LockSessionState _self;
  final $Res Function(_LockSessionState) _then;

/// Create a copy of LockSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locked = null,Object? mode = null,Object? backgroundedAt = freezed,Object? externalActivity = null,Object? pendingLocation = freezed,Object? coveredLocation = freezed,}) {
  return _then(_LockSessionState(
locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as LockMode,backgroundedAt: freezed == backgroundedAt ? _self.backgroundedAt : backgroundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,externalActivity: null == externalActivity ? _self.externalActivity : externalActivity // ignore: cast_nullable_to_non_nullable
as bool,pendingLocation: freezed == pendingLocation ? _self.pendingLocation : pendingLocation // ignore: cast_nullable_to_non_nullable
as String?,coveredLocation: freezed == coveredLocation ? _self.coveredLocation : coveredLocation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
