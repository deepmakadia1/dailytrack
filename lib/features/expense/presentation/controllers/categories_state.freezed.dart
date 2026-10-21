// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'categories_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoriesState {

 CategoryType get tab;/// Every non-deleted category of [tab] in its order, with this month's
/// total; hidden ones included (flagged).
 AsyncValue<List<CategoryWithStats>> get items; bool get hiddenExpanded; bool get reorderFailed;
/// Create a copy of CategoriesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoriesStateCopyWith<CategoriesState> get copyWith => _$CategoriesStateCopyWithImpl<CategoriesState>(this as CategoriesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CategoriesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoriesState&&(identical(other.tab, _this.tab) || other.tab == _this.tab)&&(identical(other.items, _this.items) || other.items == _this.items)&&(identical(other.hiddenExpanded, _this.hiddenExpanded) || other.hiddenExpanded == _this.hiddenExpanded)&&(identical(other.reorderFailed, _this.reorderFailed) || other.reorderFailed == _this.reorderFailed));
}


@override
int get hashCode {
  final _this = this as CategoriesState;
  return Object.hash(runtimeType,_this.tab,_this.items,_this.hiddenExpanded,_this.reorderFailed);
}

@override
String toString() {
  final _this = this as CategoriesState;
  return 'CategoriesState(tab: ${_this.tab}, items: ${_this.items}, hiddenExpanded: ${_this.hiddenExpanded}, reorderFailed: ${_this.reorderFailed})';
}


}

/// @nodoc
abstract mixin class $CategoriesStateCopyWith<$Res>  {
  factory $CategoriesStateCopyWith(CategoriesState value, $Res Function(CategoriesState) _then) = _$CategoriesStateCopyWithImpl;
@useResult
$Res call({
 CategoryType tab, AsyncValue<List<CategoryWithStats>> items, bool hiddenExpanded, bool reorderFailed
});




}
/// @nodoc
class _$CategoriesStateCopyWithImpl<$Res>
    implements $CategoriesStateCopyWith<$Res> {
  _$CategoriesStateCopyWithImpl(this._self, this._then);

  final CategoriesState _self;
  final $Res Function(CategoriesState) _then;

/// Create a copy of CategoriesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tab = null,Object? items = null,Object? hiddenExpanded = null,Object? reorderFailed = null,}) {
  return _then(CategoriesState(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as CategoryType,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<CategoryWithStats>>,hiddenExpanded: null == hiddenExpanded ? _self.hiddenExpanded : hiddenExpanded // ignore: cast_nullable_to_non_nullable
as bool,reorderFailed: null == reorderFailed ? _self.reorderFailed : reorderFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoriesState].
extension CategoriesStatePatterns on CategoriesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoriesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoriesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoriesState value)  $default,){
final _that = this;
switch (_that) {
case _CategoriesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoriesState value)?  $default,){
final _that = this;
switch (_that) {
case _CategoriesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CategoryType tab,  AsyncValue<List<CategoryWithStats>> items,  bool hiddenExpanded,  bool reorderFailed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoriesState() when $default != null:
return $default(_that.tab,_that.items,_that.hiddenExpanded,_that.reorderFailed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CategoryType tab,  AsyncValue<List<CategoryWithStats>> items,  bool hiddenExpanded,  bool reorderFailed)  $default,) {final _that = this;
switch (_that) {
case _CategoriesState():
return $default(_that.tab,_that.items,_that.hiddenExpanded,_that.reorderFailed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CategoryType tab,  AsyncValue<List<CategoryWithStats>> items,  bool hiddenExpanded,  bool reorderFailed)?  $default,) {final _that = this;
switch (_that) {
case _CategoriesState() when $default != null:
return $default(_that.tab,_that.items,_that.hiddenExpanded,_that.reorderFailed);case _:
  return null;

}
}

}

/// @nodoc


class _CategoriesState extends CategoriesState {
  const _CategoriesState({required this.tab, required this.items, this.hiddenExpanded = false, this.reorderFailed = false}): super._();
  

@override final  CategoryType tab;
/// Every non-deleted category of [tab] in its order, with this month's
/// total; hidden ones included (flagged).
@override final  AsyncValue<List<CategoryWithStats>> items;
@override@JsonKey() final  bool hiddenExpanded;
@override@JsonKey() final  bool reorderFailed;

/// Create a copy of CategoriesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoriesStateCopyWith<_CategoriesState> get copyWith => __$CategoriesStateCopyWithImpl<_CategoriesState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoriesState&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.items, items) || other.items == items)&&(identical(other.hiddenExpanded, hiddenExpanded) || other.hiddenExpanded == hiddenExpanded)&&(identical(other.reorderFailed, reorderFailed) || other.reorderFailed == reorderFailed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,tab,items,hiddenExpanded,reorderFailed);
}

@override
String toString() {
    return 'CategoriesState(tab: $tab, items: $items, hiddenExpanded: $hiddenExpanded, reorderFailed: $reorderFailed)';
}


}

/// @nodoc
abstract mixin class _$CategoriesStateCopyWith<$Res> implements $CategoriesStateCopyWith<$Res> {
  factory _$CategoriesStateCopyWith(_CategoriesState value, $Res Function(_CategoriesState) _then) = __$CategoriesStateCopyWithImpl;
@override @useResult
$Res call({
 CategoryType tab, AsyncValue<List<CategoryWithStats>> items, bool hiddenExpanded, bool reorderFailed
});




}
/// @nodoc
class __$CategoriesStateCopyWithImpl<$Res>
    implements _$CategoriesStateCopyWith<$Res> {
  __$CategoriesStateCopyWithImpl(this._self, this._then);

  final _CategoriesState _self;
  final $Res Function(_CategoriesState) _then;

/// Create a copy of CategoriesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tab = null,Object? items = null,Object? hiddenExpanded = null,Object? reorderFailed = null,}) {
  return _then(_CategoriesState(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as CategoryType,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<CategoryWithStats>>,hiddenExpanded: null == hiddenExpanded ? _self.hiddenExpanded : hiddenExpanded // ignore: cast_nullable_to_non_nullable
as bool,reorderFailed: null == reorderFailed ? _self.reorderFailed : reorderFailed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
