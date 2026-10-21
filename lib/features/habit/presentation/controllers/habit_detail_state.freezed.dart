// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitDetailState {

 AsyncValue<HabitDetailData> get data; bool get notFound;
/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitDetailStateCopyWith<HabitDetailState> get copyWith => _$HabitDetailStateCopyWithImpl<HabitDetailState>(this as HabitDetailState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitDetailState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailState&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.notFound, _this.notFound) || other.notFound == _this.notFound));
}


@override
int get hashCode {
  final _this = this as HabitDetailState;
  return Object.hash(runtimeType,_this.data,_this.notFound);
}

@override
String toString() {
  final _this = this as HabitDetailState;
  return 'HabitDetailState(data: ${_this.data}, notFound: ${_this.notFound})';
}


}

/// @nodoc
abstract mixin class $HabitDetailStateCopyWith<$Res>  {
  factory $HabitDetailStateCopyWith(HabitDetailState value, $Res Function(HabitDetailState) _then) = _$HabitDetailStateCopyWithImpl;
@useResult
$Res call({
 AsyncValue<HabitDetailData> data, bool notFound
});




}
/// @nodoc
class _$HabitDetailStateCopyWithImpl<$Res>
    implements $HabitDetailStateCopyWith<$Res> {
  _$HabitDetailStateCopyWithImpl(this._self, this._then);

  final HabitDetailState _self;
  final $Res Function(HabitDetailState) _then;

/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? notFound = null,}) {
  return _then(HabitDetailState(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AsyncValue<HabitDetailData>,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitDetailState].
extension HabitDetailStatePatterns on HabitDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitDetailState value)  $default,){
final _that = this;
switch (_that) {
case _HabitDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _HabitDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AsyncValue<HabitDetailData> data,  bool notFound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitDetailState() when $default != null:
return $default(_that.data,_that.notFound);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AsyncValue<HabitDetailData> data,  bool notFound)  $default,) {final _that = this;
switch (_that) {
case _HabitDetailState():
return $default(_that.data,_that.notFound);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AsyncValue<HabitDetailData> data,  bool notFound)?  $default,) {final _that = this;
switch (_that) {
case _HabitDetailState() when $default != null:
return $default(_that.data,_that.notFound);case _:
  return null;

}
}

}

/// @nodoc


class _HabitDetailState implements HabitDetailState {
  const _HabitDetailState({this.data = const AsyncLoading<HabitDetailData>(), this.notFound = false});
  

@override@JsonKey() final  AsyncValue<HabitDetailData> data;
@override@JsonKey() final  bool notFound;

/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitDetailStateCopyWith<_HabitDetailState> get copyWith => __$HabitDetailStateCopyWithImpl<_HabitDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitDetailState&&(identical(other.data, data) || other.data == data)&&(identical(other.notFound, notFound) || other.notFound == notFound));
}


@override
int get hashCode {
    return Object.hash(runtimeType,data,notFound);
}

@override
String toString() {
    return 'HabitDetailState(data: $data, notFound: $notFound)';
}


}

