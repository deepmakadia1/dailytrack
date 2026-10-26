// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackupState {

 bool get encrypt; bool get includeReceipts;/// Google Drive is configured in this build.
 bool get driveAvailable; AutoBackupFrequency get autoFrequency; bool get wifiOnly;/// UTC epoch milliseconds of the last backup, or null.
 int? get lastBackupAt; BackupLocation? get lastBackupLocation; int? get lastBackupSizeBytes;/// The signed-in Google account, or null (also when this run's silent
/// sign-in failed; feature 010 research R2).
 String? get accountEmail;/// Signed out because the Google sign-in expired (research R2).
 bool get sessionExpired;/// The 7-day copy of the data a restore replaced (FR-019a).
 SafetyCopyInfo? get safetyCopy;/// The Drive backups; null while signed out.
 AsyncValue<List<DriveBackupEntry>>? get drive;/// True while a backup file is being saved.
 bool get busy;/// True while backing up to Drive.
 bool get uploading;
/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupStateCopyWith<BackupState> get copyWith => _$BackupStateCopyWithImpl<BackupState>(this as BackupState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BackupState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupState&&(identical(other.encrypt, _this.encrypt) || other.encrypt == _this.encrypt)&&(identical(other.includeReceipts, _this.includeReceipts) || other.includeReceipts == _this.includeReceipts)&&(identical(other.driveAvailable, _this.driveAvailable) || other.driveAvailable == _this.driveAvailable)&&(identical(other.autoFrequency, _this.autoFrequency) || other.autoFrequency == _this.autoFrequency)&&(identical(other.wifiOnly, _this.wifiOnly) || other.wifiOnly == _this.wifiOnly)&&(identical(other.lastBackupAt, _this.lastBackupAt) || other.lastBackupAt == _this.lastBackupAt)&&(identical(other.lastBackupLocation, _this.lastBackupLocation) || other.lastBackupLocation == _this.lastBackupLocation)&&(identical(other.lastBackupSizeBytes, _this.lastBackupSizeBytes) || other.lastBackupSizeBytes == _this.lastBackupSizeBytes)&&(identical(other.accountEmail, _this.accountEmail) || other.accountEmail == _this.accountEmail)&&(identical(other.sessionExpired, _this.sessionExpired) || other.sessionExpired == _this.sessionExpired)&&(identical(other.safetyCopy, _this.safetyCopy) || other.safetyCopy == _this.safetyCopy)&&(identical(other.drive, _this.drive) || other.drive == _this.drive)&&(identical(other.busy, _this.busy) || other.busy == _this.busy)&&(identical(other.uploading, _this.uploading) || other.uploading == _this.uploading));
}


@override
int get hashCode {
  final _this = this as BackupState;
  return Object.hash(runtimeType,_this.encrypt,_this.includeReceipts,_this.driveAvailable,_this.autoFrequency,_this.wifiOnly,_this.lastBackupAt,_this.lastBackupLocation,_this.lastBackupSizeBytes,_this.accountEmail,_this.sessionExpired,_this.safetyCopy,_this.drive,_this.busy,_this.uploading);
}

@override
String toString() {
  final _this = this as BackupState;
  return 'BackupState(encrypt: ${_this.encrypt}, includeReceipts: ${_this.includeReceipts}, driveAvailable: ${_this.driveAvailable}, autoFrequency: ${_this.autoFrequency}, wifiOnly: ${_this.wifiOnly}, lastBackupAt: ${_this.lastBackupAt}, lastBackupLocation: ${_this.lastBackupLocation}, lastBackupSizeBytes: ${_this.lastBackupSizeBytes}, accountEmail: ${_this.accountEmail}, sessionExpired: ${_this.sessionExpired}, safetyCopy: ${_this.safetyCopy}, drive: ${_this.drive}, busy: ${_this.busy}, uploading: ${_this.uploading})';
}


}

