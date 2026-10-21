// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repeat_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RepeatSettings {

 Frequency get frequency;/// Last local day an occurrence may fall on (inclusive); null = no end.
 DateTime? get endDate;
/// Create a copy of RepeatSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepeatSettingsCopyWith<RepeatSettings> get copyWith => _$RepeatSettingsCopyWithImpl<RepeatSettings>(this as RepeatSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RepeatSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepeatSettings&&(identical(other.frequency, _this.frequency) || other.frequency == _this.frequency)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate));
}


@override
int get hashCode {
  final _this = this as RepeatSettings;
  return Object.hash(runtimeType,_this.frequency,_this.endDate);
}

@override
String toString() {
  final _this = this as RepeatSettings;
  return 'RepeatSettings(frequency: ${_this.frequency}, endDate: ${_this.endDate})';
}


}

/// @nodoc
abstract mixin class $RepeatSettingsCopyWith<$Res>  {
  factory $RepeatSettingsCopyWith(RepeatSettings value, $Res Function(RepeatSettings) _then) = _$RepeatSettingsCopyWithImpl;
@useResult
$Res call({
 Frequency frequency, DateTime? endDate
});




}
/// @nodoc
class _$RepeatSettingsCopyWithImpl<$Res>
    implements $RepeatSettingsCopyWith<$Res> {
  _$RepeatSettingsCopyWithImpl(this._self, this._then);

  final RepeatSettings _self;
  final $Res Function(RepeatSettings) _then;

/// Create a copy of RepeatSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? frequency = null,Object? endDate = freezed,}) {
  return _then(RepeatSettings(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as Frequency,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepeatSettings].
extension RepeatSettingsPatterns on RepeatSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepeatSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepeatSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepeatSettings value)  $default,){
final _that = this;
switch (_that) {
case _RepeatSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepeatSettings value)?  $default,){
final _that = this;
switch (_that) {
case _RepeatSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Frequency frequency,  DateTime? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepeatSettings() when $default != null:
return $default(_that.frequency,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Frequency frequency,  DateTime? endDate)  $default,) {final _that = this;
switch (_that) {
case _RepeatSettings():
return $default(_that.frequency,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Frequency frequency,  DateTime? endDate)?  $default,) {final _that = this;
switch (_that) {
case _RepeatSettings() when $default != null:
return $default(_that.frequency,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _RepeatSettings extends RepeatSettings {
  const _RepeatSettings({this.frequency = Frequency.monthly, this.endDate}): super._();
  

@override@JsonKey() final  Frequency frequency;
/// Last local day an occurrence may fall on (inclusive); null = no end.
@override final  DateTime? endDate;

/// Create a copy of RepeatSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepeatSettingsCopyWith<_RepeatSettings> get copyWith => __$RepeatSettingsCopyWithImpl<_RepeatSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepeatSettings&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,frequency,endDate);
}

@override
String toString() {
    return 'RepeatSettings(frequency: $frequency, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$RepeatSettingsCopyWith<$Res> implements $RepeatSettingsCopyWith<$Res> {
  factory _$RepeatSettingsCopyWith(_RepeatSettings value, $Res Function(_RepeatSettings) _then) = __$RepeatSettingsCopyWithImpl;
@override @useResult
$Res call({
 Frequency frequency, DateTime? endDate
});




}
/// @nodoc
class __$RepeatSettingsCopyWithImpl<$Res>
    implements _$RepeatSettingsCopyWith<$Res> {
  __$RepeatSettingsCopyWithImpl(this._self, this._then);

  final _RepeatSettings _self;
  final $Res Function(_RepeatSettings) _then;

/// Create a copy of RepeatSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? frequency = null,Object? endDate = freezed,}) {
  return _then(_RepeatSettings(
frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as Frequency,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
