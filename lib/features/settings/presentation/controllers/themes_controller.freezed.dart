// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'themes_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ThemesState {

/// `system`, `light`, or `dark`.
 String get themeMode;/// The stored color theme id (may be a locked premium theme).
 String get selectedThemeId;/// The theme in the preview card. Equals [selectedThemeId] until the
/// user taps a locked theme, which is previewed but never stored.
 String get previewThemeId;/// `default` or `large`.
 String get fontSize;
/// Create a copy of ThemesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemesStateCopyWith<ThemesState> get copyWith => _$ThemesStateCopyWithImpl<ThemesState>(this as ThemesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ThemesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemesState&&(identical(other.themeMode, _this.themeMode) || other.themeMode == _this.themeMode)&&(identical(other.selectedThemeId, _this.selectedThemeId) || other.selectedThemeId == _this.selectedThemeId)&&(identical(other.previewThemeId, _this.previewThemeId) || other.previewThemeId == _this.previewThemeId)&&(identical(other.fontSize, _this.fontSize) || other.fontSize == _this.fontSize));
}


@override
int get hashCode {
  final _this = this as ThemesState;
  return Object.hash(runtimeType,_this.themeMode,_this.selectedThemeId,_this.previewThemeId,_this.fontSize);
}

@override
String toString() {
  final _this = this as ThemesState;
  return 'ThemesState(themeMode: ${_this.themeMode}, selectedThemeId: ${_this.selectedThemeId}, previewThemeId: ${_this.previewThemeId}, fontSize: ${_this.fontSize})';
}


}

/// @nodoc
abstract mixin class $ThemesStateCopyWith<$Res>  {
  factory $ThemesStateCopyWith(ThemesState value, $Res Function(ThemesState) _then) = _$ThemesStateCopyWithImpl;
@useResult
$Res call({
 String themeMode, String selectedThemeId, String previewThemeId, String fontSize
});




}
/// @nodoc
class _$ThemesStateCopyWithImpl<$Res>
    implements $ThemesStateCopyWith<$Res> {
  _$ThemesStateCopyWithImpl(this._self, this._then);

  final ThemesState _self;
  final $Res Function(ThemesState) _then;

/// Create a copy of ThemesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? selectedThemeId = null,Object? previewThemeId = null,Object? fontSize = null,}) {
  return _then(ThemesState(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,selectedThemeId: null == selectedThemeId ? _self.selectedThemeId : selectedThemeId // ignore: cast_nullable_to_non_nullable
as String,previewThemeId: null == previewThemeId ? _self.previewThemeId : previewThemeId // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemesState].
extension ThemesStatePatterns on ThemesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemesState value)  $default,){
final _that = this;
switch (_that) {
case _ThemesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemesState value)?  $default,){
final _that = this;
switch (_that) {
case _ThemesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String themeMode,  String selectedThemeId,  String previewThemeId,  String fontSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemesState() when $default != null:
return $default(_that.themeMode,_that.selectedThemeId,_that.previewThemeId,_that.fontSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String themeMode,  String selectedThemeId,  String previewThemeId,  String fontSize)  $default,) {final _that = this;
switch (_that) {
case _ThemesState():
return $default(_that.themeMode,_that.selectedThemeId,_that.previewThemeId,_that.fontSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String themeMode,  String selectedThemeId,  String previewThemeId,  String fontSize)?  $default,) {final _that = this;
switch (_that) {
case _ThemesState() when $default != null:
return $default(_that.themeMode,_that.selectedThemeId,_that.previewThemeId,_that.fontSize);case _:
  return null;

}
}

}

/// @nodoc


class _ThemesState implements ThemesState {
  const _ThemesState({required this.themeMode, required this.selectedThemeId, required this.previewThemeId, required this.fontSize});
  

/// `system`, `light`, or `dark`.
@override final  String themeMode;
/// The stored color theme id (may be a locked premium theme).
@override final  String selectedThemeId;
/// The theme in the preview card. Equals [selectedThemeId] until the
/// user taps a locked theme, which is previewed but never stored.
@override final  String previewThemeId;
/// `default` or `large`.
@override final  String fontSize;

/// Create a copy of ThemesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemesStateCopyWith<_ThemesState> get copyWith => __$ThemesStateCopyWithImpl<_ThemesState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemesState&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.selectedThemeId, selectedThemeId) || other.selectedThemeId == selectedThemeId)&&(identical(other.previewThemeId, previewThemeId) || other.previewThemeId == previewThemeId)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize));
}


@override
int get hashCode {
    return Object.hash(runtimeType,themeMode,selectedThemeId,previewThemeId,fontSize);
}

@override
String toString() {
    return 'ThemesState(themeMode: $themeMode, selectedThemeId: $selectedThemeId, previewThemeId: $previewThemeId, fontSize: $fontSize)';
}


}

/// @nodoc
abstract mixin class _$ThemesStateCopyWith<$Res> implements $ThemesStateCopyWith<$Res> {
  factory _$ThemesStateCopyWith(_ThemesState value, $Res Function(_ThemesState) _then) = __$ThemesStateCopyWithImpl;
@override @useResult
$Res call({
 String themeMode, String selectedThemeId, String previewThemeId, String fontSize
});




}
/// @nodoc
class __$ThemesStateCopyWithImpl<$Res>
    implements _$ThemesStateCopyWith<$Res> {
  __$ThemesStateCopyWithImpl(this._self, this._then);

  final _ThemesState _self;
  final $Res Function(_ThemesState) _then;

/// Create a copy of ThemesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? selectedThemeId = null,Object? previewThemeId = null,Object? fontSize = null,}) {
  return _then(_ThemesState(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,selectedThemeId: null == selectedThemeId ? _self.selectedThemeId : selectedThemeId // ignore: cast_nullable_to_non_nullable
as String,previewThemeId: null == previewThemeId ? _self.previewThemeId : previewThemeId // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
