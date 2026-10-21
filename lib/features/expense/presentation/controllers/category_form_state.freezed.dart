// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryFormArgs {

 CategoryType get type; String? get id;
/// Create a copy of CategoryFormArgs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryFormArgsCopyWith<CategoryFormArgs> get copyWith => _$CategoryFormArgsCopyWithImpl<CategoryFormArgs>(this as CategoryFormArgs, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryFormArgs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryFormArgs&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.id, _this.id) || other.id == _this.id));
}


@override
int get hashCode {
  final _this = this as CategoryFormArgs;
  return Object.hash(runtimeType,_this.type,_this.id);
}

@override
String toString() {
  final _this = this as CategoryFormArgs;
  return 'CategoryFormArgs(type: ${_this.type}, id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $CategoryFormArgsCopyWith<$Res>  {
  factory $CategoryFormArgsCopyWith(CategoryFormArgs value, $Res Function(CategoryFormArgs) _then) = _$CategoryFormArgsCopyWithImpl;
@useResult
$Res call({
 CategoryType type, String? id
});




}
/// @nodoc
class _$CategoryFormArgsCopyWithImpl<$Res>
    implements $CategoryFormArgsCopyWith<$Res> {
  _$CategoryFormArgsCopyWithImpl(this._self, this._then);

  final CategoryFormArgs _self;
  final $Res Function(CategoryFormArgs) _then;

/// Create a copy of CategoryFormArgs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? id = freezed,}) {
  return _then(CategoryFormArgs(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryFormArgs].
extension CategoryFormArgsPatterns on CategoryFormArgs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryFormArgs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryFormArgs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryFormArgs value)  $default,){
final _that = this;
switch (_that) {
case _CategoryFormArgs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryFormArgs value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryFormArgs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CategoryType type,  String? id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryFormArgs() when $default != null:
return $default(_that.type,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CategoryType type,  String? id)  $default,) {final _that = this;
switch (_that) {
case _CategoryFormArgs():
return $default(_that.type,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CategoryType type,  String? id)?  $default,) {final _that = this;
switch (_that) {
case _CategoryFormArgs() when $default != null:
return $default(_that.type,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryFormArgs implements CategoryFormArgs {
  const _CategoryFormArgs({required this.type, this.id});
  

@override final  CategoryType type;
@override final  String? id;

/// Create a copy of CategoryFormArgs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryFormArgsCopyWith<_CategoryFormArgs> get copyWith => __$CategoryFormArgsCopyWithImpl<_CategoryFormArgs>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryFormArgs&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,id);
}

@override
String toString() {
    return 'CategoryFormArgs(type: $type, id: $id)';
}


}

/// @nodoc
abstract mixin class _$CategoryFormArgsCopyWith<$Res> implements $CategoryFormArgsCopyWith<$Res> {
  factory _$CategoryFormArgsCopyWith(_CategoryFormArgs value, $Res Function(_CategoryFormArgs) _then) = __$CategoryFormArgsCopyWithImpl;
@override @useResult
$Res call({
 CategoryType type, String? id
});




}
/// @nodoc
class __$CategoryFormArgsCopyWithImpl<$Res>
    implements _$CategoryFormArgsCopyWith<$Res> {
  __$CategoryFormArgsCopyWithImpl(this._self, this._then);

  final _CategoryFormArgs _self;
  final $Res Function(_CategoryFormArgs) _then;

/// Create a copy of CategoryFormArgs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = freezed,}) {
  return _then(_CategoryFormArgs(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CategoryFormState {

 CategoryFormStatus get status; CategoryType get type; String get name; String get iconKey; String get colorHex; CategoryNameError? get nameError; bool get saving; bool get saveFailed;/// Non-deleted categories, for the duplicate check.
 List<Category> get existing;/// The category being edited; null for a new one.
 Category? get original;
/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryFormStateCopyWith<CategoryFormState> get copyWith => _$CategoryFormStateCopyWithImpl<CategoryFormState>(this as CategoryFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryFormState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&(identical(other.nameError, _this.nameError) || other.nameError == _this.nameError)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.saveFailed, _this.saveFailed) || other.saveFailed == _this.saveFailed)&&const DeepCollectionEquality().equals(other.existing, _this.existing)&&(identical(other.original, _this.original) || other.original == _this.original));
}


@override
int get hashCode {
  final _this = this as CategoryFormState;
  return Object.hash(runtimeType,_this.status,_this.type,_this.name,_this.iconKey,_this.colorHex,_this.nameError,_this.saving,_this.saveFailed,const DeepCollectionEquality().hash(_this.existing),_this.original);
}

@override
String toString() {
  final _this = this as CategoryFormState;
  return 'CategoryFormState(status: ${_this.status}, type: ${_this.type}, name: ${_this.name}, iconKey: ${_this.iconKey}, colorHex: ${_this.colorHex}, nameError: ${_this.nameError}, saving: ${_this.saving}, saveFailed: ${_this.saveFailed}, existing: ${_this.existing}, original: ${_this.original})';
}


}

/// @nodoc
abstract mixin class $CategoryFormStateCopyWith<$Res>  {
  factory $CategoryFormStateCopyWith(CategoryFormState value, $Res Function(CategoryFormState) _then) = _$CategoryFormStateCopyWithImpl;
@useResult
$Res call({
 CategoryFormStatus status, CategoryType type, String name, String iconKey, String colorHex, CategoryNameError? nameError, bool saving, bool saveFailed, List<Category> existing, Category? original
});


$CategoryCopyWith<$Res>? get original;

}
/// @nodoc
class _$CategoryFormStateCopyWithImpl<$Res>
    implements $CategoryFormStateCopyWith<$Res> {
  _$CategoryFormStateCopyWithImpl(this._self, this._then);

  final CategoryFormState _self;
  final $Res Function(CategoryFormState) _then;

/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? type = null,Object? name = null,Object? iconKey = null,Object? colorHex = null,Object? nameError = freezed,Object? saving = null,Object? saveFailed = null,Object? existing = null,Object? original = freezed,}) {
  return _then(CategoryFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CategoryFormStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as CategoryNameError?,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,existing: null == existing ? _self.existing : existing // ignore: cast_nullable_to_non_nullable
as List<Category>,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}
/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryFormState].
extension CategoryFormStatePatterns on CategoryFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryFormState value)  $default,){
final _that = this;
switch (_that) {
case _CategoryFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CategoryFormStatus status,  CategoryType type,  String name,  String iconKey,  String colorHex,  CategoryNameError? nameError,  bool saving,  bool saveFailed,  List<Category> existing,  Category? original)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryFormState() when $default != null:
return $default(_that.status,_that.type,_that.name,_that.iconKey,_that.colorHex,_that.nameError,_that.saving,_that.saveFailed,_that.existing,_that.original);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CategoryFormStatus status,  CategoryType type,  String name,  String iconKey,  String colorHex,  CategoryNameError? nameError,  bool saving,  bool saveFailed,  List<Category> existing,  Category? original)  $default,) {final _that = this;
switch (_that) {
case _CategoryFormState():
return $default(_that.status,_that.type,_that.name,_that.iconKey,_that.colorHex,_that.nameError,_that.saving,_that.saveFailed,_that.existing,_that.original);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CategoryFormStatus status,  CategoryType type,  String name,  String iconKey,  String colorHex,  CategoryNameError? nameError,  bool saving,  bool saveFailed,  List<Category> existing,  Category? original)?  $default,) {final _that = this;
switch (_that) {
case _CategoryFormState() when $default != null:
return $default(_that.status,_that.type,_that.name,_that.iconKey,_that.colorHex,_that.nameError,_that.saving,_that.saveFailed,_that.existing,_that.original);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryFormState extends CategoryFormState {
  const _CategoryFormState({required this.status, required this.type, this.name = '', this.iconKey = '', this.colorHex = '', this.nameError, this.saving = false, this.saveFailed = false,  List<Category> existing = const <Category>[], this.original}): _existing = existing,super._();
  

@override final  CategoryFormStatus status;
@override final  CategoryType type;
@override@JsonKey() final  String name;
@override@JsonKey() final  String iconKey;
@override@JsonKey() final  String colorHex;
@override final  CategoryNameError? nameError;
@override@JsonKey() final  bool saving;
@override@JsonKey() final  bool saveFailed;
/// Non-deleted categories, for the duplicate check.
 final  List<Category> _existing;
/// Non-deleted categories, for the duplicate check.
@override@JsonKey() List<Category> get existing {
  if (_existing is EqualUnmodifiableListView) return _existing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_existing);
}

/// The category being edited; null for a new one.
@override final  Category? original;

/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryFormStateCopyWith<_CategoryFormState> get copyWith => __$CategoryFormStateCopyWithImpl<_CategoryFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryFormState&&(identical(other.status, status) || other.status == status)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.saveFailed, saveFailed) || other.saveFailed == saveFailed)&&const DeepCollectionEquality().equals(other.existing, _existing)&&(identical(other.original, original) || other.original == original));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,type,name,iconKey,colorHex,nameError,saving,saveFailed,const DeepCollectionEquality().hash(_existing),original);
}

