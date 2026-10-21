// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitFormState {

 HabitFormStatus get status; HabitDraft get draft; HabitDraft? get initial;/// The habit being edited; null for a new one.
 Habit? get original; List<HabitFieldError> get errors; bool get saving; bool get saveFailed;/// Hints (US4-7, FR-041).
 bool get notificationsAllowed; bool get exactAlarmsAllowed;/// Why the last "Add reminder" was refused, if it was.
 HabitFieldError? get reminderError;/// The template applied, so it is applied only once.
 String? get templateId;
/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitFormStateCopyWith<HabitFormState> get copyWith => _$HabitFormStateCopyWithImpl<HabitFormState>(this as HabitFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitFormState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.draft, _this.draft) || other.draft == _this.draft)&&(identical(other.initial, _this.initial) || other.initial == _this.initial)&&(identical(other.original, _this.original) || other.original == _this.original)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.saveFailed, _this.saveFailed) || other.saveFailed == _this.saveFailed)&&(identical(other.notificationsAllowed, _this.notificationsAllowed) || other.notificationsAllowed == _this.notificationsAllowed)&&(identical(other.exactAlarmsAllowed, _this.exactAlarmsAllowed) || other.exactAlarmsAllowed == _this.exactAlarmsAllowed)&&(identical(other.reminderError, _this.reminderError) || other.reminderError == _this.reminderError)&&(identical(other.templateId, _this.templateId) || other.templateId == _this.templateId));
}


@override
int get hashCode {
  final _this = this as HabitFormState;
  return Object.hash(runtimeType,_this.status,_this.draft,_this.initial,_this.original,const DeepCollectionEquality().hash(_this.errors),_this.saving,_this.saveFailed,_this.notificationsAllowed,_this.exactAlarmsAllowed,_this.reminderError,_this.templateId);
}

@override
String toString() {
  final _this = this as HabitFormState;
  return 'HabitFormState(status: ${_this.status}, draft: ${_this.draft}, initial: ${_this.initial}, original: ${_this.original}, errors: ${_this.errors}, saving: ${_this.saving}, saveFailed: ${_this.saveFailed}, notificationsAllowed: ${_this.notificationsAllowed}, exactAlarmsAllowed: ${_this.exactAlarmsAllowed}, reminderError: ${_this.reminderError}, templateId: ${_this.templateId})';
}


}

