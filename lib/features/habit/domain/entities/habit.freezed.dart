// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Habit {

 String get id;/// 1–40 characters.
 String get name; String get iconKey; String get colorHex;/// Fixed after create.
 HabitKind get kind; HabitSchedule get schedule; List<ReminderTime> get reminderTimes; bool get remindOnlyIfNotDone; LocalDate get startDate; bool get isArchived; int get sortOrder;/// 0–2 stored streak freezes.
 int get freezesAvailable; Set<Milestone> get celebratedMilestones;/// UTC.
 DateTime get createdAt; DateTime get updatedAt;/// Count habits only, at most 20 characters.
 String? get unit;/// UTC; set while archived.
 DateTime? get archivedAt;
/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitCopyWith<Habit> get copyWith => _$HabitCopyWithImpl<Habit>(this as Habit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Habit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Habit&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.schedule, _this.schedule) || other.schedule == _this.schedule)&&const DeepCollectionEquality().equals(other.reminderTimes, _this.reminderTimes)&&(identical(other.remindOnlyIfNotDone, _this.remindOnlyIfNotDone) || other.remindOnlyIfNotDone == _this.remindOnlyIfNotDone)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.isArchived, _this.isArchived) || other.isArchived == _this.isArchived)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.freezesAvailable, _this.freezesAvailable) || other.freezesAvailable == _this.freezesAvailable)&&const DeepCollectionEquality().equals(other.celebratedMilestones, _this.celebratedMilestones)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.archivedAt, _this.archivedAt) || other.archivedAt == _this.archivedAt));
}


@override
int get hashCode {
  final _this = this as Habit;
  return Object.hash(runtimeType,_this.id,_this.name,_this.iconKey,_this.colorHex,_this.kind,_this.schedule,const DeepCollectionEquality().hash(_this.reminderTimes),_this.remindOnlyIfNotDone,_this.startDate,_this.isArchived,_this.sortOrder,_this.freezesAvailable,const DeepCollectionEquality().hash(_this.celebratedMilestones),_this.createdAt,_this.updatedAt,_this.unit,_this.archivedAt);
}

@override
String toString() {
  final _this = this as Habit;
  return 'Habit(id: ${_this.id}, name: ${_this.name}, iconKey: ${_this.iconKey}, colorHex: ${_this.colorHex}, kind: ${_this.kind}, schedule: ${_this.schedule}, reminderTimes: ${_this.reminderTimes}, remindOnlyIfNotDone: ${_this.remindOnlyIfNotDone}, startDate: ${_this.startDate}, isArchived: ${_this.isArchived}, sortOrder: ${_this.sortOrder}, freezesAvailable: ${_this.freezesAvailable}, celebratedMilestones: ${_this.celebratedMilestones}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, unit: ${_this.unit}, archivedAt: ${_this.archivedAt})';
}


}

/// @nodoc
abstract mixin class $HabitCopyWith<$Res>  {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) _then) = _$HabitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String iconKey, String colorHex, HabitKind kind, HabitSchedule schedule, List<ReminderTime> reminderTimes, bool remindOnlyIfNotDone, LocalDate startDate, bool isArchived, int sortOrder, int freezesAvailable, Set<Milestone> celebratedMilestones, DateTime createdAt, DateTime updatedAt, String? unit, DateTime? archivedAt
});


$HabitScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class _$HabitCopyWithImpl<$Res>
    implements $HabitCopyWith<$Res> {
  _$HabitCopyWithImpl(this._self, this._then);

  final Habit _self;
  final $Res Function(Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconKey = null,Object? colorHex = null,Object? kind = null,Object? schedule = null,Object? reminderTimes = null,Object? remindOnlyIfNotDone = null,Object? startDate = null,Object? isArchived = null,Object? sortOrder = null,Object? freezesAvailable = null,Object? celebratedMilestones = null,Object? createdAt = null,Object? updatedAt = null,Object? unit = freezed,Object? archivedAt = freezed,}) {
  return _then(Habit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HabitKind,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as HabitSchedule,reminderTimes: null == reminderTimes ? _self.reminderTimes : reminderTimes // ignore: cast_nullable_to_non_nullable
as List<ReminderTime>,remindOnlyIfNotDone: null == remindOnlyIfNotDone ? _self.remindOnlyIfNotDone : remindOnlyIfNotDone // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as LocalDate,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,freezesAvailable: null == freezesAvailable ? _self.freezesAvailable : freezesAvailable // ignore: cast_nullable_to_non_nullable
as int,celebratedMilestones: null == celebratedMilestones ? _self.celebratedMilestones : celebratedMilestones // ignore: cast_nullable_to_non_nullable
as Set<Milestone>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitScheduleCopyWith<$Res> get schedule {
  
  return $HabitScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// Adds pattern-matching-related methods to [Habit].
extension HabitPatterns on Habit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Habit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Habit value)  $default,){
final _that = this;
switch (_that) {
case _Habit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Habit value)?  $default,){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String iconKey,  String colorHex,  HabitKind kind,  HabitSchedule schedule,  List<ReminderTime> reminderTimes,  bool remindOnlyIfNotDone,  LocalDate startDate,  bool isArchived,  int sortOrder,  int freezesAvailable,  Set<Milestone> celebratedMilestones,  DateTime createdAt,  DateTime updatedAt,  String? unit,  DateTime? archivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.name,_that.iconKey,_that.colorHex,_that.kind,_that.schedule,_that.reminderTimes,_that.remindOnlyIfNotDone,_that.startDate,_that.isArchived,_that.sortOrder,_that.freezesAvailable,_that.celebratedMilestones,_that.createdAt,_that.updatedAt,_that.unit,_that.archivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String iconKey,  String colorHex,  HabitKind kind,  HabitSchedule schedule,  List<ReminderTime> reminderTimes,  bool remindOnlyIfNotDone,  LocalDate startDate,  bool isArchived,  int sortOrder,  int freezesAvailable,  Set<Milestone> celebratedMilestones,  DateTime createdAt,  DateTime updatedAt,  String? unit,  DateTime? archivedAt)  $default,) {final _that = this;
switch (_that) {
case _Habit():
return $default(_that.id,_that.name,_that.iconKey,_that.colorHex,_that.kind,_that.schedule,_that.reminderTimes,_that.remindOnlyIfNotDone,_that.startDate,_that.isArchived,_that.sortOrder,_that.freezesAvailable,_that.celebratedMilestones,_that.createdAt,_that.updatedAt,_that.unit,_that.archivedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String iconKey,  String colorHex,  HabitKind kind,  HabitSchedule schedule,  List<ReminderTime> reminderTimes,  bool remindOnlyIfNotDone,  LocalDate startDate,  bool isArchived,  int sortOrder,  int freezesAvailable,  Set<Milestone> celebratedMilestones,  DateTime createdAt,  DateTime updatedAt,  String? unit,  DateTime? archivedAt)?  $default,) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.name,_that.iconKey,_that.colorHex,_that.kind,_that.schedule,_that.reminderTimes,_that.remindOnlyIfNotDone,_that.startDate,_that.isArchived,_that.sortOrder,_that.freezesAvailable,_that.celebratedMilestones,_that.createdAt,_that.updatedAt,_that.unit,_that.archivedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Habit implements Habit {
  const _Habit({required this.id, required this.name, required this.iconKey, required this.colorHex, required this.kind, required this.schedule, required  List<ReminderTime> reminderTimes, required this.remindOnlyIfNotDone, required this.startDate, required this.isArchived, required this.sortOrder, required this.freezesAvailable, required  Set<Milestone> celebratedMilestones, required this.createdAt, required this.updatedAt, this.unit, this.archivedAt}): _reminderTimes = reminderTimes,_celebratedMilestones = celebratedMilestones;
  

@override final  String id;
/// 1–40 characters.
@override final  String name;
@override final  String iconKey;
@override final  String colorHex;
/// Fixed after create.
@override final  HabitKind kind;
@override final  HabitSchedule schedule;
 final  List<ReminderTime> _reminderTimes;
@override List<ReminderTime> get reminderTimes {
  if (_reminderTimes is EqualUnmodifiableListView) return _reminderTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminderTimes);
}

@override final  bool remindOnlyIfNotDone;
@override final  LocalDate startDate;
@override final  bool isArchived;
@override final  int sortOrder;
/// 0–2 stored streak freezes.
@override final  int freezesAvailable;
 final  Set<Milestone> _celebratedMilestones;
@override Set<Milestone> get celebratedMilestones {
  if (_celebratedMilestones is EqualUnmodifiableSetView) return _celebratedMilestones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_celebratedMilestones);
}

