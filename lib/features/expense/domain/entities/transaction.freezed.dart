// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Transaction {

 String get id; TxnType get type;/// Always positive, in minor units (paise). The sign comes from [type].
 int get amountMinor; String get accountId; PaymentMode get paymentMode;/// UTC.
 DateTime get occurredAt; DateTime get createdAt; DateTime get updatedAt; String? get toAccountId; String? get categoryId; String? get note;/// Relative path `receipts/<uuid>.jpg`.
 String? get receiptPath;/// The rule this entry came from, or is the first occurrence of.
 String? get recurringRuleId; DateTime? get deletedAt;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Transaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.paymentMode, _this.paymentMode) || other.paymentMode == _this.paymentMode)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.toAccountId, _this.toAccountId) || other.toAccountId == _this.toAccountId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.receiptPath, _this.receiptPath) || other.receiptPath == _this.receiptPath)&&(identical(other.recurringRuleId, _this.recurringRuleId) || other.recurringRuleId == _this.recurringRuleId)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as Transaction;
  return Object.hash(runtimeType,_this.id,_this.type,_this.amountMinor,_this.accountId,_this.paymentMode,_this.occurredAt,_this.createdAt,_this.updatedAt,_this.toAccountId,_this.categoryId,_this.note,_this.receiptPath,_this.recurringRuleId,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Transaction;
  return 'Transaction(id: ${_this.id}, type: ${_this.type}, amountMinor: ${_this.amountMinor}, accountId: ${_this.accountId}, paymentMode: ${_this.paymentMode}, occurredAt: ${_this.occurredAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, toAccountId: ${_this.toAccountId}, categoryId: ${_this.categoryId}, note: ${_this.note}, receiptPath: ${_this.receiptPath}, recurringRuleId: ${_this.recurringRuleId}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id, TxnType type, int amountMinor, String accountId, PaymentMode paymentMode, DateTime occurredAt, DateTime createdAt, DateTime updatedAt, String? toAccountId, String? categoryId, String? note, String? receiptPath, String? recurringRuleId, DateTime? deletedAt
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amountMinor = null,Object? accountId = null,Object? paymentMode = null,Object? occurredAt = null,Object? createdAt = null,Object? updatedAt = null,Object? toAccountId = freezed,Object? categoryId = freezed,Object? note = freezed,Object? receiptPath = freezed,Object? recurringRuleId = freezed,Object? deletedAt = freezed,}) {
  return _then(Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxnType,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as PaymentMode,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,receiptPath: freezed == receiptPath ? _self.receiptPath : receiptPath // ignore: cast_nullable_to_non_nullable
as String?,recurringRuleId: freezed == recurringRuleId ? _self.recurringRuleId : recurringRuleId // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TxnType type,  int amountMinor,  String accountId,  PaymentMode paymentMode,  DateTime occurredAt,  DateTime createdAt,  DateTime updatedAt,  String? toAccountId,  String? categoryId,  String? note,  String? receiptPath,  String? recurringRuleId,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.type,_that.amountMinor,_that.accountId,_that.paymentMode,_that.occurredAt,_that.createdAt,_that.updatedAt,_that.toAccountId,_that.categoryId,_that.note,_that.receiptPath,_that.recurringRuleId,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TxnType type,  int amountMinor,  String accountId,  PaymentMode paymentMode,  DateTime occurredAt,  DateTime createdAt,  DateTime updatedAt,  String? toAccountId,  String? categoryId,  String? note,  String? receiptPath,  String? recurringRuleId,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.type,_that.amountMinor,_that.accountId,_that.paymentMode,_that.occurredAt,_that.createdAt,_that.updatedAt,_that.toAccountId,_that.categoryId,_that.note,_that.receiptPath,_that.recurringRuleId,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TxnType type,  int amountMinor,  String accountId,  PaymentMode paymentMode,  DateTime occurredAt,  DateTime createdAt,  DateTime updatedAt,  String? toAccountId,  String? categoryId,  String? note,  String? receiptPath,  String? recurringRuleId,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.type,_that.amountMinor,_that.accountId,_that.paymentMode,_that.occurredAt,_that.createdAt,_that.updatedAt,_that.toAccountId,_that.categoryId,_that.note,_that.receiptPath,_that.recurringRuleId,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Transaction extends Transaction {
  const _Transaction({required this.id, required this.type, required this.amountMinor, required this.accountId, required this.paymentMode, required this.occurredAt, required this.createdAt, required this.updatedAt, this.toAccountId, this.categoryId, this.note, this.receiptPath, this.recurringRuleId, this.deletedAt}): super._();
  

@override final  String id;
@override final  TxnType type;
/// Always positive, in minor units (paise). The sign comes from [type].
@override final  int amountMinor;
@override final  String accountId;
@override final  PaymentMode paymentMode;
/// UTC.
@override final  DateTime occurredAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? toAccountId;
@override final  String? categoryId;
@override final  String? note;
/// Relative path `receipts/<uuid>.jpg`.
@override final  String? receiptPath;
/// The rule this entry came from, or is the first occurrence of.
@override final  String? recurringRuleId;
@override final  DateTime? deletedAt;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.toAccountId, toAccountId) || other.toAccountId == toAccountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&(identical(other.receiptPath, receiptPath) || other.receiptPath == receiptPath)&&(identical(other.recurringRuleId, recurringRuleId) || other.recurringRuleId == recurringRuleId)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,type,amountMinor,accountId,paymentMode,occurredAt,createdAt,updatedAt,toAccountId,categoryId,note,receiptPath,recurringRuleId,deletedAt);
}

@override
String toString() {
    return 'Transaction(id: $id, type: $type, amountMinor: $amountMinor, accountId: $accountId, paymentMode: $paymentMode, occurredAt: $occurredAt, createdAt: $createdAt, updatedAt: $updatedAt, toAccountId: $toAccountId, categoryId: $categoryId, note: $note, receiptPath: $receiptPath, recurringRuleId: $recurringRuleId, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, TxnType type, int amountMinor, String accountId, PaymentMode paymentMode, DateTime occurredAt, DateTime createdAt, DateTime updatedAt, String? toAccountId, String? categoryId, String? note, String? receiptPath, String? recurringRuleId, DateTime? deletedAt
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amountMinor = null,Object? accountId = null,Object? paymentMode = null,Object? occurredAt = null,Object? createdAt = null,Object? updatedAt = null,Object? toAccountId = freezed,Object? categoryId = freezed,Object? note = freezed,Object? receiptPath = freezed,Object? recurringRuleId = freezed,Object? deletedAt = freezed,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxnType,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as PaymentMode,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,receiptPath: freezed == receiptPath ? _self.receiptPath : receiptPath // ignore: cast_nullable_to_non_nullable
as String?,recurringRuleId: freezed == recurringRuleId ? _self.recurringRuleId : recurringRuleId // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
