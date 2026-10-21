// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_write_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DayWriteResult {

/// The day before the write, for Undo.
 EntrySnapshot get before;/// Statistics after the write.
 StreakSummary get summary;/// The highest milestone this write celebrated for the first time.
 Milestone? get milestone;
/// Create a copy of DayWriteResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayWriteResultCopyWith<DayWriteResult> get copyWith => _$DayWriteResultCopyWithImpl<DayWriteResult>(this as DayWriteResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DayWriteResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayWriteResult&&(identical(other.before, _this.before) || other.before == _this.before)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.milestone, _this.milestone) || other.milestone == _this.milestone));
}


@override
int get hashCode {
  final _this = this as DayWriteResult;
  return Object.hash(runtimeType,_this.before,_this.summary,_this.milestone);
}

@override
String toString() {
  final _this = this as DayWriteResult;
  return 'DayWriteResult(before: ${_this.before}, summary: ${_this.summary}, milestone: ${_this.milestone})';
}


}

/// @nodoc
abstract mixin class $DayWriteResultCopyWith<$Res>  {
  factory $DayWriteResultCopyWith(DayWriteResult value, $Res Function(DayWriteResult) _then) = _$DayWriteResultCopyWithImpl;
@useResult
$Res call({
 EntrySnapshot before, StreakSummary summary, Milestone? milestone
});


$EntrySnapshotCopyWith<$Res> get before;$StreakSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$DayWriteResultCopyWithImpl<$Res>
    implements $DayWriteResultCopyWith<$Res> {
  _$DayWriteResultCopyWithImpl(this._self, this._then);

  final DayWriteResult _self;
  final $Res Function(DayWriteResult) _then;

/// Create a copy of DayWriteResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? before = null,Object? summary = null,Object? milestone = freezed,}) {
  return _then(DayWriteResult(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as EntrySnapshot,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as StreakSummary,milestone: freezed == milestone ? _self.milestone : milestone // ignore: cast_nullable_to_non_nullable
as Milestone?,
  ));
}
/// Create a copy of DayWriteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntrySnapshotCopyWith<$Res> get before {
  
  return $EntrySnapshotCopyWith<$Res>(_self.before, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of DayWriteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakSummaryCopyWith<$Res> get summary {
  
  return $StreakSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [DayWriteResult].
extension DayWriteResultPatterns on DayWriteResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayWriteResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayWriteResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayWriteResult value)  $default,){
final _that = this;
switch (_that) {
case _DayWriteResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayWriteResult value)?  $default,){
final _that = this;
switch (_that) {
case _DayWriteResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EntrySnapshot before,  StreakSummary summary,  Milestone? milestone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayWriteResult() when $default != null:
return $default(_that.before,_that.summary,_that.milestone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EntrySnapshot before,  StreakSummary summary,  Milestone? milestone)  $default,) {final _that = this;
switch (_that) {
case _DayWriteResult():
return $default(_that.before,_that.summary,_that.milestone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EntrySnapshot before,  StreakSummary summary,  Milestone? milestone)?  $default,) {final _that = this;
switch (_that) {
case _DayWriteResult() when $default != null:
return $default(_that.before,_that.summary,_that.milestone);case _:
  return null;

}
}

}

/// @nodoc


class _DayWriteResult implements DayWriteResult {
  const _DayWriteResult({required this.before, required this.summary, this.milestone});
  

/// The day before the write, for Undo.
@override final  EntrySnapshot before;
/// Statistics after the write.
@override final  StreakSummary summary;
/// The highest milestone this write celebrated for the first time.
@override final  Milestone? milestone;

/// Create a copy of DayWriteResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayWriteResultCopyWith<_DayWriteResult> get copyWith => __$DayWriteResultCopyWithImpl<_DayWriteResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayWriteResult&&(identical(other.before, before) || other.before == before)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.milestone, milestone) || other.milestone == milestone));
}


@override
int get hashCode {
    return Object.hash(runtimeType,before,summary,milestone);
}

@override
String toString() {
    return 'DayWriteResult(before: $before, summary: $summary, milestone: $milestone)';
}


}

/// @nodoc
abstract mixin class _$DayWriteResultCopyWith<$Res> implements $DayWriteResultCopyWith<$Res> {
  factory _$DayWriteResultCopyWith(_DayWriteResult value, $Res Function(_DayWriteResult) _then) = __$DayWriteResultCopyWithImpl;
@override @useResult
$Res call({
 EntrySnapshot before, StreakSummary summary, Milestone? milestone
});


@override $EntrySnapshotCopyWith<$Res> get before;@override $StreakSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$DayWriteResultCopyWithImpl<$Res>
    implements _$DayWriteResultCopyWith<$Res> {
  __$DayWriteResultCopyWithImpl(this._self, this._then);

  final _DayWriteResult _self;
  final $Res Function(_DayWriteResult) _then;

/// Create a copy of DayWriteResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? before = null,Object? summary = null,Object? milestone = freezed,}) {
  return _then(_DayWriteResult(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as EntrySnapshot,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as StreakSummary,milestone: freezed == milestone ? _self.milestone : milestone // ignore: cast_nullable_to_non_nullable
as Milestone?,
  ));
}

/// Create a copy of DayWriteResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntrySnapshotCopyWith<$Res> get before {
  
  return $EntrySnapshotCopyWith<$Res>(_self.before, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of DayWriteResult
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
