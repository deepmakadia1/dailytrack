// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurringRule {

 String get id; TxnType get type; int get amountMinor; String get accountId; PaymentMode get paymentMode; Frequency get frequency; int get interval;/// UTC of the first occurrence; the schedule is computed from it.
 DateTime get anchorAt;/// UTC of the next occurrence not yet generated.
 DateTime get nextRunAt;/// False when paused or ended.
 bool get isActive; DateTime get createdAt; DateTime get updatedAt; String? get toAccountId; String? get categoryId; String? get note;/// UTC, inclusive. Null = no end.
 DateTime? get endAt; DateTime? get deletedAt;
/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<RecurringRule> get copyWith => _$RecurringRuleCopyWithImpl<RecurringRule>(this as RecurringRule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecurringRule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringRule&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.paymentMode, _this.paymentMode) || other.paymentMode == _this.paymentMode)&&(identical(other.frequency, _this.frequency) || other.frequency == _this.frequency)&&(identical(other.interval, _this.interval) || other.interval == _this.interval)&&(identical(other.anchorAt, _this.anchorAt) || other.anchorAt == _this.anchorAt)&&(identical(other.nextRunAt, _this.nextRunAt) || other.nextRunAt == _this.nextRunAt)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.toAccountId, _this.toAccountId) || other.toAccountId == _this.toAccountId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as RecurringRule;
  return Object.hash(runtimeType,_this.id,_this.type,_this.amountMinor,_this.accountId,_this.paymentMode,_this.frequency,_this.interval,_this.anchorAt,_this.nextRunAt,_this.isActive,_this.createdAt,_this.updatedAt,_this.toAccountId,_this.categoryId,_this.note,_this.endAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as RecurringRule;
  return 'RecurringRule(id: ${_this.id}, type: ${_this.type}, amountMinor: ${_this.amountMinor}, accountId: ${_this.accountId}, paymentMode: ${_this.paymentMode}, frequency: ${_this.frequency}, interval: ${_this.interval}, anchorAt: ${_this.anchorAt}, nextRunAt: ${_this.nextRunAt}, isActive: ${_this.isActive}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, toAccountId: ${_this.toAccountId}, categoryId: ${_this.categoryId}, note: ${_this.note}, endAt: ${_this.endAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $RecurringRuleCopyWith<$Res>  {
  factory $RecurringRuleCopyWith(RecurringRule value, $Res Function(RecurringRule) _then) = _$RecurringRuleCopyWithImpl;
@useResult
$Res call({
 String id, TxnType type, int amountMinor, String accountId, PaymentMode paymentMode, Frequency frequency, int interval, DateTime anchorAt, DateTime nextRunAt, bool isActive, DateTime createdAt, DateTime updatedAt, String? toAccountId, String? categoryId, String? note, DateTime? endAt, DateTime? deletedAt
});




}
/// @nodoc
class _$RecurringRuleCopyWithImpl<$Res>
    implements $RecurringRuleCopyWith<$Res> {
  _$RecurringRuleCopyWithImpl(this._self, this._then);

  final RecurringRule _self;
  final $Res Function(RecurringRule) _then;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amountMinor = null,Object? accountId = null,Object? paymentMode = null,Object? frequency = null,Object? interval = null,Object? anchorAt = null,Object? nextRunAt = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? toAccountId = freezed,Object? categoryId = freezed,Object? note = freezed,Object? endAt = freezed,Object? deletedAt = freezed,}) {
  return _then(RecurringRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxnType,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as PaymentMode,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as Frequency,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,anchorAt: null == anchorAt ? _self.anchorAt : anchorAt // ignore: cast_nullable_to_non_nullable
as DateTime,nextRunAt: null == nextRunAt ? _self.nextRunAt : nextRunAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringRule].
extension RecurringRulePatterns on RecurringRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringRule value)  $default,){
final _that = this;
switch (_that) {
case _RecurringRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringRule value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TxnType type,  int amountMinor,  String accountId,  PaymentMode paymentMode,  Frequency frequency,  int interval,  DateTime anchorAt,  DateTime nextRunAt,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? toAccountId,  String? categoryId,  String? note,  DateTime? endAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
return $default(_that.id,_that.type,_that.amountMinor,_that.accountId,_that.paymentMode,_that.frequency,_that.interval,_that.anchorAt,_that.nextRunAt,_that.isActive,_that.createdAt,_that.updatedAt,_that.toAccountId,_that.categoryId,_that.note,_that.endAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TxnType type,  int amountMinor,  String accountId,  PaymentMode paymentMode,  Frequency frequency,  int interval,  DateTime anchorAt,  DateTime nextRunAt,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? toAccountId,  String? categoryId,  String? note,  DateTime? endAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _RecurringRule():
return $default(_that.id,_that.type,_that.amountMinor,_that.accountId,_that.paymentMode,_that.frequency,_that.interval,_that.anchorAt,_that.nextRunAt,_that.isActive,_that.createdAt,_that.updatedAt,_that.toAccountId,_that.categoryId,_that.note,_that.endAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TxnType type,  int amountMinor,  String accountId,  PaymentMode paymentMode,  Frequency frequency,  int interval,  DateTime anchorAt,  DateTime nextRunAt,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? toAccountId,  String? categoryId,  String? note,  DateTime? endAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecurringRule() when $default != null:
return $default(_that.id,_that.type,_that.amountMinor,_that.accountId,_that.paymentMode,_that.frequency,_that.interval,_that.anchorAt,_that.nextRunAt,_that.isActive,_that.createdAt,_that.updatedAt,_that.toAccountId,_that.categoryId,_that.note,_that.endAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RecurringRule extends RecurringRule {
  const _RecurringRule({required this.id, required this.type, required this.amountMinor, required this.accountId, required this.paymentMode, required this.frequency, required this.interval, required this.anchorAt, required this.nextRunAt, required this.isActive, required this.createdAt, required this.updatedAt, this.toAccountId, this.categoryId, this.note, this.endAt, this.deletedAt}): super._();
  

@override final  String id;
@override final  TxnType type;
@override final  int amountMinor;
@override final  String accountId;
@override final  PaymentMode paymentMode;
@override final  Frequency frequency;
@override final  int interval;
/// UTC of the first occurrence; the schedule is computed from it.
@override final  DateTime anchorAt;
/// UTC of the next occurrence not yet generated.
@override final  DateTime nextRunAt;
/// False when paused or ended.
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? toAccountId;
@override final  String? categoryId;
@override final  String? note;
/// UTC, inclusive. Null = no end.
@override final  DateTime? endAt;
@override final  DateTime? deletedAt;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringRuleCopyWith<_RecurringRule> get copyWith => __$RecurringRuleCopyWithImpl<_RecurringRule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringRule&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.anchorAt, anchorAt) || other.anchorAt == anchorAt)&&(identical(other.nextRunAt, nextRunAt) || other.nextRunAt == nextRunAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.toAccountId, toAccountId) || other.toAccountId == toAccountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,type,amountMinor,accountId,paymentMode,frequency,interval,anchorAt,nextRunAt,isActive,createdAt,updatedAt,toAccountId,categoryId,note,endAt,deletedAt);
}

@override
String toString() {
    return 'RecurringRule(id: $id, type: $type, amountMinor: $amountMinor, accountId: $accountId, paymentMode: $paymentMode, frequency: $frequency, interval: $interval, anchorAt: $anchorAt, nextRunAt: $nextRunAt, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, toAccountId: $toAccountId, categoryId: $categoryId, note: $note, endAt: $endAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$RecurringRuleCopyWith<$Res> implements $RecurringRuleCopyWith<$Res> {
  factory _$RecurringRuleCopyWith(_RecurringRule value, $Res Function(_RecurringRule) _then) = __$RecurringRuleCopyWithImpl;
@override @useResult
$Res call({
 String id, TxnType type, int amountMinor, String accountId, PaymentMode paymentMode, Frequency frequency, int interval, DateTime anchorAt, DateTime nextRunAt, bool isActive, DateTime createdAt, DateTime updatedAt, String? toAccountId, String? categoryId, String? note, DateTime? endAt, DateTime? deletedAt
});




}
/// @nodoc
class __$RecurringRuleCopyWithImpl<$Res>
    implements _$RecurringRuleCopyWith<$Res> {
  __$RecurringRuleCopyWithImpl(this._self, this._then);

  final _RecurringRule _self;
  final $Res Function(_RecurringRule) _then;

/// Create a copy of RecurringRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amountMinor = null,Object? accountId = null,Object? paymentMode = null,Object? frequency = null,Object? interval = null,Object? anchorAt = null,Object? nextRunAt = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? toAccountId = freezed,Object? categoryId = freezed,Object? note = freezed,Object? endAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_RecurringRule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxnType,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as PaymentMode,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as Frequency,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,anchorAt: null == anchorAt ? _self.anchorAt : anchorAt // ignore: cast_nullable_to_non_nullable
as DateTime,nextRunAt: null == nextRunAt ? _self.nextRunAt : nextRunAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$RecurringRuleView {

 RecurringRule get rule; Account get account; Account? get toAccount; Category? get category;
/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringRuleViewCopyWith<RecurringRuleView> get copyWith => _$RecurringRuleViewCopyWithImpl<RecurringRuleView>(this as RecurringRuleView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecurringRuleView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringRuleView&&(identical(other.rule, _this.rule) || other.rule == _this.rule)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.toAccount, _this.toAccount) || other.toAccount == _this.toAccount)&&(identical(other.category, _this.category) || other.category == _this.category));
}


@override
int get hashCode {
  final _this = this as RecurringRuleView;
  return Object.hash(runtimeType,_this.rule,_this.account,_this.toAccount,_this.category);
}

@override
String toString() {
  final _this = this as RecurringRuleView;
  return 'RecurringRuleView(rule: ${_this.rule}, account: ${_this.account}, toAccount: ${_this.toAccount}, category: ${_this.category})';
}


}

