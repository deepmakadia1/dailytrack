// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountScreenState {

/// Signed out, or signed in without a working session this run, shows
/// the signed-out content (research R2).
 AccountState get account;/// Google Drive is configured in this build.
 bool get driveAvailable; AutoBackupFrequency get autoFrequency; bool get wifiOnly;/// Auto backup is paused by a newer backup from another phone.
 bool get paused; int get autoBackupFailures;/// UTC epoch milliseconds of the last backup, or null.
 int? get lastBackupAt;/// The account's Drive backups, newest first; null while signed out.
 AsyncValue<List<DriveBackupEntry>>? get drive; AccountBusy get busy;
/// Create a copy of AccountScreenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountScreenStateCopyWith<AccountScreenState> get copyWith => _$AccountScreenStateCopyWithImpl<AccountScreenState>(this as AccountScreenState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountScreenState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountScreenState&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.driveAvailable, _this.driveAvailable) || other.driveAvailable == _this.driveAvailable)&&(identical(other.autoFrequency, _this.autoFrequency) || other.autoFrequency == _this.autoFrequency)&&(identical(other.wifiOnly, _this.wifiOnly) || other.wifiOnly == _this.wifiOnly)&&(identical(other.paused, _this.paused) || other.paused == _this.paused)&&(identical(other.autoBackupFailures, _this.autoBackupFailures) || other.autoBackupFailures == _this.autoBackupFailures)&&(identical(other.lastBackupAt, _this.lastBackupAt) || other.lastBackupAt == _this.lastBackupAt)&&(identical(other.drive, _this.drive) || other.drive == _this.drive)&&(identical(other.busy, _this.busy) || other.busy == _this.busy));
}


@override
int get hashCode {
  final _this = this as AccountScreenState;
  return Object.hash(runtimeType,_this.account,_this.driveAvailable,_this.autoFrequency,_this.wifiOnly,_this.paused,_this.autoBackupFailures,_this.lastBackupAt,_this.drive,_this.busy);
}

@override
String toString() {
  final _this = this as AccountScreenState;
  return 'AccountScreenState(account: ${_this.account}, driveAvailable: ${_this.driveAvailable}, autoFrequency: ${_this.autoFrequency}, wifiOnly: ${_this.wifiOnly}, paused: ${_this.paused}, autoBackupFailures: ${_this.autoBackupFailures}, lastBackupAt: ${_this.lastBackupAt}, drive: ${_this.drive}, busy: ${_this.busy})';
}


}

