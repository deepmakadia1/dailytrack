// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingState {

/// 1..4.
 int get step;/// Chosen UI language, or null to follow the device.
 String? get languageCode; String get currencyCode; List<String> get moduleOrder; List<String> get enabledModules;/// Currency search text (step 2).
 String get query;/// True while settings are being saved.
 bool get saving;/// ARB key of the inline "keep one module on" message, if shown.
 String? get moduleMessageKey;/// Result of the notification request, or null if not asked yet.
 bool? get notificationsGranted;/// ARB key of the inline save error, if the last save failed.
 String? get saveErrorKey; GoogleRestoreStatus get googleRestore;/// Why "Restore with Google" failed.
 Object? get googleRestoreError;
/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingStateCopyWith<OnboardingState> get copyWith => _$OnboardingStateCopyWithImpl<OnboardingState>(this as OnboardingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OnboardingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingState&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.languageCode, _this.languageCode) || other.languageCode == _this.languageCode)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&const DeepCollectionEquality().equals(other.moduleOrder, _this.moduleOrder)&&const DeepCollectionEquality().equals(other.enabledModules, _this.enabledModules)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.moduleMessageKey, _this.moduleMessageKey) || other.moduleMessageKey == _this.moduleMessageKey)&&(identical(other.notificationsGranted, _this.notificationsGranted) || other.notificationsGranted == _this.notificationsGranted)&&(identical(other.saveErrorKey, _this.saveErrorKey) || other.saveErrorKey == _this.saveErrorKey)&&(identical(other.googleRestore, _this.googleRestore) || other.googleRestore == _this.googleRestore)&&const DeepCollectionEquality().equals(other.googleRestoreError, _this.googleRestoreError));
}


@override
int get hashCode {
  final _this = this as OnboardingState;
  return Object.hash(runtimeType,_this.step,_this.languageCode,_this.currencyCode,const DeepCollectionEquality().hash(_this.moduleOrder),const DeepCollectionEquality().hash(_this.enabledModules),_this.query,_this.saving,_this.moduleMessageKey,_this.notificationsGranted,_this.saveErrorKey,_this.googleRestore,const DeepCollectionEquality().hash(_this.googleRestoreError));
}

@override
String toString() {
  final _this = this as OnboardingState;
  return 'OnboardingState(step: ${_this.step}, languageCode: ${_this.languageCode}, currencyCode: ${_this.currencyCode}, moduleOrder: ${_this.moduleOrder}, enabledModules: ${_this.enabledModules}, query: ${_this.query}, saving: ${_this.saving}, moduleMessageKey: ${_this.moduleMessageKey}, notificationsGranted: ${_this.notificationsGranted}, saveErrorKey: ${_this.saveErrorKey}, googleRestore: ${_this.googleRestore}, googleRestoreError: ${_this.googleRestoreError})';
}


}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res>  {
  factory $OnboardingStateCopyWith(OnboardingState value, $Res Function(OnboardingState) _then) = _$OnboardingStateCopyWithImpl;
@useResult
$Res call({
 int step, String? languageCode, String currencyCode, List<String> moduleOrder, List<String> enabledModules, String query, bool saving, String? moduleMessageKey, bool? notificationsGranted, String? saveErrorKey, GoogleRestoreStatus googleRestore, Object? googleRestoreError
});




}
/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? languageCode = freezed,Object? currencyCode = null,Object? moduleOrder = null,Object? enabledModules = null,Object? query = null,Object? saving = null,Object? moduleMessageKey = freezed,Object? notificationsGranted = freezed,Object? saveErrorKey = freezed,Object? googleRestore = null,Object? googleRestoreError = freezed,}) {
  return _then(OnboardingState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,moduleOrder: null == moduleOrder ? _self.moduleOrder : moduleOrder // ignore: cast_nullable_to_non_nullable
as List<String>,enabledModules: null == enabledModules ? _self.enabledModules : enabledModules // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,moduleMessageKey: freezed == moduleMessageKey ? _self.moduleMessageKey : moduleMessageKey // ignore: cast_nullable_to_non_nullable
as String?,notificationsGranted: freezed == notificationsGranted ? _self.notificationsGranted : notificationsGranted // ignore: cast_nullable_to_non_nullable
as bool?,saveErrorKey: freezed == saveErrorKey ? _self.saveErrorKey : saveErrorKey // ignore: cast_nullable_to_non_nullable
as String?,googleRestore: null == googleRestore ? _self.googleRestore : googleRestore // ignore: cast_nullable_to_non_nullable
as GoogleRestoreStatus,googleRestoreError: freezed == googleRestoreError ? _self.googleRestoreError : googleRestoreError ,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int step,  String? languageCode,  String currencyCode,  List<String> moduleOrder,  List<String> enabledModules,  String query,  bool saving,  String? moduleMessageKey,  bool? notificationsGranted,  String? saveErrorKey,  GoogleRestoreStatus googleRestore,  Object? googleRestoreError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.step,_that.languageCode,_that.currencyCode,_that.moduleOrder,_that.enabledModules,_that.query,_that.saving,_that.moduleMessageKey,_that.notificationsGranted,_that.saveErrorKey,_that.googleRestore,_that.googleRestoreError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int step,  String? languageCode,  String currencyCode,  List<String> moduleOrder,  List<String> enabledModules,  String query,  bool saving,  String? moduleMessageKey,  bool? notificationsGranted,  String? saveErrorKey,  GoogleRestoreStatus googleRestore,  Object? googleRestoreError)  $default,) {final _that = this;
switch (_that) {
case _OnboardingState():
return $default(_that.step,_that.languageCode,_that.currencyCode,_that.moduleOrder,_that.enabledModules,_that.query,_that.saving,_that.moduleMessageKey,_that.notificationsGranted,_that.saveErrorKey,_that.googleRestore,_that.googleRestoreError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int step,  String? languageCode,  String currencyCode,  List<String> moduleOrder,  List<String> enabledModules,  String query,  bool saving,  String? moduleMessageKey,  bool? notificationsGranted,  String? saveErrorKey,  GoogleRestoreStatus googleRestore,  Object? googleRestoreError)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingState() when $default != null:
return $default(_that.step,_that.languageCode,_that.currencyCode,_that.moduleOrder,_that.enabledModules,_that.query,_that.saving,_that.moduleMessageKey,_that.notificationsGranted,_that.saveErrorKey,_that.googleRestore,_that.googleRestoreError);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingState extends OnboardingState {
  const _OnboardingState({this.step = 1, this.languageCode, this.currencyCode = 'INR',  List<String> moduleOrder = const <String>[],  List<String> enabledModules = const <String>[], this.query = '', this.saving = false, this.moduleMessageKey, this.notificationsGranted, this.saveErrorKey, this.googleRestore = GoogleRestoreStatus.idle, this.googleRestoreError}): _moduleOrder = moduleOrder,_enabledModules = enabledModules,super._();
  

/// 1..4.
@override@JsonKey() final  int step;
/// Chosen UI language, or null to follow the device.
@override final  String? languageCode;
@override@JsonKey() final  String currencyCode;
 final  List<String> _moduleOrder;
@override@JsonKey() List<String> get moduleOrder {
  if (_moduleOrder is EqualUnmodifiableListView) return _moduleOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_moduleOrder);
}

 final  List<String> _enabledModules;
@override@JsonKey() List<String> get enabledModules {
  if (_enabledModules is EqualUnmodifiableListView) return _enabledModules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_enabledModules);
}

/// Currency search text (step 2).
@override@JsonKey() final  String query;
/// True while settings are being saved.
@override@JsonKey() final  bool saving;
/// ARB key of the inline "keep one module on" message, if shown.
@override final  String? moduleMessageKey;
/// Result of the notification request, or null if not asked yet.
@override final  bool? notificationsGranted;
/// ARB key of the inline save error, if the last save failed.
@override final  String? saveErrorKey;
@override@JsonKey() final  GoogleRestoreStatus googleRestore;
/// Why "Restore with Google" failed.
@override final  Object? googleRestoreError;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingStateCopyWith<_OnboardingState> get copyWith => __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingState&&(identical(other.step, step) || other.step == step)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&const DeepCollectionEquality().equals(other.moduleOrder, _moduleOrder)&&const DeepCollectionEquality().equals(other.enabledModules, _enabledModules)&&(identical(other.query, query) || other.query == query)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.moduleMessageKey, moduleMessageKey) || other.moduleMessageKey == moduleMessageKey)&&(identical(other.notificationsGranted, notificationsGranted) || other.notificationsGranted == notificationsGranted)&&(identical(other.saveErrorKey, saveErrorKey) || other.saveErrorKey == saveErrorKey)&&(identical(other.googleRestore, googleRestore) || other.googleRestore == googleRestore)&&const DeepCollectionEquality().equals(other.googleRestoreError, googleRestoreError));
}


