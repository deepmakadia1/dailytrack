// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restore_choice_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RestoreChoiceState {

/// This phone's counts, keyed like `BackupMeta.counts`.
 AsyncValue<Map<String, int>> get phoneCounts;/// This install's ID, for "From this phone"; null while loading.
 String? get thisDeviceId;/// The saved backup password didn't open it: the field shows.
 bool get passwordNeeded;/// The typed password didn't work.
 bool get passwordError;/// Restoring or keeping is running.
 bool get working;/// The last restore failed; this phone's data is unchanged.
 Object? get failure;
/// Create a copy of RestoreChoiceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestoreChoiceStateCopyWith<RestoreChoiceState> get copyWith => _$RestoreChoiceStateCopyWithImpl<RestoreChoiceState>(this as RestoreChoiceState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RestoreChoiceState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestoreChoiceState&&(identical(other.phoneCounts, _this.phoneCounts) || other.phoneCounts == _this.phoneCounts)&&(identical(other.thisDeviceId, _this.thisDeviceId) || other.thisDeviceId == _this.thisDeviceId)&&(identical(other.passwordNeeded, _this.passwordNeeded) || other.passwordNeeded == _this.passwordNeeded)&&(identical(other.passwordError, _this.passwordError) || other.passwordError == _this.passwordError)&&(identical(other.working, _this.working) || other.working == _this.working)&&const DeepCollectionEquality().equals(other.failure, _this.failure));
}


@override
int get hashCode {
  final _this = this as RestoreChoiceState;
  return Object.hash(runtimeType,_this.phoneCounts,_this.thisDeviceId,_this.passwordNeeded,_this.passwordError,_this.working,const DeepCollectionEquality().hash(_this.failure));
}

@override
String toString() {
  final _this = this as RestoreChoiceState;
  return 'RestoreChoiceState(phoneCounts: ${_this.phoneCounts}, thisDeviceId: ${_this.thisDeviceId}, passwordNeeded: ${_this.passwordNeeded}, passwordError: ${_this.passwordError}, working: ${_this.working}, failure: ${_this.failure})';
}


}

/// @nodoc
abstract mixin class $RestoreChoiceStateCopyWith<$Res>  {
  factory $RestoreChoiceStateCopyWith(RestoreChoiceState value, $Res Function(RestoreChoiceState) _then) = _$RestoreChoiceStateCopyWithImpl;
@useResult
$Res call({
 AsyncValue<Map<String, int>> phoneCounts, String? thisDeviceId, bool passwordNeeded, bool passwordError, bool working, Object? failure
});




}
/// @nodoc
class _$RestoreChoiceStateCopyWithImpl<$Res>
    implements $RestoreChoiceStateCopyWith<$Res> {
  _$RestoreChoiceStateCopyWithImpl(this._self, this._then);

  final RestoreChoiceState _self;
  final $Res Function(RestoreChoiceState) _then;

/// Create a copy of RestoreChoiceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneCounts = null,Object? thisDeviceId = freezed,Object? passwordNeeded = null,Object? passwordError = null,Object? working = null,Object? failure = freezed,}) {
  return _then(RestoreChoiceState(
phoneCounts: null == phoneCounts ? _self.phoneCounts : phoneCounts // ignore: cast_nullable_to_non_nullable
as AsyncValue<Map<String, int>>,thisDeviceId: freezed == thisDeviceId ? _self.thisDeviceId : thisDeviceId // ignore: cast_nullable_to_non_nullable
as String?,passwordNeeded: null == passwordNeeded ? _self.passwordNeeded : passwordNeeded // ignore: cast_nullable_to_non_nullable
as bool,passwordError: null == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as bool,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure ,
  ));
}

}


