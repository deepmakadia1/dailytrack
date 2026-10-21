// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modules_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ModulesState {

/// Registered modules in the user's order.
 List<ModuleRow> get rows;/// ARB key of the inline "keep one module on" message, if shown.
 String? get messageKey;
/// Create a copy of ModulesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModulesStateCopyWith<ModulesState> get copyWith => _$ModulesStateCopyWithImpl<ModulesState>(this as ModulesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ModulesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModulesState&&const DeepCollectionEquality().equals(other.rows, _this.rows)&&(identical(other.messageKey, _this.messageKey) || other.messageKey == _this.messageKey));
}


@override
int get hashCode {
  final _this = this as ModulesState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.rows),_this.messageKey);
}

@override
String toString() {
  final _this = this as ModulesState;
  return 'ModulesState(rows: ${_this.rows}, messageKey: ${_this.messageKey})';
}


}

/// @nodoc
abstract mixin class $ModulesStateCopyWith<$Res>  {
  factory $ModulesStateCopyWith(ModulesState value, $Res Function(ModulesState) _then) = _$ModulesStateCopyWithImpl;
@useResult
$Res call({
 List<ModuleRow> rows, String? messageKey
});




}
/// @nodoc
class _$ModulesStateCopyWithImpl<$Res>
    implements $ModulesStateCopyWith<$Res> {
  _$ModulesStateCopyWithImpl(this._self, this._then);

  final ModulesState _self;
  final $Res Function(ModulesState) _then;

/// Create a copy of ModulesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rows = null,Object? messageKey = freezed,}) {
  return _then(ModulesState(
rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<ModuleRow>,messageKey: freezed == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModulesState].
extension ModulesStatePatterns on ModulesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModulesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModulesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModulesState value)  $default,){
final _that = this;
switch (_that) {
case _ModulesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModulesState value)?  $default,){
final _that = this;
switch (_that) {
case _ModulesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ModuleRow> rows,  String? messageKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModulesState() when $default != null:
return $default(_that.rows,_that.messageKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ModuleRow> rows,  String? messageKey)  $default,) {final _that = this;
switch (_that) {
case _ModulesState():
return $default(_that.rows,_that.messageKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ModuleRow> rows,  String? messageKey)?  $default,) {final _that = this;
switch (_that) {
case _ModulesState() when $default != null:
return $default(_that.rows,_that.messageKey);case _:
  return null;

}
}

}

/// @nodoc


class _ModulesState implements ModulesState {
  const _ModulesState({required  List<ModuleRow> rows, this.messageKey}): _rows = rows;
  

/// Registered modules in the user's order.
 final  List<ModuleRow> _rows;
/// Registered modules in the user's order.
@override List<ModuleRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

/// ARB key of the inline "keep one module on" message, if shown.
@override final  String? messageKey;

/// Create a copy of ModulesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModulesStateCopyWith<_ModulesState> get copyWith => __$ModulesStateCopyWithImpl<_ModulesState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModulesState&&const DeepCollectionEquality().equals(other.rows, _rows)&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_rows),messageKey);
}

@override
String toString() {
    return 'ModulesState(rows: $rows, messageKey: $messageKey)';
}


}

/// @nodoc
abstract mixin class _$ModulesStateCopyWith<$Res> implements $ModulesStateCopyWith<$Res> {
  factory _$ModulesStateCopyWith(_ModulesState value, $Res Function(_ModulesState) _then) = __$ModulesStateCopyWithImpl;
@override @useResult
$Res call({
 List<ModuleRow> rows, String? messageKey
});




}
/// @nodoc
class __$ModulesStateCopyWithImpl<$Res>
    implements _$ModulesStateCopyWith<$Res> {
  __$ModulesStateCopyWithImpl(this._self, this._then);

  final _ModulesState _self;
  final $Res Function(_ModulesState) _then;

/// Create a copy of ModulesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rows = null,Object? messageKey = freezed,}) {
  return _then(_ModulesState(
rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<ModuleRow>,messageKey: freezed == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ModuleRow {

 String get id; bool get enabled;
/// Create a copy of ModuleRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModuleRowCopyWith<ModuleRow> get copyWith => _$ModuleRowCopyWithImpl<ModuleRow>(this as ModuleRow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ModuleRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModuleRow&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled));
}


@override
int get hashCode {
  final _this = this as ModuleRow;
  return Object.hash(runtimeType,_this.id,_this.enabled);
}

@override
String toString() {
  final _this = this as ModuleRow;
  return 'ModuleRow(id: ${_this.id}, enabled: ${_this.enabled})';
}


}

/// @nodoc
abstract mixin class $ModuleRowCopyWith<$Res>  {
  factory $ModuleRowCopyWith(ModuleRow value, $Res Function(ModuleRow) _then) = _$ModuleRowCopyWithImpl;
@useResult
$Res call({
 String id, bool enabled
});




}
/// @nodoc
class _$ModuleRowCopyWithImpl<$Res>
    implements $ModuleRowCopyWith<$Res> {
  _$ModuleRowCopyWithImpl(this._self, this._then);

  final ModuleRow _self;
  final $Res Function(ModuleRow) _then;

/// Create a copy of ModuleRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? enabled = null,}) {
  return _then(ModuleRow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ModuleRow].
extension ModuleRowPatterns on ModuleRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModuleRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModuleRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModuleRow value)  $default,){
final _that = this;
switch (_that) {
case _ModuleRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModuleRow value)?  $default,){
final _that = this;
switch (_that) {
case _ModuleRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModuleRow() when $default != null:
return $default(_that.id,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _ModuleRow():
return $default(_that.id,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _ModuleRow() when $default != null:
return $default(_that.id,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc


class _ModuleRow implements ModuleRow {
  const _ModuleRow({required this.id, required this.enabled});
  

@override final  String id;
@override final  bool enabled;

/// Create a copy of ModuleRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModuleRowCopyWith<_ModuleRow> get copyWith => __$ModuleRowCopyWithImpl<_ModuleRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModuleRow&&(identical(other.id, id) || other.id == id)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,enabled);
}

@override
String toString() {
    return 'ModuleRow(id: $id, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$ModuleRowCopyWith<$Res> implements $ModuleRowCopyWith<$Res> {
  factory _$ModuleRowCopyWith(_ModuleRow value, $Res Function(_ModuleRow) _then) = __$ModuleRowCopyWithImpl;
@override @useResult
$Res call({
 String id, bool enabled
});




}
/// @nodoc
class __$ModuleRowCopyWithImpl<$Res>
    implements _$ModuleRowCopyWith<$Res> {
  __$ModuleRowCopyWithImpl(this._self, this._then);

  final _ModuleRow _self;
  final $Res Function(_ModuleRow) _then;

/// Create a copy of ModuleRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? enabled = null,}) {
  return _then(_ModuleRow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
