// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsViewData {

 AppSettings get settings;/// Enabled module ids in the user's order; the Habit reminders row is
/// shown only when `habit` is here (clarification Q2).
 List<String> get visibleModuleIds;/// Dev flavor only: shows the Developer section (FR-013).
 bool get devTools;
/// Create a copy of SettingsViewData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsViewDataCopyWith<SettingsViewData> get copyWith => _$SettingsViewDataCopyWithImpl<SettingsViewData>(this as SettingsViewData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SettingsViewData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsViewData&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&const DeepCollectionEquality().equals(other.visibleModuleIds, _this.visibleModuleIds)&&(identical(other.devTools, _this.devTools) || other.devTools == _this.devTools));
}


@override
int get hashCode {
  final _this = this as SettingsViewData;
  return Object.hash(runtimeType,_this.settings,const DeepCollectionEquality().hash(_this.visibleModuleIds),_this.devTools);
}

@override
String toString() {
  final _this = this as SettingsViewData;
  return 'SettingsViewData(settings: ${_this.settings}, visibleModuleIds: ${_this.visibleModuleIds}, devTools: ${_this.devTools})';
}


}

/// @nodoc
abstract mixin class $SettingsViewDataCopyWith<$Res>  {
  factory $SettingsViewDataCopyWith(SettingsViewData value, $Res Function(SettingsViewData) _then) = _$SettingsViewDataCopyWithImpl;
@useResult
$Res call({
 AppSettings settings, List<String> visibleModuleIds, bool devTools
});


$AppSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$SettingsViewDataCopyWithImpl<$Res>
    implements $SettingsViewDataCopyWith<$Res> {
  _$SettingsViewDataCopyWithImpl(this._self, this._then);

  final SettingsViewData _self;
  final $Res Function(SettingsViewData) _then;

/// Create a copy of SettingsViewData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? settings = null,Object? visibleModuleIds = null,Object? devTools = null,}) {
  return _then(SettingsViewData(
settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as AppSettings,visibleModuleIds: null == visibleModuleIds ? _self.visibleModuleIds : visibleModuleIds // ignore: cast_nullable_to_non_nullable
as List<String>,devTools: null == devTools ? _self.devTools : devTools // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SettingsViewData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<$Res> get settings {
  
  return $AppSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [SettingsViewData].
extension SettingsViewDataPatterns on SettingsViewData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsViewData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsViewData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsViewData value)  $default,){
final _that = this;
switch (_that) {
case _SettingsViewData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsViewData value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsViewData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppSettings settings,  List<String> visibleModuleIds,  bool devTools)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsViewData() when $default != null:
return $default(_that.settings,_that.visibleModuleIds,_that.devTools);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppSettings settings,  List<String> visibleModuleIds,  bool devTools)  $default,) {final _that = this;
switch (_that) {
case _SettingsViewData():
return $default(_that.settings,_that.visibleModuleIds,_that.devTools);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppSettings settings,  List<String> visibleModuleIds,  bool devTools)?  $default,) {final _that = this;
switch (_that) {
case _SettingsViewData() when $default != null:
return $default(_that.settings,_that.visibleModuleIds,_that.devTools);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsViewData implements SettingsViewData {
  const _SettingsViewData({required this.settings, required  List<String> visibleModuleIds, required this.devTools}): _visibleModuleIds = visibleModuleIds;
  

@override final  AppSettings settings;
/// Enabled module ids in the user's order; the Habit reminders row is
/// shown only when `habit` is here (clarification Q2).
 final  List<String> _visibleModuleIds;
/// Enabled module ids in the user's order; the Habit reminders row is
/// shown only when `habit` is here (clarification Q2).
@override List<String> get visibleModuleIds {
  if (_visibleModuleIds is EqualUnmodifiableListView) return _visibleModuleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_visibleModuleIds);
}

/// Dev flavor only: shows the Developer section (FR-013).
@override final  bool devTools;

/// Create a copy of SettingsViewData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsViewDataCopyWith<_SettingsViewData> get copyWith => __$SettingsViewDataCopyWithImpl<_SettingsViewData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsViewData&&(identical(other.settings, settings) || other.settings == settings)&&const DeepCollectionEquality().equals(other.visibleModuleIds, _visibleModuleIds)&&(identical(other.devTools, devTools) || other.devTools == devTools));
}


@override
int get hashCode {
    return Object.hash(runtimeType,settings,const DeepCollectionEquality().hash(_visibleModuleIds),devTools);
}

@override
String toString() {
    return 'SettingsViewData(settings: $settings, visibleModuleIds: $visibleModuleIds, devTools: $devTools)';
}


}

/// @nodoc
abstract mixin class _$SettingsViewDataCopyWith<$Res> implements $SettingsViewDataCopyWith<$Res> {
  factory _$SettingsViewDataCopyWith(_SettingsViewData value, $Res Function(_SettingsViewData) _then) = __$SettingsViewDataCopyWithImpl;
@override @useResult
$Res call({
 AppSettings settings, List<String> visibleModuleIds, bool devTools
});


@override $AppSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$SettingsViewDataCopyWithImpl<$Res>
    implements _$SettingsViewDataCopyWith<$Res> {
  __$SettingsViewDataCopyWithImpl(this._self, this._then);

  final _SettingsViewData _self;
  final $Res Function(_SettingsViewData) _then;

/// Create a copy of SettingsViewData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? settings = null,Object? visibleModuleIds = null,Object? devTools = null,}) {
  return _then(_SettingsViewData(
settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as AppSettings,visibleModuleIds: null == visibleModuleIds ? _self._visibleModuleIds : visibleModuleIds // ignore: cast_nullable_to_non_nullable
as List<String>,devTools: null == devTools ? _self.devTools : devTools // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SettingsViewData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<$Res> get settings {
  
  return $AppSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
