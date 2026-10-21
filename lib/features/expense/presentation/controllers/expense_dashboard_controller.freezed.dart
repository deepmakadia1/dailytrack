// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_dashboard_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpenseDashboardData {

 int get todayMinor; int get monthMinor; bool get hasAnyTransaction;/// This month's Overall budget, or null when none is set.
 BudgetStatus? get overall;
/// Create a copy of ExpenseDashboardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseDashboardDataCopyWith<ExpenseDashboardData> get copyWith => _$ExpenseDashboardDataCopyWithImpl<ExpenseDashboardData>(this as ExpenseDashboardData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExpenseDashboardData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseDashboardData&&(identical(other.todayMinor, _this.todayMinor) || other.todayMinor == _this.todayMinor)&&(identical(other.monthMinor, _this.monthMinor) || other.monthMinor == _this.monthMinor)&&(identical(other.hasAnyTransaction, _this.hasAnyTransaction) || other.hasAnyTransaction == _this.hasAnyTransaction)&&(identical(other.overall, _this.overall) || other.overall == _this.overall));
}


@override
int get hashCode {
  final _this = this as ExpenseDashboardData;
  return Object.hash(runtimeType,_this.todayMinor,_this.monthMinor,_this.hasAnyTransaction,_this.overall);
}

@override
String toString() {
  final _this = this as ExpenseDashboardData;
  return 'ExpenseDashboardData(todayMinor: ${_this.todayMinor}, monthMinor: ${_this.monthMinor}, hasAnyTransaction: ${_this.hasAnyTransaction}, overall: ${_this.overall})';
}


}

/// @nodoc
abstract mixin class $ExpenseDashboardDataCopyWith<$Res>  {
  factory $ExpenseDashboardDataCopyWith(ExpenseDashboardData value, $Res Function(ExpenseDashboardData) _then) = _$ExpenseDashboardDataCopyWithImpl;
@useResult
$Res call({
 int todayMinor, int monthMinor, bool hasAnyTransaction, BudgetStatus? overall
});


$BudgetStatusCopyWith<$Res>? get overall;

}
/// @nodoc
class _$ExpenseDashboardDataCopyWithImpl<$Res>
    implements $ExpenseDashboardDataCopyWith<$Res> {
  _$ExpenseDashboardDataCopyWithImpl(this._self, this._then);

  final ExpenseDashboardData _self;
  final $Res Function(ExpenseDashboardData) _then;

/// Create a copy of ExpenseDashboardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todayMinor = null,Object? monthMinor = null,Object? hasAnyTransaction = null,Object? overall = freezed,}) {
  return _then(ExpenseDashboardData(
todayMinor: null == todayMinor ? _self.todayMinor : todayMinor // ignore: cast_nullable_to_non_nullable
as int,monthMinor: null == monthMinor ? _self.monthMinor : monthMinor // ignore: cast_nullable_to_non_nullable
as int,hasAnyTransaction: null == hasAnyTransaction ? _self.hasAnyTransaction : hasAnyTransaction // ignore: cast_nullable_to_non_nullable
as bool,overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as BudgetStatus?,
  ));
}
/// Create a copy of ExpenseDashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $BudgetStatusCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExpenseDashboardData].
extension ExpenseDashboardDataPatterns on ExpenseDashboardData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseDashboardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseDashboardData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseDashboardData value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseDashboardData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseDashboardData value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseDashboardData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int todayMinor,  int monthMinor,  bool hasAnyTransaction,  BudgetStatus? overall)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseDashboardData() when $default != null:
return $default(_that.todayMinor,_that.monthMinor,_that.hasAnyTransaction,_that.overall);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int todayMinor,  int monthMinor,  bool hasAnyTransaction,  BudgetStatus? overall)  $default,) {final _that = this;
switch (_that) {
case _ExpenseDashboardData():
return $default(_that.todayMinor,_that.monthMinor,_that.hasAnyTransaction,_that.overall);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int todayMinor,  int monthMinor,  bool hasAnyTransaction,  BudgetStatus? overall)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseDashboardData() when $default != null:
return $default(_that.todayMinor,_that.monthMinor,_that.hasAnyTransaction,_that.overall);case _:
  return null;

}
}

}

/// @nodoc


class _ExpenseDashboardData implements ExpenseDashboardData {
  const _ExpenseDashboardData({required this.todayMinor, required this.monthMinor, required this.hasAnyTransaction, this.overall});
  

@override final  int todayMinor;
@override final  int monthMinor;
@override final  bool hasAnyTransaction;
/// This month's Overall budget, or null when none is set.
@override final  BudgetStatus? overall;

/// Create a copy of ExpenseDashboardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseDashboardDataCopyWith<_ExpenseDashboardData> get copyWith => __$ExpenseDashboardDataCopyWithImpl<_ExpenseDashboardData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseDashboardData&&(identical(other.todayMinor, todayMinor) || other.todayMinor == todayMinor)&&(identical(other.monthMinor, monthMinor) || other.monthMinor == monthMinor)&&(identical(other.hasAnyTransaction, hasAnyTransaction) || other.hasAnyTransaction == hasAnyTransaction)&&(identical(other.overall, overall) || other.overall == overall));
}


@override
int get hashCode {
    return Object.hash(runtimeType,todayMinor,monthMinor,hasAnyTransaction,overall);
}

@override
String toString() {
    return 'ExpenseDashboardData(todayMinor: $todayMinor, monthMinor: $monthMinor, hasAnyTransaction: $hasAnyTransaction, overall: $overall)';
}


}

/// @nodoc
abstract mixin class _$ExpenseDashboardDataCopyWith<$Res> implements $ExpenseDashboardDataCopyWith<$Res> {
  factory _$ExpenseDashboardDataCopyWith(_ExpenseDashboardData value, $Res Function(_ExpenseDashboardData) _then) = __$ExpenseDashboardDataCopyWithImpl;
@override @useResult
$Res call({
 int todayMinor, int monthMinor, bool hasAnyTransaction, BudgetStatus? overall
});


@override $BudgetStatusCopyWith<$Res>? get overall;

}
/// @nodoc
class __$ExpenseDashboardDataCopyWithImpl<$Res>
    implements _$ExpenseDashboardDataCopyWith<$Res> {
  __$ExpenseDashboardDataCopyWithImpl(this._self, this._then);

  final _ExpenseDashboardData _self;
  final $Res Function(_ExpenseDashboardData) _then;

/// Create a copy of ExpenseDashboardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todayMinor = null,Object? monthMinor = null,Object? hasAnyTransaction = null,Object? overall = freezed,}) {
  return _then(_ExpenseDashboardData(
todayMinor: null == todayMinor ? _self.todayMinor : todayMinor // ignore: cast_nullable_to_non_nullable
as int,monthMinor: null == monthMinor ? _self.monthMinor : monthMinor // ignore: cast_nullable_to_non_nullable
as int,hasAnyTransaction: null == hasAnyTransaction ? _self.hasAnyTransaction : hasAnyTransaction // ignore: cast_nullable_to_non_nullable
as bool,overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as BudgetStatus?,
  ));
}

/// Create a copy of ExpenseDashboardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $BudgetStatusCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}

// dart format on
