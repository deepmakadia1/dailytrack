// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionFormArgs {

 FormMode get mode;/// The transaction being edited (edit mode).
 String? get id; TxnType get initialType;/// Prefill from this transaction, dated now, without its receipt.
 String? get duplicateOf;/// The rule being edited (rule-edit mode, `/expenses/recurring/:id/edit`).
 String? get ruleId;/// Start with Repeat on (`/expenses/recurring/add`, the EXP-10 empty
/// state).
 bool get repeat;
/// Create a copy of TransactionFormArgs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionFormArgsCopyWith<TransactionFormArgs> get copyWith => _$TransactionFormArgsCopyWithImpl<TransactionFormArgs>(this as TransactionFormArgs, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransactionFormArgs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionFormArgs&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.initialType, _this.initialType) || other.initialType == _this.initialType)&&(identical(other.duplicateOf, _this.duplicateOf) || other.duplicateOf == _this.duplicateOf)&&(identical(other.ruleId, _this.ruleId) || other.ruleId == _this.ruleId)&&(identical(other.repeat, _this.repeat) || other.repeat == _this.repeat));
}


@override
int get hashCode {
  final _this = this as TransactionFormArgs;
  return Object.hash(runtimeType,_this.mode,_this.id,_this.initialType,_this.duplicateOf,_this.ruleId,_this.repeat);
}

@override
String toString() {
  final _this = this as TransactionFormArgs;
  return 'TransactionFormArgs(mode: ${_this.mode}, id: ${_this.id}, initialType: ${_this.initialType}, duplicateOf: ${_this.duplicateOf}, ruleId: ${_this.ruleId}, repeat: ${_this.repeat})';
}


}