/// @nodoc
abstract mixin class $BackupStateCopyWith<$Res>  {
  factory $BackupStateCopyWith(BackupState value, $Res Function(BackupState) _then) = _$BackupStateCopyWithImpl;
@useResult
$Res call({
 bool encrypt, bool includeReceipts, bool driveAvailable, AutoBackupFrequency autoFrequency, bool wifiOnly, int? lastBackupAt, BackupLocation? lastBackupLocation, int? lastBackupSizeBytes, String? accountEmail, bool sessionExpired, SafetyCopyInfo? safetyCopy, AsyncValue<List<DriveBackupEntry>>? drive, bool busy, bool uploading
});




}
/// @nodoc
class _$BackupStateCopyWithImpl<$Res>
    implements $BackupStateCopyWith<$Res> {
  _$BackupStateCopyWithImpl(this._self, this._then);

  final BackupState _self;
  final $Res Function(BackupState) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? encrypt = null,Object? includeReceipts = null,Object? driveAvailable = null,Object? autoFrequency = null,Object? wifiOnly = null,Object? lastBackupAt = freezed,Object? lastBackupLocation = freezed,Object? lastBackupSizeBytes = freezed,Object? accountEmail = freezed,Object? sessionExpired = null,Object? safetyCopy = freezed,Object? drive = freezed,Object? busy = null,Object? uploading = null,}) {
  return _then(BackupState(
encrypt: null == encrypt ? _self.encrypt : encrypt // ignore: cast_nullable_to_non_nullable
as bool,includeReceipts: null == includeReceipts ? _self.includeReceipts : includeReceipts // ignore: cast_nullable_to_non_nullable
as bool,driveAvailable: null == driveAvailable ? _self.driveAvailable : driveAvailable // ignore: cast_nullable_to_non_nullable
as bool,autoFrequency: null == autoFrequency ? _self.autoFrequency : autoFrequency // ignore: cast_nullable_to_non_nullable
as AutoBackupFrequency,wifiOnly: null == wifiOnly ? _self.wifiOnly : wifiOnly // ignore: cast_nullable_to_non_nullable
as bool,lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as int?,lastBackupLocation: freezed == lastBackupLocation ? _self.lastBackupLocation : lastBackupLocation // ignore: cast_nullable_to_non_nullable
as BackupLocation?,lastBackupSizeBytes: freezed == lastBackupSizeBytes ? _self.lastBackupSizeBytes : lastBackupSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,accountEmail: freezed == accountEmail ? _self.accountEmail : accountEmail // ignore: cast_nullable_to_non_nullable
as String?,sessionExpired: null == sessionExpired ? _self.sessionExpired : sessionExpired // ignore: cast_nullable_to_non_nullable
as bool,safetyCopy: freezed == safetyCopy ? _self.safetyCopy : safetyCopy // ignore: cast_nullable_to_non_nullable
as SafetyCopyInfo?,drive: freezed == drive ? _self.drive : drive // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<DriveBackupEntry>>?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BackupState].
extension BackupStatePatterns on BackupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackupState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackupState value)  $default,){
final _that = this;
switch (_that) {
case _BackupState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackupState value)?  $default,){
final _that = this;
switch (_that) {
case _BackupState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool encrypt,  bool includeReceipts,  bool driveAvailable,  AutoBackupFrequency autoFrequency,  bool wifiOnly,  int? lastBackupAt,  BackupLocation? lastBackupLocation,  int? lastBackupSizeBytes,  String? accountEmail,  bool sessionExpired,  SafetyCopyInfo? safetyCopy,  AsyncValue<List<DriveBackupEntry>>? drive,  bool busy,  bool uploading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackupState() when $default != null:
return $default(_that.encrypt,_that.includeReceipts,_that.driveAvailable,_that.autoFrequency,_that.wifiOnly,_that.lastBackupAt,_that.lastBackupLocation,_that.lastBackupSizeBytes,_that.accountEmail,_that.sessionExpired,_that.safetyCopy,_that.drive,_that.busy,_that.uploading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool encrypt,  bool includeReceipts,  bool driveAvailable,  AutoBackupFrequency autoFrequency,  bool wifiOnly,  int? lastBackupAt,  BackupLocation? lastBackupLocation,  int? lastBackupSizeBytes,  String? accountEmail,  bool sessionExpired,  SafetyCopyInfo? safetyCopy,  AsyncValue<List<DriveBackupEntry>>? drive,  bool busy,  bool uploading)  $default,) {final _that = this;
switch (_that) {
case _BackupState():
return $default(_that.encrypt,_that.includeReceipts,_that.driveAvailable,_that.autoFrequency,_that.wifiOnly,_that.lastBackupAt,_that.lastBackupLocation,_that.lastBackupSizeBytes,_that.accountEmail,_that.sessionExpired,_that.safetyCopy,_that.drive,_that.busy,_that.uploading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool encrypt,  bool includeReceipts,  bool driveAvailable,  AutoBackupFrequency autoFrequency,  bool wifiOnly,  int? lastBackupAt,  BackupLocation? lastBackupLocation,  int? lastBackupSizeBytes,  String? accountEmail,  bool sessionExpired,  SafetyCopyInfo? safetyCopy,  AsyncValue<List<DriveBackupEntry>>? drive,  bool busy,  bool uploading)?  $default,) {final _that = this;
switch (_that) {
case _BackupState() when $default != null:
return $default(_that.encrypt,_that.includeReceipts,_that.driveAvailable,_that.autoFrequency,_that.wifiOnly,_that.lastBackupAt,_that.lastBackupLocation,_that.lastBackupSizeBytes,_that.accountEmail,_that.sessionExpired,_that.safetyCopy,_that.drive,_that.busy,_that.uploading);case _:
  return null;

}
}

}

/// @nodoc


class _BackupState implements BackupState {
  const _BackupState({required this.encrypt, required this.includeReceipts, required this.driveAvailable, required this.autoFrequency, required this.wifiOnly, this.lastBackupAt, this.lastBackupLocation, this.lastBackupSizeBytes, this.accountEmail, this.sessionExpired = false, this.safetyCopy, this.drive, this.busy = false, this.uploading = false});
  

@override final  bool encrypt;
@override final  bool includeReceipts;
/// Google Drive is configured in this build.
@override final  bool driveAvailable;
@override final  AutoBackupFrequency autoFrequency;
@override final  bool wifiOnly;
/// UTC epoch milliseconds of the last backup, or null.
@override final  int? lastBackupAt;
@override final  BackupLocation? lastBackupLocation;
@override final  int? lastBackupSizeBytes;
/// The signed-in Google account, or null (also when this run's silent
/// sign-in failed; feature 010 research R2).
@override final  String? accountEmail;
/// Signed out because the Google sign-in expired (research R2).
@override@JsonKey() final  bool sessionExpired;
/// The 7-day copy of the data a restore replaced (FR-019a).
@override final  SafetyCopyInfo? safetyCopy;
/// The Drive backups; null while signed out.
@override final  AsyncValue<List<DriveBackupEntry>>? drive;
/// True while a backup file is being saved.
@override@JsonKey() final  bool busy;
/// True while backing up to Drive.
@override@JsonKey() final  bool uploading;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupStateCopyWith<_BackupState> get copyWith => __$BackupStateCopyWithImpl<_BackupState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupState&&(identical(other.encrypt, encrypt) || other.encrypt == encrypt)&&(identical(other.includeReceipts, includeReceipts) || other.includeReceipts == includeReceipts)&&(identical(other.driveAvailable, driveAvailable) || other.driveAvailable == driveAvailable)&&(identical(other.autoFrequency, autoFrequency) || other.autoFrequency == autoFrequency)&&(identical(other.wifiOnly, wifiOnly) || other.wifiOnly == wifiOnly)&&(identical(other.lastBackupAt, lastBackupAt) || other.lastBackupAt == lastBackupAt)&&(identical(other.lastBackupLocation, lastBackupLocation) || other.lastBackupLocation == lastBackupLocation)&&(identical(other.lastBackupSizeBytes, lastBackupSizeBytes) || other.lastBackupSizeBytes == lastBackupSizeBytes)&&(identical(other.accountEmail, accountEmail) || other.accountEmail == accountEmail)&&(identical(other.sessionExpired, sessionExpired) || other.sessionExpired == sessionExpired)&&(identical(other.safetyCopy, safetyCopy) || other.safetyCopy == safetyCopy)&&(identical(other.drive, drive) || other.drive == drive)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uploading, uploading) || other.uploading == uploading));
}