/// UTC.
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
/// Count habits only, at most 20 characters.
@override final  String? unit;
/// UTC; set while archived.
@override final  DateTime? archivedAt;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitCopyWith<_Habit> get copyWith => __$HabitCopyWithImpl<_Habit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&const DeepCollectionEquality().equals(other.reminderTimes, _reminderTimes)&&(identical(other.remindOnlyIfNotDone, remindOnlyIfNotDone) || other.remindOnlyIfNotDone == remindOnlyIfNotDone)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.freezesAvailable, freezesAvailable) || other.freezesAvailable == freezesAvailable)&&const DeepCollectionEquality().equals(other.celebratedMilestones, _celebratedMilestones)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,iconKey,colorHex,kind,schedule,const DeepCollectionEquality().hash(_reminderTimes),remindOnlyIfNotDone,startDate,isArchived,sortOrder,freezesAvailable,const DeepCollectionEquality().hash(_celebratedMilestones),createdAt,updatedAt,unit,archivedAt);
}

@override
String toString() {
    return 'Habit(id: $id, name: $name, iconKey: $iconKey, colorHex: $colorHex, kind: $kind, schedule: $schedule, reminderTimes: $reminderTimes, remindOnlyIfNotDone: $remindOnlyIfNotDone, startDate: $startDate, isArchived: $isArchived, sortOrder: $sortOrder, freezesAvailable: $freezesAvailable, celebratedMilestones: $celebratedMilestones, createdAt: $createdAt, updatedAt: $updatedAt, unit: $unit, archivedAt: $archivedAt)';
}


}

/// @nodoc
abstract mixin class _$HabitCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$HabitCopyWith(_Habit value, $Res Function(_Habit) _then) = __$HabitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String iconKey, String colorHex, HabitKind kind, HabitSchedule schedule, List<ReminderTime> reminderTimes, bool remindOnlyIfNotDone, LocalDate startDate, bool isArchived, int sortOrder, int freezesAvailable, Set<Milestone> celebratedMilestones, DateTime createdAt, DateTime updatedAt, String? unit, DateTime? archivedAt
});


