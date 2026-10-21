// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'txn_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TxnQuery {

 Period get period;/// Raw search text; blank means no search.
 String get search;/// Categories whose displayed (localized) name matches [search],
/// resolved by the controller (research R5).
 Set<String> get matchingCategoryIds; Set<String> get categoryIds;/// Matches either the source or the destination account.
 Set<String> get accountIds; Set<PaymentMode> get paymentModes; Set<TxnType> get types; int? get minAmountMinor; int? get maxAmountMinor;
/// Create a copy of TxnQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TxnQueryCopyWith<TxnQuery> get copyWith => _$TxnQueryCopyWithImpl<TxnQuery>(this as TxnQuery, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TxnQuery;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TxnQuery&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.search, _this.search) || other.search == _this.search)&&const DeepCollectionEquality().equals(other.matchingCategoryIds, _this.matchingCategoryIds)&&const DeepCollectionEquality().equals(other.categoryIds, _this.categoryIds)&&const DeepCollectionEquality().equals(other.accountIds, _this.accountIds)&&const DeepCollectionEquality().equals(other.paymentModes, _this.paymentModes)&&const DeepCollectionEquality().equals(other.types, _this.types)&&(identical(other.minAmountMinor, _this.minAmountMinor) || other.minAmountMinor == _this.minAmountMinor)&&(identical(other.maxAmountMinor, _this.maxAmountMinor) || other.maxAmountMinor == _this.maxAmountMinor));
}


@override
int get hashCode {
  final _this = this as TxnQuery;
  return Object.hash(runtimeType,_this.period,_this.search,const DeepCollectionEquality().hash(_this.matchingCategoryIds),const DeepCollectionEquality().hash(_this.categoryIds),const DeepCollectionEquality().hash(_this.accountIds),const DeepCollectionEquality().hash(_this.paymentModes),const DeepCollectionEquality().hash(_this.types),_this.minAmountMinor,_this.maxAmountMinor);
}

@override
String toString() {
  final _this = this as TxnQuery;
  return 'TxnQuery(period: ${_this.period}, search: ${_this.search}, matchingCategoryIds: ${_this.matchingCategoryIds}, categoryIds: ${_this.categoryIds}, accountIds: ${_this.accountIds}, paymentModes: ${_this.paymentModes}, types: ${_this.types}, minAmountMinor: ${_this.minAmountMinor}, maxAmountMinor: ${_this.maxAmountMinor})';
}


}

/// @nodoc
abstract mixin class $TxnQueryCopyWith<$Res>  {
  factory $TxnQueryCopyWith(TxnQuery value, $Res Function(TxnQuery) _then) = _$TxnQueryCopyWithImpl;
@useResult
$Res call({
 Period period, String search, Set<String> matchingCategoryIds, Set<String> categoryIds, Set<String> accountIds, Set<PaymentMode> paymentModes, Set<TxnType> types, int? minAmountMinor, int? maxAmountMinor
});




}
/// @nodoc
class _$TxnQueryCopyWithImpl<$Res>
    implements $TxnQueryCopyWith<$Res> {
  _$TxnQueryCopyWithImpl(this._self, this._then);

  final TxnQuery _self;
  final $Res Function(TxnQuery) _then;

/// Create a copy of TxnQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? search = null,Object? matchingCategoryIds = null,Object? categoryIds = null,Object? accountIds = null,Object? paymentModes = null,Object? types = null,Object? minAmountMinor = freezed,Object? maxAmountMinor = freezed,}) {
  return _then(TxnQuery(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,matchingCategoryIds: null == matchingCategoryIds ? _self.matchingCategoryIds : matchingCategoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,accountIds: null == accountIds ? _self.accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as Set<String>,paymentModes: null == paymentModes ? _self.paymentModes : paymentModes // ignore: cast_nullable_to_non_nullable
as Set<PaymentMode>,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as Set<TxnType>,minAmountMinor: freezed == minAmountMinor ? _self.minAmountMinor : minAmountMinor // ignore: cast_nullable_to_non_nullable
as int?,maxAmountMinor: freezed == maxAmountMinor ? _self.maxAmountMinor : maxAmountMinor // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TxnQuery].
extension TxnQueryPatterns on TxnQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TxnQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TxnQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TxnQuery value)  $default,){
final _that = this;
switch (_that) {
case _TxnQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TxnQuery value)?  $default,){
final _that = this;
switch (_that) {
case _TxnQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Period period,  String search,  Set<String> matchingCategoryIds,  Set<String> categoryIds,  Set<String> accountIds,  Set<PaymentMode> paymentModes,  Set<TxnType> types,  int? minAmountMinor,  int? maxAmountMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TxnQuery() when $default != null:
return $default(_that.period,_that.search,_that.matchingCategoryIds,_that.categoryIds,_that.accountIds,_that.paymentModes,_that.types,_that.minAmountMinor,_that.maxAmountMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Period period,  String search,  Set<String> matchingCategoryIds,  Set<String> categoryIds,  Set<String> accountIds,  Set<PaymentMode> paymentModes,  Set<TxnType> types,  int? minAmountMinor,  int? maxAmountMinor)  $default,) {final _that = this;
switch (_that) {
case _TxnQuery():
return $default(_that.period,_that.search,_that.matchingCategoryIds,_that.categoryIds,_that.accountIds,_that.paymentModes,_that.types,_that.minAmountMinor,_that.maxAmountMinor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Period period,  String search,  Set<String> matchingCategoryIds,  Set<String> categoryIds,  Set<String> accountIds,  Set<PaymentMode> paymentModes,  Set<TxnType> types,  int? minAmountMinor,  int? maxAmountMinor)?  $default,) {final _that = this;
switch (_that) {
case _TxnQuery() when $default != null:
return $default(_that.period,_that.search,_that.matchingCategoryIds,_that.categoryIds,_that.accountIds,_that.paymentModes,_that.types,_that.minAmountMinor,_that.maxAmountMinor);case _:
  return null;

}
}

}

/// @nodoc


class _TxnQuery extends TxnQuery {
  const _TxnQuery({required this.period, this.search = '',  Set<String> matchingCategoryIds = const <String>{},  Set<String> categoryIds = const <String>{},  Set<String> accountIds = const <String>{},  Set<PaymentMode> paymentModes = const <PaymentMode>{},  Set<TxnType> types = const <TxnType>{}, this.minAmountMinor, this.maxAmountMinor}): _matchingCategoryIds = matchingCategoryIds,_categoryIds = categoryIds,_accountIds = accountIds,_paymentModes = paymentModes,_types = types,super._();
  

@override final  Period period;
/// Raw search text; blank means no search.
@override@JsonKey() final  String search;
/// Categories whose displayed (localized) name matches [search],
/// resolved by the controller (research R5).
 final  Set<String> _matchingCategoryIds;
/// Categories whose displayed (localized) name matches [search],
/// resolved by the controller (research R5).
@override@JsonKey() Set<String> get matchingCategoryIds {
  if (_matchingCategoryIds is EqualUnmodifiableSetView) return _matchingCategoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_matchingCategoryIds);
}

 final  Set<String> _categoryIds;
@override@JsonKey() Set<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableSetView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_categoryIds);
}

