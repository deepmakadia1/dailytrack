// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interstitial_cap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InterstitialCapState {

/// UTC.
 DateTime get installAt;/// UTC. Null until the first interstitial.
 DateTime? get lastShownAt;/// Local `yyyy-MM-dd` that [shownToday] counts for.
 String? get dayKey; int get shownToday;/// The current session is the user's first of the local day.
 bool get isFirstSessionOfDay;/// New EXP-02 entries saved in this session since the last interstitial.
 int get expenseSaves;
/// Create a copy of InterstitialCapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterstitialCapStateCopyWith<InterstitialCapState> get copyWith => _$InterstitialCapStateCopyWithImpl<InterstitialCapState>(this as InterstitialCapState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InterstitialCapState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterstitialCapState&&(identical(other.installAt, _this.installAt) || other.installAt == _this.installAt)&&(identical(other.lastShownAt, _this.lastShownAt) || other.lastShownAt == _this.lastShownAt)&&(identical(other.dayKey, _this.dayKey) || other.dayKey == _this.dayKey)&&(identical(other.shownToday, _this.shownToday) || other.shownToday == _this.shownToday)&&(identical(other.isFirstSessionOfDay, _this.isFirstSessionOfDay) || other.isFirstSessionOfDay == _this.isFirstSessionOfDay)&&(identical(other.expenseSaves, _this.expenseSaves) || other.expenseSaves == _this.expenseSaves));
}


@override
int get hashCode {
  final _this = this as InterstitialCapState;
  return Object.hash(runtimeType,_this.installAt,_this.lastShownAt,_this.dayKey,_this.shownToday,_this.isFirstSessionOfDay,_this.expenseSaves);
}

@override
String toString() {
  final _this = this as InterstitialCapState;
  return 'InterstitialCapState(installAt: ${_this.installAt}, lastShownAt: ${_this.lastShownAt}, dayKey: ${_this.dayKey}, shownToday: ${_this.shownToday}, isFirstSessionOfDay: ${_this.isFirstSessionOfDay}, expenseSaves: ${_this.expenseSaves})';
}


}

/// @nodoc
abstract mixin class $InterstitialCapStateCopyWith<$Res>  {
  factory $InterstitialCapStateCopyWith(InterstitialCapState value, $Res Function(InterstitialCapState) _then) = _$InterstitialCapStateCopyWithImpl;
@useResult
$Res call({
 DateTime installAt, DateTime? lastShownAt, String? dayKey, int shownToday, bool isFirstSessionOfDay, int expenseSaves
});




}
/// @nodoc
class _$InterstitialCapStateCopyWithImpl<$Res>
    implements $InterstitialCapStateCopyWith<$Res> {
  _$InterstitialCapStateCopyWithImpl(this._self, this._then);

  final InterstitialCapState _self;
  final $Res Function(InterstitialCapState) _then;

/// Create a copy of InterstitialCapState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? installAt = null,Object? lastShownAt = freezed,Object? dayKey = freezed,Object? shownToday = null,Object? isFirstSessionOfDay = null,Object? expenseSaves = null,}) {
  return _then(InterstitialCapState(
installAt: null == installAt ? _self.installAt : installAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastShownAt: freezed == lastShownAt ? _self.lastShownAt : lastShownAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dayKey: freezed == dayKey ? _self.dayKey : dayKey // ignore: cast_nullable_to_non_nullable
as String?,shownToday: null == shownToday ? _self.shownToday : shownToday // ignore: cast_nullable_to_non_nullable
as int,isFirstSessionOfDay: null == isFirstSessionOfDay ? _self.isFirstSessionOfDay : isFirstSessionOfDay // ignore: cast_nullable_to_non_nullable
as bool,expenseSaves: null == expenseSaves ? _self.expenseSaves : expenseSaves // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InterstitialCapState].
extension InterstitialCapStatePatterns on InterstitialCapState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterstitialCapState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterstitialCapState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterstitialCapState value)  $default,){
final _that = this;
switch (_that) {
case _InterstitialCapState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterstitialCapState value)?  $default,){
final _that = this;
switch (_that) {
case _InterstitialCapState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime installAt,  DateTime? lastShownAt,  String? dayKey,  int shownToday,  bool isFirstSessionOfDay,  int expenseSaves)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterstitialCapState() when $default != null:
return $default(_that.installAt,_that.lastShownAt,_that.dayKey,_that.shownToday,_that.isFirstSessionOfDay,_that.expenseSaves);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime installAt,  DateTime? lastShownAt,  String? dayKey,  int shownToday,  bool isFirstSessionOfDay,  int expenseSaves)  $default,) {final _that = this;
switch (_that) {
case _InterstitialCapState():
return $default(_that.installAt,_that.lastShownAt,_that.dayKey,_that.shownToday,_that.isFirstSessionOfDay,_that.expenseSaves);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime installAt,  DateTime? lastShownAt,  String? dayKey,  int shownToday,  bool isFirstSessionOfDay,  int expenseSaves)?  $default,) {final _that = this;
switch (_that) {
case _InterstitialCapState() when $default != null:
return $default(_that.installAt,_that.lastShownAt,_that.dayKey,_that.shownToday,_that.isFirstSessionOfDay,_that.expenseSaves);case _:
  return null;

}
}

}

