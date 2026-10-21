// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_breakdown.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpenseBreakdown {

/// Category id → paise.
 Map<String, int> get byCategory;/// Source account id → paise.
 Map<String, int> get byAccount; Map<PaymentMode, int> get byPaymentMode; int get totalExpenseMinor;
/// Create a copy of ExpenseBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseBreakdownCopyWith<ExpenseBreakdown> get copyWith => _$ExpenseBreakdownCopyWithImpl<ExpenseBreakdown>(this as ExpenseBreakdown, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExpenseBreakdown;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseBreakdown&&const DeepCollectionEquality().equals(other.byCategory, _this.byCategory)&&const DeepCollectionEquality().equals(other.byAccount, _this.byAccount)&&const DeepCollectionEquality().equals(other.byPaymentMode, _this.byPaymentMode)&&(identical(other.totalExpenseMinor, _this.totalExpenseMinor) || other.totalExpenseMinor == _this.totalExpenseMinor));
}


@override
int get hashCode {
  final _this = this as ExpenseBreakdown;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.byCategory),const DeepCollectionEquality().hash(_this.byAccount),const DeepCollectionEquality().hash(_this.byPaymentMode),_this.totalExpenseMinor);
}

@override
String toString() {
  final _this = this as ExpenseBreakdown;
  return 'ExpenseBreakdown(byCategory: ${_this.byCategory}, byAccount: ${_this.byAccount}, byPaymentMode: ${_this.byPaymentMode}, totalExpenseMinor: ${_this.totalExpenseMinor})';
}


}

/// @nodoc
abstract mixin class $ExpenseBreakdownCopyWith<$Res>  {
  factory $ExpenseBreakdownCopyWith(ExpenseBreakdown value, $Res Function(ExpenseBreakdown) _then) = _$ExpenseBreakdownCopyWithImpl;
@useResult
$Res call({
 Map<String, int> byCategory, Map<String, int> byAccount, Map<PaymentMode, int> byPaymentMode, int totalExpenseMinor
});




}
/// @nodoc
class _$ExpenseBreakdownCopyWithImpl<$Res>
    implements $ExpenseBreakdownCopyWith<$Res> {
  _$ExpenseBreakdownCopyWithImpl(this._self, this._then);

  final ExpenseBreakdown _self;
  final $Res Function(ExpenseBreakdown) _then;

/// Create a copy of ExpenseBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? byCategory = null,Object? byAccount = null,Object? byPaymentMode = null,Object? totalExpenseMinor = null,}) {
  return _then(ExpenseBreakdown(
byCategory: null == byCategory ? _self.byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>,byAccount: null == byAccount ? _self.byAccount : byAccount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,byPaymentMode: null == byPaymentMode ? _self.byPaymentMode : byPaymentMode // ignore: cast_nullable_to_non_nullable
as Map<PaymentMode, int>,totalExpenseMinor: null == totalExpenseMinor ? _self.totalExpenseMinor : totalExpenseMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseBreakdown].
extension ExpenseBreakdownPatterns on ExpenseBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, int> byCategory,  Map<String, int> byAccount,  Map<PaymentMode, int> byPaymentMode,  int totalExpenseMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseBreakdown() when $default != null:
return $default(_that.byCategory,_that.byAccount,_that.byPaymentMode,_that.totalExpenseMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, int> byCategory,  Map<String, int> byAccount,  Map<PaymentMode, int> byPaymentMode,  int totalExpenseMinor)  $default,) {final _that = this;
switch (_that) {
case _ExpenseBreakdown():
return $default(_that.byCategory,_that.byAccount,_that.byPaymentMode,_that.totalExpenseMinor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, int> byCategory,  Map<String, int> byAccount,  Map<PaymentMode, int> byPaymentMode,  int totalExpenseMinor)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseBreakdown() when $default != null:
return $default(_that.byCategory,_that.byAccount,_that.byPaymentMode,_that.totalExpenseMinor);case _:
  return null;

}
}

}

/// @nodoc


class _ExpenseBreakdown implements ExpenseBreakdown {
  const _ExpenseBreakdown({ Map<String, int> byCategory = const <String, int>{},  Map<String, int> byAccount = const <String, int>{},  Map<PaymentMode, int> byPaymentMode = const <PaymentMode, int>{}, this.totalExpenseMinor = 0}): _byCategory = byCategory,_byAccount = byAccount,_byPaymentMode = byPaymentMode;
  

/// Category id → paise.
 final  Map<String, int> _byCategory;
/// Category id → paise.
@override@JsonKey() Map<String, int> get byCategory {
  if (_byCategory is EqualUnmodifiableMapView) return _byCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byCategory);
}

/// Source account id → paise.
 final  Map<String, int> _byAccount;
/// Source account id → paise.
@override@JsonKey() Map<String, int> get byAccount {
  if (_byAccount is EqualUnmodifiableMapView) return _byAccount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byAccount);
}

 final  Map<PaymentMode, int> _byPaymentMode;
@override@JsonKey() Map<PaymentMode, int> get byPaymentMode {
  if (_byPaymentMode is EqualUnmodifiableMapView) return _byPaymentMode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byPaymentMode);
}

@override@JsonKey() final  int totalExpenseMinor;

/// Create a copy of ExpenseBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseBreakdownCopyWith<_ExpenseBreakdown> get copyWith => __$ExpenseBreakdownCopyWithImpl<_ExpenseBreakdown>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseBreakdown&&const DeepCollectionEquality().equals(other.byCategory, _byCategory)&&const DeepCollectionEquality().equals(other.byAccount, _byAccount)&&const DeepCollectionEquality().equals(other.byPaymentMode, _byPaymentMode)&&(identical(other.totalExpenseMinor, totalExpenseMinor) || other.totalExpenseMinor == totalExpenseMinor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_byCategory),const DeepCollectionEquality().hash(_byAccount),const DeepCollectionEquality().hash(_byPaymentMode),totalExpenseMinor);
}

@override
String toString() {
    return 'ExpenseBreakdown(byCategory: $byCategory, byAccount: $byAccount, byPaymentMode: $byPaymentMode, totalExpenseMinor: $totalExpenseMinor)';
}


}

/// @nodoc
abstract mixin class _$ExpenseBreakdownCopyWith<$Res> implements $ExpenseBreakdownCopyWith<$Res> {
  factory _$ExpenseBreakdownCopyWith(_ExpenseBreakdown value, $Res Function(_ExpenseBreakdown) _then) = __$ExpenseBreakdownCopyWithImpl;
@override @useResult
$Res call({
 Map<String, int> byCategory, Map<String, int> byAccount, Map<PaymentMode, int> byPaymentMode, int totalExpenseMinor
});




}
/// @nodoc
class __$ExpenseBreakdownCopyWithImpl<$Res>
    implements _$ExpenseBreakdownCopyWith<$Res> {
  __$ExpenseBreakdownCopyWithImpl(this._self, this._then);

  final _ExpenseBreakdown _self;
  final $Res Function(_ExpenseBreakdown) _then;

/// Create a copy of ExpenseBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? byCategory = null,Object? byAccount = null,Object? byPaymentMode = null,Object? totalExpenseMinor = null,}) {
  return _then(_ExpenseBreakdown(
byCategory: null == byCategory ? _self._byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>,byAccount: null == byAccount ? _self._byAccount : byAccount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,byPaymentMode: null == byPaymentMode ? _self._byPaymentMode : byPaymentMode // ignore: cast_nullable_to_non_nullable
as Map<PaymentMode, int>,totalExpenseMinor: null == totalExpenseMinor ? _self.totalExpenseMinor : totalExpenseMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
