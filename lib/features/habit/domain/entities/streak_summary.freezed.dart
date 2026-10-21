// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StreakSummary {

 int get current; int get best; int get totalCompletions; StreakUnit get unit;/// Whole percent over the last 30 days, or null when no day (week)
/// counts yet.
 int? get completionRate;
/// Create a copy of StreakSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakSummaryCopyWith<StreakSummary> get copyWith => _$StreakSummaryCopyWithImpl<StreakSummary>(this as StreakSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StreakSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakSummary&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.best, _this.best) || other.best == _this.best)&&(identical(other.totalCompletions, _this.totalCompletions) || other.totalCompletions == _this.totalCompletions)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.completionRate, _this.completionRate) || other.completionRate == _this.completionRate));
}


@override
int get hashCode {
  final _this = this as StreakSummary;
  return Object.hash(runtimeType,_this.current,_this.best,_this.totalCompletions,_this.unit,_this.completionRate);
}

@override
String toString() {
  final _this = this as StreakSummary;
  return 'StreakSummary(current: ${_this.current}, best: ${_this.best}, totalCompletions: ${_this.totalCompletions}, unit: ${_this.unit}, completionRate: ${_this.completionRate})';
}


}

/// @nodoc
abstract mixin class $StreakSummaryCopyWith<$Res>  {
  factory $StreakSummaryCopyWith(StreakSummary value, $Res Function(StreakSummary) _then) = _$StreakSummaryCopyWithImpl;
@useResult
$Res call({
 int current, int best, int totalCompletions, StreakUnit unit, int? completionRate
});




}
/// @nodoc
class _$StreakSummaryCopyWithImpl<$Res>
    implements $StreakSummaryCopyWith<$Res> {
  _$StreakSummaryCopyWithImpl(this._self, this._then);

  final StreakSummary _self;
  final $Res Function(StreakSummary) _then;

/// Create a copy of StreakSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? best = null,Object? totalCompletions = null,Object? unit = null,Object? completionRate = freezed,}) {
  return _then(StreakSummary(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,totalCompletions: null == totalCompletions ? _self.totalCompletions : totalCompletions // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as StreakUnit,completionRate: freezed == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakSummary].
extension StreakSummaryPatterns on StreakSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakSummary value)  $default,){
final _that = this;
switch (_that) {
case _StreakSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakSummary value)?  $default,){
final _that = this;
switch (_that) {
case _StreakSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int best,  int totalCompletions,  StreakUnit unit,  int? completionRate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakSummary() when $default != null:
return $default(_that.current,_that.best,_that.totalCompletions,_that.unit,_that.completionRate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int best,  int totalCompletions,  StreakUnit unit,  int? completionRate)  $default,) {final _that = this;
switch (_that) {
case _StreakSummary():
return $default(_that.current,_that.best,_that.totalCompletions,_that.unit,_that.completionRate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int best,  int totalCompletions,  StreakUnit unit,  int? completionRate)?  $default,) {final _that = this;
switch (_that) {
case _StreakSummary() when $default != null:
return $default(_that.current,_that.best,_that.totalCompletions,_that.unit,_that.completionRate);case _:
  return null;

}
}

}

/// @nodoc


class _StreakSummary implements StreakSummary {
  const _StreakSummary({required this.current, required this.best, required this.totalCompletions, required this.unit, this.completionRate});
  

@override final  int current;
@override final  int best;
@override final  int totalCompletions;
@override final  StreakUnit unit;
/// Whole percent over the last 30 days, or null when no day (week)
/// counts yet.
@override final  int? completionRate;

/// Create a copy of StreakSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakSummaryCopyWith<_StreakSummary> get copyWith => __$StreakSummaryCopyWithImpl<_StreakSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakSummary&&(identical(other.current, current) || other.current == current)&&(identical(other.best, best) || other.best == best)&&(identical(other.totalCompletions, totalCompletions) || other.totalCompletions == totalCompletions)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,current,best,totalCompletions,unit,completionRate);
}

@override
String toString() {
    return 'StreakSummary(current: $current, best: $best, totalCompletions: $totalCompletions, unit: $unit, completionRate: $completionRate)';
}


}

/// @nodoc
abstract mixin class _$StreakSummaryCopyWith<$Res> implements $StreakSummaryCopyWith<$Res> {
  factory _$StreakSummaryCopyWith(_StreakSummary value, $Res Function(_StreakSummary) _then) = __$StreakSummaryCopyWithImpl;
@override @useResult
$Res call({
 int current, int best, int totalCompletions, StreakUnit unit, int? completionRate
});




}
/// @nodoc
class __$StreakSummaryCopyWithImpl<$Res>
    implements _$StreakSummaryCopyWith<$Res> {
  __$StreakSummaryCopyWithImpl(this._self, this._then);

  final _StreakSummary _self;
  final $Res Function(_StreakSummary) _then;

/// Create a copy of StreakSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? best = null,Object? totalCompletions = null,Object? unit = null,Object? completionRate = freezed,}) {
  return _then(_StreakSummary(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,totalCompletions: null == totalCompletions ? _self.totalCompletions : totalCompletions // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as StreakUnit,completionRate: freezed == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
