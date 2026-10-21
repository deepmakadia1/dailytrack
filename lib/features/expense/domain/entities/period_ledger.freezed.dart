// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'period_ledger.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayTotal {

 int get incomeMinor; int get expenseMinor;
/// Create a copy of DayTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayTotalCopyWith<DayTotal> get copyWith => _$DayTotalCopyWithImpl<DayTotal>(this as DayTotal, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DayTotal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayTotal&&(identical(other.incomeMinor, _this.incomeMinor) || other.incomeMinor == _this.incomeMinor)&&(identical(other.expenseMinor, _this.expenseMinor) || other.expenseMinor == _this.expenseMinor));
}


@override
int get hashCode {
  final _this = this as DayTotal;
  return Object.hash(runtimeType,_this.incomeMinor,_this.expenseMinor);
}

@override
String toString() {
  final _this = this as DayTotal;
  return 'DayTotal(incomeMinor: ${_this.incomeMinor}, expenseMinor: ${_this.expenseMinor})';
}


}

/// @nodoc
abstract mixin class $DayTotalCopyWith<$Res>  {
  factory $DayTotalCopyWith(DayTotal value, $Res Function(DayTotal) _then) = _$DayTotalCopyWithImpl;
@useResult
$Res call({
 int incomeMinor, int expenseMinor
});




}
/// @nodoc
class _$DayTotalCopyWithImpl<$Res>
    implements $DayTotalCopyWith<$Res> {
  _$DayTotalCopyWithImpl(this._self, this._then);

  final DayTotal _self;
  final $Res Function(DayTotal) _then;

/// Create a copy of DayTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? incomeMinor = null,Object? expenseMinor = null,}) {
  return _then(DayTotal(
incomeMinor: null == incomeMinor ? _self.incomeMinor : incomeMinor // ignore: cast_nullable_to_non_nullable
as int,expenseMinor: null == expenseMinor ? _self.expenseMinor : expenseMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DayTotal].
extension DayTotalPatterns on DayTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayTotal value)  $default,){
final _that = this;
switch (_that) {
case _DayTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayTotal value)?  $default,){
final _that = this;
switch (_that) {
case _DayTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int incomeMinor,  int expenseMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayTotal() when $default != null:
return $default(_that.incomeMinor,_that.expenseMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int incomeMinor,  int expenseMinor)  $default,) {final _that = this;
switch (_that) {
case _DayTotal():
return $default(_that.incomeMinor,_that.expenseMinor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int incomeMinor,  int expenseMinor)?  $default,) {final _that = this;
switch (_that) {
case _DayTotal() when $default != null:
return $default(_that.incomeMinor,_that.expenseMinor);case _:
  return null;

}
}

}

/// @nodoc


class _DayTotal extends DayTotal {
  const _DayTotal({this.incomeMinor = 0, this.expenseMinor = 0}): super._();
  

@override@JsonKey() final  int incomeMinor;
@override@JsonKey() final  int expenseMinor;

/// Create a copy of DayTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayTotalCopyWith<_DayTotal> get copyWith => __$DayTotalCopyWithImpl<_DayTotal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayTotal&&(identical(other.incomeMinor, incomeMinor) || other.incomeMinor == incomeMinor)&&(identical(other.expenseMinor, expenseMinor) || other.expenseMinor == expenseMinor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,incomeMinor,expenseMinor);
}

@override
String toString() {
    return 'DayTotal(incomeMinor: $incomeMinor, expenseMinor: $expenseMinor)';
}


}

/// @nodoc
abstract mixin class _$DayTotalCopyWith<$Res> implements $DayTotalCopyWith<$Res> {
  factory _$DayTotalCopyWith(_DayTotal value, $Res Function(_DayTotal) _then) = __$DayTotalCopyWithImpl;
@override @useResult
$Res call({
 int incomeMinor, int expenseMinor
});




}
/// @nodoc
class __$DayTotalCopyWithImpl<$Res>
    implements _$DayTotalCopyWith<$Res> {
  __$DayTotalCopyWithImpl(this._self, this._then);

  final _DayTotal _self;
  final $Res Function(_DayTotal) _then;

/// Create a copy of DayTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? incomeMinor = null,Object? expenseMinor = null,}) {
  return _then(_DayTotal(
incomeMinor: null == incomeMinor ? _self.incomeMinor : incomeMinor // ignore: cast_nullable_to_non_nullable
as int,expenseMinor: null == expenseMinor ? _self.expenseMinor : expenseMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PeriodLedger {

 int get incomeMinor; int get expenseMinor;/// Local `yyyy-MM-dd` → totals.
 Map<String, DayTotal> get dayTotals;
/// Create a copy of PeriodLedger
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeriodLedgerCopyWith<PeriodLedger> get copyWith => _$PeriodLedgerCopyWithImpl<PeriodLedger>(this as PeriodLedger, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PeriodLedger;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeriodLedger&&(identical(other.incomeMinor, _this.incomeMinor) || other.incomeMinor == _this.incomeMinor)&&(identical(other.expenseMinor, _this.expenseMinor) || other.expenseMinor == _this.expenseMinor)&&const DeepCollectionEquality().equals(other.dayTotals, _this.dayTotals));
}


@override
int get hashCode {
  final _this = this as PeriodLedger;
  return Object.hash(runtimeType,_this.incomeMinor,_this.expenseMinor,const DeepCollectionEquality().hash(_this.dayTotals));
}

@override
String toString() {
  final _this = this as PeriodLedger;
  return 'PeriodLedger(incomeMinor: ${_this.incomeMinor}, expenseMinor: ${_this.expenseMinor}, dayTotals: ${_this.dayTotals})';
}


}

/// @nodoc
abstract mixin class $PeriodLedgerCopyWith<$Res>  {
  factory $PeriodLedgerCopyWith(PeriodLedger value, $Res Function(PeriodLedger) _then) = _$PeriodLedgerCopyWithImpl;
@useResult
$Res call({
 int incomeMinor, int expenseMinor, Map<String, DayTotal> dayTotals
});




}
/// @nodoc
class _$PeriodLedgerCopyWithImpl<$Res>
    implements $PeriodLedgerCopyWith<$Res> {
  _$PeriodLedgerCopyWithImpl(this._self, this._then);

  final PeriodLedger _self;
  final $Res Function(PeriodLedger) _then;

/// Create a copy of PeriodLedger
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? incomeMinor = null,Object? expenseMinor = null,Object? dayTotals = null,}) {
  return _then(PeriodLedger(
incomeMinor: null == incomeMinor ? _self.incomeMinor : incomeMinor // ignore: cast_nullable_to_non_nullable
as int,expenseMinor: null == expenseMinor ? _self.expenseMinor : expenseMinor // ignore: cast_nullable_to_non_nullable
as int,dayTotals: null == dayTotals ? _self.dayTotals : dayTotals // ignore: cast_nullable_to_non_nullable
as Map<String, DayTotal>,
  ));
}

}