@override $HabitScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class __$HabitCopyWithImpl<$Res>
    implements _$HabitCopyWith<$Res> {
  __$HabitCopyWithImpl(this._self, this._then);

  final _Habit _self;
  final $Res Function(_Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconKey = null,Object? colorHex = null,Object? kind = null,Object? schedule = null,Object? reminderTimes = null,Object? remindOnlyIfNotDone = null,Object? startDate = null,Object? isArchived = null,Object? sortOrder = null,Object? freezesAvailable = null,Object? celebratedMilestones = null,Object? createdAt = null,Object? updatedAt = null,Object? unit = freezed,Object? archivedAt = freezed,}) {
  return _then(_Habit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HabitKind,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as HabitSchedule,reminderTimes: null == reminderTimes ? _self._reminderTimes : reminderTimes // ignore: cast_nullable_to_non_nullable
as List<ReminderTime>,remindOnlyIfNotDone: null == remindOnlyIfNotDone ? _self.remindOnlyIfNotDone : remindOnlyIfNotDone // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as LocalDate,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,freezesAvailable: null == freezesAvailable ? _self.freezesAvailable : freezesAvailable // ignore: cast_nullable_to_non_nullable
as int,celebratedMilestones: null == celebratedMilestones ? _self._celebratedMilestones : celebratedMilestones // ignore: cast_nullable_to_non_nullable
as Set<Milestone>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitScheduleCopyWith<$Res> get schedule {
  
  return $HabitScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}

/// @nodoc
mixin _$HabitDraft {

 String get name; String get iconKey; String get colorHex; HabitKind get kind; HabitSchedule get schedule; LocalDate get startDate; List<ReminderTime> get reminderTimes; bool get remindOnlyIfNotDone; String? get unit;
/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitDraftCopyWith<HabitDraft> get copyWith => _$HabitDraftCopyWithImpl<HabitDraft>(this as HabitDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDraft&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.schedule, _this.schedule) || other.schedule == _this.schedule)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&const DeepCollectionEquality().equals(other.reminderTimes, _this.reminderTimes)&&(identical(other.remindOnlyIfNotDone, _this.remindOnlyIfNotDone) || other.remindOnlyIfNotDone == _this.remindOnlyIfNotDone)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}


@override
int get hashCode {
  final _this = this as HabitDraft;
  return Object.hash(runtimeType,_this.name,_this.iconKey,_this.colorHex,_this.kind,_this.schedule,_this.startDate,const DeepCollectionEquality().hash(_this.reminderTimes),_this.remindOnlyIfNotDone,_this.unit);
}

@override
String toString() {
  final _this = this as HabitDraft;
  return 'HabitDraft(name: ${_this.name}, iconKey: ${_this.iconKey}, colorHex: ${_this.colorHex}, kind: ${_this.kind}, schedule: ${_this.schedule}, startDate: ${_this.startDate}, reminderTimes: ${_this.reminderTimes}, remindOnlyIfNotDone: ${_this.remindOnlyIfNotDone}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $HabitDraftCopyWith<$Res>  {
  factory $HabitDraftCopyWith(HabitDraft value, $Res Function(HabitDraft) _then) = _$HabitDraftCopyWithImpl;
@useResult
$Res call({
 String name, String iconKey, String colorHex, HabitKind kind, HabitSchedule schedule, LocalDate startDate, List<ReminderTime> reminderTimes, bool remindOnlyIfNotDone, String? unit
});


$HabitScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class _$HabitDraftCopyWithImpl<$Res>
    implements $HabitDraftCopyWith<$Res> {
  _$HabitDraftCopyWithImpl(this._self, this._then);

  final HabitDraft _self;
  final $Res Function(HabitDraft) _then;

/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? iconKey = null,Object? colorHex = null,Object? kind = null,Object? schedule = null,Object? startDate = null,Object? reminderTimes = null,Object? remindOnlyIfNotDone = null,Object? unit = freezed,}) {
  return _then(HabitDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HabitKind,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as HabitSchedule,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as LocalDate,reminderTimes: null == reminderTimes ? _self.reminderTimes : reminderTimes // ignore: cast_nullable_to_non_nullable
as List<ReminderTime>,remindOnlyIfNotDone: null == remindOnlyIfNotDone ? _self.remindOnlyIfNotDone : remindOnlyIfNotDone // ignore: cast_nullable_to_non_nullable
as bool,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitScheduleCopyWith<$Res> get schedule {
  
  return $HabitScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitDraft].
extension HabitDraftPatterns on HabitDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitDraft value)  $default,){
final _that = this;
switch (_that) {
case _HabitDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitDraft value)?  $default,){
final _that = this;
switch (_that) {
case _HabitDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String iconKey,  String colorHex,  HabitKind kind,  HabitSchedule schedule,  LocalDate startDate,  List<ReminderTime> reminderTimes,  bool remindOnlyIfNotDone,  String? unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitDraft() when $default != null:
return $default(_that.name,_that.iconKey,_that.colorHex,_that.kind,_that.schedule,_that.startDate,_that.reminderTimes,_that.remindOnlyIfNotDone,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String iconKey,  String colorHex,  HabitKind kind,  HabitSchedule schedule,  LocalDate startDate,  List<ReminderTime> reminderTimes,  bool remindOnlyIfNotDone,  String? unit)  $default,) {final _that = this;
switch (_that) {
case _HabitDraft():
return $default(_that.name,_that.iconKey,_that.colorHex,_that.kind,_that.schedule,_that.startDate,_that.reminderTimes,_that.remindOnlyIfNotDone,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String iconKey,  String colorHex,  HabitKind kind,  HabitSchedule schedule,  LocalDate startDate,  List<ReminderTime> reminderTimes,  bool remindOnlyIfNotDone,  String? unit)?  $default,) {final _that = this;
switch (_that) {
case _HabitDraft() when $default != null:
return $default(_that.name,_that.iconKey,_that.colorHex,_that.kind,_that.schedule,_that.startDate,_that.reminderTimes,_that.remindOnlyIfNotDone,_that.unit);case _:
  return null;

}
}

}

/// @nodoc


class _HabitDraft implements HabitDraft {
  const _HabitDraft({required this.name, required this.iconKey, required this.colorHex, required this.kind, required this.schedule, required this.startDate,  List<ReminderTime> reminderTimes = const <ReminderTime>[], this.remindOnlyIfNotDone = true, this.unit}): _reminderTimes = reminderTimes;
  

@override final  String name;
@override final  String iconKey;
@override final  String colorHex;
@override final  HabitKind kind;
@override final  HabitSchedule schedule;
@override final  LocalDate startDate;
 final  List<ReminderTime> _reminderTimes;
@override@JsonKey() List<ReminderTime> get reminderTimes {
  if (_reminderTimes is EqualUnmodifiableListView) return _reminderTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reminderTimes);
}

@override@JsonKey() final  bool remindOnlyIfNotDone;
@override final  String? unit;

/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitDraftCopyWith<_HabitDraft> get copyWith => __$HabitDraftCopyWithImpl<_HabitDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&const DeepCollectionEquality().equals(other.reminderTimes, _reminderTimes)&&(identical(other.remindOnlyIfNotDone, remindOnlyIfNotDone) || other.remindOnlyIfNotDone == remindOnlyIfNotDone)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,iconKey,colorHex,kind,schedule,startDate,const DeepCollectionEquality().hash(_reminderTimes),remindOnlyIfNotDone,unit);
}

