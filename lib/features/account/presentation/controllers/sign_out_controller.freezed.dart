// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_out_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignOutState {

 SignOutBackup get backup; SignOutChoice get choice;/// "Sign out anyway" after a failed backup.
 bool get signedOutAnyway;/// A newer backup from another phone: the sheet asks, then calls
/// [SignOutController.resolveConflict].
 ConflictCheck? get conflict;/// Signing out (and erasing) is running.
 bool get working;
/// Create a copy of SignOutState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignOutStateCopyWith<SignOutState> get copyWith => _$SignOutStateCopyWithImpl<SignOutState>(this as SignOutState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SignOutState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignOutState&&(identical(other.backup, _this.backup) || other.backup == _this.backup)&&(identical(other.choice, _this.choice) || other.choice == _this.choice)&&(identical(other.signedOutAnyway, _this.signedOutAnyway) || other.signedOutAnyway == _this.signedOutAnyway)&&(identical(other.conflict, _this.conflict) || other.conflict == _this.conflict)&&(identical(other.working, _this.working) || other.working == _this.working));
}


@override
int get hashCode {
  final _this = this as SignOutState;
  return Object.hash(runtimeType,_this.backup,_this.choice,_this.signedOutAnyway,_this.conflict,_this.working);
}

@override
String toString() {
  final _this = this as SignOutState;
  return 'SignOutState(backup: ${_this.backup}, choice: ${_this.choice}, signedOutAnyway: ${_this.signedOutAnyway}, conflict: ${_this.conflict}, working: ${_this.working})';
}


}

/// @nodoc
abstract mixin class $SignOutStateCopyWith<$Res>  {
  factory $SignOutStateCopyWith(SignOutState value, $Res Function(SignOutState) _then) = _$SignOutStateCopyWithImpl;
@useResult
$Res call({
 SignOutBackup backup, SignOutChoice choice, bool signedOutAnyway, ConflictCheck? conflict, bool working
});




}
/// @nodoc
class _$SignOutStateCopyWithImpl<$Res>
    implements $SignOutStateCopyWith<$Res> {
  _$SignOutStateCopyWithImpl(this._self, this._then);

  final SignOutState _self;
  final $Res Function(SignOutState) _then;

/// Create a copy of SignOutState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? backup = null,Object? choice = null,Object? signedOutAnyway = null,Object? conflict = freezed,Object? working = null,}) {
  return _then(SignOutState(
backup: null == backup ? _self.backup : backup // ignore: cast_nullable_to_non_nullable
as SignOutBackup,choice: null == choice ? _self.choice : choice // ignore: cast_nullable_to_non_nullable
as SignOutChoice,signedOutAnyway: null == signedOutAnyway ? _self.signedOutAnyway : signedOutAnyway // ignore: cast_nullable_to_non_nullable
as bool,conflict: freezed == conflict ? _self.conflict : conflict // ignore: cast_nullable_to_non_nullable
as ConflictCheck?,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SignOutState].
extension SignOutStatePatterns on SignOutState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignOutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignOutState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignOutState value)  $default,){
final _that = this;
switch (_that) {
case _SignOutState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignOutState value)?  $default,){
final _that = this;
switch (_that) {
case _SignOutState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SignOutBackup backup,  SignOutChoice choice,  bool signedOutAnyway,  ConflictCheck? conflict,  bool working)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignOutState() when $default != null:
return $default(_that.backup,_that.choice,_that.signedOutAnyway,_that.conflict,_that.working);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SignOutBackup backup,  SignOutChoice choice,  bool signedOutAnyway,  ConflictCheck? conflict,  bool working)  $default,) {final _that = this;
switch (_that) {
case _SignOutState():
return $default(_that.backup,_that.choice,_that.signedOutAnyway,_that.conflict,_that.working);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SignOutBackup backup,  SignOutChoice choice,  bool signedOutAnyway,  ConflictCheck? conflict,  bool working)?  $default,) {final _that = this;
switch (_that) {
case _SignOutState() when $default != null:
return $default(_that.backup,_that.choice,_that.signedOutAnyway,_that.conflict,_that.working);case _:
  return null;

}
}

}

/// @nodoc


class _SignOutState extends SignOutState {
  const _SignOutState({this.backup = SignOutBackup.checking, this.choice = SignOutChoice.keep, this.signedOutAnyway = false, this.conflict, this.working = false}): super._();
  

@override@JsonKey() final  SignOutBackup backup;
@override@JsonKey() final  SignOutChoice choice;
/// "Sign out anyway" after a failed backup.
@override@JsonKey() final  bool signedOutAnyway;
/// A newer backup from another phone: the sheet asks, then calls
/// [SignOutController.resolveConflict].
@override final  ConflictCheck? conflict;
/// Signing out (and erasing) is running.
@override@JsonKey() final  bool working;

/// Create a copy of SignOutState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignOutStateCopyWith<_SignOutState> get copyWith => __$SignOutStateCopyWithImpl<_SignOutState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignOutState&&(identical(other.backup, backup) || other.backup == backup)&&(identical(other.choice, choice) || other.choice == choice)&&(identical(other.signedOutAnyway, signedOutAnyway) || other.signedOutAnyway == signedOutAnyway)&&(identical(other.conflict, conflict) || other.conflict == conflict)&&(identical(other.working, working) || other.working == working));
}


@override
int get hashCode {
    return Object.hash(runtimeType,backup,choice,signedOutAnyway,conflict,working);
}

@override
String toString() {
    return 'SignOutState(backup: $backup, choice: $choice, signedOutAnyway: $signedOutAnyway, conflict: $conflict, working: $working)';
}


}

/// @nodoc
abstract mixin class _$SignOutStateCopyWith<$Res> implements $SignOutStateCopyWith<$Res> {
  factory _$SignOutStateCopyWith(_SignOutState value, $Res Function(_SignOutState) _then) = __$SignOutStateCopyWithImpl;
@override @useResult
$Res call({
 SignOutBackup backup, SignOutChoice choice, bool signedOutAnyway, ConflictCheck? conflict, bool working
});




}
/// @nodoc
class __$SignOutStateCopyWithImpl<$Res>
    implements _$SignOutStateCopyWith<$Res> {
  __$SignOutStateCopyWithImpl(this._self, this._then);

  final _SignOutState _self;
  final $Res Function(_SignOutState) _then;

/// Create a copy of SignOutState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? backup = null,Object? choice = null,Object? signedOutAnyway = null,Object? conflict = freezed,Object? working = null,}) {
  return _then(_SignOutState(
backup: null == backup ? _self.backup : backup // ignore: cast_nullable_to_non_nullable
as SignOutBackup,choice: null == choice ? _self.choice : choice // ignore: cast_nullable_to_non_nullable
as SignOutChoice,signedOutAnyway: null == signedOutAnyway ? _self.signedOutAnyway : signedOutAnyway // ignore: cast_nullable_to_non_nullable
as bool,conflict: freezed == conflict ? _self.conflict : conflict // ignore: cast_nullable_to_non_nullable
as ConflictCheck?,working: null == working ? _self.working : working // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
