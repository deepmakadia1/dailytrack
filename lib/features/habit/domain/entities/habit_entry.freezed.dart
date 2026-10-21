// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitEntry {

 String get habitId; LocalDate get date;/// 1 for a done yes/no day, or the count achieved; 0 on a note-only or
/// freeze day.
 int get value; bool get isFreeze;/// At most 200 characters.
 String? get note;
/// Create a copy of HabitEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitEntryCopyWith<HabitEntry> get copyWith => _$HabitEntryCopyWithImpl<HabitEntry>(this as HabitEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HabitEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitEntry&&(identical(other.habitId, _this.habitId) || other.habitId == _this.habitId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.isFreeze, _this.isFreeze) || other.isFreeze == _this.isFreeze)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as HabitEntry;
  return Object.hash(runtimeType,_this.habitId,_this.date,_this.value,_this.isFreeze,_this.note);
}

@override
String toString() {
  final _this = this as HabitEntry;
  return 'HabitEntry(habitId: ${_this.habitId}, date: ${_this.date}, value: ${_this.value}, isFreeze: ${_this.isFreeze}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $HabitEntryCopyWith<$Res>  {
  factory $HabitEntryCopyWith(HabitEntry value, $Res Function(HabitEntry) _then) = _$HabitEntryCopyWithImpl;
@useResult
$Res call({
 String habitId, LocalDate date, int value, bool isFreeze, String? note
});




}
/// @nodoc
class _$HabitEntryCopyWithImpl<$Res>
    implements $HabitEntryCopyWith<$Res> {
  _$HabitEntryCopyWithImpl(this._self, this._then);

  final HabitEntry _self;
  final $Res Function(HabitEntry) _then;

/// Create a copy of HabitEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habitId = null,Object? date = null,Object? value = null,Object? isFreeze = null,Object? note = freezed,}) {
  return _then(HabitEntry(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,isFreeze: null == isFreeze ? _self.isFreeze : isFreeze // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HabitEntry].
extension HabitEntryPatterns on HabitEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitEntry value)  $default,){
final _that = this;
switch (_that) {
case _HabitEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitEntry value)?  $default,){
final _that = this;
switch (_that) {
case _HabitEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String habitId,  LocalDate date,  int value,  bool isFreeze,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitEntry() when $default != null:
return $default(_that.habitId,_that.date,_that.value,_that.isFreeze,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String habitId,  LocalDate date,  int value,  bool isFreeze,  String? note)  $default,) {final _that = this;
switch (_that) {
case _HabitEntry():
return $default(_that.habitId,_that.date,_that.value,_that.isFreeze,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String habitId,  LocalDate date,  int value,  bool isFreeze,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _HabitEntry() when $default != null:
return $default(_that.habitId,_that.date,_that.value,_that.isFreeze,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _HabitEntry implements HabitEntry {
  const _HabitEntry({required this.habitId, required this.date, required this.value, required this.isFreeze, this.note});
  

@override final  String habitId;
@override final  LocalDate date;
/// 1 for a done yes/no day, or the count achieved; 0 on a note-only or
/// freeze day.
@override final  int value;
@override final  bool isFreeze;
/// At most 200 characters.
@override final  String? note;

/// Create a copy of HabitEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitEntryCopyWith<_HabitEntry> get copyWith => __$HabitEntryCopyWithImpl<_HabitEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitEntry&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.isFreeze, isFreeze) || other.isFreeze == isFreeze)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,habitId,date,value,isFreeze,note);
}

@override
String toString() {
    return 'HabitEntry(habitId: $habitId, date: $date, value: $value, isFreeze: $isFreeze, note: $note)';
}


}

/// @nodoc
abstract mixin class _$HabitEntryCopyWith<$Res> implements $HabitEntryCopyWith<$Res> {
  factory _$HabitEntryCopyWith(_HabitEntry value, $Res Function(_HabitEntry) _then) = __$HabitEntryCopyWithImpl;
@override @useResult
$Res call({
 String habitId, LocalDate date, int value, bool isFreeze, String? note
});




}
/// @nodoc
class __$HabitEntryCopyWithImpl<$Res>
    implements _$HabitEntryCopyWith<$Res> {
  __$HabitEntryCopyWithImpl(this._self, this._then);

  final _HabitEntry _self;
  final $Res Function(_HabitEntry) _then;

/// Create a copy of HabitEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habitId = null,Object? date = null,Object? value = null,Object? isFreeze = null,Object? note = freezed,}) {
  return _then(_HabitEntry(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,isFreeze: null == isFreeze ? _self.isFreeze : isFreeze // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$EntrySnapshot {

 String get habitId; LocalDate get date;/// Whether a live row existed.
 bool get wasLive; int get value; bool get isFreeze; int get freezesAvailableBefore; String? get note;
/// Create a copy of EntrySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntrySnapshotCopyWith<EntrySnapshot> get copyWith => _$EntrySnapshotCopyWithImpl<EntrySnapshot>(this as EntrySnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EntrySnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntrySnapshot&&(identical(other.habitId, _this.habitId) || other.habitId == _this.habitId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.wasLive, _this.wasLive) || other.wasLive == _this.wasLive)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.isFreeze, _this.isFreeze) || other.isFreeze == _this.isFreeze)&&(identical(other.freezesAvailableBefore, _this.freezesAvailableBefore) || other.freezesAvailableBefore == _this.freezesAvailableBefore)&&(identical(other.note, _this.note) || other.note == _this.note));
}


@override
int get hashCode {
  final _this = this as EntrySnapshot;
  return Object.hash(runtimeType,_this.habitId,_this.date,_this.wasLive,_this.value,_this.isFreeze,_this.freezesAvailableBefore,_this.note);
}

@override
String toString() {
  final _this = this as EntrySnapshot;
  return 'EntrySnapshot(habitId: ${_this.habitId}, date: ${_this.date}, wasLive: ${_this.wasLive}, value: ${_this.value}, isFreeze: ${_this.isFreeze}, freezesAvailableBefore: ${_this.freezesAvailableBefore}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $EntrySnapshotCopyWith<$Res>  {
  factory $EntrySnapshotCopyWith(EntrySnapshot value, $Res Function(EntrySnapshot) _then) = _$EntrySnapshotCopyWithImpl;
@useResult
$Res call({
 String habitId, LocalDate date, bool wasLive, int value, bool isFreeze, int freezesAvailableBefore, String? note
});




}
/// @nodoc
class _$EntrySnapshotCopyWithImpl<$Res>
    implements $EntrySnapshotCopyWith<$Res> {
  _$EntrySnapshotCopyWithImpl(this._self, this._then);

  final EntrySnapshot _self;
  final $Res Function(EntrySnapshot) _then;

/// Create a copy of EntrySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habitId = null,Object? date = null,Object? wasLive = null,Object? value = null,Object? isFreeze = null,Object? freezesAvailableBefore = null,Object? note = freezed,}) {
  return _then(EntrySnapshot(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,wasLive: null == wasLive ? _self.wasLive : wasLive // ignore: cast_nullable_to_non_nullable
as bool,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,isFreeze: null == isFreeze ? _self.isFreeze : isFreeze // ignore: cast_nullable_to_non_nullable
as bool,freezesAvailableBefore: null == freezesAvailableBefore ? _self.freezesAvailableBefore : freezesAvailableBefore // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EntrySnapshot].
extension EntrySnapshotPatterns on EntrySnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntrySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntrySnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntrySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _EntrySnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntrySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _EntrySnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String habitId,  LocalDate date,  bool wasLive,  int value,  bool isFreeze,  int freezesAvailableBefore,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntrySnapshot() when $default != null:
return $default(_that.habitId,_that.date,_that.wasLive,_that.value,_that.isFreeze,_that.freezesAvailableBefore,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String habitId,  LocalDate date,  bool wasLive,  int value,  bool isFreeze,  int freezesAvailableBefore,  String? note)  $default,) {final _that = this;
switch (_that) {
case _EntrySnapshot():
return $default(_that.habitId,_that.date,_that.wasLive,_that.value,_that.isFreeze,_that.freezesAvailableBefore,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String habitId,  LocalDate date,  bool wasLive,  int value,  bool isFreeze,  int freezesAvailableBefore,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _EntrySnapshot() when $default != null:
return $default(_that.habitId,_that.date,_that.wasLive,_that.value,_that.isFreeze,_that.freezesAvailableBefore,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _EntrySnapshot implements EntrySnapshot {
  const _EntrySnapshot({required this.habitId, required this.date, required this.wasLive, required this.value, required this.isFreeze, required this.freezesAvailableBefore, this.note});
  

@override final  String habitId;
@override final  LocalDate date;
/// Whether a live row existed.
@override final  bool wasLive;
@override final  int value;
@override final  bool isFreeze;
@override final  int freezesAvailableBefore;
@override final  String? note;

/// Create a copy of EntrySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntrySnapshotCopyWith<_EntrySnapshot> get copyWith => __$EntrySnapshotCopyWithImpl<_EntrySnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntrySnapshot&&(identical(other.habitId, habitId) || other.habitId == habitId)&&(identical(other.date, date) || other.date == date)&&(identical(other.wasLive, wasLive) || other.wasLive == wasLive)&&(identical(other.value, value) || other.value == value)&&(identical(other.isFreeze, isFreeze) || other.isFreeze == isFreeze)&&(identical(other.freezesAvailableBefore, freezesAvailableBefore) || other.freezesAvailableBefore == freezesAvailableBefore)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode {
    return Object.hash(runtimeType,habitId,date,wasLive,value,isFreeze,freezesAvailableBefore,note);
}

@override
String toString() {
    return 'EntrySnapshot(habitId: $habitId, date: $date, wasLive: $wasLive, value: $value, isFreeze: $isFreeze, freezesAvailableBefore: $freezesAvailableBefore, note: $note)';
}


}

/// @nodoc
abstract mixin class _$EntrySnapshotCopyWith<$Res> implements $EntrySnapshotCopyWith<$Res> {
  factory _$EntrySnapshotCopyWith(_EntrySnapshot value, $Res Function(_EntrySnapshot) _then) = __$EntrySnapshotCopyWithImpl;
@override @useResult
$Res call({
 String habitId, LocalDate date, bool wasLive, int value, bool isFreeze, int freezesAvailableBefore, String? note
});




}
/// @nodoc
class __$EntrySnapshotCopyWithImpl<$Res>
    implements _$EntrySnapshotCopyWith<$Res> {
  __$EntrySnapshotCopyWithImpl(this._self, this._then);

  final _EntrySnapshot _self;
  final $Res Function(_EntrySnapshot) _then;

/// Create a copy of EntrySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habitId = null,Object? date = null,Object? wasLive = null,Object? value = null,Object? isFreeze = null,Object? freezesAvailableBefore = null,Object? note = freezed,}) {
  return _then(_EntrySnapshot(
habitId: null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as LocalDate,wasLive: null == wasLive ? _self.wasLive : wasLive // ignore: cast_nullable_to_non_nullable
as bool,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,isFreeze: null == isFreeze ? _self.isFreeze : isFreeze // ignore: cast_nullable_to_non_nullable
as bool,freezesAvailableBefore: null == freezesAvailableBefore ? _self.freezesAvailableBefore : freezesAvailableBefore // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