/// @nodoc
abstract mixin class $HabitFormStateCopyWith<$Res>  {
  factory $HabitFormStateCopyWith(HabitFormState value, $Res Function(HabitFormState) _then) = _$HabitFormStateCopyWithImpl;
@useResult
$Res call({
 HabitFormStatus status, HabitDraft draft, HabitDraft? initial, Habit? original, List<HabitFieldError> errors, bool saving, bool saveFailed, bool notificationsAllowed, bool exactAlarmsAllowed, HabitFieldError? reminderError, String? templateId
});


$HabitDraftCopyWith<$Res> get draft;$HabitDraftCopyWith<$Res>? get initial;$HabitCopyWith<$Res>? get original;

}
/// @nodoc
class _$HabitFormStateCopyWithImpl<$Res>
    implements $HabitFormStateCopyWith<$Res> {
  _$HabitFormStateCopyWithImpl(this._self, this._then);

  final HabitFormState _self;
  final $Res Function(HabitFormState) _then;

/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? draft = null,Object? initial = freezed,Object? original = freezed,Object? errors = null,Object? saving = null,Object? saveFailed = null,Object? notificationsAllowed = null,Object? exactAlarmsAllowed = null,Object? reminderError = freezed,Object? templateId = freezed,}) {
  return _then(HabitFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HabitFormStatus,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as HabitDraft,initial: freezed == initial ? _self.initial : initial // ignore: cast_nullable_to_non_nullable
as HabitDraft?,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Habit?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<HabitFieldError>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,notificationsAllowed: null == notificationsAllowed ? _self.notificationsAllowed : notificationsAllowed // ignore: cast_nullable_to_non_nullable
as bool,exactAlarmsAllowed: null == exactAlarmsAllowed ? _self.exactAlarmsAllowed : exactAlarmsAllowed // ignore: cast_nullable_to_non_nullable
as bool,reminderError: freezed == reminderError ? _self.reminderError : reminderError // ignore: cast_nullable_to_non_nullable
as HabitFieldError?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitDraftCopyWith<$Res> get draft {
  
  return $HabitDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitDraftCopyWith<$Res>? get initial {
    if (_self.initial == null) {
    return null;
  }

  return $HabitDraftCopyWith<$Res>(_self.initial!, (value) {
    return _then(_self.copyWith(initial: value));
  });
}/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $HabitCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitFormState].
extension HabitFormStatePatterns on HabitFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitFormState value)  $default,){
final _that = this;
switch (_that) {
case _HabitFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitFormState value)?  $default,){
final _that = this;
switch (_that) {
case _HabitFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HabitFormStatus status,  HabitDraft draft,  HabitDraft? initial,  Habit? original,  List<HabitFieldError> errors,  bool saving,  bool saveFailed,  bool notificationsAllowed,  bool exactAlarmsAllowed,  HabitFieldError? reminderError,  String? templateId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitFormState() when $default != null:
return $default(_that.status,_that.draft,_that.initial,_that.original,_that.errors,_that.saving,_that.saveFailed,_that.notificationsAllowed,_that.exactAlarmsAllowed,_that.reminderError,_that.templateId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HabitFormStatus status,  HabitDraft draft,  HabitDraft? initial,  Habit? original,  List<HabitFieldError> errors,  bool saving,  bool saveFailed,  bool notificationsAllowed,  bool exactAlarmsAllowed,  HabitFieldError? reminderError,  String? templateId)  $default,) {final _that = this;
switch (_that) {
case _HabitFormState():
return $default(_that.status,_that.draft,_that.initial,_that.original,_that.errors,_that.saving,_that.saveFailed,_that.notificationsAllowed,_that.exactAlarmsAllowed,_that.reminderError,_that.templateId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HabitFormStatus status,  HabitDraft draft,  HabitDraft? initial,  Habit? original,  List<HabitFieldError> errors,  bool saving,  bool saveFailed,  bool notificationsAllowed,  bool exactAlarmsAllowed,  HabitFieldError? reminderError,  String? templateId)?  $default,) {final _that = this;
switch (_that) {
case _HabitFormState() when $default != null:
return $default(_that.status,_that.draft,_that.initial,_that.original,_that.errors,_that.saving,_that.saveFailed,_that.notificationsAllowed,_that.exactAlarmsAllowed,_that.reminderError,_that.templateId);case _:
  return null;

}
}

}

/// @nodoc


class _HabitFormState extends HabitFormState {
  const _HabitFormState({required this.status, required this.draft, this.initial, this.original,  List<HabitFieldError> errors = const <HabitFieldError>[], this.saving = false, this.saveFailed = false, this.notificationsAllowed = true, this.exactAlarmsAllowed = true, this.reminderError, this.templateId}): _errors = errors,super._();
  

@override final  HabitFormStatus status;
@override final  HabitDraft draft;
@override final  HabitDraft? initial;
/// The habit being edited; null for a new one.
@override final  Habit? original;
 final  List<HabitFieldError> _errors;
@override@JsonKey() List<HabitFieldError> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}

@override@JsonKey() final  bool saving;
@override@JsonKey() final  bool saveFailed;
/// Hints (US4-7, FR-041).
@override@JsonKey() final  bool notificationsAllowed;
@override@JsonKey() final  bool exactAlarmsAllowed;
/// Why the last "Add reminder" was refused, if it was.
@override final  HabitFieldError? reminderError;
/// The template applied, so it is applied only once.
@override final  String? templateId;

/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitFormStateCopyWith<_HabitFormState> get copyWith => __$HabitFormStateCopyWithImpl<_HabitFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitFormState&&(identical(other.status, status) || other.status == status)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.initial, initial) || other.initial == initial)&&(identical(other.original, original) || other.original == original)&&const DeepCollectionEquality().equals(other.errors, _errors)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.saveFailed, saveFailed) || other.saveFailed == saveFailed)&&(identical(other.notificationsAllowed, notificationsAllowed) || other.notificationsAllowed == notificationsAllowed)&&(identical(other.exactAlarmsAllowed, exactAlarmsAllowed) || other.exactAlarmsAllowed == exactAlarmsAllowed)&&(identical(other.reminderError, reminderError) || other.reminderError == reminderError)&&(identical(other.templateId, templateId) || other.templateId == templateId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,draft,initial,original,const DeepCollectionEquality().hash(_errors),saving,saveFailed,notificationsAllowed,exactAlarmsAllowed,reminderError,templateId);
}