/// @nodoc


class _InterstitialCapState implements InterstitialCapState {
  const _InterstitialCapState({required this.installAt, this.lastShownAt, this.dayKey, this.shownToday = 0, this.isFirstSessionOfDay = false, this.expenseSaves = 0});
  

/// UTC.
@override final  DateTime installAt;
/// UTC. Null until the first interstitial.
@override final  DateTime? lastShownAt;
/// Local `yyyy-MM-dd` that [shownToday] counts for.
@override final  String? dayKey;
@override@JsonKey() final  int shownToday;
/// The current session is the user's first of the local day.
@override@JsonKey() final  bool isFirstSessionOfDay;
/// New EXP-02 entries saved in this session since the last interstitial.
@override@JsonKey() final  int expenseSaves;

/// Create a copy of InterstitialCapState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterstitialCapStateCopyWith<_InterstitialCapState> get copyWith => __$InterstitialCapStateCopyWithImpl<_InterstitialCapState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterstitialCapState&&(identical(other.installAt, installAt) || other.installAt == installAt)&&(identical(other.lastShownAt, lastShownAt) || other.lastShownAt == lastShownAt)&&(identical(other.dayKey, dayKey) || other.dayKey == dayKey)&&(identical(other.shownToday, shownToday) || other.shownToday == shownToday)&&(identical(other.isFirstSessionOfDay, isFirstSessionOfDay) || other.isFirstSessionOfDay == isFirstSessionOfDay)&&(identical(other.expenseSaves, expenseSaves) || other.expenseSaves == expenseSaves));
}


@override
int get hashCode {
    return Object.hash(runtimeType,installAt,lastShownAt,dayKey,shownToday,isFirstSessionOfDay,expenseSaves);
}

@override
String toString() {
    return 'InterstitialCapState(installAt: $installAt, lastShownAt: $lastShownAt, dayKey: $dayKey, shownToday: $shownToday, isFirstSessionOfDay: $isFirstSessionOfDay, expenseSaves: $expenseSaves)';
}


}

/// @nodoc
abstract mixin class _$InterstitialCapStateCopyWith<$Res> implements $InterstitialCapStateCopyWith<$Res> {
  factory _$InterstitialCapStateCopyWith(_InterstitialCapState value, $Res Function(_InterstitialCapState) _then) = __$InterstitialCapStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime installAt, DateTime? lastShownAt, String? dayKey, int shownToday, bool isFirstSessionOfDay, int expenseSaves
});




}
/// @nodoc
class __$InterstitialCapStateCopyWithImpl<$Res>
    implements _$InterstitialCapStateCopyWith<$Res> {
  __$InterstitialCapStateCopyWithImpl(this._self, this._then);

  final _InterstitialCapState _self;
  final $Res Function(_InterstitialCapState) _then;

/// Create a copy of InterstitialCapState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? installAt = null,Object? lastShownAt = freezed,Object? dayKey = freezed,Object? shownToday = null,Object? isFirstSessionOfDay = null,Object? expenseSaves = null,}) {
  return _then(_InterstitialCapState(
installAt: null == installAt ? _self.installAt : installAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastShownAt: freezed == lastShownAt ? _self.lastShownAt : lastShownAt // ignore: cast_nullable_to_non_nullable
as DateTime?,dayKey: freezed == dayKey ? _self.dayKey : dayKey // ignore: cast_nullable_to_non_nullable
as String?,shownToday: null == shownToday ? _self.shownToday : shownToday // ignore: cast_nullable_to_non_nullable
as int,isFirstSessionOfDay: null == isFirstSessionOfDay ? _self.isFirstSessionOfDay : isFirstSessionOfDay // ignore: cast_nullable_to_non_nullable
as bool,expenseSaves: null == expenseSaves ? _self.expenseSaves : expenseSaves // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
