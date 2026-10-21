// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transactions_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionsState {

/// The session filter (FR-020).
 TxnQuery get query;/// Rows of the current page window, newest first.
 AsyncValue<List<TransactionView>> get rows;/// Totals for ALL matching rows (summary strip, day headers).
 AsyncValue<PeriodLedger> get ledger;/// What the search field shows; applied to [query] after 300 ms.
 String get searchText; bool get searchOpen; int get pageCount;/// Every non-deleted category by id (row display, search, filters).
 Map<String, Category> get categories;/// Every non-deleted account by id, archived ones too (filters, chips).
 Map<String, Account> get accounts;/// Rows deleted a moment ago, hidden until the stream catches up, so a
/// dismissed row never reappears under the finger.
 Set<String> get hiddenIds;
/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionsStateCopyWith<TransactionsState> get copyWith => _$TransactionsStateCopyWithImpl<TransactionsState>(this as TransactionsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransactionsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionsState&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.rows, _this.rows) || other.rows == _this.rows)&&(identical(other.ledger, _this.ledger) || other.ledger == _this.ledger)&&(identical(other.searchText, _this.searchText) || other.searchText == _this.searchText)&&(identical(other.searchOpen, _this.searchOpen) || other.searchOpen == _this.searchOpen)&&(identical(other.pageCount, _this.pageCount) || other.pageCount == _this.pageCount)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.accounts, _this.accounts)&&const DeepCollectionEquality().equals(other.hiddenIds, _this.hiddenIds));
}


@override
int get hashCode {
  final _this = this as TransactionsState;
  return Object.hash(runtimeType,_this.query,_this.rows,_this.ledger,_this.searchText,_this.searchOpen,_this.pageCount,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.accounts),const DeepCollectionEquality().hash(_this.hiddenIds));
}

@override
String toString() {
  final _this = this as TransactionsState;
  return 'TransactionsState(query: ${_this.query}, rows: ${_this.rows}, ledger: ${_this.ledger}, searchText: ${_this.searchText}, searchOpen: ${_this.searchOpen}, pageCount: ${_this.pageCount}, categories: ${_this.categories}, accounts: ${_this.accounts}, hiddenIds: ${_this.hiddenIds})';
}


}

/// @nodoc
abstract mixin class $TransactionsStateCopyWith<$Res>  {
  factory $TransactionsStateCopyWith(TransactionsState value, $Res Function(TransactionsState) _then) = _$TransactionsStateCopyWithImpl;
@useResult
$Res call({
 TxnQuery query, AsyncValue<List<TransactionView>> rows, AsyncValue<PeriodLedger> ledger, String searchText, bool searchOpen, int pageCount, Map<String, Category> categories, Map<String, Account> accounts, Set<String> hiddenIds
});


$TxnQueryCopyWith<$Res> get query;

}
/// @nodoc
class _$TransactionsStateCopyWithImpl<$Res>
    implements $TransactionsStateCopyWith<$Res> {
  _$TransactionsStateCopyWithImpl(this._self, this._then);

  final TransactionsState _self;
  final $Res Function(TransactionsState) _then;

/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? rows = null,Object? ledger = null,Object? searchText = null,Object? searchOpen = null,Object? pageCount = null,Object? categories = null,Object? accounts = null,Object? hiddenIds = null,}) {
  return _then(TransactionsState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as TxnQuery,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<TransactionView>>,ledger: null == ledger ? _self.ledger : ledger // ignore: cast_nullable_to_non_nullable
as AsyncValue<PeriodLedger>,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,searchOpen: null == searchOpen ? _self.searchOpen : searchOpen // ignore: cast_nullable_to_non_nullable
as bool,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as Map<String, Category>,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as Map<String, Account>,hiddenIds: null == hiddenIds ? _self.hiddenIds : hiddenIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}
/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TxnQueryCopyWith<$Res> get query {
  
  return $TxnQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}
}