/// @nodoc
abstract mixin class _$HabitDetailStateCopyWith<$Res> implements $HabitDetailStateCopyWith<$Res> {
  factory _$HabitDetailStateCopyWith(_HabitDetailState value, $Res Function(_HabitDetailState) _then) = __$HabitDetailStateCopyWithImpl;
@override @useResult
$Res call({
 AsyncValue<HabitDetailData> data, bool notFound
});




}
/// @nodoc
class __$HabitDetailStateCopyWithImpl<$Res>
    implements _$HabitDetailStateCopyWith<$Res> {
  __$HabitDetailStateCopyWithImpl(this._self, this._then);

  final _HabitDetailState _self;
  final $Res Function(_HabitDetailState) _then;

/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? notFound = null,}) {
  return _then(_HabitDetailState(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AsyncValue<HabitDetailData>,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$HabitDetailData {

 Habit get habit; StreakSummary get summary; HabitDetailViewModel get vm; ScheduleTextData get schedule;/// Entries with notes, newest first (US5-6).
 List<HabitEntry> get notes; bool get advancedReportsUnlocked;/// Dev tools available and "Unlock all features (debug)" on (FR-037).
 bool get showDebugFreezeButton;/// Missed days 1–3 back a freeze can go on (FR-035), newest first.
 List<LocalDate> get freezeableDays;
/// Create a copy of HabitDetailData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitDetailDataCopyWith<HabitDetailData> get copyWith => _$HabitDetailDataCopyWithImpl<HabitDetailData>(this as HabitDetailData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitDetailData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailData&&(identical(other.habit, _this.habit) || other.habit == _this.habit)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.vm, _this.vm) || other.vm == _this.vm)&&(identical(other.schedule, _this.schedule) || other.schedule == _this.schedule)&&const DeepCollectionEquality().equals(other.notes, _this.notes)&&(identical(other.advancedReportsUnlocked, _this.advancedReportsUnlocked) || other.advancedReportsUnlocked == _this.advancedReportsUnlocked)&&(identical(other.showDebugFreezeButton, _this.showDebugFreezeButton) || other.showDebugFreezeButton == _this.showDebugFreezeButton)&&const DeepCollectionEquality().equals(other.freezeableDays, _this.freezeableDays));
}


@override
int get hashCode {
  final _this = this as HabitDetailData;
  return Object.hash(runtimeType,_this.habit,_this.summary,_this.vm,_this.schedule,const DeepCollectionEquality().hash(_this.notes),_this.advancedReportsUnlocked,_this.showDebugFreezeButton,const DeepCollectionEquality().hash(_this.freezeableDays));
}

@override
String toString() {
  final _this = this as HabitDetailData;
  return 'HabitDetailData(habit: ${_this.habit}, summary: ${_this.summary}, vm: ${_this.vm}, schedule: ${_this.schedule}, notes: ${_this.notes}, advancedReportsUnlocked: ${_this.advancedReportsUnlocked}, showDebugFreezeButton: ${_this.showDebugFreezeButton}, freezeableDays: ${_this.freezeableDays})';
}


}

/// @nodoc
abstract mixin class $HabitDetailDataCopyWith<$Res>  {
  factory $HabitDetailDataCopyWith(HabitDetailData value, $Res Function(HabitDetailData) _then) = _$HabitDetailDataCopyWithImpl;
@useResult
$Res call({
 Habit habit, StreakSummary summary, HabitDetailViewModel vm, ScheduleTextData schedule, List<HabitEntry> notes, bool advancedReportsUnlocked, bool showDebugFreezeButton, List<LocalDate> freezeableDays
});


$HabitCopyWith<$Res> get habit;$StreakSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$HabitDetailDataCopyWithImpl<$Res>
    implements $HabitDetailDataCopyWith<$Res> {
  _$HabitDetailDataCopyWithImpl(this._self, this._then);

  final HabitDetailData _self;
  final $Res Function(HabitDetailData) _then;

/// Create a copy of HabitDetailData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habit = null,Object? summary = null,Object? vm = null,Object? schedule = null,Object? notes = null,Object? advancedReportsUnlocked = null,Object? showDebugFreezeButton = null,Object? freezeableDays = null,}) {
  return _then(HabitDetailData(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as StreakSummary,vm: null == vm ? _self.vm : vm // ignore: cast_nullable_to_non_nullable
as HabitDetailViewModel,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as ScheduleTextData,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<HabitEntry>,advancedReportsUnlocked: null == advancedReportsUnlocked ? _self.advancedReportsUnlocked : advancedReportsUnlocked // ignore: cast_nullable_to_non_nullable
as bool,showDebugFreezeButton: null == showDebugFreezeButton ? _self.showDebugFreezeButton : showDebugFreezeButton // ignore: cast_nullable_to_non_nullable
as bool,freezeableDays: null == freezeableDays ? _self.freezeableDays : freezeableDays // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,
  ));
}
/// Create a copy of HabitDetailData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of HabitDetailData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakSummaryCopyWith<$Res> get summary {
  
  return $StreakSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitDetailData].
extension HabitDetailDataPatterns on HabitDetailData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitDetailData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitDetailData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitDetailData value)  $default,){
final _that = this;
switch (_that) {
case _HabitDetailData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitDetailData value)?  $default,){
final _that = this;
switch (_that) {
case _HabitDetailData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Habit habit,  StreakSummary summary,  HabitDetailViewModel vm,  ScheduleTextData schedule,  List<HabitEntry> notes,  bool advancedReportsUnlocked,  bool showDebugFreezeButton,  List<LocalDate> freezeableDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitDetailData() when $default != null:
return $default(_that.habit,_that.summary,_that.vm,_that.schedule,_that.notes,_that.advancedReportsUnlocked,_that.showDebugFreezeButton,_that.freezeableDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Habit habit,  StreakSummary summary,  HabitDetailViewModel vm,  ScheduleTextData schedule,  List<HabitEntry> notes,  bool advancedReportsUnlocked,  bool showDebugFreezeButton,  List<LocalDate> freezeableDays)  $default,) {final _that = this;
switch (_that) {
case _HabitDetailData():
return $default(_that.habit,_that.summary,_that.vm,_that.schedule,_that.notes,_that.advancedReportsUnlocked,_that.showDebugFreezeButton,_that.freezeableDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Habit habit,  StreakSummary summary,  HabitDetailViewModel vm,  ScheduleTextData schedule,  List<HabitEntry> notes,  bool advancedReportsUnlocked,  bool showDebugFreezeButton,  List<LocalDate> freezeableDays)?  $default,) {final _that = this;
switch (_that) {
case _HabitDetailData() when $default != null:
return $default(_that.habit,_that.summary,_that.vm,_that.schedule,_that.notes,_that.advancedReportsUnlocked,_that.showDebugFreezeButton,_that.freezeableDays);case _:
  return null;

}
}

}

/// @nodoc


class _HabitDetailData implements HabitDetailData {
  const _HabitDetailData({required this.habit, required this.summary, required this.vm, required this.schedule, required  List<HabitEntry> notes, required this.advancedReportsUnlocked, required this.showDebugFreezeButton, required  List<LocalDate> freezeableDays}): _notes = notes,_freezeableDays = freezeableDays;
  

@override final  Habit habit;
@override final  StreakSummary summary;
@override final  HabitDetailViewModel vm;
@override final  ScheduleTextData schedule;
/// Entries with notes, newest first (US5-6).
 final  List<HabitEntry> _notes;
/// Entries with notes, newest first (US5-6).
@override List<HabitEntry> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

@override final  bool advancedReportsUnlocked;
/// Dev tools available and "Unlock all features (debug)" on (FR-037).
@override final  bool showDebugFreezeButton;
/// Missed days 1–3 back a freeze can go on (FR-035), newest first.
 final  List<LocalDate> _freezeableDays;
/// Missed days 1–3 back a freeze can go on (FR-035), newest first.
@override List<LocalDate> get freezeableDays {
  if (_freezeableDays is EqualUnmodifiableListView) return _freezeableDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_freezeableDays);
}


/// Create a copy of HabitDetailData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitDetailDataCopyWith<_HabitDetailData> get copyWith => __$HabitDetailDataCopyWithImpl<_HabitDetailData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitDetailData&&(identical(other.habit, habit) || other.habit == habit)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.vm, vm) || other.vm == vm)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&const DeepCollectionEquality().equals(other.notes, _notes)&&(identical(other.advancedReportsUnlocked, advancedReportsUnlocked) || other.advancedReportsUnlocked == advancedReportsUnlocked)&&(identical(other.showDebugFreezeButton, showDebugFreezeButton) || other.showDebugFreezeButton == showDebugFreezeButton)&&const DeepCollectionEquality().equals(other.freezeableDays, _freezeableDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,habit,summary,vm,schedule,const DeepCollectionEquality().hash(_notes),advancedReportsUnlocked,showDebugFreezeButton,const DeepCollectionEquality().hash(_freezeableDays));
}