/// Matches either the source or the destination account.
 final  Set<String> _accountIds;
/// Matches either the source or the destination account.
@override@JsonKey() Set<String> get accountIds {
  if (_accountIds is EqualUnmodifiableSetView) return _accountIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_accountIds);
}

 final  Set<PaymentMode> _paymentModes;
@override@JsonKey() Set<PaymentMode> get paymentModes {
  if (_paymentModes is EqualUnmodifiableSetView) return _paymentModes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_paymentModes);
}

 final  Set<TxnType> _types;
@override@JsonKey() Set<TxnType> get types {
  if (_types is EqualUnmodifiableSetView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_types);
}

@override final  int? minAmountMinor;
@override final  int? maxAmountMinor;

/// Create a copy of TxnQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TxnQueryCopyWith<_TxnQuery> get copyWith => __$TxnQueryCopyWithImpl<_TxnQuery>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TxnQuery&&(identical(other.period, period) || other.period == period)&&(identical(other.search, search) || other.search == search)&&const DeepCollectionEquality().equals(other.matchingCategoryIds, _matchingCategoryIds)&&const DeepCollectionEquality().equals(other.categoryIds, _categoryIds)&&const DeepCollectionEquality().equals(other.accountIds, _accountIds)&&const DeepCollectionEquality().equals(other.paymentModes, _paymentModes)&&const DeepCollectionEquality().equals(other.types, _types)&&(identical(other.minAmountMinor, minAmountMinor) || other.minAmountMinor == minAmountMinor)&&(identical(other.maxAmountMinor, maxAmountMinor) || other.maxAmountMinor == maxAmountMinor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,search,const DeepCollectionEquality().hash(_matchingCategoryIds),const DeepCollectionEquality().hash(_categoryIds),const DeepCollectionEquality().hash(_accountIds),const DeepCollectionEquality().hash(_paymentModes),const DeepCollectionEquality().hash(_types),minAmountMinor,maxAmountMinor);
}

@override
String toString() {
    return 'TxnQuery(period: $period, search: $search, matchingCategoryIds: $matchingCategoryIds, categoryIds: $categoryIds, accountIds: $accountIds, paymentModes: $paymentModes, types: $types, minAmountMinor: $minAmountMinor, maxAmountMinor: $maxAmountMinor)';
}


}

/// @nodoc
abstract mixin class _$TxnQueryCopyWith<$Res> implements $TxnQueryCopyWith<$Res> {
  factory _$TxnQueryCopyWith(_TxnQuery value, $Res Function(_TxnQuery) _then) = __$TxnQueryCopyWithImpl;
@override @useResult
$Res call({
 Period period, String search, Set<String> matchingCategoryIds, Set<String> categoryIds, Set<String> accountIds, Set<PaymentMode> paymentModes, Set<TxnType> types, int? minAmountMinor, int? maxAmountMinor
});




}
/// @nodoc
class __$TxnQueryCopyWithImpl<$Res>
    implements _$TxnQueryCopyWith<$Res> {
  __$TxnQueryCopyWithImpl(this._self, this._then);

  final _TxnQuery _self;
  final $Res Function(_TxnQuery) _then;

/// Create a copy of TxnQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? search = null,Object? matchingCategoryIds = null,Object? categoryIds = null,Object? accountIds = null,Object? paymentModes = null,Object? types = null,Object? minAmountMinor = freezed,Object? maxAmountMinor = freezed,}) {
  return _then(_TxnQuery(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,matchingCategoryIds: null == matchingCategoryIds ? _self._matchingCategoryIds : matchingCategoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,accountIds: null == accountIds ? _self._accountIds : accountIds // ignore: cast_nullable_to_non_nullable
as Set<String>,paymentModes: null == paymentModes ? _self._paymentModes : paymentModes // ignore: cast_nullable_to_non_nullable
as Set<PaymentMode>,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as Set<TxnType>,minAmountMinor: freezed == minAmountMinor ? _self.minAmountMinor : minAmountMinor // ignore: cast_nullable_to_non_nullable
as int?,maxAmountMinor: freezed == maxAmountMinor ? _self.maxAmountMinor : maxAmountMinor // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
