// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archived_habits_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArchivedHabitRow {

 Habit get habit; DateTime get archivedAt; int get bestStreak; StreakUnit get unit;
/// Create a copy of ArchivedHabitRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArchivedHabitRowCopyWith<ArchivedHabitRow> get copyWith => _$ArchivedHabitRowCopyWithImpl<ArchivedHabitRow>(this as ArchivedHabitRow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ArchivedHabitRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArchivedHabitRow&&(identical(other.habit, _this.habit) || other.habit == _this.habit)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt)&&(identical(other.bestStreak, _this.bestStreak) || other.bestStreak == _this.bestStreak)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}


@override
int get hashCode {
  final _this = this as ArchivedHabitRow;
  return Object.hash(runtimeType,_this.habit,_this.archivedAt,_this.bestStreak,_this.unit);
}

@override
String toString() {
  final _this = this as ArchivedHabitRow;
  return 'ArchivedHabitRow(habit: ${_this.habit}, archivedAt: ${_this.archivedAt}, bestStreak: ${_this.bestStreak}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $ArchivedHabitRowCopyWith<$Res>  {
  factory $ArchivedHabitRowCopyWith(ArchivedHabitRow value, $Res Function(ArchivedHabitRow) _then) = _$ArchivedHabitRowCopyWithImpl;
@useResult
$Res call({
 Habit habit, DateTime archivedAt, int bestStreak, StreakUnit unit
});


$HabitCopyWith<$Res> get habit;

}
/// @nodoc
class _$ArchivedHabitRowCopyWithImpl<$Res>
    implements $ArchivedHabitRowCopyWith<$Res> {
  _$ArchivedHabitRowCopyWithImpl(this._self, this._then);

  final ArchivedHabitRow _self;
  final $Res Function(ArchivedHabitRow) _then;

/// Create a copy of ArchivedHabitRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habit = null,Object? archivedAt = null,Object? bestStreak = null,Object? unit = null,}) {
  return _then(ArchivedHabitRow(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,archivedAt: null == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as StreakUnit,
  ));
}
/// Create a copy of ArchivedHabitRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}
}


/// Adds pattern-matching-related methods to [ArchivedHabitRow].
extension ArchivedHabitRowPatterns on ArchivedHabitRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArchivedHabitRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArchivedHabitRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArchivedHabitRow value)  $default,){
final _that = this;
switch (_that) {
case _ArchivedHabitRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArchivedHabitRow value)?  $default,){
final _that = this;
switch (_that) {
case _ArchivedHabitRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Habit habit,  DateTime archivedAt,  int bestStreak,  StreakUnit unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArchivedHabitRow() when $default != null:
return $default(_that.habit,_that.archivedAt,_that.bestStreak,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Habit habit,  DateTime archivedAt,  int bestStreak,  StreakUnit unit)  $default,) {final _that = this;
switch (_that) {
case _ArchivedHabitRow():
return $default(_that.habit,_that.archivedAt,_that.bestStreak,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Habit habit,  DateTime archivedAt,  int bestStreak,  StreakUnit unit)?  $default,) {final _that = this;
switch (_that) {
case _ArchivedHabitRow() when $default != null:
return $default(_that.habit,_that.archivedAt,_that.bestStreak,_that.unit);case _:
  return null;

}
}

}

/// @nodoc


class _ArchivedHabitRow implements ArchivedHabitRow {
  const _ArchivedHabitRow({required this.habit, required this.archivedAt, required this.bestStreak, required this.unit});
  

@override final  Habit habit;
@override final  DateTime archivedAt;
@override final  int bestStreak;
@override final  StreakUnit unit;

/// Create a copy of ArchivedHabitRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchivedHabitRowCopyWith<_ArchivedHabitRow> get copyWith => __$ArchivedHabitRowCopyWithImpl<_ArchivedHabitRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArchivedHabitRow&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.bestStreak, bestStreak) || other.bestStreak == bestStreak)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,habit,archivedAt,bestStreak,unit);
}

@override
String toString() {
    return 'ArchivedHabitRow(habit: $habit, archivedAt: $archivedAt, bestStreak: $bestStreak, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$ArchivedHabitRowCopyWith<$Res> implements $ArchivedHabitRowCopyWith<$Res> {
  factory _$ArchivedHabitRowCopyWith(_ArchivedHabitRow value, $Res Function(_ArchivedHabitRow) _then) = __$ArchivedHabitRowCopyWithImpl;
@override @useResult
$Res call({
 Habit habit, DateTime archivedAt, int bestStreak, StreakUnit unit
});


@override $HabitCopyWith<$Res> get habit;

}
/// @nodoc
class __$ArchivedHabitRowCopyWithImpl<$Res>
    implements _$ArchivedHabitRowCopyWith<$Res> {
  __$ArchivedHabitRowCopyWithImpl(this._self, this._then);

  final _ArchivedHabitRow _self;
  final $Res Function(_ArchivedHabitRow) _then;

/// Create a copy of ArchivedHabitRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habit = null,Object? archivedAt = null,Object? bestStreak = null,Object? unit = null,}) {
  return _then(_ArchivedHabitRow(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,archivedAt: null == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,bestStreak: null == bestStreak ? _self.bestStreak : bestStreak // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as StreakUnit,
  ));
}

/// Create a copy of ArchivedHabitRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}
}

// dart format on
