// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habits_today_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitsTodayState {

 AsyncValue<HabitsTodayData> get data;
/// Create a copy of HabitsTodayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitsTodayStateCopyWith<HabitsTodayState> get copyWith => _$HabitsTodayStateCopyWithImpl<HabitsTodayState>(this as HabitsTodayState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitsTodayState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitsTodayState&&(identical(other.data, _this.data) || other.data == _this.data));
}


@override
int get hashCode {
  final _this = this as HabitsTodayState;
  return Object.hash(runtimeType,_this.data);
}

@override
String toString() {
  final _this = this as HabitsTodayState;
  return 'HabitsTodayState(data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $HabitsTodayStateCopyWith<$Res>  {
  factory $HabitsTodayStateCopyWith(HabitsTodayState value, $Res Function(HabitsTodayState) _then) = _$HabitsTodayStateCopyWithImpl;
@useResult
$Res call({
 AsyncValue<HabitsTodayData> data
});




}
/// @nodoc
class _$HabitsTodayStateCopyWithImpl<$Res>
    implements $HabitsTodayStateCopyWith<$Res> {
  _$HabitsTodayStateCopyWithImpl(this._self, this._then);

  final HabitsTodayState _self;
  final $Res Function(HabitsTodayState) _then;

/// Create a copy of HabitsTodayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,}) {
  return _then(HabitsTodayState(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AsyncValue<HabitsTodayData>,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitsTodayState].
extension HabitsTodayStatePatterns on HabitsTodayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitsTodayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitsTodayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitsTodayState value)  $default,){
final _that = this;
switch (_that) {
case _HabitsTodayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitsTodayState value)?  $default,){
final _that = this;
switch (_that) {
case _HabitsTodayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AsyncValue<HabitsTodayData> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitsTodayState() when $default != null:
return $default(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AsyncValue<HabitsTodayData> data)  $default,) {final _that = this;
switch (_that) {
case _HabitsTodayState():
return $default(_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AsyncValue<HabitsTodayData> data)?  $default,) {final _that = this;
switch (_that) {
case _HabitsTodayState() when $default != null:
return $default(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _HabitsTodayState implements HabitsTodayState {
  const _HabitsTodayState({this.data = const AsyncLoading<HabitsTodayData>()});
  

@override@JsonKey() final  AsyncValue<HabitsTodayData> data;

/// Create a copy of HabitsTodayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitsTodayStateCopyWith<_HabitsTodayState> get copyWith => __$HabitsTodayStateCopyWithImpl<_HabitsTodayState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitsTodayState&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'HabitsTodayState(data: $data)';
}


}

/// @nodoc
abstract mixin class _$HabitsTodayStateCopyWith<$Res> implements $HabitsTodayStateCopyWith<$Res> {
  factory _$HabitsTodayStateCopyWith(_HabitsTodayState value, $Res Function(_HabitsTodayState) _then) = __$HabitsTodayStateCopyWithImpl;
@override @useResult
$Res call({
 AsyncValue<HabitsTodayData> data
});




}
/// @nodoc
class __$HabitsTodayStateCopyWithImpl<$Res>
    implements _$HabitsTodayStateCopyWith<$Res> {
  __$HabitsTodayStateCopyWithImpl(this._self, this._then);

  final _HabitsTodayState _self;
  final $Res Function(_HabitsTodayState) _then;

/// Create a copy of HabitsTodayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_HabitsTodayState(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AsyncValue<HabitsTodayData>,
  ));
}


}

/// @nodoc
mixin _$HabitsTodayData {

 LocalDate get today; LocalDate get selected;/// 0 = the current week, -1 = the previous one (research R14).
 int get weekOffset;/// The 7 days of the shown week, from the first day of the week.
 List<WeekDayCell> get week;/// Progress header for the selected day.
 int get doneCount; int get scheduledCount; List<HabitCardData> get scheduled; List<HabitCardData> get notScheduled;/// Every active habit in sort order (reorder mode).
 List<Habit> get habits;/// "All done for today" banner: only when [selected] is today.
 bool get allDoneToday; bool get reorderMode;
/// Create a copy of HabitsTodayData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitsTodayDataCopyWith<HabitsTodayData> get copyWith => _$HabitsTodayDataCopyWithImpl<HabitsTodayData>(this as HabitsTodayData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitsTodayData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitsTodayData&&(identical(other.today, _this.today) || other.today == _this.today)&&(identical(other.selected, _this.selected) || other.selected == _this.selected)&&(identical(other.weekOffset, _this.weekOffset) || other.weekOffset == _this.weekOffset)&&const DeepCollectionEquality().equals(other.week, _this.week)&&(identical(other.doneCount, _this.doneCount) || other.doneCount == _this.doneCount)&&(identical(other.scheduledCount, _this.scheduledCount) || other.scheduledCount == _this.scheduledCount)&&const DeepCollectionEquality().equals(other.scheduled, _this.scheduled)&&const DeepCollectionEquality().equals(other.notScheduled, _this.notScheduled)&&const DeepCollectionEquality().equals(other.habits, _this.habits)&&(identical(other.allDoneToday, _this.allDoneToday) || other.allDoneToday == _this.allDoneToday)&&(identical(other.reorderMode, _this.reorderMode) || other.reorderMode == _this.reorderMode));
}


@override
int get hashCode {
  final _this = this as HabitsTodayData;
  return Object.hash(runtimeType,_this.today,_this.selected,_this.weekOffset,const DeepCollectionEquality().hash(_this.week),_this.doneCount,_this.scheduledCount,const DeepCollectionEquality().hash(_this.scheduled),const DeepCollectionEquality().hash(_this.notScheduled),const DeepCollectionEquality().hash(_this.habits),_this.allDoneToday,_this.reorderMode);
}

@override
String toString() {
  final _this = this as HabitsTodayData;
  return 'HabitsTodayData(today: ${_this.today}, selected: ${_this.selected}, weekOffset: ${_this.weekOffset}, week: ${_this.week}, doneCount: ${_this.doneCount}, scheduledCount: ${_this.scheduledCount}, scheduled: ${_this.scheduled}, notScheduled: ${_this.notScheduled}, habits: ${_this.habits}, allDoneToday: ${_this.allDoneToday}, reorderMode: ${_this.reorderMode})';
}


}

