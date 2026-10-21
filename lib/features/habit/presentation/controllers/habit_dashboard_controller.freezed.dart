// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_dashboard_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitCheckData {

 Habit get habit; bool get isDone; int get value; int get target;
/// Create a copy of HabitCheckData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitCheckDataCopyWith<HabitCheckData> get copyWith => _$HabitCheckDataCopyWithImpl<HabitCheckData>(this as HabitCheckData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitCheckData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitCheckData&&(identical(other.habit, _this.habit) || other.habit == _this.habit)&&(identical(other.isDone, _this.isDone) || other.isDone == _this.isDone)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.target, _this.target) || other.target == _this.target));
}


@override
int get hashCode {
  final _this = this as HabitCheckData;
  return Object.hash(runtimeType,_this.habit,_this.isDone,_this.value,_this.target);
}

@override
String toString() {
  final _this = this as HabitCheckData;
  return 'HabitCheckData(habit: ${_this.habit}, isDone: ${_this.isDone}, value: ${_this.value}, target: ${_this.target})';
}


}

/// @nodoc
abstract mixin class $HabitCheckDataCopyWith<$Res>  {
  factory $HabitCheckDataCopyWith(HabitCheckData value, $Res Function(HabitCheckData) _then) = _$HabitCheckDataCopyWithImpl;
@useResult
$Res call({
 Habit habit, bool isDone, int value, int target
});


$HabitCopyWith<$Res> get habit;

}
/// @nodoc
class _$HabitCheckDataCopyWithImpl<$Res>
    implements $HabitCheckDataCopyWith<$Res> {
  _$HabitCheckDataCopyWithImpl(this._self, this._then);

  final HabitCheckData _self;
  final $Res Function(HabitCheckData) _then;

/// Create a copy of HabitCheckData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habit = null,Object? isDone = null,Object? value = null,Object? target = null,}) {
  return _then(HabitCheckData(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of HabitCheckData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitCheckData].
extension HabitCheckDataPatterns on HabitCheckData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitCheckData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitCheckData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitCheckData value)  $default,){
final _that = this;
switch (_that) {
case _HabitCheckData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitCheckData value)?  $default,){
final _that = this;
switch (_that) {
case _HabitCheckData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Habit habit,  bool isDone,  int value,  int target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitCheckData() when $default != null:
return $default(_that.habit,_that.isDone,_that.value,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Habit habit,  bool isDone,  int value,  int target)  $default,) {final _that = this;
switch (_that) {
case _HabitCheckData():
return $default(_that.habit,_that.isDone,_that.value,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Habit habit,  bool isDone,  int value,  int target)?  $default,) {final _that = this;
switch (_that) {
case _HabitCheckData() when $default != null:
return $default(_that.habit,_that.isDone,_that.value,_that.target);case _:
  return null;

}
}

}

/// @nodoc


class _HabitCheckData implements HabitCheckData {
  const _HabitCheckData({required this.habit, required this.isDone, required this.value, required this.target});
  

@override final  Habit habit;
@override final  bool isDone;
@override final  int value;
@override final  int target;

/// Create a copy of HabitCheckData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitCheckDataCopyWith<_HabitCheckData> get copyWith => __$HabitCheckDataCopyWithImpl<_HabitCheckData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitCheckData&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.value, value) || other.value == value)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode {
    return Object.hash(runtimeType,habit,isDone,value,target);
}

@override
String toString() {
    return 'HabitCheckData(habit: $habit, isDone: $isDone, value: $value, target: $target)';
}


}

/// @nodoc
abstract mixin class _$HabitCheckDataCopyWith<$Res> implements $HabitCheckDataCopyWith<$Res> {
  factory _$HabitCheckDataCopyWith(_HabitCheckData value, $Res Function(_HabitCheckData) _then) = __$HabitCheckDataCopyWithImpl;
@override @useResult
$Res call({
 Habit habit, bool isDone, int value, int target
});


@override $HabitCopyWith<$Res> get habit;

}
/// @nodoc
class __$HabitCheckDataCopyWithImpl<$Res>
    implements _$HabitCheckDataCopyWith<$Res> {
  __$HabitCheckDataCopyWithImpl(this._self, this._then);

  final _HabitCheckData _self;
  final $Res Function(_HabitCheckData) _then;

/// Create a copy of HabitCheckData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habit = null,Object? isDone = null,Object? value = null,Object? target = null,}) {
  return _then(_HabitCheckData(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of HabitCheckData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}
}

/// @nodoc
mixin _$HabitDashboardData {

 int get doneCount; int get scheduledCount;/// Today's scheduled habits, in sort order.
 List<HabitCheckData> get checks; bool get hasHabits;
/// Create a copy of HabitDashboardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitDashboardDataCopyWith<HabitDashboardData> get copyWith => _$HabitDashboardDataCopyWithImpl<HabitDashboardData>(this as HabitDashboardData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitDashboardData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDashboardData&&(identical(other.doneCount, _this.doneCount) || other.doneCount == _this.doneCount)&&(identical(other.scheduledCount, _this.scheduledCount) || other.scheduledCount == _this.scheduledCount)&&const DeepCollectionEquality().equals(other.checks, _this.checks)&&(identical(other.hasHabits, _this.hasHabits) || other.hasHabits == _this.hasHabits));
}


@override
int get hashCode {
  final _this = this as HabitDashboardData;
  return Object.hash(runtimeType,_this.doneCount,_this.scheduledCount,const DeepCollectionEquality().hash(_this.checks),_this.hasHabits);
}

@override
String toString() {
  final _this = this as HabitDashboardData;
  return 'HabitDashboardData(doneCount: ${_this.doneCount}, scheduledCount: ${_this.scheduledCount}, checks: ${_this.checks}, hasHabits: ${_this.hasHabits})';
}


}

