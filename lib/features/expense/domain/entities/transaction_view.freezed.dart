// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionView {

 Transaction get transaction; Account get account; Category? get category; Account? get toAccount;
/// Create a copy of TransactionView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionViewCopyWith<TransactionView> get copyWith => _$TransactionViewCopyWithImpl<TransactionView>(this as TransactionView, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransactionView;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionView&&(identical(other.transaction, _this.transaction) || other.transaction == _this.transaction)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.toAccount, _this.toAccount) || other.toAccount == _this.toAccount));
}


@override
int get hashCode {
  final _this = this as TransactionView;
  return Object.hash(runtimeType,_this.transaction,_this.account,_this.category,_this.toAccount);
}

@override
String toString() {
  final _this = this as TransactionView;
  return 'TransactionView(transaction: ${_this.transaction}, account: ${_this.account}, category: ${_this.category}, toAccount: ${_this.toAccount})';
}


}

/// @nodoc
abstract mixin class $TransactionViewCopyWith<$Res>  {
  factory $TransactionViewCopyWith(TransactionView value, $Res Function(TransactionView) _then) = _$TransactionViewCopyWithImpl;
@useResult
$Res call({
 Transaction transaction, Account account, Category? category, Account? toAccount
});


$TransactionCopyWith<$Res> get transaction;$AccountCopyWith<$Res> get account;$CategoryCopyWith<$Res>? get category;$AccountCopyWith<$Res>? get toAccount;

}
/// @nodoc
class _$TransactionViewCopyWithImpl<$Res>
    implements $TransactionViewCopyWith<$Res> {
  _$TransactionViewCopyWithImpl(this._self, this._then);

  final TransactionView _self;
  final $Res Function(TransactionView) _then;

/// Create a copy of TransactionView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transaction = null,Object? account = null,Object? category = freezed,Object? toAccount = freezed,}) {
  return _then(TransactionView(
transaction: null == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as Transaction,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,toAccount: freezed == toAccount ? _self.toAccount : toAccount // ignore: cast_nullable_to_non_nullable
as Account?,
  ));
}
/// Create a copy of TransactionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionCopyWith<$Res> get transaction {
  
  return $TransactionCopyWith<$Res>(_self.transaction, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}/// Create a copy of TransactionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {
  
  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of TransactionView
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
}/// Create a copy of TransactionView
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
}
}


/// Adds pattern-matching-related methods to [TransactionView].
extension TransactionViewPatterns on TransactionView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionView value)  $default,){
final _that = this;
switch (_that) {
case _TransactionView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionView value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Transaction transaction,  Account account,  Category? category,  Account? toAccount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionView() when $default != null:
return $default(_that.transaction,_that.account,_that.category,_that.toAccount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Transaction transaction,  Account account,  Category? category,  Account? toAccount)  $default,) {final _that = this;
switch (_that) {
case _TransactionView():
return $default(_that.transaction,_that.account,_that.category,_that.toAccount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Transaction transaction,  Account account,  Category? category,  Account? toAccount)?  $default,) {final _that = this;
switch (_that) {
case _TransactionView() when $default != null:
return $default(_that.transaction,_that.account,_that.category,_that.toAccount);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionView extends TransactionView {
  const _TransactionView({required this.transaction, required this.account, this.category, this.toAccount}): super._();
  

@override final  Transaction transaction;
@override final  Account account;
@override final  Category? category;
@override final  Account? toAccount;

/// Create a copy of TransactionView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionViewCopyWith<_TransactionView> get copyWith => __$TransactionViewCopyWithImpl<_TransactionView>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionView&&(identical(other.transaction, transaction) || other.transaction == transaction)&&(identical(other.account, account) || other.account == account)&&(identical(other.category, category) || other.category == category)&&(identical(other.toAccount, toAccount) || other.toAccount == toAccount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,transaction,account,category,toAccount);
}

@override
String toString() {
    return 'TransactionView(transaction: $transaction, account: $account, category: $category, toAccount: $toAccount)';
}


}

/// @nodoc
abstract mixin class _$TransactionViewCopyWith<$Res> implements $TransactionViewCopyWith<$Res> {
  factory _$TransactionViewCopyWith(_TransactionView value, $Res Function(_TransactionView) _then) = __$TransactionViewCopyWithImpl;
@override @useResult
$Res call({
 Transaction transaction, Account account, Category? category, Account? toAccount
});


@override $TransactionCopyWith<$Res> get transaction;@override $AccountCopyWith<$Res> get account;@override $CategoryCopyWith<$Res>? get category;@override $AccountCopyWith<$Res>? get toAccount;

}
/// @nodoc
class __$TransactionViewCopyWithImpl<$Res>
    implements _$TransactionViewCopyWith<$Res> {
  __$TransactionViewCopyWithImpl(this._self, this._then);

  final _TransactionView _self;
  final $Res Function(_TransactionView) _then;

/// Create a copy of TransactionView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transaction = null,Object? account = null,Object? category = freezed,Object? toAccount = freezed,}) {
  return _then(_TransactionView(
transaction: null == transaction ? _self.transaction : transaction // ignore: cast_nullable_to_non_nullable
as Transaction,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,toAccount: freezed == toAccount ? _self.toAccount : toAccount // ignore: cast_nullable_to_non_nullable
as Account?,
  ));
}

/// Create a copy of TransactionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionCopyWith<$Res> get transaction {
  
  return $TransactionCopyWith<$Res>(_self.transaction, (value) {
    return _then(_self.copyWith(transaction: value));
  });
}/// Create a copy of TransactionView
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {
  
  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of TransactionView
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
}/// Create a copy of TransactionView
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
}
}

// dart format on