@override
String toString() {
    return 'HabitFormState(status: $status, draft: $draft, initial: $initial, original: $original, errors: $errors, saving: $saving, saveFailed: $saveFailed, notificationsAllowed: $notificationsAllowed, exactAlarmsAllowed: $exactAlarmsAllowed, reminderError: $reminderError, templateId: $templateId)';
}


}

/// @nodoc
abstract mixin class _$HabitFormStateCopyWith<$Res> implements $HabitFormStateCopyWith<$Res> {
  factory _$HabitFormStateCopyWith(_HabitFormState value, $Res Function(_HabitFormState) _then) = __$HabitFormStateCopyWithImpl;
@override @useResult
$Res call({
 HabitFormStatus status, HabitDraft draft, HabitDraft? initial, Habit? original, List<HabitFieldError> errors, bool saving, bool saveFailed, bool notificationsAllowed, bool exactAlarmsAllowed, HabitFieldError? reminderError, String? templateId
});


@override $HabitDraftCopyWith<$Res> get draft;@override $HabitDraftCopyWith<$Res>? get initial;@override $HabitCopyWith<$Res>? get original;

}
/// @nodoc
class __$HabitFormStateCopyWithImpl<$Res>
    implements _$HabitFormStateCopyWith<$Res> {
  __$HabitFormStateCopyWithImpl(this._self, this._then);

  final _HabitFormState _self;
  final $Res Function(_HabitFormState) _then;

/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? draft = null,Object? initial = freezed,Object? original = freezed,Object? errors = null,Object? saving = null,Object? saveFailed = null,Object? notificationsAllowed = null,Object? exactAlarmsAllowed = null,Object? reminderError = freezed,Object? templateId = freezed,}) {
  return _then(_HabitFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HabitFormStatus,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as HabitDraft,initial: freezed == initial ? _self.initial : initial // ignore: cast_nullable_to_non_nullable
as HabitDraft?,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Habit?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<HabitFieldError>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,notificationsAllowed: null == notificationsAllowed ? _self.notificationsAllowed : notificationsAllowed // ignore: cast_nullable_to_non_nullable
as bool,exactAlarmsAllowed: null == exactAlarmsAllowed ? _self.exactAlarmsAllowed : exactAlarmsAllowed // ignore: cast_nullable_to_non_nullable
as bool,reminderError: freezed == reminderError ? _self.reminderError : reminderError // ignore: cast_nullable_to_non_nullable
as HabitFieldError?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitDraftCopyWith<$Res> get draft {
  
  return $HabitDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitDraftCopyWith<$Res>? get initial {
    if (_self.initial == null) {
    return null;
  }

  return $HabitDraftCopyWith<$Res>(_self.initial!, (value) {
    return _then(_self.copyWith(initial: value));
  });
}/// Create a copy of HabitFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $HabitCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