/// @nodoc
abstract mixin class $HabitsTodayDataCopyWith<$Res>  {
  factory $HabitsTodayDataCopyWith(HabitsTodayData value, $Res Function(HabitsTodayData) _then) = _$HabitsTodayDataCopyWithImpl;
@useResult
$Res call({
 LocalDate today, LocalDate selected, int weekOffset, List<WeekDayCell> week, int doneCount, int scheduledCount, List<HabitCardData> scheduled, List<HabitCardData> notScheduled, List<Habit> habits, bool allDoneToday, bool reorderMode
});




}
/// @nodoc
class _$HabitsTodayDataCopyWithImpl<$Res>
    implements $HabitsTodayDataCopyWith<$Res> {
  _$HabitsTodayDataCopyWithImpl(this._self, this._then);

  final HabitsTodayData _self;
  final $Res Function(HabitsTodayData) _then;

/// Create a copy of HabitsTodayData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? today = null,Object? selected = null,Object? weekOffset = null,Object? week = null,Object? doneCount = null,Object? scheduledCount = null,Object? scheduled = null,Object? notScheduled = null,Object? habits = null,Object? allDoneToday = null,Object? reorderMode = null,}) {
  return _then(HabitsTodayData(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as LocalDate,weekOffset: null == weekOffset ? _self.weekOffset : weekOffset // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as List<WeekDayCell>,doneCount: null == doneCount ? _self.doneCount : doneCount // ignore: cast_nullable_to_non_nullable
as int,scheduledCount: null == scheduledCount ? _self.scheduledCount : scheduledCount // ignore: cast_nullable_to_non_nullable
as int,scheduled: null == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as List<HabitCardData>,notScheduled: null == notScheduled ? _self.notScheduled : notScheduled // ignore: cast_nullable_to_non_nullable
as List<HabitCardData>,habits: null == habits ? _self.habits : habits // ignore: cast_nullable_to_non_nullable
as List<Habit>,allDoneToday: null == allDoneToday ? _self.allDoneToday : allDoneToday // ignore: cast_nullable_to_non_nullable
as bool,reorderMode: null == reorderMode ? _self.reorderMode : reorderMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitsTodayData].
extension HabitsTodayDataPatterns on HabitsTodayData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitsTodayData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitsTodayData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitsTodayData value)  $default,){
final _that = this;
switch (_that) {
case _HabitsTodayData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitsTodayData value)?  $default,){
final _that = this;
switch (_that) {
case _HabitsTodayData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate today,  LocalDate selected,  int weekOffset,  List<WeekDayCell> week,  int doneCount,  int scheduledCount,  List<HabitCardData> scheduled,  List<HabitCardData> notScheduled,  List<Habit> habits,  bool allDoneToday,  bool reorderMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitsTodayData() when $default != null:
return $default(_that.today,_that.selected,_that.weekOffset,_that.week,_that.doneCount,_that.scheduledCount,_that.scheduled,_that.notScheduled,_that.habits,_that.allDoneToday,_that.reorderMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate today,  LocalDate selected,  int weekOffset,  List<WeekDayCell> week,  int doneCount,  int scheduledCount,  List<HabitCardData> scheduled,  List<HabitCardData> notScheduled,  List<Habit> habits,  bool allDoneToday,  bool reorderMode)  $default,) {final _that = this;
switch (_that) {
case _HabitsTodayData():
return $default(_that.today,_that.selected,_that.weekOffset,_that.week,_that.doneCount,_that.scheduledCount,_that.scheduled,_that.notScheduled,_that.habits,_that.allDoneToday,_that.reorderMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate today,  LocalDate selected,  int weekOffset,  List<WeekDayCell> week,  int doneCount,  int scheduledCount,  List<HabitCardData> scheduled,  List<HabitCardData> notScheduled,  List<Habit> habits,  bool allDoneToday,  bool reorderMode)?  $default,) {final _that = this;
switch (_that) {
case _HabitsTodayData() when $default != null:
return $default(_that.today,_that.selected,_that.weekOffset,_that.week,_that.doneCount,_that.scheduledCount,_that.scheduled,_that.notScheduled,_that.habits,_that.allDoneToday,_that.reorderMode);case _:
  return null;

}
}

}

/// @nodoc


class _HabitsTodayData extends HabitsTodayData {
  const _HabitsTodayData({required this.today, required this.selected, required this.weekOffset, required  List<WeekDayCell> week, required this.doneCount, required this.scheduledCount, required  List<HabitCardData> scheduled, required  List<HabitCardData> notScheduled, required  List<Habit> habits, required this.allDoneToday, this.reorderMode = false}): _week = week,_scheduled = scheduled,_notScheduled = notScheduled,_habits = habits,super._();
  

@override final  LocalDate today;
@override final  LocalDate selected;
/// 0 = the current week, -1 = the previous one (research R14).
@override final  int weekOffset;
/// The 7 days of the shown week, from the first day of the week.
 final  List<WeekDayCell> _week;
/// The 7 days of the shown week, from the first day of the week.
@override List<WeekDayCell> get week {
  if (_week is EqualUnmodifiableListView) return _week;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_week);
}

/// Progress header for the selected day.
@override final  int doneCount;
@override final  int scheduledCount;
 final  List<HabitCardData> _scheduled;
@override List<HabitCardData> get scheduled {
  if (_scheduled is EqualUnmodifiableListView) return _scheduled;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scheduled);
}

 final  List<HabitCardData> _notScheduled;
