// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {

 LoginBusy get busy; LoginError? get error;/// The restore error view, with "Try again" and "Continue without
/// restoring".
 bool get restoreFailed;/// The account's newest backup, for "Try again" on the restore error.
 DriveBackupEntry? get pendingBackup;
/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStateCopyWith<LoginState> get copyWith => _$LoginStateCopyWithImpl<LoginState>(this as LoginState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LoginState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.restoreFailed, _this.restoreFailed) || other.restoreFailed == _this.restoreFailed)&&(identical(other.pendingBackup, _this.pendingBackup) || other.pendingBackup == _this.pendingBackup));
}


@override
int get hashCode {
  final _this = this as LoginState;
  return Object.hash(runtimeType,_this.busy,_this.error,_this.restoreFailed,_this.pendingBackup);
}

@override
String toString() {
  final _this = this as LoginState;
  return 'LoginState(busy: ${_this.busy}, error: ${_this.error}, restoreFailed: ${_this.restoreFailed}, pendingBackup: ${_this.pendingBackup})';
}


}

/// @nodoc
abstract mixin class $LoginStateCopyWith<$Res>  {
  factory $LoginStateCopyWith(LoginState value, $Res Function(LoginState) _then) = _$LoginStateCopyWithImpl;
@useResult
$Res call({
 LoginBusy busy, LoginError? error, bool restoreFailed, DriveBackupEntry? pendingBackup
});




}
/// @nodoc
class _$LoginStateCopyWithImpl<$Res>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._self, this._then);

  final LoginState _self;
  final $Res Function(LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? busy = null,Object? error = freezed,Object? restoreFailed = null,Object? pendingBackup = freezed,}) {
  return _then(LoginState(
busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as LoginBusy,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as LoginError?,restoreFailed: null == restoreFailed ? _self.restoreFailed : restoreFailed // ignore: cast_nullable_to_non_nullable
as bool,pendingBackup: freezed == pendingBackup ? _self.pendingBackup : pendingBackup // ignore: cast_nullable_to_non_nullable
as DriveBackupEntry?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginState value)  $default,){
final _that = this;
switch (_that) {
case _LoginState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LoginBusy busy,  LoginError? error,  bool restoreFailed,  DriveBackupEntry? pendingBackup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.busy,_that.error,_that.restoreFailed,_that.pendingBackup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LoginBusy busy,  LoginError? error,  bool restoreFailed,  DriveBackupEntry? pendingBackup)  $default,) {final _that = this;
switch (_that) {
case _LoginState():
return $default(_that.busy,_that.error,_that.restoreFailed,_that.pendingBackup);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LoginBusy busy,  LoginError? error,  bool restoreFailed,  DriveBackupEntry? pendingBackup)?  $default,) {final _that = this;
switch (_that) {
case _LoginState() when $default != null:
return $default(_that.busy,_that.error,_that.restoreFailed,_that.pendingBackup);case _:
  return null;

}
}

}

/// @nodoc


class _LoginState extends LoginState {
  const _LoginState({this.busy = LoginBusy.none, this.error, this.restoreFailed = false, this.pendingBackup}): super._();
  

@override@JsonKey() final  LoginBusy busy;
@override final  LoginError? error;
/// The restore error view, with "Try again" and "Continue without
/// restoring".
@override@JsonKey() final  bool restoreFailed;
/// The account's newest backup, for "Try again" on the restore error.
@override final  DriveBackupEntry? pendingBackup;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginStateCopyWith<_LoginState> get copyWith => __$LoginStateCopyWithImpl<_LoginState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginState&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.error, error) || other.error == error)&&(identical(other.restoreFailed, restoreFailed) || other.restoreFailed == restoreFailed)&&(identical(other.pendingBackup, pendingBackup) || other.pendingBackup == pendingBackup));
}


@override
int get hashCode {
    return Object.hash(runtimeType,busy,error,restoreFailed,pendingBackup);
}

@override
String toString() {
    return 'LoginState(busy: $busy, error: $error, restoreFailed: $restoreFailed, pendingBackup: $pendingBackup)';
}


}

/// @nodoc
abstract mixin class _$LoginStateCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory _$LoginStateCopyWith(_LoginState value, $Res Function(_LoginState) _then) = __$LoginStateCopyWithImpl;
@override @useResult
$Res call({
 LoginBusy busy, LoginError? error, bool restoreFailed, DriveBackupEntry? pendingBackup
});




}
/// @nodoc
class __$LoginStateCopyWithImpl<$Res>
    implements _$LoginStateCopyWith<$Res> {
  __$LoginStateCopyWithImpl(this._self, this._then);

  final _LoginState _self;
  final $Res Function(_LoginState) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? busy = null,Object? error = freezed,Object? restoreFailed = null,Object? pendingBackup = freezed,}) {
  return _then(_LoginState(
busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as LoginBusy,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as LoginError?,restoreFailed: null == restoreFailed ? _self.restoreFailed : restoreFailed // ignore: cast_nullable_to_non_nullable
as bool,pendingBackup: freezed == pendingBackup ? _self.pendingBackup : pendingBackup // ignore: cast_nullable_to_non_nullable
as DriveBackupEntry?,
  ));
}


}

// dart format on