/// Adds pattern-matching-related methods to [RestoreChoiceState].
extension RestoreChoiceStatePatterns on RestoreChoiceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestoreChoiceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestoreChoiceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestoreChoiceState value)  $default,){
final _that = this;
switch (_that) {
case _RestoreChoiceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestoreChoiceState value)?  $default,){
final _that = this;
switch (_that) {
case _RestoreChoiceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AsyncValue<Map<String, int>> phoneCounts,  String? thisDeviceId,  bool passwordNeeded,  bool passwordError,  bool working,  Object? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestoreChoiceState() when $default != null:
return $default(_that.phoneCounts,_that.thisDeviceId,_that.passwordNeeded,_that.passwordError,_that.working,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AsyncValue<Map<String, int>> phoneCounts,  String? thisDeviceId,  bool passwordNeeded,  bool passwordError,  bool working,  Object? failure)  $default,) {final _that = this;
switch (_that) {
case _RestoreChoiceState():
return $default(_that.phoneCounts,_that.thisDeviceId,_that.passwordNeeded,_that.passwordError,_that.working,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AsyncValue<Map<String, int>> phoneCounts,  String? thisDeviceId,  bool passwordNeeded,  bool passwordError,  bool working,  Object? failure)?  $default,) {final _that = this;
switch (_that) {
case _RestoreChoiceState() when $default != null:
return $default(_that.phoneCounts,_that.thisDeviceId,_that.passwordNeeded,_that.passwordError,_that.working,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _RestoreChoiceState implements RestoreChoiceState {
  const _RestoreChoiceState({required this.phoneCounts, this.thisDeviceId, this.passwordNeeded = false, this.passwordError = false, this.working = false, this.failure});
  

/// This phone's counts, keyed like `BackupMeta.counts`.
@override final  AsyncValue<Map<String, int>> phoneCounts;
/// This install's ID, for "From this phone"; null while loading.
@override final  String? thisDeviceId;
/// The saved backup password didn't open it: the field shows.
@override@JsonKey() final  bool passwordNeeded;
/// The typed password didn't work.
@override@JsonKey() final  bool passwordError;
/// Restoring or keeping is running.
@override@JsonKey() final  bool working;
/// The last restore failed; this phone's data is unchanged.
@override final  Object? failure;

/// Create a copy of RestoreChoiceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestoreChoiceStateCopyWith<_RestoreChoiceState> get copyWith => __$RestoreChoiceStateCopyWithImpl<_RestoreChoiceState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestoreChoiceState&&(identical(other.phoneCounts, phoneCounts) || other.phoneCounts == phoneCounts)&&(identical(other.thisDeviceId, thisDeviceId) || other.thisDeviceId == thisDeviceId)&&(identical(other.passwordNeeded, passwordNeeded) || other.passwordNeeded == passwordNeeded)&&(identical(other.passwordError, passwordError) || other.passwordError == passwordError)&&(identical(other.working, working) || other.working == working)&&const DeepCollectionEquality().equals(other.failure, failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,phoneCounts,thisDeviceId,passwordNeeded,passwordError,working,const DeepCollectionEquality().hash(failure));
}

@override
String toString() {
    return 'RestoreChoiceState(phoneCounts: $phoneCounts, thisDeviceId: $thisDeviceId, passwordNeeded: $passwordNeeded, passwordError: $passwordError, working: $working, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$RestoreChoiceStateCopyWith<$Res> implements $RestoreChoiceStateCopyWith<$Res> {
  factory _$RestoreChoiceStateCopyWith(_RestoreChoiceState value, $Res Function(_RestoreChoiceState) _then) = __$RestoreChoiceStateCopyWithImpl;
@override @useResult
$Res call({
 AsyncValue<Map<String, int>> phoneCounts, String? thisDeviceId, bool passwordNeeded, bool passwordError, bool working, Object? failure
});




}
/// @nodoc
class __$RestoreChoiceStateCopyWithImpl<$Res>
    implements _$RestoreChoiceStateCopyWith<$Res> {
  __$RestoreChoiceStateCopyWithImpl(this._self, this._then);

  final _RestoreChoiceState _self;
  final $Res Function(_RestoreChoiceState) _then;

/// Create a copy of RestoreChoiceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneCounts = null,Object? thisDeviceId = freezed,Object? passwordNeeded = null,Object? passwordError = null,Object? working = null,Object? failure = freezed,}) {
  return _then(_RestoreChoiceState(
phoneCounts: null == phoneCounts ? _self.phoneCounts : phoneCounts // ignore: cast_nullable_to_non_nullable
as AsyncValue<Map<String, int>>,thisDeviceId: freezed == thisDeviceId ? _self.thisDeviceId : thisDeviceId // ignore: cast_nullable_to_non_nullable
as String?,passwordNeeded: null == passwordNeeded ? _self.passwordNeeded : passwordNeeded // ignore: cast_nullable_to_non_nullable
as bool,passwordError: null == passwordError ? _self.passwordError : passwordError // ignore: cast_nullable_to_non_nullable
as bool,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure ,
  ));
}


}

// dart format on
