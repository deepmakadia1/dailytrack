// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Account {

 String get id;/// `expense_account_cash` for the seeded account, otherwise user text.
 String get name; AccountType get type;/// Paise; may be negative (e.g. a card).
 int get openingBalanceMinor; String get iconKey; String get colorHex; bool get isArchived; int get sortOrder;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Account;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.openingBalanceMinor, _this.openingBalanceMinor) || other.openingBalanceMinor == _this.openingBalanceMinor)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&(identical(other.isArchived, _this.isArchived) || other.isArchived == _this.isArchived)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}


@override
int get hashCode {
  final _this = this as Account;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.openingBalanceMinor,_this.iconKey,_this.colorHex,_this.isArchived,_this.sortOrder);
}

@override
String toString() {
  final _this = this as Account;
  return 'Account(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, openingBalanceMinor: ${_this.openingBalanceMinor}, iconKey: ${_this.iconKey}, colorHex: ${_this.colorHex}, isArchived: ${_this.isArchived}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
 String id, String name, AccountType type, int openingBalanceMinor, String iconKey, String colorHex, bool isArchived, int sortOrder
});




}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? openingBalanceMinor = null,Object? iconKey = null,Object? colorHex = null,Object? isArchived = null,Object? sortOrder = null,}) {
  return _then(Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,openingBalanceMinor: null == openingBalanceMinor ? _self.openingBalanceMinor : openingBalanceMinor // ignore: cast_nullable_to_non_nullable
as int,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  AccountType type,  int openingBalanceMinor,  String iconKey,  String colorHex,  bool isArchived,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.openingBalanceMinor,_that.iconKey,_that.colorHex,_that.isArchived,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  AccountType type,  int openingBalanceMinor,  String iconKey,  String colorHex,  bool isArchived,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.id,_that.name,_that.type,_that.openingBalanceMinor,_that.iconKey,_that.colorHex,_that.isArchived,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  AccountType type,  int openingBalanceMinor,  String iconKey,  String colorHex,  bool isArchived,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.openingBalanceMinor,_that.iconKey,_that.colorHex,_that.isArchived,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc


class _Account implements Account {
  const _Account({required this.id, required this.name, required this.type, required this.openingBalanceMinor, required this.iconKey, required this.colorHex, required this.isArchived, required this.sortOrder});
  

@override final  String id;
/// `expense_account_cash` for the seeded account, otherwise user text.
@override final  String name;
@override final  AccountType type;
/// Paise; may be negative (e.g. a card).
@override final  int openingBalanceMinor;
@override final  String iconKey;
@override final  String colorHex;
@override final  bool isArchived;
@override final  int sortOrder;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.openingBalanceMinor, openingBalanceMinor) || other.openingBalanceMinor == openingBalanceMinor)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,openingBalanceMinor,iconKey,colorHex,isArchived,sortOrder);
}