/// @nodoc
abstract mixin class $RecurringRuleViewCopyWith<$Res>  {
  factory $RecurringRuleViewCopyWith(RecurringRuleView value, $Res Function(RecurringRuleView) _then) = _$RecurringRuleViewCopyWithImpl;
@useResult
$Res call({
 RecurringRule rule, Account account, Account? toAccount, Category? category
});


$RecurringRuleCopyWith<$Res> get rule;$AccountCopyWith<$Res> get account;$AccountCopyWith<$Res>? get toAccount;$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$RecurringRuleViewCopyWithImpl<$Res>
    implements $RecurringRuleViewCopyWith<$Res> {
  _$RecurringRuleViewCopyWithImpl(this._self, this._then);

  final RecurringRuleView _self;
  final $Res Function(RecurringRuleView) _then;

/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rule = null,Object? account = null,Object? toAccount = freezed,Object? category = freezed,}) {
  return _then(RecurringRuleView(
rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as RecurringRule,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,toAccount: freezed == toAccount ? _self.toAccount : toAccount // ignore: cast_nullable_to_non_nullable
as Account?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}
/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<$Res> get rule {
  
  return $RecurringRuleCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {
  
  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res>? get toAccount {
    if (_self.toAccount == null) {
    return null;
  }

  return $AccountCopyWith<$Res>(_self.toAccount!, (value) {
    return _then(_self.copyWith(toAccount: value));
  });
}/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecurringRuleView].
extension RecurringRuleViewPatterns on RecurringRuleView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringRuleView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringRuleView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringRuleView value)  $default,){
final _that = this;
switch (_that) {
case _RecurringRuleView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringRuleView value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringRuleView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecurringRule rule,  Account account,  Account? toAccount,  Category? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringRuleView() when $default != null:
return $default(_that.rule,_that.account,_that.toAccount,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecurringRule rule,  Account account,  Account? toAccount,  Category? category)  $default,) {final _that = this;
switch (_that) {
case _RecurringRuleView():
return $default(_that.rule,_that.account,_that.toAccount,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecurringRule rule,  Account account,  Account? toAccount,  Category? category)?  $default,) {final _that = this;
switch (_that) {
case _RecurringRuleView() when $default != null:
return $default(_that.rule,_that.account,_that.toAccount,_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _RecurringRuleView extends RecurringRuleView {
  const _RecurringRuleView({required this.rule, required this.account, this.toAccount, this.category}): super._();
  

@override final  RecurringRule rule;
@override final  Account account;
@override final  Account? toAccount;
@override final  Category? category;

/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringRuleViewCopyWith<_RecurringRuleView> get copyWith => __$RecurringRuleViewCopyWithImpl<_RecurringRuleView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringRuleView&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.account, account) || other.account == account)&&(identical(other.toAccount, toAccount) || other.toAccount == toAccount)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode {
    return Object.hash(runtimeType,rule,account,toAccount,category);
}

@override
String toString() {
    return 'RecurringRuleView(rule: $rule, account: $account, toAccount: $toAccount, category: $category)';
}


}

/// @nodoc
abstract mixin class _$RecurringRuleViewCopyWith<$Res> implements $RecurringRuleViewCopyWith<$Res> {
  factory _$RecurringRuleViewCopyWith(_RecurringRuleView value, $Res Function(_RecurringRuleView) _then) = __$RecurringRuleViewCopyWithImpl;
@override @useResult
$Res call({
 RecurringRule rule, Account account, Account? toAccount, Category? category
});


@override $RecurringRuleCopyWith<$Res> get rule;@override $AccountCopyWith<$Res> get account;@override $AccountCopyWith<$Res>? get toAccount;@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$RecurringRuleViewCopyWithImpl<$Res>
    implements _$RecurringRuleViewCopyWith<$Res> {
  __$RecurringRuleViewCopyWithImpl(this._self, this._then);

  final _RecurringRuleView _self;
  final $Res Function(_RecurringRuleView) _then;

/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rule = null,Object? account = null,Object? toAccount = freezed,Object? category = freezed,}) {
  return _then(_RecurringRuleView(
rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as RecurringRule,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,toAccount: freezed == toAccount ? _self.toAccount : toAccount // ignore: cast_nullable_to_non_nullable
as Account?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}

/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringRuleCopyWith<$Res> get rule {
  
  return $RecurringRuleCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {
  
  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res>? get toAccount {
    if (_self.toAccount == null) {
    return null;
  }

  return $AccountCopyWith<$Res>(_self.toAccount!, (value) {
    return _then(_self.copyWith(toAccount: value));
  });
}/// Create a copy of RecurringRuleView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