@override List<HabitCardData> get notScheduled {
  if (_notScheduled is EqualUnmodifiableListView) return _notScheduled;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notScheduled);
}

/// Every active habit in sort order (reorder mode).
 final  List<Habit> _habits;
/// Every active habit in sort order (reorder mode).
@override List<Habit> get habits {
  if (_habits is EqualUnmodifiableListView) return _habits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_habits);
}

/// "All done for today" banner: only when [selected] is today.
@override final  bool allDoneToday;
@override@JsonKey() final  bool reorderMode;

/// Create a copy of HabitsTodayData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitsTodayDataCopyWith<_HabitsTodayData> get copyWith => __$HabitsTodayDataCopyWithImpl<_HabitsTodayData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitsTodayData&&(identical(other.today, today) || other.today == today)&&(identical(other.selected, selected) || other.selected == selected)&&(identical(other.weekOffset, weekOffset) || other.weekOffset == weekOffset)&&const DeepCollectionEquality().equals(other.week, _week)&&(identical(other.doneCount, doneCount) || other.doneCount == doneCount)&&(identical(other.scheduledCount, scheduledCount) || other.scheduledCount == scheduledCount)&&const DeepCollectionEquality().equals(other.scheduled, _scheduled)&&const DeepCollectionEquality().equals(other.notScheduled, _notScheduled)&&const DeepCollectionEquality().equals(other.habits, _habits)&&(identical(other.allDoneToday, allDoneToday) || other.allDoneToday == allDoneToday)&&(identical(other.reorderMode, reorderMode) || other.reorderMode == reorderMode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,today,selected,weekOffset,const DeepCollectionEquality().hash(_week),doneCount,scheduledCount,const DeepCollectionEquality().hash(_scheduled),const DeepCollectionEquality().hash(_notScheduled),const DeepCollectionEquality().hash(_habits),allDoneToday,reorderMode);
}

