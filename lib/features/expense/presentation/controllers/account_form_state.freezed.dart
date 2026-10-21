// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountFormState {

 AccountFormStatus get status; String get name; AccountType get type; String get openingExpression; bool get negative; String get iconKey; String get colorHex; Map<AccountField, AccountError> get errors; bool get keypadOpen; bool get saving; bool get saveFailed;/// The account being edited; null for a new one.
 Account? get original;
/// Create a copy of AccountFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountFormStateCopyWith<AccountFormState> get copyWith => _$AccountFormStateCopyWithImpl<AccountFormState>(this as AccountFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountFormState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.openingExpression, _this.openingExpression) || other.openingExpression == _this.openingExpression)&&(identical(other.negative, _this.negative) || other.negative == _this.negative)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&(identical(other.keypadOpen, _this.keypadOpen) || other.keypadOpen == _this.keypadOpen)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.saveFailed, _this.saveFailed) || other.saveFailed == _this.saveFailed)&&(identical(other.original, _this.original) || other.original == _this.original));
}


@override
int get hashCode {
  final _this = this as AccountFormState;
  return Object.hash(runtimeType,_this.status,_this.name,_this.type,_this.openingExpression,_this.negative,_this.iconKey,_this.colorHex,const DeepCollectionEquality().hash(_this.errors),_this.keypadOpen,_this.saving,_this.saveFailed,_this.original);
}

@override
String toString() {
  final _this = this as AccountFormState;
  return 'AccountFormState(status: ${_this.status}, name: ${_this.name}, type: ${_this.type}, openingExpression: ${_this.openingExpression}, negative: ${_this.negative}, iconKey: ${_this.iconKey}, colorHex: ${_this.colorHex}, errors: ${_this.errors}, keypadOpen: ${_this.keypadOpen}, saving: ${_this.saving}, saveFailed: ${_this.saveFailed}, original: ${_this.original})';
}


}

/// @nodoc
abstract mixin class $AccountFormStateCopyWith<$Res>  {
  factory $AccountFormStateCopyWith(AccountFormState value, $Res Function(AccountFormState) _then) = _$AccountFormStateCopyWithImpl;
@useResult
$Res call({
 AccountFormStatus status, String name, AccountType type, String openingExpression, bool negative, String iconKey, String colorHex, Map<AccountField, AccountError> errors, bool keypadOpen, bool saving, bool saveFailed, Account? original
});


$AccountCopyWith<$Res>? get original;

}
/// @nodoc
class _$AccountFormStateCopyWithImpl<$Res>
    implements $AccountFormStateCopyWith<$Res> {
  _$AccountFormStateCopyWithImpl(this._self, this._then);

  final AccountFormState _self;
  final $Res Function(AccountFormState) _then;

/// Create a copy of AccountFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? name = null,Object? type = null,Object? openingExpression = null,Object? negative = null,Object? iconKey = null,Object? colorHex = null,Object? errors = null,Object? keypadOpen = null,Object? saving = null,Object? saveFailed = null,Object? original = freezed,}) {
  return _then(AccountFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountFormStatus,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,openingExpression: null == openingExpression ? _self.openingExpression : openingExpression // ignore: cast_nullable_to_non_nullable
as String,negative: null == negative ? _self.negative : negative // ignore: cast_nullable_to_non_nullable
as bool,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<AccountField, AccountError>,keypadOpen: null == keypadOpen ? _self.keypadOpen : keypadOpen // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Account?,
  ));
}
/// Create a copy of AccountFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $AccountCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountFormState].
extension AccountFormStatePatterns on AccountFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountFormState value)  $default,){
final _that = this;
switch (_that) {
case _AccountFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountFormState value)?  $default,){
final _that = this;
switch (_that) {
case _AccountFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccountFormStatus status,  String name,  AccountType type,  String openingExpression,  bool negative,  String iconKey,  String colorHex,  Map<AccountField, AccountError> errors,  bool keypadOpen,  bool saving,  bool saveFailed,  Account? original)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountFormState() when $default != null:
return $default(_that.status,_that.name,_that.type,_that.openingExpression,_that.negative,_that.iconKey,_that.colorHex,_that.errors,_that.keypadOpen,_that.saving,_that.saveFailed,_that.original);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccountFormStatus status,  String name,  AccountType type,  String openingExpression,  bool negative,  String iconKey,  String colorHex,  Map<AccountField, AccountError> errors,  bool keypadOpen,  bool saving,  bool saveFailed,  Account? original)  $default,) {final _that = this;
switch (_that) {
case _AccountFormState():
return $default(_that.status,_that.name,_that.type,_that.openingExpression,_that.negative,_that.iconKey,_that.colorHex,_that.errors,_that.keypadOpen,_that.saving,_that.saveFailed,_that.original);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccountFormStatus status,  String name,  AccountType type,  String openingExpression,  bool negative,  String iconKey,  String colorHex,  Map<AccountField, AccountError> errors,  bool keypadOpen,  bool saving,  bool saveFailed,  Account? original)?  $default,) {final _that = this;
switch (_that) {
case _AccountFormState() when $default != null:
return $default(_that.status,_that.name,_that.type,_that.openingExpression,_that.negative,_that.iconKey,_that.colorHex,_that.errors,_that.keypadOpen,_that.saving,_that.saveFailed,_that.original);case _:
  return null;

}
}

}