@override
String toString() {
    return 'HabitDetailData(habit: $habit, summary: $summary, vm: $vm, schedule: $schedule, notes: $notes, advancedReportsUnlocked: $advancedReportsUnlocked, showDebugFreezeButton: $showDebugFreezeButton, freezeableDays: $freezeableDays)';
}


}

/// @nodoc
abstract mixin class _$HabitDetailDataCopyWith<$Res> implements $HabitDetailDataCopyWith<$Res> {
  factory _$HabitDetailDataCopyWith(_HabitDetailData value, $Res Function(_HabitDetailData) _then) = __$HabitDetailDataCopyWithImpl;
@override @useResult
$Res call({
 Habit habit, StreakSummary summary, HabitDetailViewModel vm, ScheduleTextData schedule, List<HabitEntry> notes, bool advancedReportsUnlocked, bool showDebugFreezeButton, List<LocalDate> freezeableDays
});


@override $HabitCopyWith<$Res> get habit;@override $StreakSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$HabitDetailDataCopyWithImpl<$Res>
    implements _$HabitDetailDataCopyWith<$Res> {
  __$HabitDetailDataCopyWithImpl(this._self, this._then);

  final _HabitDetailData _self;
  final $Res Function(_HabitDetailData) _then;

/// Create a copy of HabitDetailData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habit = null,Object? summary = null,Object? vm = null,Object? schedule = null,Object? notes = null,Object? advancedReportsUnlocked = null,Object? showDebugFreezeButton = null,Object? freezeableDays = null,}) {
  return _then(_HabitDetailData(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as Habit,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as StreakSummary,vm: null == vm ? _self.vm : vm // ignore: cast_nullable_to_non_nullable
as HabitDetailViewModel,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as ScheduleTextData,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<HabitEntry>,advancedReportsUnlocked: null == advancedReportsUnlocked ? _self.advancedReportsUnlocked : advancedReportsUnlocked // ignore: cast_nullable_to_non_nullable
as bool,showDebugFreezeButton: null == showDebugFreezeButton ? _self.showDebugFreezeButton : showDebugFreezeButton // ignore: cast_nullable_to_non_nullable
as bool,freezeableDays: null == freezeableDays ? _self._freezeableDays : freezeableDays // ignore: cast_nullable_to_non_nullable
as List<LocalDate>,
  ));
}

/// Create a copy of HabitDetailData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitCopyWith<$Res> get habit {
  
  return $HabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of HabitDetailData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakSummaryCopyWith<$Res> get summary {
  
  return $StreakSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