/// @nodoc
abstract mixin class $HabitDashboardDataCopyWith<$Res>  {
  factory $HabitDashboardDataCopyWith(HabitDashboardData value, $Res Function(HabitDashboardData) _then) = _$HabitDashboardDataCopyWithImpl;
@useResult
$Res call({
 int doneCount, int scheduledCount, List<HabitCheckData> checks, bool hasHabits
});




}
/// @nodoc
class _$HabitDashboardDataCopyWithImpl<$Res>
    implements $HabitDashboardDataCopyWith<$Res> {
  _$HabitDashboardDataCopyWithImpl(this._self, this._then);

  final HabitDashboardData _self;
  final $Res Function(HabitDashboardData) _then;

/// Create a copy of HabitDashboardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? doneCount = null,Object? scheduledCount = null,Object? checks = null,Object? hasHabits = null,}) {
  return _then(HabitDashboardData(
doneCount: null == doneCount ? _self.doneCount : doneCount // ignore: cast_nullable_to_non_nullable
as int,scheduledCount: null == scheduledCount ? _self.scheduledCount : scheduledCount // ignore: cast_nullable_to_non_nullable
as int,checks: null == checks ? _self.checks : checks // ignore: cast_nullable_to_non_nullable
as List<HabitCheckData>,hasHabits: null == hasHabits ? _self.hasHabits : hasHabits // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitDashboardData].
extension HabitDashboardDataPatterns on HabitDashboardData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitDashboardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitDashboardData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitDashboardData value)  $default,){
final _that = this;
switch (_that) {
case _HabitDashboardData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitDashboardData value)?  $default,){
final _that = this;
switch (_that) {
case _HabitDashboardData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int doneCount,  int scheduledCount,  List<HabitCheckData> checks,  bool hasHabits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitDashboardData() when $default != null:
return $default(_that.doneCount,_that.scheduledCount,_that.checks,_that.hasHabits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int doneCount,  int scheduledCount,  List<HabitCheckData> checks,  bool hasHabits)  $default,) {final _that = this;
switch (_that) {
case _HabitDashboardData():
return $default(_that.doneCount,_that.scheduledCount,_that.checks,_that.hasHabits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int doneCount,  int scheduledCount,  List<HabitCheckData> checks,  bool hasHabits)?  $default,) {final _that = this;
switch (_that) {
case _HabitDashboardData() when $default != null:
return $default(_that.doneCount,_that.scheduledCount,_that.checks,_that.hasHabits);case _:
  return null;

}
}

}

/// @nodoc


class _HabitDashboardData implements HabitDashboardData {
  const _HabitDashboardData({required this.doneCount, required this.scheduledCount, required  List<HabitCheckData> checks, required this.hasHabits}): _checks = checks;
  

@override final  int doneCount;
@override final  int scheduledCount;
/// Today's scheduled habits, in sort order.
 final  List<HabitCheckData> _checks;
/// Today's scheduled habits, in sort order.
@override List<HabitCheckData> get checks {
  if (_checks is EqualUnmodifiableListView) return _checks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checks);
}

@override final  bool hasHabits;

/// Create a copy of HabitDashboardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitDashboardDataCopyWith<_HabitDashboardData> get copyWith => __$HabitDashboardDataCopyWithImpl<_HabitDashboardData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitDashboardData&&(identical(other.doneCount, doneCount) || other.doneCount == doneCount)&&(identical(other.scheduledCount, scheduledCount) || other.scheduledCount == scheduledCount)&&const DeepCollectionEquality().equals(other.checks, _checks)&&(identical(other.hasHabits, hasHabits) || other.hasHabits == hasHabits));
}


@override
int get hashCode {
    return Object.hash(runtimeType,doneCount,scheduledCount,const DeepCollectionEquality().hash(_checks),hasHabits);
}

@override
String toString() {
    return 'HabitDashboardData(doneCount: $doneCount, scheduledCount: $scheduledCount, checks: $checks, hasHabits: $hasHabits)';
}


}

/// @nodoc
abstract mixin class _$HabitDashboardDataCopyWith<$Res> implements $HabitDashboardDataCopyWith<$Res> {
  factory _$HabitDashboardDataCopyWith(_HabitDashboardData value, $Res Function(_HabitDashboardData) _then) = __$HabitDashboardDataCopyWithImpl;
@override @useResult
$Res call({
 int doneCount, int scheduledCount, List<HabitCheckData> checks, bool hasHabits
});




}
/// @nodoc
class __$HabitDashboardDataCopyWithImpl<$Res>
    implements _$HabitDashboardDataCopyWith<$Res> {
  __$HabitDashboardDataCopyWithImpl(this._self, this._then);

  final _HabitDashboardData _self;
  final $Res Function(_HabitDashboardData) _then;

/// Create a copy of HabitDashboardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? doneCount = null,Object? scheduledCount = null,Object? checks = null,Object? hasHabits = null,}) {
  return _then(_HabitDashboardData(
doneCount: null == doneCount ? _self.doneCount : doneCount // ignore: cast_nullable_to_non_nullable
as int,scheduledCount: null == scheduledCount ? _self.scheduledCount : scheduledCount // ignore: cast_nullable_to_non_nullable
as int,checks: null == checks ? _self._checks : checks // ignore: cast_nullable_to_non_nullable
as List<HabitCheckData>,hasHabits: null == hasHabits ? _self.hasHabits : hasHabits // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