/// @nodoc
abstract mixin class $AccountScreenStateCopyWith<$Res>  {
  factory $AccountScreenStateCopyWith(AccountScreenState value, $Res Function(AccountScreenState) _then) = _$AccountScreenStateCopyWithImpl;
@useResult
$Res call({
 AccountState account, bool driveAvailable, AutoBackupFrequency autoFrequency, bool wifiOnly, bool paused, int autoBackupFailures, int? lastBackupAt, AsyncValue<List<DriveBackupEntry>>? drive, AccountBusy busy
});




}
/// @nodoc
class _$AccountScreenStateCopyWithImpl<$Res>
    implements $AccountScreenStateCopyWith<$Res> {
  _$AccountScreenStateCopyWithImpl(this._self, this._then);

  final AccountScreenState _self;
  final $Res Function(AccountScreenState) _then;

/// Create a copy of AccountScreenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = null,Object? driveAvailable = null,Object? autoFrequency = null,Object? wifiOnly = null,Object? paused = null,Object? autoBackupFailures = null,Object? lastBackupAt = freezed,Object? drive = freezed,Object? busy = null,}) {
  return _then(AccountScreenState(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as AccountState,driveAvailable: null == driveAvailable ? _self.driveAvailable : driveAvailable // ignore: cast_nullable_to_non_nullable
as bool,autoFrequency: null == autoFrequency ? _self.autoFrequency : autoFrequency // ignore: cast_nullable_to_non_nullable
as AutoBackupFrequency,wifiOnly: null == wifiOnly ? _self.wifiOnly : wifiOnly // ignore: cast_nullable_to_non_nullable
as bool,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,autoBackupFailures: null == autoBackupFailures ? _self.autoBackupFailures : autoBackupFailures // ignore: cast_nullable_to_non_nullable
as int,lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as int?,drive: freezed == drive ? _self.drive : drive // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<DriveBackupEntry>>?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as AccountBusy,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountScreenState].
extension AccountScreenStatePatterns on AccountScreenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountScreenState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountScreenState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountScreenState value)  $default,){
final _that = this;
switch (_that) {
case _AccountScreenState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountScreenState value)?  $default,){
final _that = this;
switch (_that) {
case _AccountScreenState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccountState account,  bool driveAvailable,  AutoBackupFrequency autoFrequency,  bool wifiOnly,  bool paused,  int autoBackupFailures,  int? lastBackupAt,  AsyncValue<List<DriveBackupEntry>>? drive,  AccountBusy busy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountScreenState() when $default != null:
return $default(_that.account,_that.driveAvailable,_that.autoFrequency,_that.wifiOnly,_that.paused,_that.autoBackupFailures,_that.lastBackupAt,_that.drive,_that.busy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccountState account,  bool driveAvailable,  AutoBackupFrequency autoFrequency,  bool wifiOnly,  bool paused,  int autoBackupFailures,  int? lastBackupAt,  AsyncValue<List<DriveBackupEntry>>? drive,  AccountBusy busy)  $default,) {final _that = this;
switch (_that) {
case _AccountScreenState():
return $default(_that.account,_that.driveAvailable,_that.autoFrequency,_that.wifiOnly,_that.paused,_that.autoBackupFailures,_that.lastBackupAt,_that.drive,_that.busy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccountState account,  bool driveAvailable,  AutoBackupFrequency autoFrequency,  bool wifiOnly,  bool paused,  int autoBackupFailures,  int? lastBackupAt,  AsyncValue<List<DriveBackupEntry>>? drive,  AccountBusy busy)?  $default,) {final _that = this;
switch (_that) {
case _AccountScreenState() when $default != null:
return $default(_that.account,_that.driveAvailable,_that.autoFrequency,_that.wifiOnly,_that.paused,_that.autoBackupFailures,_that.lastBackupAt,_that.drive,_that.busy);case _:
  return null;

}
}

}

/// @nodoc


class _AccountScreenState implements AccountScreenState {
  const _AccountScreenState({required this.account, required this.driveAvailable, required this.autoFrequency, required this.wifiOnly, required this.paused, required this.autoBackupFailures, this.lastBackupAt, this.drive, this.busy = AccountBusy.none});
  

/// Signed out, or signed in without a working session this run, shows
/// the signed-out content (research R2).
@override final  AccountState account;
/// Google Drive is configured in this build.
@override final  bool driveAvailable;
@override final  AutoBackupFrequency autoFrequency;
@override final  bool wifiOnly;
/// Auto backup is paused by a newer backup from another phone.
@override final  bool paused;
@override final  int autoBackupFailures;
/// UTC epoch milliseconds of the last backup, or null.
@override final  int? lastBackupAt;
/// The account's Drive backups, newest first; null while signed out.
@override final  AsyncValue<List<DriveBackupEntry>>? drive;
@override@JsonKey() final  AccountBusy busy;

/// Create a copy of AccountScreenState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountScreenStateCopyWith<_AccountScreenState> get copyWith => __$AccountScreenStateCopyWithImpl<_AccountScreenState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountScreenState&&(identical(other.account, account) || other.account == account)&&(identical(other.driveAvailable, driveAvailable) || other.driveAvailable == driveAvailable)&&(identical(other.autoFrequency, autoFrequency) || other.autoFrequency == autoFrequency)&&(identical(other.wifiOnly, wifiOnly) || other.wifiOnly == wifiOnly)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.autoBackupFailures, autoBackupFailures) || other.autoBackupFailures == autoBackupFailures)&&(identical(other.lastBackupAt, lastBackupAt) || other.lastBackupAt == lastBackupAt)&&(identical(other.drive, drive) || other.drive == drive)&&(identical(other.busy, busy) || other.busy == busy));
}


@override
int get hashCode {
    return Object.hash(runtimeType,account,driveAvailable,autoFrequency,wifiOnly,paused,autoBackupFailures,lastBackupAt,drive,busy);
}

@override
String toString() {
    return 'AccountScreenState(account: $account, driveAvailable: $driveAvailable, autoFrequency: $autoFrequency, wifiOnly: $wifiOnly, paused: $paused, autoBackupFailures: $autoBackupFailures, lastBackupAt: $lastBackupAt, drive: $drive, busy: $busy)';
}


}

/// @nodoc
abstract mixin class _$AccountScreenStateCopyWith<$Res> implements $AccountScreenStateCopyWith<$Res> {
  factory _$AccountScreenStateCopyWith(_AccountScreenState value, $Res Function(_AccountScreenState) _then) = __$AccountScreenStateCopyWithImpl;
@override @useResult
$Res call({
 AccountState account, bool driveAvailable, AutoBackupFrequency autoFrequency, bool wifiOnly, bool paused, int autoBackupFailures, int? lastBackupAt, AsyncValue<List<DriveBackupEntry>>? drive, AccountBusy busy
});




}
/// @nodoc
class __$AccountScreenStateCopyWithImpl<$Res>
    implements _$AccountScreenStateCopyWith<$Res> {
  __$AccountScreenStateCopyWithImpl(this._self, this._then);

  final _AccountScreenState _self;
  final $Res Function(_AccountScreenState) _then;

/// Create a copy of AccountScreenState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = null,Object? driveAvailable = null,Object? autoFrequency = null,Object? wifiOnly = null,Object? paused = null,Object? autoBackupFailures = null,Object? lastBackupAt = freezed,Object? drive = freezed,Object? busy = null,}) {
  return _then(_AccountScreenState(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as AccountState,driveAvailable: null == driveAvailable ? _self.driveAvailable : driveAvailable // ignore: cast_nullable_to_non_nullable
as bool,autoFrequency: null == autoFrequency ? _self.autoFrequency : autoFrequency // ignore: cast_nullable_to_non_nullable
as AutoBackupFrequency,wifiOnly: null == wifiOnly ? _self.wifiOnly : wifiOnly // ignore: cast_nullable_to_non_nullable
as bool,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,autoBackupFailures: null == autoBackupFailures ? _self.autoBackupFailures : autoBackupFailures // ignore: cast_nullable_to_non_nullable
as int,lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as int?,drive: freezed == drive ? _self.drive : drive // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<DriveBackupEntry>>?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as AccountBusy,
  ));
}


}

// dart format on