@override
String toString() {
    return 'CategoryFormState(status: $status, type: $type, name: $name, iconKey: $iconKey, colorHex: $colorHex, nameError: $nameError, saving: $saving, saveFailed: $saveFailed, existing: $existing, original: $original)';
}


}

/// @nodoc
abstract mixin class _$CategoryFormStateCopyWith<$Res> implements $CategoryFormStateCopyWith<$Res> {
  factory _$CategoryFormStateCopyWith(_CategoryFormState value, $Res Function(_CategoryFormState) _then) = __$CategoryFormStateCopyWithImpl;
@override @useResult
$Res call({
 CategoryFormStatus status, CategoryType type, String name, String iconKey, String colorHex, CategoryNameError? nameError, bool saving, bool saveFailed, List<Category> existing, Category? original
});


@override $CategoryCopyWith<$Res>? get original;

}
/// @nodoc
class __$CategoryFormStateCopyWithImpl<$Res>
    implements _$CategoryFormStateCopyWith<$Res> {
  __$CategoryFormStateCopyWithImpl(this._self, this._then);

  final _CategoryFormState _self;
  final $Res Function(_CategoryFormState) _then;

/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? type = null,Object? name = null,Object? iconKey = null,Object? colorHex = null,Object? nameError = freezed,Object? saving = null,Object? saveFailed = null,Object? existing = null,Object? original = freezed,}) {
  return _then(_CategoryFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CategoryFormStatus,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as CategoryNameError?,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,existing: null == existing ? _self._existing : existing // ignore: cast_nullable_to_non_nullable
as List<Category>,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}

/// Create a copy of CategoryFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