@override
String toString() {
    return 'Account(id: $id, name: $name, type: $type, openingBalanceMinor: $openingBalanceMinor, iconKey: $iconKey, colorHex: $colorHex, isArchived: $isArchived, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, AccountType type, int openingBalanceMinor, String iconKey, String colorHex, bool isArchived, int sortOrder
});




}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? openingBalanceMinor = null,Object? iconKey = null,Object? colorHex = null,Object? isArchived = null,Object? sortOrder = null,}) {
  return _then(_Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,openingBalanceMinor: null == openingBalanceMinor ? _self.openingBalanceMinor : openingBalanceMinor // ignore: cast_nullable_to_non_nullable
as int,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AccountWithBalance {

 Account get account; int get balanceMinor; bool get hasTransactions;
/// Create a copy of AccountWithBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountWithBalanceCopyWith<AccountWithBalance> get copyWith => _$AccountWithBalanceCopyWithImpl<AccountWithBalance>(this as AccountWithBalance, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountWithBalance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountWithBalance&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.balanceMinor, _this.balanceMinor) || other.balanceMinor == _this.balanceMinor)&&(identical(other.hasTransactions, _this.hasTransactions) || other.hasTransactions == _this.hasTransactions));
}


@override
int get hashCode {
  final _this = this as AccountWithBalance;
  return Object.hash(runtimeType,_this.account,_this.balanceMinor,_this.hasTransactions);
}

@override
String toString() {
  final _this = this as AccountWithBalance;
  return 'AccountWithBalance(account: ${_this.account}, balanceMinor: ${_this.balanceMinor}, hasTransactions: ${_this.hasTransactions})';
}


}

/// @nodoc
abstract mixin class $AccountWithBalanceCopyWith<$Res>  {
  factory $AccountWithBalanceCopyWith(AccountWithBalance value, $Res Function(AccountWithBalance) _then) = _$AccountWithBalanceCopyWithImpl;
@useResult
$Res call({
 Account account, int balanceMinor, bool hasTransactions
});


$AccountCopyWith<$Res> get account;

}
/// @nodoc
class _$AccountWithBalanceCopyWithImpl<$Res>
    implements $AccountWithBalanceCopyWith<$Res> {
  _$AccountWithBalanceCopyWithImpl(this._self, this._then);

  final AccountWithBalance _self;
  final $Res Function(AccountWithBalance) _then;

/// Create a copy of AccountWithBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = null,Object? balanceMinor = null,Object? hasTransactions = null,}) {
  return _then(AccountWithBalance(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,balanceMinor: null == balanceMinor ? _self.balanceMinor : balanceMinor // ignore: cast_nullable_to_non_nullable
as int,hasTransactions: null == hasTransactions ? _self.hasTransactions : hasTransactions // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AccountWithBalance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {
  
  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountWithBalance].
extension AccountWithBalancePatterns on AccountWithBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountWithBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountWithBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountWithBalance value)  $default,){
final _that = this;
switch (_that) {
case _AccountWithBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountWithBalance value)?  $default,){
final _that = this;
switch (_that) {
case _AccountWithBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Account account,  int balanceMinor,  bool hasTransactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountWithBalance() when $default != null:
return $default(_that.account,_that.balanceMinor,_that.hasTransactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Account account,  int balanceMinor,  bool hasTransactions)  $default,) {final _that = this;
switch (_that) {
case _AccountWithBalance():
return $default(_that.account,_that.balanceMinor,_that.hasTransactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Account account,  int balanceMinor,  bool hasTransactions)?  $default,) {final _that = this;
switch (_that) {
case _AccountWithBalance() when $default != null:
return $default(_that.account,_that.balanceMinor,_that.hasTransactions);case _:
  return null;

}
}

}

/// @nodoc


class _AccountWithBalance implements AccountWithBalance {
  const _AccountWithBalance({required this.account, required this.balanceMinor, required this.hasTransactions});
  

@override final  Account account;
@override final  int balanceMinor;
@override final  bool hasTransactions;

/// Create a copy of AccountWithBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountWithBalanceCopyWith<_AccountWithBalance> get copyWith => __$AccountWithBalanceCopyWithImpl<_AccountWithBalance>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountWithBalance&&(identical(other.account, account) || other.account == account)&&(identical(other.balanceMinor, balanceMinor) || other.balanceMinor == balanceMinor)&&(identical(other.hasTransactions, hasTransactions) || other.hasTransactions == hasTransactions));
}


@override
int get hashCode {
    return Object.hash(runtimeType,account,balanceMinor,hasTransactions);
}

@override
String toString() {
    return 'AccountWithBalance(account: $account, balanceMinor: $balanceMinor, hasTransactions: $hasTransactions)';
}


}

/// @nodoc
abstract mixin class _$AccountWithBalanceCopyWith<$Res> implements $AccountWithBalanceCopyWith<$Res> {
  factory _$AccountWithBalanceCopyWith(_AccountWithBalance value, $Res Function(_AccountWithBalance) _then) = __$AccountWithBalanceCopyWithImpl;
@override @useResult
$Res call({
 Account account, int balanceMinor, bool hasTransactions
});


@override $AccountCopyWith<$Res> get account;

}
/// @nodoc
class __$AccountWithBalanceCopyWithImpl<$Res>
    implements _$AccountWithBalanceCopyWith<$Res> {
  __$AccountWithBalanceCopyWithImpl(this._self, this._then);

  final _AccountWithBalance _self;
  final $Res Function(_AccountWithBalance) _then;

/// Create a copy of AccountWithBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = null,Object? balanceMinor = null,Object? hasTransactions = null,}) {
  return _then(_AccountWithBalance(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,balanceMinor: null == balanceMinor ? _self.balanceMinor : balanceMinor // ignore: cast_nullable_to_non_nullable
as int,hasTransactions: null == hasTransactions ? _self.hasTransactions : hasTransactions // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AccountWithBalance
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {
  
  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}

// dart format on
