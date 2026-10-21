// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitHistory {

 String get habitId; HabitKind get kind; LocalDate get startDate;/// Oldest first; never empty.
 List<ScheduleVersion> get versions; Map<LocalDate, HabitEntry> get entries;/// Set when only entries on or after this day were loaded (research R7);
/// streaks reaching it may be longer than computed.
 LocalDate? get loadedFrom;
/// Create a copy of HabitHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitHistoryCopyWith<HabitHistory> get copyWith => _$HabitHistoryCopyWithImpl<HabitHistory>(this as HabitHistory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitHistory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitHistory&&(identical(other.habitId, _this.habitId) || other.habitId == _this.habitId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&const DeepCollectionEquality().equals(other.versions, _this.versions)&&const DeepCollectionEquality().equals(other.entries, _this.entries)&&(identical(other.loadedFrom, _this.loadedFrom) || other.loadedFrom == _this.loadedFrom));
}


@override
int get hashCode {
  final _this = this as HabitHistory;
  return Object.hash(runtimeType,_this.habitId,_this.kind,_this.startDate,const DeepCollectionEquality().hash(_this.versions),const DeepCollectionEquality().hash(_this.entries),_this.loadedFrom);
}

@override
String toString() {
  final _this = this as HabitHistory;
  return 'HabitHistory(habitId: ${_this.habitId}, kind: ${_this.kind}, startDate: ${_this.startDate}, versions: ${_this.versions}, entries: ${_this.entries}, loadedFrom: ${_this.loadedFrom})';
}


}

/// @nodoc
abstract mixin class $HabitHistoryCopyWith<$Res>  {
  factory $HabitHistoryCopyWith(HabitHistory value, $Res Function(HabitHistory) _then) = _$HabitHistoryCopyWithImpl;
@useResult
$Res call({
 String habitId, HabitKind kind, LocalDate startDate, List<ScheduleVersion> versions, Map<LocalDate, HabitEntry> entries, LocalDate? loadedFrom
});




}
/// @nodoc
class _$HabitHistoryCopyWithImpl<$Res>
    implements $HabitHistoryCopyWith<$Res> {
  _$HabitHistoryCopyWithImpl(this._self, this._then);

  final HabitHistory _self;
  final $Res Function(HabitHistory) _then;

/// Create a copy of HabitHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habitId = null,Object? kind = null,Object? startDate = null,Object? versions = null,Object? entries = null,Object? loadedFrom = freezed,}) {
  return _then(HabitHistory(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HabitKind,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as LocalDate,versions: null == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as List<ScheduleVersion>,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as Map<LocalDate, HabitEntry>,loadedFrom: freezed == loadedFrom ? _self.loadedFrom : loadedFrom // ignore: cast_nullable_to_non_nullable
as LocalDate?,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitHistory].
extension HabitHistoryPatterns on HabitHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitHistory value)  $default,){
final _that = this;
switch (_that) {
case _HabitHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitHistory value)?  $default,){
final _that = this;
switch (_that) {
case _HabitHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String habitId,  HabitKind kind,  LocalDate startDate,  List<ScheduleVersion> versions,  Map<LocalDate, HabitEntry> entries,  LocalDate? loadedFrom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitHistory() when $default != null:
return $default(_that.habitId,_that.kind,_that.startDate,_that.versions,_that.entries,_that.loadedFrom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String habitId,  HabitKind kind,  LocalDate startDate,  List<ScheduleVersion> versions,  Map<LocalDate, HabitEntry> entries,  LocalDate? loadedFrom)  $default,) {final _that = this;
switch (_that) {
case _HabitHistory():
return $default(_that.habitId,_that.kind,_that.startDate,_that.versions,_that.entries,_that.loadedFrom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String habitId,  HabitKind kind,  LocalDate startDate,  List<ScheduleVersion> versions,  Map<LocalDate, HabitEntry> entries,  LocalDate? loadedFrom)?  $default,) {final _that = this;
switch (_that) {
case _HabitHistory() when $default != null:
return $default(_that.habitId,_that.kind,_that.startDate,_that.versions,_that.entries,_that.loadedFrom);case _:
  return null;

}
}

}

/// @nodoc


class _HabitHistory implements HabitHistory {
  const _HabitHistory({required this.habitId, required this.kind, required this.startDate, required  List<ScheduleVersion> versions, required  Map<LocalDate, HabitEntry> entries, this.loadedFrom}): _versions = versions,_entries = entries;
  

@override final  String habitId;
@override final  HabitKind kind;
@override final  LocalDate startDate;
/// Oldest first; never empty.
 final  List<ScheduleVersion> _versions;
/// Oldest first; never empty.
@override List<ScheduleVersion> get versions {
  if (_versions is EqualUnmodifiableListView) return _versions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_versions);
}

 final  Map<LocalDate, HabitEntry> _entries;
@override Map<LocalDate, HabitEntry> get entries {
  if (_entries is EqualUnmodifiableMapView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_entries);
}

/// Set when only entries on or after this day were loaded (research R7);
/// streaks reaching it may be longer than computed.
@override final  LocalDate? loadedFrom;

/// Create a copy of HabitHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitHistoryCopyWith<_HabitHistory> get copyWith => __$HabitHistoryCopyWithImpl<_HabitHistory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitHistory&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&const DeepCollectionEquality().equals(other.versions, _versions)&&const DeepCollectionEquality().equals(other.entries, _entries)&&(identical(other.loadedFrom, loadedFrom) || other.loadedFrom == loadedFrom));
}


@override
int get hashCode {
    return Object.hash(runtimeType,habitId,kind,startDate,const DeepCollectionEquality().hash(_versions),const DeepCollectionEquality().hash(_entries),loadedFrom);
}

@override
String toString() {
    return 'HabitHistory(habitId: $habitId, kind: $kind, startDate: $startDate, versions: $versions, entries: $entries, loadedFrom: $loadedFrom)';
}


}

/// @nodoc
abstract mixin class _$HabitHistoryCopyWith<$Res> implements $HabitHistoryCopyWith<$Res> {
  factory _$HabitHistoryCopyWith(_HabitHistory value, $Res Function(_HabitHistory) _then) = __$HabitHistoryCopyWithImpl;
@override @useResult
$Res call({
 String habitId, HabitKind kind, LocalDate startDate, List<ScheduleVersion> versions, Map<LocalDate, HabitEntry> entries, LocalDate? loadedFrom
});




}
/// @nodoc
class __$HabitHistoryCopyWithImpl<$Res>
    implements _$HabitHistoryCopyWith<$Res> {
  __$HabitHistoryCopyWithImpl(this._self, this._then);

  final _HabitHistory _self;
  final $Res Function(_HabitHistory) _then;

/// Create a copy of HabitHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habitId = null,Object? kind = null,Object? startDate = null,Object? versions = null,Object? entries = null,Object? loadedFrom = freezed,}) {
  return _then(_HabitHistory(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as HabitKind,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as LocalDate,versions: null == versions ? _self._versions : versions // ignore: cast_nullable_to_non_nullable
as List<ScheduleVersion>,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as Map<LocalDate, HabitEntry>,loadedFrom: freezed == loadedFrom ? _self.loadedFrom : loadedFrom // ignore: cast_nullable_to_non_nullable
as LocalDate?,
  ));
}


}

// dart format on