/// Adds pattern-matching-related methods to [TransactionsState].
extension TransactionsStatePatterns on TransactionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionsState value)  $default,){
final _that = this;
switch (_that) {
case _TransactionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionsState value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TxnQuery query,  AsyncValue<List<TransactionView>> rows,  AsyncValue<PeriodLedger> ledger,  String searchText,  bool searchOpen,  int pageCount,  Map<String, Category> categories,  Map<String, Account> accounts,  Set<String> hiddenIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
return $default(_that.query,_that.rows,_that.ledger,_that.searchText,_that.searchOpen,_that.pageCount,_that.categories,_that.accounts,_that.hiddenIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TxnQuery query,  AsyncValue<List<TransactionView>> rows,  AsyncValue<PeriodLedger> ledger,  String searchText,  bool searchOpen,  int pageCount,  Map<String, Category> categories,  Map<String, Account> accounts,  Set<String> hiddenIds)  $default,) {final _that = this;
switch (_that) {
case _TransactionsState():
return $default(_that.query,_that.rows,_that.ledger,_that.searchText,_that.searchOpen,_that.pageCount,_that.categories,_that.accounts,_that.hiddenIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TxnQuery query,  AsyncValue<List<TransactionView>> rows,  AsyncValue<PeriodLedger> ledger,  String searchText,  bool searchOpen,  int pageCount,  Map<String, Category> categories,  Map<String, Account> accounts,  Set<String> hiddenIds)?  $default,) {final _that = this;
switch (_that) {
case _TransactionsState() when $default != null:
return $default(_that.query,_that.rows,_that.ledger,_that.searchText,_that.searchOpen,_that.pageCount,_that.categories,_that.accounts,_that.hiddenIds);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionsState extends TransactionsState {
  const _TransactionsState({required this.query, required this.rows, required this.ledger, this.searchText = '', this.searchOpen = false, this.pageCount = 1,  Map<String, Category> categories = const <String, Category>{},  Map<String, Account> accounts = const <String, Account>{},  Set<String> hiddenIds = const <String>{}}): _categories = categories,_accounts = accounts,_hiddenIds = hiddenIds,super._();
  

/// The session filter (FR-020).
@override final  TxnQuery query;
/// Rows of the current page window, newest first.
@override final  AsyncValue<List<TransactionView>> rows;
/// Totals for ALL matching rows (summary strip, day headers).
@override final  AsyncValue<PeriodLedger> ledger;
/// What the search field shows; applied to [query] after 300 ms.
@override@JsonKey() final  String searchText;
@override@JsonKey() final  bool searchOpen;
@override@JsonKey() final  int pageCount;
/// Every non-deleted category by id (row display, search, filters).
 final  Map<String, Category> _categories;
/// Every non-deleted category by id (row display, search, filters).
@override@JsonKey() Map<String, Category> get categories {
  if (_categories is EqualUnmodifiableMapView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categories);
}

/// Every non-deleted account by id, archived ones too (filters, chips).
 final  Map<String, Account> _accounts;
/// Every non-deleted account by id, archived ones too (filters, chips).
@override@JsonKey() Map<String, Account> get accounts {
  if (_accounts is EqualUnmodifiableMapView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_accounts);
}

/// Rows deleted a moment ago, hidden until the stream catches up, so a
/// dismissed row never reappears under the finger.
 final  Set<String> _hiddenIds;
/// Rows deleted a moment ago, hidden until the stream catches up, so a
/// dismissed row never reappears under the finger.
@override@JsonKey() Set<String> get hiddenIds {
  if (_hiddenIds is EqualUnmodifiableSetView) return _hiddenIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_hiddenIds);
}


/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionsStateCopyWith<_TransactionsState> get copyWith => __$TransactionsStateCopyWithImpl<_TransactionsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionsState&&(identical(other.query, query) || other.query == query)&&(identical(other.rows, rows) || other.rows == rows)&&(identical(other.ledger, ledger) || other.ledger == ledger)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.searchOpen, searchOpen) || other.searchOpen == searchOpen)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.accounts, _accounts)&&const DeepCollectionEquality().equals(other.hiddenIds, _hiddenIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query,rows,ledger,searchText,searchOpen,pageCount,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_accounts),const DeepCollectionEquality().hash(_hiddenIds));
}

@override
String toString() {
    return 'TransactionsState(query: $query, rows: $rows, ledger: $ledger, searchText: $searchText, searchOpen: $searchOpen, pageCount: $pageCount, categories: $categories, accounts: $accounts, hiddenIds: $hiddenIds)';
}


}

/// @nodoc
abstract mixin class _$TransactionsStateCopyWith<$Res> implements $TransactionsStateCopyWith<$Res> {
  factory _$TransactionsStateCopyWith(_TransactionsState value, $Res Function(_TransactionsState) _then) = __$TransactionsStateCopyWithImpl;
@override @useResult
$Res call({
 TxnQuery query, AsyncValue<List<TransactionView>> rows, AsyncValue<PeriodLedger> ledger, String searchText, bool searchOpen, int pageCount, Map<String, Category> categories, Map<String, Account> accounts, Set<String> hiddenIds
});


@override $TxnQueryCopyWith<$Res> get query;

}
/// @nodoc
class __$TransactionsStateCopyWithImpl<$Res>
    implements _$TransactionsStateCopyWith<$Res> {
  __$TransactionsStateCopyWithImpl(this._self, this._then);

  final _TransactionsState _self;
  final $Res Function(_TransactionsState) _then;

/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? rows = null,Object? ledger = null,Object? searchText = null,Object? searchOpen = null,Object? pageCount = null,Object? categories = null,Object? accounts = null,Object? hiddenIds = null,}) {
  return _then(_TransactionsState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as TxnQuery,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<TransactionView>>,ledger: null == ledger ? _self.ledger : ledger // ignore: cast_nullable_to_non_nullable
as AsyncValue<PeriodLedger>,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,searchOpen: null == searchOpen ? _self.searchOpen : searchOpen // ignore: cast_nullable_to_non_nullable
as bool,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as Map<String, Category>,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as Map<String, Account>,hiddenIds: null == hiddenIds ? _self._hiddenIds : hiddenIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

/// Create a copy of TransactionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TxnQueryCopyWith<$Res> get query {
  
  return $TxnQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}
}

// dart format on