@override
String toString() {
    return 'HabitDraft(name: $name, iconKey: $iconKey, colorHex: $colorHex, kind: $kind, schedule: $schedule, startDate: $startDate, reminderTimes: $reminderTimes, remindOnlyIfNotDone: $remindOnlyIfNotDone, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$HabitDraftCopyWith<$Res> implements $HabitDraftCopyWith<$Res> {
  factory _$HabitDraftCopyWith(_HabitDraft value, $Res Function(_HabitDraft) _then) = __$HabitDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String iconKey, String colorHex, HabitKind kind, HabitSchedule schedule, LocalDate startDate, List<ReminderTime> reminderTimes, bool remindOnlyIfNotDone, String? unit
});


@override $HabitScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class __$HabitDraftCopyWithImpl<$Res>
    implements _$HabitDraftCopyWith<$Res> {
  __$HabitDraftCopyWithImpl(this._self, this._then);

  final _HabitDraft _self;
  final $Res Function(_HabitDraft) _then;

/// Create a copy of HabitDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? iconKey = null,Object? colorHex = null,Object? kind = null,Object? schedule = null,Object? startDate = null,Object? reminderTimes = null,Object? remindOnlyIfNotDone = null,Object? unit = freezed,}) {
  return _then(_HabitDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HabitKind,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as HabitSchedule,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as LocalDate,reminderTimes: null == reminderTimes ? _self._reminderTimes : reminderTimes // ignore: cast_nullable_to_non_nullable
as List<ReminderTime>,remindOnlyIfNotDone: null == remindOnlyIfNotDone ? _self.remindOnlyIfNotDone : remindOnlyIfNotDone // ignore: cast_nullable_to_non_nullable
as bool,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of HabitDraft
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