/// Adds pattern-matching-related methods to [PeriodLedger].
extension PeriodLedgerPatterns on PeriodLedger {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeriodLedger value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeriodLedger() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeriodLedger value)  $default,){
final _that = this;
switch (_that) {
case _PeriodLedger():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeriodLedger value)?  $default,){
final _that = this;
switch (_that) {
case _PeriodLedger() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int incomeMinor,  int expenseMinor,  Map<String, DayTotal> dayTotals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeriodLedger() when $default != null:
return $default(_that.incomeMinor,_that.expenseMinor,_that.dayTotals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int incomeMinor,  int expenseMinor,  Map<String, DayTotal> dayTotals)  $default,) {final _that = this;
switch (_that) {
case _PeriodLedger():
return $default(_that.incomeMinor,_that.expenseMinor,_that.dayTotals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int incomeMinor,  int expenseMinor,  Map<String, DayTotal> dayTotals)?  $default,) {final _that = this;
switch (_that) {
case _PeriodLedger() when $default != null:
return $default(_that.incomeMinor,_that.expenseMinor,_that.dayTotals);case _:
  return null;

}
}

}

/// @nodoc


class _PeriodLedger extends PeriodLedger {
  const _PeriodLedger({this.incomeMinor = 0, this.expenseMinor = 0,  Map<String, DayTotal> dayTotals = const <String, DayTotal>{}}): _dayTotals = dayTotals,super._();
  

@override@JsonKey() final  int incomeMinor;
@override@JsonKey() final  int expenseMinor;
/// Local `yyyy-MM-dd` → totals.
 final  Map<String, DayTotal> _dayTotals;
/// Local `yyyy-MM-dd` → totals.
@override@JsonKey() Map<String, DayTotal> get dayTotals {
  if (_dayTotals is EqualUnmodifiableMapView) return _dayTotals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dayTotals);
}


/// Create a copy of PeriodLedger
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeriodLedgerCopyWith<_PeriodLedger> get copyWith => __$PeriodLedgerCopyWithImpl<_PeriodLedger>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeriodLedger&&(identical(other.incomeMinor, incomeMinor) || other.incomeMinor == incomeMinor)&&(identical(other.expenseMinor, expenseMinor) || other.expenseMinor == expenseMinor)&&const DeepCollectionEquality().equals(other.dayTotals, _dayTotals));
}


@override
int get hashCode {
    return Object.hash(runtimeType,incomeMinor,expenseMinor,const DeepCollectionEquality().hash(_dayTotals));
}

@override
String toString() {
    return 'PeriodLedger(incomeMinor: $incomeMinor, expenseMinor: $expenseMinor, dayTotals: $dayTotals)';
}


}

/// @nodoc
abstract mixin class _$PeriodLedgerCopyWith<$Res> implements $PeriodLedgerCopyWith<$Res> {
  factory _$PeriodLedgerCopyWith(_PeriodLedger value, $Res Function(_PeriodLedger) _then) = __$PeriodLedgerCopyWithImpl;
@override @useResult
$Res call({
 int incomeMinor, int expenseMinor, Map<String, DayTotal> dayTotals
});




}
/// @nodoc
class __$PeriodLedgerCopyWithImpl<$Res>
    implements _$PeriodLedgerCopyWith<$Res> {
  __$PeriodLedgerCopyWithImpl(this._self, this._then);

  final _PeriodLedger _self;
  final $Res Function(_PeriodLedger) _then;

/// Create a copy of PeriodLedger
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? incomeMinor = null,Object? expenseMinor = null,Object? dayTotals = null,}) {
  return _then(_PeriodLedger(
incomeMinor: null == incomeMinor ? _self.incomeMinor : incomeMinor // ignore: cast_nullable_to_non_nullable
as int,expenseMinor: null == expenseMinor ? _self.expenseMinor : expenseMinor // ignore: cast_nullable_to_non_nullable
as int,dayTotals: null == dayTotals ? _self._dayTotals : dayTotals // ignore: cast_nullable_to_non_nullable
as Map<String, DayTotal>,
  ));
}


}

// dart format on