@override
String toString() {
    return 'HabitsTodayData(today: $today, selected: $selected, weekOffset: $weekOffset, week: $week, doneCount: $doneCount, scheduledCount: $scheduledCount, scheduled: $scheduled, notScheduled: $notScheduled, habits: $habits, allDoneToday: $allDoneToday, reorderMode: $reorderMode)';
}


}

/// @nodoc
abstract mixin class _$HabitsTodayDataCopyWith<$Res> implements $HabitsTodayDataCopyWith<$Res> {
  factory _$HabitsTodayDataCopyWith(_HabitsTodayData value, $Res Function(_HabitsTodayData) _then) = __$HabitsTodayDataCopyWithImpl;
@override @useResult
$Res call({
 LocalDate today, LocalDate selected, int weekOffset, List<WeekDayCell> week, int doneCount, int scheduledCount, List<HabitCardData> scheduled, List<HabitCardData> notScheduled, List<Habit> habits, bool allDoneToday, bool reorderMode
});




}
/// @nodoc
class __$HabitsTodayDataCopyWithImpl<$Res>
    implements _$HabitsTodayDataCopyWith<$Res> {
  __$HabitsTodayDataCopyWithImpl(this._self, this._then);

  final _HabitsTodayData _self;
  final $Res Function(_HabitsTodayData) _then;

/// Create a copy of HabitsTodayData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? today = null,Object? selected = null,Object? weekOffset = null,Object? week = null,Object? doneCount = null,Object? scheduledCount = null,Object? scheduled = null,Object? notScheduled = null,Object? habits = null,Object? allDoneToday = null,Object? reorderMode = null,}) {
  return _then(_HabitsTodayData(
today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as LocalDate,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as LocalDate,weekOffset: null == weekOffset ? _self.weekOffset : weekOffset // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self._week : week // ignore: cast_nullable_to_non_nullable
as List<WeekDayCell>,doneCount: null == doneCount ? _self.doneCount : doneCount // ignore: cast_nullable_to_non_nullable
as int,scheduledCount: null == scheduledCount ? _self.scheduledCount : scheduledCount // ignore: cast_nullable_to_non_nullable
as int,scheduled: null == scheduled ? _self._scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as List<HabitCardData>,notScheduled: null == notScheduled ? _self._notScheduled : notScheduled // ignore: cast_nullable_to_non_nullable
as List<HabitCardData>,habits: null == habits ? _self._habits : habits // ignore: cast_nullable_to_non_nullable
as List<Habit>,allDoneToday: null == allDoneToday ? _self.allDoneToday : allDoneToday // ignore: cast_nullable_to_non_nullable
as bool,reorderMode: null == reorderMode ? _self.reorderMode : reorderMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$WeekDayCell {

 LocalDate get date; int get done; int get scheduled;/// Today and up to 7 days back (FR-017).
 bool get selectable; bool get isFuture; bool get isToday;
/// Create a copy of WeekDayCell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekDayCellCopyWith<WeekDayCell> get copyWith => _$WeekDayCellCopyWithImpl<WeekDayCell>(this as WeekDayCell, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WeekDayCell;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekDayCell&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.done, _this.done) || other.done == _this.done)&&(identical(other.scheduled, _this.scheduled) || other.scheduled == _this.scheduled)&&(identical(other.selectable, _this.selectable) || other.selectable == _this.selectable)&&(identical(other.isFuture, _this.isFuture) || other.isFuture == _this.isFuture)&&(identical(other.isToday, _this.isToday) || other.isToday == _this.isToday));
}


@override
int get hashCode {
  final _this = this as WeekDayCell;
  return Object.hash(runtimeType,_this.date,_this.done,_this.scheduled,_this.selectable,_this.isFuture,_this.isToday);
}

@override
String toString() {
  final _this = this as WeekDayCell;
  return 'WeekDayCell(date: ${_this.date}, done: ${_this.done}, scheduled: ${_this.scheduled}, selectable: ${_this.selectable}, isFuture: ${_this.isFuture}, isToday: ${_this.isToday})';
}


}

/// @nodoc
abstract mixin class $WeekDayCellCopyWith<$Res>  {
  factory $WeekDayCellCopyWith(WeekDayCell value, $Res Function(WeekDayCell) _then) = _$WeekDayCellCopyWithImpl;
@useResult
$Res call({
 LocalDate date, int done, int scheduled, bool selectable, bool isFuture, bool isToday
});




}
/// @nodoc
class _$WeekDayCellCopyWithImpl<$Res>
    implements $WeekDayCellCopyWith<$Res> {
  _$WeekDayCellCopyWithImpl(this._self, this._then);

  final WeekDayCell _self;
  final $Res Function(WeekDayCell) _then;

/// Create a copy of WeekDayCell
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? done = null,Object? scheduled = null,Object? selectable = null,Object? isFuture = null,Object? isToday = null,}) {
  return _then(WeekDayCell(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,scheduled: null == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as int,selectable: null == selectable ? _self.selectable : selectable // ignore: cast_nullable_to_non_nullable
as bool,isFuture: null == isFuture ? _self.isFuture : isFuture // ignore: cast_nullable_to_non_nullable
as bool,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WeekDayCell].
extension WeekDayCellPatterns on WeekDayCell {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekDayCell value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekDayCell() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekDayCell value)  $default,){
final _that = this;
switch (_that) {
case _WeekDayCell():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekDayCell value)?  $default,){
final _that = this;
switch (_that) {
case _WeekDayCell() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocalDate date,  int done,  int scheduled,  bool selectable,  bool isFuture,  bool isToday)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekDayCell() when $default != null:
return $default(_that.date,_that.done,_that.scheduled,_that.selectable,_that.isFuture,_that.isToday);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocalDate date,  int done,  int scheduled,  bool selectable,  bool isFuture,  bool isToday)  $default,) {final _that = this;
switch (_that) {
case _WeekDayCell():
return $default(_that.date,_that.done,_that.scheduled,_that.selectable,_that.isFuture,_that.isToday);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocalDate date,  int done,  int scheduled,  bool selectable,  bool isFuture,  bool isToday)?  $default,) {final _that = this;
switch (_that) {
case _WeekDayCell() when $default != null:
return $default(_that.date,_that.done,_that.scheduled,_that.selectable,_that.isFuture,_that.isToday);case _:
  return null;

}
}

}