/// @nodoc
abstract mixin class $TransactionFormArgsCopyWith<$Res>  {
  factory $TransactionFormArgsCopyWith(TransactionFormArgs value, $Res Function(TransactionFormArgs) _then) = _$TransactionFormArgsCopyWithImpl;
@useResult
$Res call({
 FormMode mode, String? id, TxnType initialType, String? duplicateOf, String? ruleId, bool repeat
});




}
/// @nodoc
class _$TransactionFormArgsCopyWithImpl<$Res>
    implements $TransactionFormArgsCopyWith<$Res> {
  _$TransactionFormArgsCopyWithImpl(this._self, this._then);

  final TransactionFormArgs _self;
  final $Res Function(TransactionFormArgs) _then;

/// Create a copy of TransactionFormArgs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? id = freezed,Object? initialType = null,Object? duplicateOf = freezed,Object? ruleId = freezed,Object? repeat = null,}) {
  return _then(TransactionFormArgs(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as FormMode,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,initialType: null == initialType ? _self.initialType : initialType // ignore: cast_nullable_to_non_nullable
as TxnType,duplicateOf: freezed == duplicateOf ? _self.duplicateOf : duplicateOf // ignore: cast_nullable_to_non_nullable
as String?,ruleId: freezed == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String?,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionFormArgs].
extension TransactionFormArgsPatterns on TransactionFormArgs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionFormArgs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionFormArgs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionFormArgs value)  $default,){
final _that = this;
switch (_that) {
case _TransactionFormArgs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionFormArgs value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionFormArgs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FormMode mode,  String? id,  TxnType initialType,  String? duplicateOf,  String? ruleId,  bool repeat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionFormArgs() when $default != null:
return $default(_that.mode,_that.id,_that.initialType,_that.duplicateOf,_that.ruleId,_that.repeat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FormMode mode,  String? id,  TxnType initialType,  String? duplicateOf,  String? ruleId,  bool repeat)  $default,) {final _that = this;
switch (_that) {
case _TransactionFormArgs():
return $default(_that.mode,_that.id,_that.initialType,_that.duplicateOf,_that.ruleId,_that.repeat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FormMode mode,  String? id,  TxnType initialType,  String? duplicateOf,  String? ruleId,  bool repeat)?  $default,) {final _that = this;
switch (_that) {
case _TransactionFormArgs() when $default != null:
return $default(_that.mode,_that.id,_that.initialType,_that.duplicateOf,_that.ruleId,_that.repeat);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionFormArgs implements TransactionFormArgs {
  const _TransactionFormArgs({required this.mode, this.id, this.initialType = TxnType.expense, this.duplicateOf, this.ruleId, this.repeat = false});
  

@override final  FormMode mode;
/// The transaction being edited (edit mode).
@override final  String? id;
@override@JsonKey() final  TxnType initialType;
/// Prefill from this transaction, dated now, without its receipt.
@override final  String? duplicateOf;
/// The rule being edited (rule-edit mode, `/expenses/recurring/:id/edit`).
@override final  String? ruleId;
/// Start with Repeat on (`/expenses/recurring/add`, the EXP-10 empty
/// state).
@override@JsonKey() final  bool repeat;

/// Create a copy of TransactionFormArgs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionFormArgsCopyWith<_TransactionFormArgs> get copyWith => __$TransactionFormArgsCopyWithImpl<_TransactionFormArgs>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionFormArgs&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.id, id) || other.id == id)&&(identical(other.initialType, initialType) || other.initialType == initialType)&&(identical(other.duplicateOf, duplicateOf) || other.duplicateOf == duplicateOf)&&(identical(other.ruleId, ruleId) || other.ruleId == ruleId)&&(identical(other.repeat, repeat) || other.repeat == repeat));
}


@override
int get hashCode {
    return Object.hash(runtimeType,mode,id,initialType,duplicateOf,ruleId,repeat);
}

@override
String toString() {
    return 'TransactionFormArgs(mode: $mode, id: $id, initialType: $initialType, duplicateOf: $duplicateOf, ruleId: $ruleId, repeat: $repeat)';
}


}

/// @nodoc
abstract mixin class _$TransactionFormArgsCopyWith<$Res> implements $TransactionFormArgsCopyWith<$Res> {
  factory _$TransactionFormArgsCopyWith(_TransactionFormArgs value, $Res Function(_TransactionFormArgs) _then) = __$TransactionFormArgsCopyWithImpl;
@override @useResult
$Res call({
 FormMode mode, String? id, TxnType initialType, String? duplicateOf, String? ruleId, bool repeat
});




}
/// @nodoc
class __$TransactionFormArgsCopyWithImpl<$Res>
    implements _$TransactionFormArgsCopyWith<$Res> {
  __$TransactionFormArgsCopyWithImpl(this._self, this._then);

  final _TransactionFormArgs _self;
  final $Res Function(_TransactionFormArgs) _then;

/// Create a copy of TransactionFormArgs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? id = freezed,Object? initialType = null,Object? duplicateOf = freezed,Object? ruleId = freezed,Object? repeat = null,}) {
  return _then(_TransactionFormArgs(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as FormMode,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,initialType: null == initialType ? _self.initialType : initialType // ignore: cast_nullable_to_non_nullable
as TxnType,duplicateOf: freezed == duplicateOf ? _self.duplicateOf : duplicateOf // ignore: cast_nullable_to_non_nullable
as String?,ruleId: freezed == ruleId ? _self.ruleId : ruleId // ignore: cast_nullable_to_non_nullable
as String?,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RepeatState {

 bool get enabled; Frequency get frequency;/// Local date; null = no end.
 DateTime? get endDate;
/// Create a copy of RepeatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepeatStateCopyWith<RepeatState> get copyWith => _$RepeatStateCopyWithImpl<RepeatState>(this as RepeatState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RepeatState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepeatState&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.frequency, _this.frequency) || other.frequency == _this.frequency)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate));
}


@override
int get hashCode {
  final _this = this as RepeatState;
  return Object.hash(runtimeType,_this.enabled,_this.frequency,_this.endDate);
}

@override
String toString() {
  final _this = this as RepeatState;
  return 'RepeatState(enabled: ${_this.enabled}, frequency: ${_this.frequency}, endDate: ${_this.endDate})';
}


}

/// @nodoc
abstract mixin class $RepeatStateCopyWith<$Res>  {
  factory $RepeatStateCopyWith(RepeatState value, $Res Function(RepeatState) _then) = _$RepeatStateCopyWithImpl;
@useResult
$Res call({
 bool enabled, Frequency frequency, DateTime? endDate
});




}
/// @nodoc
class _$RepeatStateCopyWithImpl<$Res>
    implements $RepeatStateCopyWith<$Res> {
  _$RepeatStateCopyWithImpl(this._self, this._then);

  final RepeatState _self;
  final $Res Function(RepeatState) _then;

/// Create a copy of RepeatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? frequency = null,Object? endDate = freezed,}) {
  return _then(RepeatState(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as Frequency,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepeatState].
extension RepeatStatePatterns on RepeatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepeatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepeatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepeatState value)  $default,){
final _that = this;
switch (_that) {
case _RepeatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepeatState value)?  $default,){
final _that = this;
switch (_that) {
case _RepeatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  Frequency frequency,  DateTime? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepeatState() when $default != null:
return $default(_that.enabled,_that.frequency,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  Frequency frequency,  DateTime? endDate)  $default,) {final _that = this;
switch (_that) {
case _RepeatState():
return $default(_that.enabled,_that.frequency,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  Frequency frequency,  DateTime? endDate)?  $default,) {final _that = this;
switch (_that) {
case _RepeatState() when $default != null:
return $default(_that.enabled,_that.frequency,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _RepeatState extends RepeatState {
  const _RepeatState({this.enabled = false, this.frequency = Frequency.monthly, this.endDate}): super._();
  

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  Frequency frequency;
/// Local date; null = no end.
@override final  DateTime? endDate;

/// Create a copy of RepeatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepeatStateCopyWith<_RepeatState> get copyWith => __$RepeatStateCopyWithImpl<_RepeatState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepeatState&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,frequency,endDate);
}

@override
String toString() {
    return 'RepeatState(enabled: $enabled, frequency: $frequency, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$RepeatStateCopyWith<$Res> implements $RepeatStateCopyWith<$Res> {
  factory _$RepeatStateCopyWith(_RepeatState value, $Res Function(_RepeatState) _then) = __$RepeatStateCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, Frequency frequency, DateTime? endDate
});




}
/// @nodoc
class __$RepeatStateCopyWithImpl<$Res>
    implements _$RepeatStateCopyWith<$Res> {
  __$RepeatStateCopyWithImpl(this._self, this._then);

  final _RepeatState _self;
  final $Res Function(_RepeatState) _then;

/// Create a copy of RepeatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? frequency = null,Object? endDate = freezed,}) {
  return _then(_RepeatState(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as Frequency,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$TransactionFormState {

 FormStatus get status; TransactionDraft get draft;/// Raw keypad input, e.g. `120+35.5`.
 String get expression; Map<TxnField, TxnError> get errors;/// True after the first save attempt; errors then update live.
 bool get showErrors; List<Category> get expenseCategories; List<Category> get incomeCategories;/// Pickable accounts, plus the edited entry's archived ones.
 List<Account> get accounts; List<String> get noteSuggestions; bool get keypadOpen; bool get isDirty; bool get saving; bool get saveFailed; bool get receiptFailed;/// The entry as loaded (edit mode), for Undo after an edit.
 Transaction? get original; RepeatState get repeat;/// Edit of an entry that belongs to a rule: Repeat is hidden and the
/// edit changes only this entry (US3 s13).
 bool get linkedToRule;/// The rule as loaded (rule-edit mode), for Undo after a rule edit.
 RecurringRule? get originalRule;
/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionFormStateCopyWith<TransactionFormState> get copyWith => _$TransactionFormStateCopyWithImpl<TransactionFormState>(this as TransactionFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransactionFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionFormState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.draft, _this.draft) || other.draft == _this.draft)&&(identical(other.expression, _this.expression) || other.expression == _this.expression)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&(identical(other.showErrors, _this.showErrors) || other.showErrors == _this.showErrors)&&const DeepCollectionEquality().equals(other.expenseCategories, _this.expenseCategories)&&const DeepCollectionEquality().equals(other.incomeCategories, _this.incomeCategories)&&const DeepCollectionEquality().equals(other.accounts, _this.accounts)&&const DeepCollectionEquality().equals(other.noteSuggestions, _this.noteSuggestions)&&(identical(other.keypadOpen, _this.keypadOpen) || other.keypadOpen == _this.keypadOpen)&&(identical(other.isDirty, _this.isDirty) || other.isDirty == _this.isDirty)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.saveFailed, _this.saveFailed) || other.saveFailed == _this.saveFailed)&&(identical(other.receiptFailed, _this.receiptFailed) || other.receiptFailed == _this.receiptFailed)&&(identical(other.original, _this.original) || other.original == _this.original)&&(identical(other.repeat, _this.repeat) || other.repeat == _this.repeat)&&(identical(other.linkedToRule, _this.linkedToRule) || other.linkedToRule == _this.linkedToRule)&&(identical(other.originalRule, _this.originalRule) || other.originalRule == _this.originalRule));
}


@override
int get hashCode {
  final _this = this as TransactionFormState;
  return Object.hash(runtimeType,_this.status,_this.draft,_this.expression,const DeepCollectionEquality().hash(_this.errors),_this.showErrors,const DeepCollectionEquality().hash(_this.expenseCategories),const DeepCollectionEquality().hash(_this.incomeCategories),const DeepCollectionEquality().hash(_this.accounts),const DeepCollectionEquality().hash(_this.noteSuggestions),_this.keypadOpen,_this.isDirty,_this.saving,_this.saveFailed,_this.receiptFailed,_this.original,_this.repeat,_this.linkedToRule,_this.originalRule);
}

@override
String toString() {
  final _this = this as TransactionFormState;
  return 'TransactionFormState(status: ${_this.status}, draft: ${_this.draft}, expression: ${_this.expression}, errors: ${_this.errors}, showErrors: ${_this.showErrors}, expenseCategories: ${_this.expenseCategories}, incomeCategories: ${_this.incomeCategories}, accounts: ${_this.accounts}, noteSuggestions: ${_this.noteSuggestions}, keypadOpen: ${_this.keypadOpen}, isDirty: ${_this.isDirty}, saving: ${_this.saving}, saveFailed: ${_this.saveFailed}, receiptFailed: ${_this.receiptFailed}, original: ${_this.original}, repeat: ${_this.repeat}, linkedToRule: ${_this.linkedToRule}, originalRule: ${_this.originalRule})';
}


}

/// @nodoc
abstract mixin class $TransactionFormStateCopyWith<$Res>  {
  factory $TransactionFormStateCopyWith(TransactionFormState value, $Res Function(TransactionFormState) _then) = _$TransactionFormStateCopyWithImpl;
@useResult
$Res call({
 FormStatus status, TransactionDraft draft, String expression, Map<TxnField, TxnError> errors, bool showErrors, List<Category> expenseCategories, List<Category> incomeCategories, List<Account> accounts, List<String> noteSuggestions, bool keypadOpen, bool isDirty, bool saving, bool saveFailed, bool receiptFailed, Transaction? original, RepeatState repeat, bool linkedToRule, RecurringRule? originalRule
});


$TransactionDraftCopyWith<$Res> get draft;$TransactionCopyWith<$Res>? get original;$RepeatStateCopyWith<$Res> get repeat;$RecurringRuleCopyWith<$Res>? get originalRule;

}
/// @nodoc
class _$TransactionFormStateCopyWithImpl<$Res>
    implements $TransactionFormStateCopyWith<$Res> {
  _$TransactionFormStateCopyWithImpl(this._self, this._then);

  final TransactionFormState _self;
  final $Res Function(TransactionFormState) _then;

/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? draft = null,Object? expression = null,Object? errors = null,Object? showErrors = null,Object? expenseCategories = null,Object? incomeCategories = null,Object? accounts = null,Object? noteSuggestions = null,Object? keypadOpen = null,Object? isDirty = null,Object? saving = null,Object? saveFailed = null,Object? receiptFailed = null,Object? original = freezed,Object? repeat = null,Object? linkedToRule = null,Object? originalRule = freezed,}) {
  return _then(TransactionFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormStatus,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as TransactionDraft,expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as String,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<TxnField, TxnError>,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,expenseCategories: null == expenseCategories ? _self.expenseCategories : expenseCategories // ignore: cast_nullable_to_non_nullable
as List<Category>,incomeCategories: null == incomeCategories ? _self.incomeCategories : incomeCategories // ignore: cast_nullable_to_non_nullable
as List<Category>,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<Account>,noteSuggestions: null == noteSuggestions ? _self.noteSuggestions : noteSuggestions // ignore: cast_nullable_to_non_nullable
as List<String>,keypadOpen: null == keypadOpen ? _self.keypadOpen : keypadOpen // ignore: cast_nullable_to_non_nullable
as bool,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,receiptFailed: null == receiptFailed ? _self.receiptFailed : receiptFailed // ignore: cast_nullable_to_non_nullable
as bool,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Transaction?,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as RepeatState,linkedToRule: null == linkedToRule ? _self.linkedToRule : linkedToRule // ignore: cast_nullable_to_non_nullable
as bool,originalRule: freezed == originalRule ? _self.originalRule : originalRule // ignore: cast_nullable_to_non_nullable
as RecurringRule?,
  ));
}
/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionDraftCopyWith<$Res> get draft {
  
  return $TransactionDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $TransactionCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepeatStateCopyWith<$Res> get repeat {
  
  return $RepeatStateCopyWith<$Res>(_self.repeat, (value) {
    return _then(_self.copyWith(repeat: value));
  });
}/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<$Res>? get originalRule {
    if (_self.originalRule == null) {
    return null;
  }

  return $RecurringRuleCopyWith<$Res>(_self.originalRule!, (value) {
    return _then(_self.copyWith(originalRule: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransactionFormState].
extension TransactionFormStatePatterns on TransactionFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionFormState value)  $default,){
final _that = this;
switch (_that) {
case _TransactionFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionFormState value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FormStatus status,  TransactionDraft draft,  String expression,  Map<TxnField, TxnError> errors,  bool showErrors,  List<Category> expenseCategories,  List<Category> incomeCategories,  List<Account> accounts,  List<String> noteSuggestions,  bool keypadOpen,  bool isDirty,  bool saving,  bool saveFailed,  bool receiptFailed,  Transaction? original,  RepeatState repeat,  bool linkedToRule,  RecurringRule? originalRule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionFormState() when $default != null:
return $default(_that.status,_that.draft,_that.expression,_that.errors,_that.showErrors,_that.expenseCategories,_that.incomeCategories,_that.accounts,_that.noteSuggestions,_that.keypadOpen,_that.isDirty,_that.saving,_that.saveFailed,_that.receiptFailed,_that.original,_that.repeat,_that.linkedToRule,_that.originalRule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FormStatus status,  TransactionDraft draft,  String expression,  Map<TxnField, TxnError> errors,  bool showErrors,  List<Category> expenseCategories,  List<Category> incomeCategories,  List<Account> accounts,  List<String> noteSuggestions,  bool keypadOpen,  bool isDirty,  bool saving,  bool saveFailed,  bool receiptFailed,  Transaction? original,  RepeatState repeat,  bool linkedToRule,  RecurringRule? originalRule)  $default,) {final _that = this;
switch (_that) {
case _TransactionFormState():
return $default(_that.status,_that.draft,_that.expression,_that.errors,_that.showErrors,_that.expenseCategories,_that.incomeCategories,_that.accounts,_that.noteSuggestions,_that.keypadOpen,_that.isDirty,_that.saving,_that.saveFailed,_that.receiptFailed,_that.original,_that.repeat,_that.linkedToRule,_that.originalRule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FormStatus status,  TransactionDraft draft,  String expression,  Map<TxnField, TxnError> errors,  bool showErrors,  List<Category> expenseCategories,  List<Category> incomeCategories,  List<Account> accounts,  List<String> noteSuggestions,  bool keypadOpen,  bool isDirty,  bool saving,  bool saveFailed,  bool receiptFailed,  Transaction? original,  RepeatState repeat,  bool linkedToRule,  RecurringRule? originalRule)?  $default,) {final _that = this;
switch (_that) {
case _TransactionFormState() when $default != null:
return $default(_that.status,_that.draft,_that.expression,_that.errors,_that.showErrors,_that.expenseCategories,_that.incomeCategories,_that.accounts,_that.noteSuggestions,_that.keypadOpen,_that.isDirty,_that.saving,_that.saveFailed,_that.receiptFailed,_that.original,_that.repeat,_that.linkedToRule,_that.originalRule);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionFormState extends TransactionFormState {
  const _TransactionFormState({required this.status, required this.draft, this.expression = '',  Map<TxnField, TxnError> errors = const <TxnField, TxnError>{}, this.showErrors = false,  List<Category> expenseCategories = const <Category>[],  List<Category> incomeCategories = const <Category>[],  List<Account> accounts = const <Account>[],  List<String> noteSuggestions = const <String>[], this.keypadOpen = true, this.isDirty = false, this.saving = false, this.saveFailed = false, this.receiptFailed = false, this.original, this.repeat = const RepeatState(), this.linkedToRule = false, this.originalRule}): _errors = errors,_expenseCategories = expenseCategories,_incomeCategories = incomeCategories,_accounts = accounts,_noteSuggestions = noteSuggestions,super._();
  

@override final  FormStatus status;
@override final  TransactionDraft draft;
/// Raw keypad input, e.g. `120+35.5`.
@override@JsonKey() final  String expression;
 final  Map<TxnField, TxnError> _errors;
@override@JsonKey() Map<TxnField, TxnError> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

/// True after the first save attempt; errors then update live.
@override@JsonKey() final  bool showErrors;
 final  List<Category> _expenseCategories;
@override@JsonKey() List<Category> get expenseCategories {
  if (_expenseCategories is EqualUnmodifiableListView) return _expenseCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenseCategories);
}

 final  List<Category> _incomeCategories;
@override@JsonKey() List<Category> get incomeCategories {
  if (_incomeCategories is EqualUnmodifiableListView) return _incomeCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_incomeCategories);
}

/// Pickable accounts, plus the edited entry's archived ones.
 final  List<Account> _accounts;
/// Pickable accounts, plus the edited entry's archived ones.
@override@JsonKey() List<Account> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

 final  List<String> _noteSuggestions;
@override@JsonKey() List<String> get noteSuggestions {
  if (_noteSuggestions is EqualUnmodifiableListView) return _noteSuggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_noteSuggestions);
}

@override@JsonKey() final  bool keypadOpen;
@override@JsonKey() final  bool isDirty;
@override@JsonKey() final  bool saving;
@override@JsonKey() final  bool saveFailed;
@override@JsonKey() final  bool receiptFailed;
/// The entry as loaded (edit mode), for Undo after an edit.
@override final  Transaction? original;
@override@JsonKey() final  RepeatState repeat;
/// Edit of an entry that belongs to a rule: Repeat is hidden and the
/// edit changes only this entry (US3 s13).
@override@JsonKey() final  bool linkedToRule;
/// The rule as loaded (rule-edit mode), for Undo after a rule edit.
@override final  RecurringRule? originalRule;

/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionFormStateCopyWith<_TransactionFormState> get copyWith => __$TransactionFormStateCopyWithImpl<_TransactionFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionFormState&&(identical(other.status, status) || other.status == status)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.expression, expression) || other.expression == expression)&&const DeepCollectionEquality().equals(other.errors, _errors)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors)&&const DeepCollectionEquality().equals(other.expenseCategories, _expenseCategories)&&const DeepCollectionEquality().equals(other.incomeCategories, _incomeCategories)&&const DeepCollectionEquality().equals(other.accounts, _accounts)&&const DeepCollectionEquality().equals(other.noteSuggestions, _noteSuggestions)&&(identical(other.keypadOpen, keypadOpen) || other.keypadOpen == keypadOpen)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.saveFailed, saveFailed) || other.saveFailed == saveFailed)&&(identical(other.receiptFailed, receiptFailed) || other.receiptFailed == receiptFailed)&&(identical(other.original, original) || other.original == original)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.linkedToRule, linkedToRule) || other.linkedToRule == linkedToRule)&&(identical(other.originalRule, originalRule) || other.originalRule == originalRule));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,draft,expression,const DeepCollectionEquality().hash(_errors),showErrors,const DeepCollectionEquality().hash(_expenseCategories),const DeepCollectionEquality().hash(_incomeCategories),const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_noteSuggestions),keypadOpen,isDirty,saving,saveFailed,receiptFailed,original,repeat,linkedToRule,originalRule);
}