/// @nodoc


class _AccountFormState extends AccountFormState {
  const _AccountFormState({required this.status, this.name = '', this.type = AccountType.cash, this.openingExpression = '', this.negative = false, this.iconKey = 'wallet', this.colorHex = '',  Map<AccountField, AccountError> errors = const <AccountField, AccountError>{}, this.keypadOpen = false, this.saving = false, this.saveFailed = false, this.original}): _errors = errors,super._();
  

@override final  AccountFormStatus status;
@override@JsonKey() final  String name;
@override@JsonKey() final  AccountType type;
@override@JsonKey() final  String openingExpression;
@override@JsonKey() final  bool negative;
@override@JsonKey() final  String iconKey;
@override@JsonKey() final  String colorHex;
 final  Map<AccountField, AccountError> _errors;
@override@JsonKey() Map<AccountField, AccountError> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override@JsonKey() final  bool keypadOpen;
@override@JsonKey() final  bool saving;
@override@JsonKey() final  bool saveFailed;
/// The account being edited; null for a new one.
@override final  Account? original;

/// Create a copy of AccountFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountFormStateCopyWith<_AccountFormState> get copyWith => __$AccountFormStateCopyWithImpl<_AccountFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountFormState&&(identical(other.status, status) || other.status == status)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.openingExpression, openingExpression) || other.openingExpression == openingExpression)&&(identical(other.negative, negative) || other.negative == negative)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&const DeepCollectionEquality().equals(other.errors, _errors)&&(identical(other.keypadOpen, keypadOpen) || other.keypadOpen == keypadOpen)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.saveFailed, saveFailed) || other.saveFailed == saveFailed)&&(identical(other.original, original) || other.original == original));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,name,type,openingExpression,negative,iconKey,colorHex,const DeepCollectionEquality().hash(_errors),keypadOpen,saving,saveFailed,original);
}

@override
String toString() {
    return 'AccountFormState(status: $status, name: $name, type: $type, openingExpression: $openingExpression, negative: $negative, iconKey: $iconKey, colorHex: $colorHex, errors: $errors, keypadOpen: $keypadOpen, saving: $saving, saveFailed: $saveFailed, original: $original)';
}


}

/// @nodoc
abstract mixin class _$AccountFormStateCopyWith<$Res> implements $AccountFormStateCopyWith<$Res> {
  factory _$AccountFormStateCopyWith(_AccountFormState value, $Res Function(_AccountFormState) _then) = __$AccountFormStateCopyWithImpl;
@override @useResult
$Res call({
 AccountFormStatus status, String name, AccountType type, String openingExpression, bool negative, String iconKey, String colorHex, Map<AccountField, AccountError> errors, bool keypadOpen, bool saving, bool saveFailed, Account? original
});


@override $AccountCopyWith<$Res>? get original;

}
/// @nodoc
class __$AccountFormStateCopyWithImpl<$Res>
    implements _$AccountFormStateCopyWith<$Res> {
  __$AccountFormStateCopyWithImpl(this._self, this._then);

  final _AccountFormState _self;
  final $Res Function(_AccountFormState) _then;

/// Create a copy of AccountFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? name = null,Object? type = null,Object? openingExpression = null,Object? negative = null,Object? iconKey = null,Object? colorHex = null,Object? errors = null,Object? keypadOpen = null,Object? saving = null,Object? saveFailed = null,Object? original = freezed,}) {
  return _then(_AccountFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AccountFormStatus,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,openingExpression: null == openingExpression ? _self.openingExpression : openingExpression // ignore: cast_nullable_to_non_nullable
as String,negative: null == negative ? _self.negative : negative // ignore: cast_nullable_to_non_nullable
as bool,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<AccountField, AccountError>,keypadOpen: null == keypadOpen ? _self.keypadOpen : keypadOpen // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Account?,
  ));
}

/// Create a copy of AccountFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $AccountCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
