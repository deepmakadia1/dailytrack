// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitSchedule {

 ScheduleType get type;/// 1 for yes/no habits; 1–9,999 for count habits.
 int get target;/// Selected weekdays, 1 = Monday … 7 = Sunday. Used by
/// [ScheduleType.specificWeekdays] only.
 Set<int> get weekdays;/// 1–6. Used by [ScheduleType.timesPerWeek] only.
 int? get timesPerWeek;
/// Create a copy of HabitSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitScheduleCopyWith<HabitSchedule> get copyWith => _$HabitScheduleCopyWithImpl<HabitSchedule>(this as HabitSchedule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitSchedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitSchedule&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.target, _this.target) || other.target == _this.target)&&const DeepCollectionEquality().equals(other.weekdays, _this.weekdays)&&(identical(other.timesPerWeek, _this.timesPerWeek) || other.timesPerWeek == _this.timesPerWeek));
}


@override
int get hashCode {
  final _this = this as HabitSchedule;
  return Object.hash(runtimeType,_this.type,_this.target,const DeepCollectionEquality().hash(_this.weekdays),_this.timesPerWeek);
}

@override
String toString() {
  final _this = this as HabitSchedule;
  return 'HabitSchedule(type: ${_this.type}, target: ${_this.target}, weekdays: ${_this.weekdays}, timesPerWeek: ${_this.timesPerWeek})';
}


}

/// @nodoc
abstract mixin class $HabitScheduleCopyWith<$Res>  {
  factory $HabitScheduleCopyWith(HabitSchedule value, $Res Function(HabitSchedule) _then) = _$HabitScheduleCopyWithImpl;
@useResult
$Res call({
 ScheduleType type, int target, Set<int> weekdays, int? timesPerWeek
});




}
/// @nodoc
class _$HabitScheduleCopyWithImpl<$Res>
    implements $HabitScheduleCopyWith<$Res> {
  _$HabitScheduleCopyWithImpl(this._self, this._then);

  final HabitSchedule _self;
  final $Res Function(HabitSchedule) _then;

/// Create a copy of HabitSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? target = null,Object? weekdays = null,Object? timesPerWeek = freezed,}) {
  return _then(HabitSchedule(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ScheduleType,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,timesPerWeek: freezed == timesPerWeek ? _self.timesPerWeek : timesPerWeek // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitSchedule].
extension HabitSchedulePatterns on HabitSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitSchedule value)  $default,){
final _that = this;
switch (_that) {
case _HabitSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _HabitSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScheduleType type,  int target,  Set<int> weekdays,  int? timesPerWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitSchedule() when $default != null:
return $default(_that.type,_that.target,_that.weekdays,_that.timesPerWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScheduleType type,  int target,  Set<int> weekdays,  int? timesPerWeek)  $default,) {final _that = this;
switch (_that) {
case _HabitSchedule():
return $default(_that.type,_that.target,_that.weekdays,_that.timesPerWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScheduleType type,  int target,  Set<int> weekdays,  int? timesPerWeek)?  $default,) {final _that = this;
switch (_that) {
case _HabitSchedule() when $default != null:
return $default(_that.type,_that.target,_that.weekdays,_that.timesPerWeek);case _:
  return null;

}
}

}

/// @nodoc


class _HabitSchedule extends HabitSchedule {
  const _HabitSchedule({required this.type, required this.target,  Set<int> weekdays = const <int>{}, this.timesPerWeek}): _weekdays = weekdays,super._();
  

@override final  ScheduleType type;
/// 1 for yes/no habits; 1–9,999 for count habits.
@override final  int target;
/// Selected weekdays, 1 = Monday … 7 = Sunday. Used by
/// [ScheduleType.specificWeekdays] only.
 final  Set<int> _weekdays;
/// Selected weekdays, 1 = Monday … 7 = Sunday. Used by
/// [ScheduleType.specificWeekdays] only.
@override@JsonKey() Set<int> get weekdays {
  if (_weekdays is EqualUnmodifiableSetView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_weekdays);
}

/// 1–6. Used by [ScheduleType.timesPerWeek] only.
@override final  int? timesPerWeek;

/// Create a copy of HabitSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitScheduleCopyWith<_HabitSchedule> get copyWith => __$HabitScheduleCopyWithImpl<_HabitSchedule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitSchedule&&(identical(other.type, type) || other.type == type)&&(identical(other.target, target) || other.target == target)&&const DeepCollectionEquality().equals(other.weekdays, _weekdays)&&(identical(other.timesPerWeek, timesPerWeek) || other.timesPerWeek == timesPerWeek));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,target,const DeepCollectionEquality().hash(_weekdays),timesPerWeek);
}

@override
String toString() {
    return 'HabitSchedule(type: $type, target: $target, weekdays: $weekdays, timesPerWeek: $timesPerWeek)';
}


}

/// @nodoc
abstract mixin class _$HabitScheduleCopyWith<$Res> implements $HabitScheduleCopyWith<$Res> {
  factory _$HabitScheduleCopyWith(_HabitSchedule value, $Res Function(_HabitSchedule) _then) = __$HabitScheduleCopyWithImpl;
@override @useResult
$Res call({
 ScheduleType type, int target, Set<int> weekdays, int? timesPerWeek
});




}
/// @nodoc
class __$HabitScheduleCopyWithImpl<$Res>
    implements _$HabitScheduleCopyWith<$Res> {
  __$HabitScheduleCopyWithImpl(this._self, this._then);

  final _HabitSchedule _self;
  final $Res Function(_HabitSchedule) _then;

/// Create a copy of HabitSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? target = null,Object? weekdays = null,Object? timesPerWeek = freezed,}) {
  return _then(_HabitSchedule(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ScheduleType,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,weekdays: null == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,timesPerWeek: freezed == timesPerWeek ? _self.timesPerWeek : timesPerWeek // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