@override
String toString() {
    return 'TransactionFormState(status: $status, draft: $draft, expression: $expression, errors: $errors, showErrors: $showErrors, expenseCategories: $expenseCategories, incomeCategories: $incomeCategories, accounts: $accounts, noteSuggestions: $noteSuggestions, keypadOpen: $keypadOpen, isDirty: $isDirty, saving: $saving, saveFailed: $saveFailed, receiptFailed: $receiptFailed, original: $original, repeat: $repeat, linkedToRule: $linkedToRule, originalRule: $originalRule)';
}


}

/// @nodoc
abstract mixin class _$TransactionFormStateCopyWith<$Res> implements $TransactionFormStateCopyWith<$Res> {
  factory _$TransactionFormStateCopyWith(_TransactionFormState value, $Res Function(_TransactionFormState) _then) = __$TransactionFormStateCopyWithImpl;
@override @useResult
$Res call({
 FormStatus status, TransactionDraft draft, String expression, Map<TxnField, TxnError> errors, bool showErrors, List<Category> expenseCategories, List<Category> incomeCategories, List<Account> accounts, List<String> noteSuggestions, bool keypadOpen, bool isDirty, bool saving, bool saveFailed, bool receiptFailed, Transaction? original, RepeatState repeat, bool linkedToRule, RecurringRule? originalRule
});


@override $TransactionDraftCopyWith<$Res> get draft;@override $TransactionCopyWith<$Res>? get original;@override $RepeatStateCopyWith<$Res> get repeat;@override $RecurringRuleCopyWith<$Res>? get originalRule;

}
/// @nodoc
class __$TransactionFormStateCopyWithImpl<$Res>
    implements _$TransactionFormStateCopyWith<$Res> {
  __$TransactionFormStateCopyWithImpl(this._self, this._then);

  final _TransactionFormState _self;
  final $Res Function(_TransactionFormState) _then;

/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? draft = null,Object? expression = null,Object? errors = null,Object? showErrors = null,Object? expenseCategories = null,Object? incomeCategories = null,Object? accounts = null,Object? noteSuggestions = null,Object? keypadOpen = null,Object? isDirty = null,Object? saving = null,Object? saveFailed = null,Object? receiptFailed = null,Object? original = freezed,Object? repeat = null,Object? linkedToRule = null,Object? originalRule = freezed,}) {
  return _then(_TransactionFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormStatus,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as TransactionDraft,expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as String,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<TxnField, TxnError>,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,expenseCategories: null == expenseCategories ? _self._expenseCategories : expenseCategories // ignore: cast_nullable_to_non_nullable
as List<Category>,incomeCategories: null == incomeCategories ? _self._incomeCategories : incomeCategories // ignore: cast_nullable_to_non_nullable
as List<Category>,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<Account>,noteSuggestions: null == noteSuggestions ? _self._noteSuggestions : noteSuggestions // ignore: cast_nullable_to_non_nullable
as List<String>,keypadOpen: null == keypadOpen ? _self.keypadOpen : keypadOpen // ignore: cast_nullable_to_non_nullable
as bool,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,receiptFailed: null == receiptFailed ? _self.receiptFailed : receiptFailed // ignore: cast_nullable_to_non_nullable
as bool,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Transaction?,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as RepeatState,linkedToRule: null == linkedToRule ? _self.linkedToRule : linkedToRule // ignore: cast_nullable_to_non_nullable
as bool,originalRule: freezed == originalRule ? _self.originalRule : originalRule // ignore: cast_nullable_to_non_nullable
as RecurringRule?,
  ));
}

/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionDraftCopyWith<$Res> get draft {
  
  return $TransactionDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $TransactionCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepeatStateCopyWith<$Res> get repeat {
  
  return $RepeatStateCopyWith<$Res>(_self.repeat, (value) {
    return _then(_self.copyWith(repeat: value));
  });
}/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<$Res>? get originalRule {
    if (_self.originalRule == null) {
    return null;
  }

  return $RecurringRuleCopyWith<$Res>(_self.originalRule!, (value) {
    return _then(_self.copyWith(originalRule: value));
  });
}
}

// dart format on
