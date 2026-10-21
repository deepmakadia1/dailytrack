// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScheduleVersion {

 LocalDate get effectiveFrom; HabitSchedule get schedule;
/// Create a copy of ScheduleVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleVersionCopyWith<ScheduleVersion> get copyWith => _$ScheduleVersionCopyWithImpl<ScheduleVersion>(this as ScheduleVersion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ScheduleVersion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleVersion&&(identical(other.effectiveFrom, _this.effectiveFrom) || other.effectiveFrom == _this.effectiveFrom)&&(identical(other.schedule, _this.schedule) || other.schedule == _this.schedule));
}


@override
int get hashCode {
  final _this = this as ScheduleVersion;
  return Object.hash(runtimeType,_this.effectiveFrom,_this.schedule);
}

@override
String toString() {
  final _this = this as ScheduleVersion;
  return 'ScheduleVersion(effectiveFrom: ${_this.effectiveFrom}, schedule: ${_this.schedule})';
}


}

/// @nodoc
abstract mixin class $ScheduleVersionCopyWith<$Res>  {
  factory $ScheduleVersionCopyWith(ScheduleVersion value, $Res Function(ScheduleVersion) _then) = _$ScheduleVersionCopyWithImpl;
@useResult
$Res call({
 LocalDate effectiveFrom, HabitSchedule schedule
});


$HabitScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class _$ScheduleVersionCopyWithImpl<$Res>
    implements $ScheduleVersionCopyWith<$Res> {
  _$ScheduleVersionCopyWithImpl(this._self, this._then);

  final ScheduleVersion _self;
  final $Res Function(ScheduleVersion) _then;

/// Create a copy of ScheduleVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? effectiveFrom = null,Object? schedule = null,}) {
  return _then(ScheduleVersion(
effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as LocalDate,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as HabitSchedule,
  ));
}
/// Create a copy of ScheduleVersion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitScheduleCopyWith<$Res> get schedule {
  
  return $HabitScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScheduleVersion].
extension ScheduleVersionPatterns on ScheduleVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleVersion value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleVersion value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate effectiveFrom,  HabitSchedule schedule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleVersion() when $default != null:
return $default(_that.effectiveFrom,_that.schedule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate effectiveFrom,  HabitSchedule schedule)  $default,) {final _that = this;
switch (_that) {
case _ScheduleVersion():
return $default(_that.effectiveFrom,_that.schedule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate effectiveFrom,  HabitSchedule schedule)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleVersion() when $default != null:
return $default(_that.effectiveFrom,_that.schedule);case _:
  return null;

}
}

}

/// @nodoc


class _ScheduleVersion implements ScheduleVersion {
  const _ScheduleVersion({required this.effectiveFrom, required this.schedule});
  

@override final  LocalDate effectiveFrom;
@override final  HabitSchedule schedule;

/// Create a copy of ScheduleVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleVersionCopyWith<_ScheduleVersion> get copyWith => __$ScheduleVersionCopyWithImpl<_ScheduleVersion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleVersion&&(identical(other.effectiveFrom, effectiveFrom) || other.effectiveFrom == effectiveFrom)&&(identical(other.schedule, schedule) || other.schedule == schedule));
}


@override
int get hashCode {
    return Object.hash(runtimeType,effectiveFrom,schedule);
}

@override
String toString() {
    return 'ScheduleVersion(effectiveFrom: $effectiveFrom, schedule: $schedule)';
}


}

/// @nodoc
abstract mixin class _$ScheduleVersionCopyWith<$Res> implements $ScheduleVersionCopyWith<$Res> {
  factory _$ScheduleVersionCopyWith(_ScheduleVersion value, $Res Function(_ScheduleVersion) _then) = __$ScheduleVersionCopyWithImpl;
@override @useResult
$Res call({
 LocalDate effectiveFrom, HabitSchedule schedule
});


@override $HabitScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class __$ScheduleVersionCopyWithImpl<$Res>
    implements _$ScheduleVersionCopyWith<$Res> {
  __$ScheduleVersionCopyWithImpl(this._self, this._then);

  final _ScheduleVersion _self;
  final $Res Function(_ScheduleVersion) _then;

/// Create a copy of ScheduleVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? effectiveFrom = null,Object? schedule = null,}) {
  return _then(_ScheduleVersion(
effectiveFrom: null == effectiveFrom ? _self.effectiveFrom : effectiveFrom // ignore: cast_nullable_to_non_nullable
as LocalDate,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as HabitSchedule,
  ));
}

/// Create a copy of ScheduleVersion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitScheduleCopyWith<$Res> get schedule {
  
  return $HabitScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}

// dart format on