@override
int get hashCode {
    return Object.hash(runtimeType,step,languageCode,currencyCode,const DeepCollectionEquality().hash(_moduleOrder),const DeepCollectionEquality().hash(_enabledModules),query,saving,moduleMessageKey,notificationsGranted,saveErrorKey,googleRestore,const DeepCollectionEquality().hash(googleRestoreError));
}

@override
String toString() {
    return 'OnboardingState(step: $step, languageCode: $languageCode, currencyCode: $currencyCode, moduleOrder: $moduleOrder, enabledModules: $enabledModules, query: $query, saving: $saving, moduleMessageKey: $moduleMessageKey, notificationsGranted: $notificationsGranted, saveErrorKey: $saveErrorKey, googleRestore: $googleRestore, googleRestoreError: $googleRestoreError)';
}


}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res> implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(_OnboardingState value, $Res Function(_OnboardingState) _then) = __$OnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 int step, String? languageCode, String currencyCode, List<String> moduleOrder, List<String> enabledModules, String query, bool saving, String? moduleMessageKey, bool? notificationsGranted, String? saveErrorKey, GoogleRestoreStatus googleRestore, Object? googleRestoreError
});




}
/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

/// Create a copy of OnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? languageCode = freezed,Object? currencyCode = null,Object? moduleOrder = null,Object? enabledModules = null,Object? query = null,Object? saving = null,Object? moduleMessageKey = freezed,Object? notificationsGranted = freezed,Object? saveErrorKey = freezed,Object? googleRestore = null,Object? googleRestoreError = freezed,}) {
  return _then(_OnboardingState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,moduleOrder: null == moduleOrder ? _self._moduleOrder : moduleOrder // ignore: cast_nullable_to_non_nullable
as List<String>,enabledModules: null == enabledModules ? _self._enabledModules : enabledModules // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,moduleMessageKey: freezed == moduleMessageKey ? _self.moduleMessageKey : moduleMessageKey // ignore: cast_nullable_to_non_nullable
as String?,notificationsGranted: freezed == notificationsGranted ? _self.notificationsGranted : notificationsGranted // ignore: cast_nullable_to_non_nullable
as bool?,saveErrorKey: freezed == saveErrorKey ? _self.saveErrorKey : saveErrorKey // ignore: cast_nullable_to_non_nullable
as String?,googleRestore: null == googleRestore ? _self.googleRestore : googleRestore // ignore: cast_nullable_to_non_nullable
as GoogleRestoreStatus,googleRestoreError: freezed == googleRestoreError ? _self.googleRestoreError : googleRestoreError ,
  ));
}


}

// dart format on