/// @nodoc


class _WeekDayCell extends WeekDayCell {
  const _WeekDayCell({required this.date, required this.done, required this.scheduled, required this.selectable, required this.isFuture, required this.isToday}): super._();
  

@override final  LocalDate date;
@override final  int done;
@override final  int scheduled;
/// Today and up to 7 days back (FR-017).
@override final  bool selectable;
@override final  bool isFuture;
@override final  bool isToday;

/// Create a copy of WeekDayCell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekDayCellCopyWith<_WeekDayCell> get copyWith => __$WeekDayCellCopyWithImpl<_WeekDayCell>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekDayCell&&(identical(other.date, date) || other.date == date)&&(identical(other.done, done) || other.done == done)&&(identical(other.scheduled, scheduled) || other.scheduled == scheduled)&&(identical(other.selectable, selectable) || other.selectable == selectable)&&(identical(other.isFuture, isFuture) || other.isFuture == isFuture)&&(identical(other.isToday, isToday) || other.isToday == isToday));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,done,scheduled,selectable,isFuture,isToday);
}

@override
String toString() {
    return 'WeekDayCell(date: $date, done: $done, scheduled: $scheduled, selectable: $selectable, isFuture: $isFuture, isToday: $isToday)';
}


}

/// @nodoc
abstract mixin class _$WeekDayCellCopyWith<$Res> implements $WeekDayCellCopyWith<$Res> {
  factory _$WeekDayCellCopyWith(_WeekDayCell value, $Res Function(_WeekDayCell) _then) = __$WeekDayCellCopyWithImpl;
@override @useResult
$Res call({
 LocalDate date, int done, int scheduled, bool selectable, bool isFuture, bool isToday
});




}
/// @nodoc
class __$WeekDayCellCopyWithImpl<$Res>
    implements _$WeekDayCellCopyWith<$Res> {
  __$WeekDayCellCopyWithImpl(this._self, this._then);

  final _WeekDayCell _self;
  final $Res Function(_WeekDayCell) _then;

/// Create a copy of WeekDayCell
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? done = null,Object? scheduled = null,Object? selectable = null,Object? isFuture = null,Object? isToday = null,}) {
  return _then(_WeekDayCell(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,done: null == done ? _self.done : done // ignore: cast_nullable_to_non_nullable
as int,scheduled: null == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as int,selectable: null == selectable ? _self.selectable : selectable // ignore: cast_nullable_to_non_nullable
as bool,isFuture: null == isFuture ? _self.isFuture : isFuture // ignore: cast_nullable_to_non_nullable
as bool,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$HabitCardData {

 Habit get habit; DayStatus get status;/// The day's value (0 without an entry) and the target in effect.
 int get value; int get target; bool get isDone; bool get isFreeze; ScheduleTextData get schedule; int get currentStreak; StreakUnit get unit;/// Skip today is offered: today, scheduled, not done, not frozen. It is
/// disabled with "No freezes left" when the habit has none (FR-036).
 bool get canSkipToday; String? get note;
/// Create a copy of HabitCardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitCardDataCopyWith<HabitCardData> get copyWith => _$HabitCardDataCopyWithImpl<HabitCardData>(this as HabitCardData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitCardData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitCardData&&(identical(other.habit, _this.habit) || other.habit == _this.habit)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.target, _this.target) || other.target == _this.target)&&(identical(other.isDone, _this.isDone) || other.isDone == _this.isDone)&&(identical(other.isFreeze, _this.isFreeze) || other.isFreeze == _this.isFreeze)&&(identical(other.schedule, _this.schedule) || other.schedule == _this.schedule)&&(identical(other.currentStreak, _this.currentStreak) || other.currentStreak == _this.currentStreak)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.canSkipToday, _this.canSkipToday) || other.canSkipToday == _this.canSkipToday)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as HabitCardData;
  return Object.hash(runtimeType,_this.habit,_this.status,_this.value,_this.target,_this.isDone,_this.isFreeze,_this.schedule,_this.currentStreak,_this.unit,_this.canSkipToday,_this.note);
}

@override
String toString() {
  final _this = this as HabitCardData;
  return 'HabitCardData(habit: ${_this.habit}, status: ${_this.status}, value: ${_this.value}, target: ${_this.target}, isDone: ${_this.isDone}, isFreeze: ${_this.isFreeze}, schedule: ${_this.schedule}, currentStreak: ${_this.currentStreak}, unit: ${_this.unit}, canSkipToday: ${_this.canSkipToday}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $HabitCardDataCopyWith<$Res>  {
  factory $HabitCardDataCopyWith(HabitCardData value, $Res Function(HabitCardData) _then) = _$HabitCardDataCopyWithImpl;
@useResult
$Res call({
 Habit habit, DayStatus status, int value, int target, bool isDone, bool isFreeze, ScheduleTextData schedule, int currentStreak, StreakUnit unit, bool canSkipToday, String? note
});


$HabitCopyWith<$Res> get habit;

}
/// @nodoc
class _$HabitCardDataCopyWithImpl<$Res>
    implements $HabitCardDataCopyWith<$Res> {
  _$HabitCardDataCopyWithImpl(this._self, this._then);

  final HabitCardData _self;
  final $Res Function(HabitCardData) _then;

/// Create a copy of HabitCardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habit = null,Object? status = null,Object? value = null,Object? target = null,Object? isDone = null,Object? isFreeze = null,Object? schedule = null,Object? currentStreak = null,Object? unit = null,Object? canSkipToday = null,Object? note = freezed,}) {
  return _then(HabitCardData(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DayStatus,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,isFreeze: null == isFreeze ? _self.isFreeze : isFreeze // ignore: cast_nullable_to_non_nullable
as bool,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as ScheduleTextData,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as StreakUnit,canSkipToday: null == canSkipToday ? _self.canSkipToday : canSkipToday // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HabitCardData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitCardData].
extension HabitCardDataPatterns on HabitCardData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitCardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitCardData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitCardData value)  $default,){
final _that = this;
switch (_that) {
case _HabitCardData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitCardData value)?  $default,){
final _that = this;
switch (_that) {
case _HabitCardData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Habit habit,  DayStatus status,  int value,  int target,  bool isDone,  bool isFreeze,  ScheduleTextData schedule,  int currentStreak,  StreakUnit unit,  bool canSkipToday,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitCardData() when $default != null:
return $default(_that.habit,_that.status,_that.value,_that.target,_that.isDone,_that.isFreeze,_that.schedule,_that.currentStreak,_that.unit,_that.canSkipToday,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Habit habit,  DayStatus status,  int value,  int target,  bool isDone,  bool isFreeze,  ScheduleTextData schedule,  int currentStreak,  StreakUnit unit,  bool canSkipToday,  String? note)  $default,) {final _that = this;
switch (_that) {
case _HabitCardData():
return $default(_that.habit,_that.status,_that.value,_that.target,_that.isDone,_that.isFreeze,_that.schedule,_that.currentStreak,_that.unit,_that.canSkipToday,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Habit habit,  DayStatus status,  int value,  int target,  bool isDone,  bool isFreeze,  ScheduleTextData schedule,  int currentStreak,  StreakUnit unit,  bool canSkipToday,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _HabitCardData() when $default != null:
return $default(_that.habit,_that.status,_that.value,_that.target,_that.isDone,_that.isFreeze,_that.schedule,_that.currentStreak,_that.unit,_that.canSkipToday,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _HabitCardData extends HabitCardData {
  const _HabitCardData({required this.habit, required this.status, required this.value, required this.target, required this.isDone, required this.isFreeze, required this.schedule, required this.currentStreak, required this.unit, required this.canSkipToday, this.note}): super._();
  

@override final  Habit habit;
@override final  DayStatus status;
/// The day's value (0 without an entry) and the target in effect.
@override final  int value;
@override final  int target;
@override final  bool isDone;
@override final  bool isFreeze;
@override final  ScheduleTextData schedule;
@override final  int currentStreak;
@override final  StreakUnit unit;
/// Skip today is offered: today, scheduled, not done, not frozen. It is
/// disabled with "No freezes left" when the habit has none (FR-036).
@override final  bool canSkipToday;
@override final  String? note;

/// Create a copy of HabitCardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitCardDataCopyWith<_HabitCardData> get copyWith => __$HabitCardDataCopyWithImpl<_HabitCardData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitCardData&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.status, status) || other.status == status)&&(identical(other.value, value) || other.value == value)&&(identical(other.target, target) || other.target == target)&&(identical(other.isDone, isDone) || other.isDone == isDone)&&(identical(other.isFreeze, isFreeze) || other.isFreeze == isFreeze)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.canSkipToday, canSkipToday) || other.canSkipToday == canSkipToday)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,habit,status,value,target,isDone,isFreeze,schedule,currentStreak,unit,canSkipToday,note);
}

@override
String toString() {
    return 'HabitCardData(habit: $habit, status: $status, value: $value, target: $target, isDone: $isDone, isFreeze: $isFreeze, schedule: $schedule, currentStreak: $currentStreak, unit: $unit, canSkipToday: $canSkipToday, note: $note)';
}


}

/// @nodoc
abstract mixin class _$HabitCardDataCopyWith<$Res> implements $HabitCardDataCopyWith<$Res> {
  factory _$HabitCardDataCopyWith(_HabitCardData value, $Res Function(_HabitCardData) _then) = __$HabitCardDataCopyWithImpl;
@override @useResult
$Res call({
 Habit habit, DayStatus status, int value, int target, bool isDone, bool isFreeze, ScheduleTextData schedule, int currentStreak, StreakUnit unit, bool canSkipToday, String? note
});


@override $HabitCopyWith<$Res> get habit;

}
/// @nodoc
class __$HabitCardDataCopyWithImpl<$Res>
    implements _$HabitCardDataCopyWith<$Res> {
  __$HabitCardDataCopyWithImpl(this._self, this._then);

  final _HabitCardData _self;
  final $Res Function(_HabitCardData) _then;

/// Create a copy of HabitCardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habit = null,Object? status = null,Object? value = null,Object? target = null,Object? isDone = null,Object? isFreeze = null,Object? schedule = null,Object? currentStreak = null,Object? unit = null,Object? canSkipToday = null,Object? note = freezed,}) {
  return _then(_HabitCardData(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DayStatus,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,isDone: null == isDone ? _self.isDone : isDone // ignore: cast_nullable_to_non_nullable
as bool,isFreeze: null == isFreeze ? _self.isFreeze : isFreeze // ignore: cast_nullable_to_non_nullable
as bool,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as ScheduleTextData,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as StreakUnit,canSkipToday: null == canSkipToday ? _self.canSkipToday : canSkipToday // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HabitCardData
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
