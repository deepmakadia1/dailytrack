// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budgets_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetsState {

/// `yyyy-MM`.
 String get monthKey; AsyncValue<BudgetsOverview> get overview;
/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetsStateCopyWith<BudgetsState> get copyWith => _$BudgetsStateCopyWithImpl<BudgetsState>(this as BudgetsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BudgetsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetsState&&(identical(other.monthKey, _this.monthKey) || other.monthKey == _this.monthKey)&&(identical(other.overview, _this.overview) || other.overview == _this.overview));
}


@override
int get hashCode {
  final _this = this as BudgetsState;
  return Object.hash(runtimeType,_this.monthKey,_this.overview);
}

@override
String toString() {
  final _this = this as BudgetsState;
  return 'BudgetsState(monthKey: ${_this.monthKey}, overview: ${_this.overview})';
}


}

/// @nodoc
abstract mixin class $BudgetsStateCopyWith<$Res>  {
  factory $BudgetsStateCopyWith(BudgetsState value, $Res Function(BudgetsState) _then) = _$BudgetsStateCopyWithImpl;
@useResult
$Res call({
 String monthKey, AsyncValue<BudgetsOverview> overview
});




}
/// @nodoc
class _$BudgetsStateCopyWithImpl<$Res>
    implements $BudgetsStateCopyWith<$Res> {
  _$BudgetsStateCopyWithImpl(this._self, this._then);

  final BudgetsState _self;
  final $Res Function(BudgetsState) _then;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthKey = null,Object? overview = null,}) {
  return _then(BudgetsState(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as AsyncValue<BudgetsOverview>,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetsState].
extension BudgetsStatePatterns on BudgetsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetsState value)  $default,){
final _that = this;
switch (_that) {
case _BudgetsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetsState value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String monthKey,  AsyncValue<BudgetsOverview> overview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
return $default(_that.monthKey,_that.overview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String monthKey,  AsyncValue<BudgetsOverview> overview)  $default,) {final _that = this;
switch (_that) {
case _BudgetsState():
return $default(_that.monthKey,_that.overview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String monthKey,  AsyncValue<BudgetsOverview> overview)?  $default,) {final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
return $default(_that.monthKey,_that.overview);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetsState implements BudgetsState {
  const _BudgetsState({required this.monthKey, this.overview = const AsyncLoading<BudgetsOverview>()});
  

/// `yyyy-MM`.
@override final  String monthKey;
@override@JsonKey() final  AsyncValue<BudgetsOverview> overview;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetsStateCopyWith<_BudgetsState> get copyWith => __$BudgetsStateCopyWithImpl<_BudgetsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetsState&&(identical(other.monthKey, monthKey) || other.monthKey == monthKey)&&(identical(other.overview, overview) || other.overview == overview));
}


@override
int get hashCode {
    return Object.hash(runtimeType,monthKey,overview);
}

@override
String toString() {
    return 'BudgetsState(monthKey: $monthKey, overview: $overview)';
}


}

/// @nodoc
abstract mixin class _$BudgetsStateCopyWith<$Res> implements $BudgetsStateCopyWith<$Res> {
  factory _$BudgetsStateCopyWith(_BudgetsState value, $Res Function(_BudgetsState) _then) = __$BudgetsStateCopyWithImpl;
@override @useResult
$Res call({
 String monthKey, AsyncValue<BudgetsOverview> overview
});




}
/// @nodoc
class __$BudgetsStateCopyWithImpl<$Res>
    implements _$BudgetsStateCopyWith<$Res> {
  __$BudgetsStateCopyWithImpl(this._self, this._then);

  final _BudgetsState _self;
  final $Res Function(_BudgetsState) _then;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthKey = null,Object? overview = null,}) {
  return _then(_BudgetsState(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as AsyncValue<BudgetsOverview>,
  ));
}


}

// dart format on
