// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Category {

 String get id;/// An ARB key (e.g. `expense_cat_food`) for a default that has not been
/// renamed, otherwise the user's text.
 String get name; CategoryType get type; String get iconKey; String get colorHex; bool get isDefault;/// Stored in the `isArchived` column.
 bool get isHidden; int get sortOrder;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Category;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.colorHex, _this.colorHex) || other.colorHex == _this.colorHex)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.isHidden, _this.isHidden) || other.isHidden == _this.isHidden)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}


@override
int get hashCode {
  final _this = this as Category;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.iconKey,_this.colorHex,_this.isDefault,_this.isHidden,_this.sortOrder);
}

@override
String toString() {
  final _this = this as Category;
  return 'Category(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, iconKey: ${_this.iconKey}, colorHex: ${_this.colorHex}, isDefault: ${_this.isDefault}, isHidden: ${_this.isHidden}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, CategoryType type, String iconKey, String colorHex, bool isDefault, bool isHidden, int sortOrder
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? iconKey = null,Object? colorHex = null,Object? isDefault = null,Object? isHidden = null,Object? sortOrder = null,}) {
  return _then(Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  CategoryType type,  String iconKey,  String colorHex,  bool isDefault,  bool isHidden,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.iconKey,_that.colorHex,_that.isDefault,_that.isHidden,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  CategoryType type,  String iconKey,  String colorHex,  bool isDefault,  bool isHidden,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.name,_that.type,_that.iconKey,_that.colorHex,_that.isDefault,_that.isHidden,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  CategoryType type,  String iconKey,  String colorHex,  bool isDefault,  bool isHidden,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.iconKey,_that.colorHex,_that.isDefault,_that.isHidden,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc


class _Category implements Category {
  const _Category({required this.id, required this.name, required this.type, required this.iconKey, required this.colorHex, required this.isDefault, required this.isHidden, required this.sortOrder});
  

@override final  String id;
/// An ARB key (e.g. `expense_cat_food`) for a default that has not been
/// renamed, otherwise the user's text.
@override final  String name;
@override final  CategoryType type;
@override final  String iconKey;
@override final  String colorHex;
@override final  bool isDefault;
/// Stored in the `isArchived` column.
@override final  bool isHidden;
@override final  int sortOrder;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,iconKey,colorHex,isDefault,isHidden,sortOrder);
}

@override
String toString() {
    return 'Category(id: $id, name: $name, type: $type, iconKey: $iconKey, colorHex: $colorHex, isDefault: $isDefault, isHidden: $isHidden, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, CategoryType type, String iconKey, String colorHex, bool isDefault, bool isHidden, int sortOrder
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? iconKey = null,Object? colorHex = null,Object? isDefault = null,Object? isHidden = null,Object? sortOrder = null,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CategoryType,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CategoryWithStats {

 Category get category; int get monthTotalMinor; int get usageCount;
/// Create a copy of CategoryWithStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryWithStatsCopyWith<CategoryWithStats> get copyWith => _$CategoryWithStatsCopyWithImpl<CategoryWithStats>(this as CategoryWithStats, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoryWithStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryWithStats&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.monthTotalMinor, _this.monthTotalMinor) || other.monthTotalMinor == _this.monthTotalMinor)&&(identical(other.usageCount, _this.usageCount) || other.usageCount == _this.usageCount));
}


@override
int get hashCode {
  final _this = this as CategoryWithStats;
  return Object.hash(runtimeType,_this.category,_this.monthTotalMinor,_this.usageCount);
}

@override
String toString() {
  final _this = this as CategoryWithStats;
  return 'CategoryWithStats(category: ${_this.category}, monthTotalMinor: ${_this.monthTotalMinor}, usageCount: ${_this.usageCount})';
}


}

/// @nodoc
abstract mixin class $CategoryWithStatsCopyWith<$Res>  {
  factory $CategoryWithStatsCopyWith(CategoryWithStats value, $Res Function(CategoryWithStats) _then) = _$CategoryWithStatsCopyWithImpl;
@useResult
$Res call({
 Category category, int monthTotalMinor, int usageCount
});


$CategoryCopyWith<$Res> get category;

}
/// @nodoc
class _$CategoryWithStatsCopyWithImpl<$Res>
    implements $CategoryWithStatsCopyWith<$Res> {
  _$CategoryWithStatsCopyWithImpl(this._self, this._then);

  final CategoryWithStats _self;
  final $Res Function(CategoryWithStats) _then;

/// Create a copy of CategoryWithStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? monthTotalMinor = null,Object? usageCount = null,}) {
  return _then(CategoryWithStats(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,monthTotalMinor: null == monthTotalMinor ? _self.monthTotalMinor : monthTotalMinor // ignore: cast_nullable_to_non_nullable
as int,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of CategoryWithStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryWithStats].
extension CategoryWithStatsPatterns on CategoryWithStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryWithStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryWithStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryWithStats value)  $default,){
final _that = this;
switch (_that) {
case _CategoryWithStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryWithStats value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryWithStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  int monthTotalMinor,  int usageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryWithStats() when $default != null:
return $default(_that.category,_that.monthTotalMinor,_that.usageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  int monthTotalMinor,  int usageCount)  $default,) {final _that = this;
switch (_that) {
case _CategoryWithStats():
return $default(_that.category,_that.monthTotalMinor,_that.usageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  int monthTotalMinor,  int usageCount)?  $default,) {final _that = this;
switch (_that) {
case _CategoryWithStats() when $default != null:
return $default(_that.category,_that.monthTotalMinor,_that.usageCount);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryWithStats implements CategoryWithStats {
  const _CategoryWithStats({required this.category, required this.monthTotalMinor, required this.usageCount});
  

@override final  Category category;
@override final  int monthTotalMinor;
@override final  int usageCount;

/// Create a copy of CategoryWithStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryWithStatsCopyWith<_CategoryWithStats> get copyWith => __$CategoryWithStatsCopyWithImpl<_CategoryWithStats>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryWithStats&&(identical(other.category, category) || other.category == category)&&(identical(other.monthTotalMinor, monthTotalMinor) || other.monthTotalMinor == monthTotalMinor)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,category,monthTotalMinor,usageCount);
}

@override
String toString() {
    return 'CategoryWithStats(category: $category, monthTotalMinor: $monthTotalMinor, usageCount: $usageCount)';
}


}

/// @nodoc
abstract mixin class _$CategoryWithStatsCopyWith<$Res> implements $CategoryWithStatsCopyWith<$Res> {
  factory _$CategoryWithStatsCopyWith(_CategoryWithStats value, $Res Function(_CategoryWithStats) _then) = __$CategoryWithStatsCopyWithImpl;
@override @useResult
$Res call({
 Category category, int monthTotalMinor, int usageCount
});


@override $CategoryCopyWith<$Res> get category;

}
/// @nodoc
class __$CategoryWithStatsCopyWithImpl<$Res>
    implements _$CategoryWithStatsCopyWith<$Res> {
  __$CategoryWithStatsCopyWithImpl(this._self, this._then);

  final _CategoryWithStats _self;
  final $Res Function(_CategoryWithStats) _then;

/// Create a copy of CategoryWithStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? monthTotalMinor = null,Object? usageCount = null,}) {
  return _then(_CategoryWithStats(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,monthTotalMinor: null == monthTotalMinor ? _self.monthTotalMinor : monthTotalMinor // ignore: cast_nullable_to_non_nullable
as int,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of CategoryWithStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
