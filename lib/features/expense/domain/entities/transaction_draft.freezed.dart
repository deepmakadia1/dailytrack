// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionDraft {

 TxnType get type; PaymentMode get paymentMode;/// UTC.
 DateTime get occurredAt; int? get amountMinor; String? get accountId; String? get toAccountId; String? get categoryId; String get note; String? get receiptPath;
/// Create a copy of TransactionDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionDraftCopyWith<TransactionDraft> get copyWith => _$TransactionDraftCopyWithImpl<TransactionDraft>(this as TransactionDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransactionDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionDraft&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.paymentMode, _this.paymentMode) || other.paymentMode == _this.paymentMode)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.toAccountId, _this.toAccountId) || other.toAccountId == _this.toAccountId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.receiptPath, _this.receiptPath) || other.receiptPath == _this.receiptPath));
}


@override
int get hashCode {
  final _this = this as TransactionDraft;
  return Object.hash(runtimeType,_this.type,_this.paymentMode,_this.occurredAt,_this.amountMinor,_this.accountId,_this.toAccountId,_this.categoryId,_this.note,_this.receiptPath);
}

@override
String toString() {
  final _this = this as TransactionDraft;
  return 'TransactionDraft(type: ${_this.type}, paymentMode: ${_this.paymentMode}, occurredAt: ${_this.occurredAt}, amountMinor: ${_this.amountMinor}, accountId: ${_this.accountId}, toAccountId: ${_this.toAccountId}, categoryId: ${_this.categoryId}, note: ${_this.note}, receiptPath: ${_this.receiptPath})';
}


}

/// @nodoc
abstract mixin class $TransactionDraftCopyWith<$Res>  {
  factory $TransactionDraftCopyWith(TransactionDraft value, $Res Function(TransactionDraft) _then) = _$TransactionDraftCopyWithImpl;
@useResult
$Res call({
 TxnType type, PaymentMode paymentMode, DateTime occurredAt, int? amountMinor, String? accountId, String? toAccountId, String? categoryId, String note, String? receiptPath
});




}
/// @nodoc
class _$TransactionDraftCopyWithImpl<$Res>
    implements $TransactionDraftCopyWith<$Res> {
  _$TransactionDraftCopyWithImpl(this._self, this._then);

  final TransactionDraft _self;
  final $Res Function(TransactionDraft) _then;

/// Create a copy of TransactionDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? paymentMode = null,Object? occurredAt = null,Object? amountMinor = freezed,Object? accountId = freezed,Object? toAccountId = freezed,Object? categoryId = freezed,Object? note = null,Object? receiptPath = freezed,}) {
  return _then(TransactionDraft(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxnType,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as PaymentMode,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,receiptPath: freezed == receiptPath ? _self.receiptPath : receiptPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionDraft].
extension TransactionDraftPatterns on TransactionDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionDraft value)  $default,){
final _that = this;
switch (_that) {
case _TransactionDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionDraft value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TxnType type,  PaymentMode paymentMode,  DateTime occurredAt,  int? amountMinor,  String? accountId,  String? toAccountId,  String? categoryId,  String note,  String? receiptPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionDraft() when $default != null:
return $default(_that.type,_that.paymentMode,_that.occurredAt,_that.amountMinor,_that.accountId,_that.toAccountId,_that.categoryId,_that.note,_that.receiptPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TxnType type,  PaymentMode paymentMode,  DateTime occurredAt,  int? amountMinor,  String? accountId,  String? toAccountId,  String? categoryId,  String note,  String? receiptPath)  $default,) {final _that = this;
switch (_that) {
case _TransactionDraft():
return $default(_that.type,_that.paymentMode,_that.occurredAt,_that.amountMinor,_that.accountId,_that.toAccountId,_that.categoryId,_that.note,_that.receiptPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TxnType type,  PaymentMode paymentMode,  DateTime occurredAt,  int? amountMinor,  String? accountId,  String? toAccountId,  String? categoryId,  String note,  String? receiptPath)?  $default,) {final _that = this;
switch (_that) {
case _TransactionDraft() when $default != null:
return $default(_that.type,_that.paymentMode,_that.occurredAt,_that.amountMinor,_that.accountId,_that.toAccountId,_that.categoryId,_that.note,_that.receiptPath);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionDraft implements TransactionDraft {
  const _TransactionDraft({required this.type, required this.paymentMode, required this.occurredAt, this.amountMinor, this.accountId, this.toAccountId, this.categoryId, this.note = '', this.receiptPath});
  

@override final  TxnType type;
@override final  PaymentMode paymentMode;
/// UTC.
@override final  DateTime occurredAt;
@override final  int? amountMinor;
@override final  String? accountId;
@override final  String? toAccountId;
@override final  String? categoryId;
@override@JsonKey() final  String note;
@override final  String? receiptPath;

/// Create a copy of TransactionDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionDraftCopyWith<_TransactionDraft> get copyWith => __$TransactionDraftCopyWithImpl<_TransactionDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionDraft&&(identical(other.type, type) || other.type == type)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.toAccountId, toAccountId) || other.toAccountId == toAccountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&(identical(other.receiptPath, receiptPath) || other.receiptPath == receiptPath));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,paymentMode,occurredAt,amountMinor,accountId,toAccountId,categoryId,note,receiptPath);
}

@override
String toString() {
    return 'TransactionDraft(type: $type, paymentMode: $paymentMode, occurredAt: $occurredAt, amountMinor: $amountMinor, accountId: $accountId, toAccountId: $toAccountId, categoryId: $categoryId, note: $note, receiptPath: $receiptPath)';
}


}

/// @nodoc
abstract mixin class _$TransactionDraftCopyWith<$Res> implements $TransactionDraftCopyWith<$Res> {
  factory _$TransactionDraftCopyWith(_TransactionDraft value, $Res Function(_TransactionDraft) _then) = __$TransactionDraftCopyWithImpl;
@override @useResult
$Res call({
 TxnType type, PaymentMode paymentMode, DateTime occurredAt, int? amountMinor, String? accountId, String? toAccountId, String? categoryId, String note, String? receiptPath
});




}
/// @nodoc
class __$TransactionDraftCopyWithImpl<$Res>
    implements _$TransactionDraftCopyWith<$Res> {
  __$TransactionDraftCopyWithImpl(this._self, this._then);

  final _TransactionDraft _self;
  final $Res Function(_TransactionDraft) _then;

/// Create a copy of TransactionDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? paymentMode = null,Object? occurredAt = null,Object? amountMinor = freezed,Object? accountId = freezed,Object? toAccountId = freezed,Object? categoryId = freezed,Object? note = null,Object? receiptPath = freezed,}) {
  return _then(_TransactionDraft(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxnType,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as PaymentMode,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,amountMinor: freezed == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,receiptPath: freezed == receiptPath ? _self.receiptPath : receiptPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