@override
int get hashCode {
    return Object.hash(runtimeType,encrypt,includeReceipts,driveAvailable,autoFrequency,wifiOnly,lastBackupAt,lastBackupLocation,lastBackupSizeBytes,accountEmail,sessionExpired,safetyCopy,drive,busy,uploading);
}

@override
String toString() {
    return 'BackupState(encrypt: $encrypt, includeReceipts: $includeReceipts, driveAvailable: $driveAvailable, autoFrequency: $autoFrequency, wifiOnly: $wifiOnly, lastBackupAt: $lastBackupAt, lastBackupLocation: $lastBackupLocation, lastBackupSizeBytes: $lastBackupSizeBytes, accountEmail: $accountEmail, sessionExpired: $sessionExpired, safetyCopy: $safetyCopy, drive: $drive, busy: $busy, uploading: $uploading)';
}


}

/// @nodoc
abstract mixin class _$BackupStateCopyWith<$Res> implements $BackupStateCopyWith<$Res> {
  factory _$BackupStateCopyWith(_BackupState value, $Res Function(_BackupState) _then) = __$BackupStateCopyWithImpl;
@override @useResult
$Res call({
 bool encrypt, bool includeReceipts, bool driveAvailable, AutoBackupFrequency autoFrequency, bool wifiOnly, int? lastBackupAt, BackupLocation? lastBackupLocation, int? lastBackupSizeBytes, String? accountEmail, bool sessionExpired, SafetyCopyInfo? safetyCopy, AsyncValue<List<DriveBackupEntry>>? drive, bool busy, bool uploading
});




}
/// @nodoc
class __$BackupStateCopyWithImpl<$Res>
    implements _$BackupStateCopyWith<$Res> {
  __$BackupStateCopyWithImpl(this._self, this._then);

  final _BackupState _self;
  final $Res Function(_BackupState) _then;

/// Create a copy of BackupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? encrypt = null,Object? includeReceipts = null,Object? driveAvailable = null,Object? autoFrequency = null,Object? wifiOnly = null,Object? lastBackupAt = freezed,Object? lastBackupLocation = freezed,Object? lastBackupSizeBytes = freezed,Object? accountEmail = freezed,Object? sessionExpired = null,Object? safetyCopy = freezed,Object? drive = freezed,Object? busy = null,Object? uploading = null,}) {
  return _then(_BackupState(
encrypt: null == encrypt ? _self.encrypt : encrypt // ignore: cast_nullable_to_non_nullable
as bool,includeReceipts: null == includeReceipts ? _self.includeReceipts : includeReceipts // ignore: cast_nullable_to_non_nullable
as bool,driveAvailable: null == driveAvailable ? _self.driveAvailable : driveAvailable // ignore: cast_nullable_to_non_nullable
as bool,autoFrequency: null == autoFrequency ? _self.autoFrequency : autoFrequency // ignore: cast_nullable_to_non_nullable
as AutoBackupFrequency,wifiOnly: null == wifiOnly ? _self.wifiOnly : wifiOnly // ignore: cast_nullable_to_non_nullable
as bool,lastBackupAt: freezed == lastBackupAt ? _self.lastBackupAt : lastBackupAt // ignore: cast_nullable_to_non_nullable
as int?,lastBackupLocation: freezed == lastBackupLocation ? _self.lastBackupLocation : lastBackupLocation // ignore: cast_nullable_to_non_nullable
as BackupLocation?,lastBackupSizeBytes: freezed == lastBackupSizeBytes ? _self.lastBackupSizeBytes : lastBackupSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,accountEmail: freezed == accountEmail ? _self.accountEmail : accountEmail // ignore: cast_nullable_to_non_nullable
as String?,sessionExpired: null == sessionExpired ? _self.sessionExpired : sessionExpired // ignore: cast_nullable_to_non_nullable
as bool,safetyCopy: freezed == safetyCopy ? _self.safetyCopy : safetyCopy // ignore: cast_nullable_to_non_nullable
as SafetyCopyInfo?,drive: freezed == drive ? _self.drive : drive // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<DriveBackupEntry>>?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uploading: null == uploading ? _self.uploading : uploading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
