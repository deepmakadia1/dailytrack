// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_and_month_spend.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodayAndMonthSpend {

 int get todayMinor; int get monthMinor; bool get hasAnyTransaction;
/// Create a copy of TodayAndMonthSpend
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayAndMonthSpendCopyWith<TodayAndMonthSpend> get copyWith => _$TodayAndMonthSpendCopyWithImpl<TodayAndMonthSpend>(this as TodayAndMonthSpend, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TodayAndMonthSpend;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayAndMonthSpend&&(identical(other.todayMinor, _this.todayMinor) || other.todayMinor == _this.todayMinor)&&(identical(other.monthMinor, _this.monthMinor) || other.monthMinor == _this.monthMinor)&&(identical(other.hasAnyTransaction, _this.hasAnyTransaction) || other.hasAnyTransaction == _this.hasAnyTransaction));
}


@override
int get hashCode {
  final _this = this as TodayAndMonthSpend;
  return Object.hash(runtimeType,_this.todayMinor,_this.monthMinor,_this.hasAnyTransaction);
}

@override
String toString() {
  final _this = this as TodayAndMonthSpend;
  return 'TodayAndMonthSpend(todayMinor: ${_this.todayMinor}, monthMinor: ${_this.monthMinor}, hasAnyTransaction: ${_this.hasAnyTransaction})';
}


}

/// @nodoc
abstract mixin class $TodayAndMonthSpendCopyWith<$Res>  {
  factory $TodayAndMonthSpendCopyWith(TodayAndMonthSpend value, $Res Function(TodayAndMonthSpend) _then) = _$TodayAndMonthSpendCopyWithImpl;
@useResult
$Res call({
 int todayMinor, int monthMinor, bool hasAnyTransaction
});




}
/// @nodoc
class _$TodayAndMonthSpendCopyWithImpl<$Res>
    implements $TodayAndMonthSpendCopyWith<$Res> {
  _$TodayAndMonthSpendCopyWithImpl(this._self, this._then);

  final TodayAndMonthSpend _self;
  final $Res Function(TodayAndMonthSpend) _then;

/// Create a copy of TodayAndMonthSpend
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todayMinor = null,Object? monthMinor = null,Object? hasAnyTransaction = null,}) {
  return _then(TodayAndMonthSpend(
todayMinor: null == todayMinor ? _self.todayMinor : todayMinor // ignore: cast_nullable_to_non_nullable
as int,monthMinor: null == monthMinor ? _self.monthMinor : monthMinor // ignore: cast_nullable_to_non_nullable
as int,hasAnyTransaction: null == hasAnyTransaction ? _self.hasAnyTransaction : hasAnyTransaction // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayAndMonthSpend].
extension TodayAndMonthSpendPatterns on TodayAndMonthSpend {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayAndMonthSpend value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayAndMonthSpend() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayAndMonthSpend value)  $default,){
final _that = this;
switch (_that) {
case _TodayAndMonthSpend():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayAndMonthSpend value)?  $default,){
final _that = this;
switch (_that) {
case _TodayAndMonthSpend() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int todayMinor,  int monthMinor,  bool hasAnyTransaction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayAndMonthSpend() when $default != null:
return $default(_that.todayMinor,_that.monthMinor,_that.hasAnyTransaction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int todayMinor,  int monthMinor,  bool hasAnyTransaction)  $default,) {final _that = this;
switch (_that) {
case _TodayAndMonthSpend():
return $default(_that.todayMinor,_that.monthMinor,_that.hasAnyTransaction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int todayMinor,  int monthMinor,  bool hasAnyTransaction)?  $default,) {final _that = this;
switch (_that) {
case _TodayAndMonthSpend() when $default != null:
return $default(_that.todayMinor,_that.monthMinor,_that.hasAnyTransaction);case _:
  return null;

}
}

}

/// @nodoc


class _TodayAndMonthSpend implements TodayAndMonthSpend {
  const _TodayAndMonthSpend({required this.todayMinor, required this.monthMinor, required this.hasAnyTransaction});
  

@override final  int todayMinor;
@override final  int monthMinor;
@override final  bool hasAnyTransaction;

/// Create a copy of TodayAndMonthSpend
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayAndMonthSpendCopyWith<_TodayAndMonthSpend> get copyWith => __$TodayAndMonthSpendCopyWithImpl<_TodayAndMonthSpend>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayAndMonthSpend&&(identical(other.todayMinor, todayMinor) || other.todayMinor == todayMinor)&&(identical(other.monthMinor, monthMinor) || other.monthMinor == monthMinor)&&(identical(other.hasAnyTransaction, hasAnyTransaction) || other.hasAnyTransaction == hasAnyTransaction));
}


@override
int get hashCode {
    return Object.hash(runtimeType,todayMinor,monthMinor,hasAnyTransaction);
}

@override
String toString() {
    return 'TodayAndMonthSpend(todayMinor: $todayMinor, monthMinor: $monthMinor, hasAnyTransaction: $hasAnyTransaction)';
}


}

/// @nodoc
abstract mixin class _$TodayAndMonthSpendCopyWith<$Res> implements $TodayAndMonthSpendCopyWith<$Res> {
  factory _$TodayAndMonthSpendCopyWith(_TodayAndMonthSpend value, $Res Function(_TodayAndMonthSpend) _then) = __$TodayAndMonthSpendCopyWithImpl;
@override @useResult
$Res call({
 int todayMinor, int monthMinor, bool hasAnyTransaction
});




}
/// @nodoc
class __$TodayAndMonthSpendCopyWithImpl<$Res>
    implements _$TodayAndMonthSpendCopyWith<$Res> {
  __$TodayAndMonthSpendCopyWithImpl(this._self, this._then);

  final _TodayAndMonthSpend _self;
  final $Res Function(_TodayAndMonthSpend) _then;

/// Create a copy of TodayAndMonthSpend
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todayMinor = null,Object? monthMinor = null,Object? hasAnyTransaction = null,}) {
  return _then(_TodayAndMonthSpend(
todayMinor: null == todayMinor ? _self.todayMinor : todayMinor // ignore: cast_nullable_to_non_nullable
as int,monthMinor: null == monthMinor ? _self.monthMinor : monthMinor // ignore: cast_nullable_to_non_nullable
as int,hasAnyTransaction: null == hasAnyTransaction ? _self.hasAnyTransaction : hasAnyTransaction // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
