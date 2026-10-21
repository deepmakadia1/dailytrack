// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurringData {

 List<RecurringRuleView> get active; List<RecurringRuleView> get paused;
/// Create a copy of RecurringData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringDataCopyWith<RecurringData> get copyWith => _$RecurringDataCopyWithImpl<RecurringData>(this as RecurringData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecurringData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringData&&const DeepCollectionEquality().equals(other.active, _this.active)&&const DeepCollectionEquality().equals(other.paused, _this.paused));
}


@override
int get hashCode {
  final _this = this as RecurringData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.active),const DeepCollectionEquality().hash(_this.paused));
}

@override
String toString() {
  final _this = this as RecurringData;
  return 'RecurringData(active: ${_this.active}, paused: ${_this.paused})';
}


}

/// @nodoc
abstract mixin class $RecurringDataCopyWith<$Res>  {
  factory $RecurringDataCopyWith(RecurringData value, $Res Function(RecurringData) _then) = _$RecurringDataCopyWithImpl;
@useResult
$Res call({
 List<RecurringRuleView> active, List<RecurringRuleView> paused
});




}
/// @nodoc
class _$RecurringDataCopyWithImpl<$Res>
    implements $RecurringDataCopyWith<$Res> {
  _$RecurringDataCopyWithImpl(this._self, this._then);

  final RecurringData _self;
  final $Res Function(RecurringData) _then;

/// Create a copy of RecurringData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? active = null,Object? paused = null,}) {
  return _then(RecurringData(
active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as List<RecurringRuleView>,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as List<RecurringRuleView>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringData].
extension RecurringDataPatterns on RecurringData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringData value)  $default,){
final _that = this;
switch (_that) {
case _RecurringData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringData value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecurringRuleView> active,  List<RecurringRuleView> paused)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringData() when $default != null:
return $default(_that.active,_that.paused);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecurringRuleView> active,  List<RecurringRuleView> paused)  $default,) {final _that = this;
switch (_that) {
case _RecurringData():
return $default(_that.active,_that.paused);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecurringRuleView> active,  List<RecurringRuleView> paused)?  $default,) {final _that = this;
switch (_that) {
case _RecurringData() when $default != null:
return $default(_that.active,_that.paused);case _:
  return null;

}
}

}

/// @nodoc


class _RecurringData extends RecurringData {
  const _RecurringData({ List<RecurringRuleView> active = const <RecurringRuleView>[],  List<RecurringRuleView> paused = const <RecurringRuleView>[]}): _active = active,_paused = paused,super._();
  

 final  List<RecurringRuleView> _active;
@override@JsonKey() List<RecurringRuleView> get active {
  if (_active is EqualUnmodifiableListView) return _active;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_active);
}

 final  List<RecurringRuleView> _paused;
@override@JsonKey() List<RecurringRuleView> get paused {
  if (_paused is EqualUnmodifiableListView) return _paused;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paused);
}


/// Create a copy of RecurringData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringDataCopyWith<_RecurringData> get copyWith => __$RecurringDataCopyWithImpl<_RecurringData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringData&&const DeepCollectionEquality().equals(other.active, _active)&&const DeepCollectionEquality().equals(other.paused, _paused));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_active),const DeepCollectionEquality().hash(_paused));
}

@override
String toString() {
    return 'RecurringData(active: $active, paused: $paused)';
}


}

/// @nodoc
abstract mixin class _$RecurringDataCopyWith<$Res> implements $RecurringDataCopyWith<$Res> {
  factory _$RecurringDataCopyWith(_RecurringData value, $Res Function(_RecurringData) _then) = __$RecurringDataCopyWithImpl;
@override @useResult
$Res call({
 List<RecurringRuleView> active, List<RecurringRuleView> paused
});




}
/// @nodoc
class __$RecurringDataCopyWithImpl<$Res>
    implements _$RecurringDataCopyWith<$Res> {
  __$RecurringDataCopyWithImpl(this._self, this._then);

  final _RecurringData _self;
  final $Res Function(_RecurringData) _then;

/// Create a copy of RecurringData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? active = null,Object? paused = null,}) {
  return _then(_RecurringData(
active: null == active ? _self._active : active // ignore: cast_nullable_to_non_nullable
as List<RecurringRuleView>,paused: null == paused ? _self._paused : paused // ignore: cast_nullable_to_non_nullable
as List<RecurringRuleView>,
  ));
}


}

// dart format on
