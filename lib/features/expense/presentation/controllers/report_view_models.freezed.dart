// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_view_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TopCategory {

 String get categoryId; int get amountMinor;/// Share of the period's expense.
 int get sharePercent; Category? get category;
/// Create a copy of TopCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopCategoryCopyWith<TopCategory> get copyWith => _$TopCategoryCopyWithImpl<TopCategory>(this as TopCategory, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TopCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopCategory&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.sharePercent, _this.sharePercent) || other.sharePercent == _this.sharePercent)&&(identical(other.category, _this.category) || other.category == _this.category));
}


@override
int get hashCode {
  final _this = this as TopCategory;
  return Object.hash(runtimeType,_this.categoryId,_this.amountMinor,_this.sharePercent,_this.category);
}

@override
String toString() {
  final _this = this as TopCategory;
  return 'TopCategory(categoryId: ${_this.categoryId}, amountMinor: ${_this.amountMinor}, sharePercent: ${_this.sharePercent}, category: ${_this.category})';
}


}

/// @nodoc
abstract mixin class $TopCategoryCopyWith<$Res>  {
  factory $TopCategoryCopyWith(TopCategory value, $Res Function(TopCategory) _then) = _$TopCategoryCopyWithImpl;
@useResult
$Res call({
 String categoryId, int amountMinor, int sharePercent, Category? category
});


$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$TopCategoryCopyWithImpl<$Res>
    implements $TopCategoryCopyWith<$Res> {
  _$TopCategoryCopyWithImpl(this._self, this._then);

  final TopCategory _self;
  final $Res Function(TopCategory) _then;

/// Create a copy of TopCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? amountMinor = null,Object? sharePercent = null,Object? category = freezed,}) {
  return _then(TopCategory(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,sharePercent: null == sharePercent ? _self.sharePercent : sharePercent // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}
/// Create a copy of TopCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [TopCategory].
extension TopCategoryPatterns on TopCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopCategory value)  $default,){
final _that = this;
switch (_that) {
case _TopCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopCategory value)?  $default,){
final _that = this;
switch (_that) {
case _TopCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  int amountMinor,  int sharePercent,  Category? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopCategory() when $default != null:
return $default(_that.categoryId,_that.amountMinor,_that.sharePercent,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  int amountMinor,  int sharePercent,  Category? category)  $default,) {final _that = this;
switch (_that) {
case _TopCategory():
return $default(_that.categoryId,_that.amountMinor,_that.sharePercent,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  int amountMinor,  int sharePercent,  Category? category)?  $default,) {final _that = this;
switch (_that) {
case _TopCategory() when $default != null:
return $default(_that.categoryId,_that.amountMinor,_that.sharePercent,_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _TopCategory implements TopCategory {
  const _TopCategory({required this.categoryId, required this.amountMinor, required this.sharePercent, this.category});
  

@override final  String categoryId;
@override final  int amountMinor;
/// Share of the period's expense.
@override final  int sharePercent;
@override final  Category? category;

/// Create a copy of TopCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopCategoryCopyWith<_TopCategory> get copyWith => __$TopCategoryCopyWithImpl<_TopCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopCategory&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.sharePercent, sharePercent) || other.sharePercent == sharePercent)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode {
    return Object.hash(runtimeType,categoryId,amountMinor,sharePercent,category);
}

@override
String toString() {
    return 'TopCategory(categoryId: $categoryId, amountMinor: $amountMinor, sharePercent: $sharePercent, category: $category)';
}


}

/// @nodoc
abstract mixin class _$TopCategoryCopyWith<$Res> implements $TopCategoryCopyWith<$Res> {
  factory _$TopCategoryCopyWith(_TopCategory value, $Res Function(_TopCategory) _then) = __$TopCategoryCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, int amountMinor, int sharePercent, Category? category
});


@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$TopCategoryCopyWithImpl<$Res>
    implements _$TopCategoryCopyWith<$Res> {
  __$TopCategoryCopyWithImpl(this._self, this._then);

  final _TopCategory _self;
  final $Res Function(_TopCategory) _then;

/// Create a copy of TopCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? amountMinor = null,Object? sharePercent = null,Object? category = freezed,}) {
  return _then(_TopCategory(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,sharePercent: null == sharePercent ? _self.sharePercent : sharePercent // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}

/// Create a copy of TopCategory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

/// @nodoc
mixin _$OverviewVm {

 int get incomeMinor; int get expenseMinor; int get netMinor;/// net ÷ income; null ("—") when income is 0.
 int? get savingsRatePercent;/// expense ÷ days so far (current period) or all days (past); null for
/// a period that has not started.
 int? get avgDailySpendMinor; List<TopCategory> get top;
/// Create a copy of OverviewVm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverviewVmCopyWith<OverviewVm> get copyWith => _$OverviewVmCopyWithImpl<OverviewVm>(this as OverviewVm, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OverviewVm;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverviewVm&&(identical(other.incomeMinor, _this.incomeMinor) || other.incomeMinor == _this.incomeMinor)&&(identical(other.expenseMinor, _this.expenseMinor) || other.expenseMinor == _this.expenseMinor)&&(identical(other.netMinor, _this.netMinor) || other.netMinor == _this.netMinor)&&(identical(other.savingsRatePercent, _this.savingsRatePercent) || other.savingsRatePercent == _this.savingsRatePercent)&&(identical(other.avgDailySpendMinor, _this.avgDailySpendMinor) || other.avgDailySpendMinor == _this.avgDailySpendMinor)&&const DeepCollectionEquality().equals(other.top, _this.top));
}


@override
int get hashCode {
  final _this = this as OverviewVm;
  return Object.hash(runtimeType,_this.incomeMinor,_this.expenseMinor,_this.netMinor,_this.savingsRatePercent,_this.avgDailySpendMinor,const DeepCollectionEquality().hash(_this.top));
}

@override
String toString() {
  final _this = this as OverviewVm;
  return 'OverviewVm(incomeMinor: ${_this.incomeMinor}, expenseMinor: ${_this.expenseMinor}, netMinor: ${_this.netMinor}, savingsRatePercent: ${_this.savingsRatePercent}, avgDailySpendMinor: ${_this.avgDailySpendMinor}, top: ${_this.top})';
}


}

/// @nodoc
abstract mixin class $OverviewVmCopyWith<$Res>  {
  factory $OverviewVmCopyWith(OverviewVm value, $Res Function(OverviewVm) _then) = _$OverviewVmCopyWithImpl;
@useResult
$Res call({
 int incomeMinor, int expenseMinor, int netMinor, int? savingsRatePercent, int? avgDailySpendMinor, List<TopCategory> top
});




}
/// @nodoc
class _$OverviewVmCopyWithImpl<$Res>
    implements $OverviewVmCopyWith<$Res> {
  _$OverviewVmCopyWithImpl(this._self, this._then);

  final OverviewVm _self;
  final $Res Function(OverviewVm) _then;

/// Create a copy of OverviewVm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? incomeMinor = null,Object? expenseMinor = null,Object? netMinor = null,Object? savingsRatePercent = freezed,Object? avgDailySpendMinor = freezed,Object? top = null,}) {
  return _then(OverviewVm(
incomeMinor: null == incomeMinor ? _self.incomeMinor : incomeMinor // ignore: cast_nullable_to_non_nullable
as int,expenseMinor: null == expenseMinor ? _self.expenseMinor : expenseMinor // ignore: cast_nullable_to_non_nullable
as int,netMinor: null == netMinor ? _self.netMinor : netMinor // ignore: cast_nullable_to_non_nullable
as int,savingsRatePercent: freezed == savingsRatePercent ? _self.savingsRatePercent : savingsRatePercent // ignore: cast_nullable_to_non_nullable
as int?,avgDailySpendMinor: freezed == avgDailySpendMinor ? _self.avgDailySpendMinor : avgDailySpendMinor // ignore: cast_nullable_to_non_nullable
as int?,top: null == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as List<TopCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [OverviewVm].
extension OverviewVmPatterns on OverviewVm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverviewVm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverviewVm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverviewVm value)  $default,){
final _that = this;
switch (_that) {
case _OverviewVm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverviewVm value)?  $default,){
final _that = this;
switch (_that) {
case _OverviewVm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int incomeMinor,  int expenseMinor,  int netMinor,  int? savingsRatePercent,  int? avgDailySpendMinor,  List<TopCategory> top)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverviewVm() when $default != null:
return $default(_that.incomeMinor,_that.expenseMinor,_that.netMinor,_that.savingsRatePercent,_that.avgDailySpendMinor,_that.top);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int incomeMinor,  int expenseMinor,  int netMinor,  int? savingsRatePercent,  int? avgDailySpendMinor,  List<TopCategory> top)  $default,) {final _that = this;
switch (_that) {
case _OverviewVm():
return $default(_that.incomeMinor,_that.expenseMinor,_that.netMinor,_that.savingsRatePercent,_that.avgDailySpendMinor,_that.top);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int incomeMinor,  int expenseMinor,  int netMinor,  int? savingsRatePercent,  int? avgDailySpendMinor,  List<TopCategory> top)?  $default,) {final _that = this;
switch (_that) {
case _OverviewVm() when $default != null:
return $default(_that.incomeMinor,_that.expenseMinor,_that.netMinor,_that.savingsRatePercent,_that.avgDailySpendMinor,_that.top);case _:
  return null;

}
}

}

/// @nodoc


class _OverviewVm implements OverviewVm {
  const _OverviewVm({required this.incomeMinor, required this.expenseMinor, required this.netMinor, this.savingsRatePercent, this.avgDailySpendMinor,  List<TopCategory> top = const <TopCategory>[]}): _top = top;
  

@override final  int incomeMinor;
@override final  int expenseMinor;
@override final  int netMinor;
/// net ÷ income; null ("—") when income is 0.
@override final  int? savingsRatePercent;
/// expense ÷ days so far (current period) or all days (past); null for
/// a period that has not started.
@override final  int? avgDailySpendMinor;
 final  List<TopCategory> _top;
@override@JsonKey() List<TopCategory> get top {
  if (_top is EqualUnmodifiableListView) return _top;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_top);
}


/// Create a copy of OverviewVm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverviewVmCopyWith<_OverviewVm> get copyWith => __$OverviewVmCopyWithImpl<_OverviewVm>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverviewVm&&(identical(other.incomeMinor, incomeMinor) || other.incomeMinor == incomeMinor)&&(identical(other.expenseMinor, expenseMinor) || other.expenseMinor == expenseMinor)&&(identical(other.netMinor, netMinor) || other.netMinor == netMinor)&&(identical(other.savingsRatePercent, savingsRatePercent) || other.savingsRatePercent == savingsRatePercent)&&(identical(other.avgDailySpendMinor, avgDailySpendMinor) || other.avgDailySpendMinor == avgDailySpendMinor)&&const DeepCollectionEquality().equals(other.top, _top));
}


@override
int get hashCode {
    return Object.hash(runtimeType,incomeMinor,expenseMinor,netMinor,savingsRatePercent,avgDailySpendMinor,const DeepCollectionEquality().hash(_top));
}

@override
String toString() {
    return 'OverviewVm(incomeMinor: $incomeMinor, expenseMinor: $expenseMinor, netMinor: $netMinor, savingsRatePercent: $savingsRatePercent, avgDailySpendMinor: $avgDailySpendMinor, top: $top)';
}


}

/// @nodoc
abstract mixin class _$OverviewVmCopyWith<$Res> implements $OverviewVmCopyWith<$Res> {
  factory _$OverviewVmCopyWith(_OverviewVm value, $Res Function(_OverviewVm) _then) = __$OverviewVmCopyWithImpl;
@override @useResult
$Res call({
 int incomeMinor, int expenseMinor, int netMinor, int? savingsRatePercent, int? avgDailySpendMinor, List<TopCategory> top
});




}
/// @nodoc
class __$OverviewVmCopyWithImpl<$Res>
    implements _$OverviewVmCopyWith<$Res> {
  __$OverviewVmCopyWithImpl(this._self, this._then);

  final _OverviewVm _self;
  final $Res Function(_OverviewVm) _then;

/// Create a copy of OverviewVm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? incomeMinor = null,Object? expenseMinor = null,Object? netMinor = null,Object? savingsRatePercent = freezed,Object? avgDailySpendMinor = freezed,Object? top = null,}) {
  return _then(_OverviewVm(
incomeMinor: null == incomeMinor ? _self.incomeMinor : incomeMinor // ignore: cast_nullable_to_non_nullable
as int,expenseMinor: null == expenseMinor ? _self.expenseMinor : expenseMinor // ignore: cast_nullable_to_non_nullable
as int,netMinor: null == netMinor ? _self.netMinor : netMinor // ignore: cast_nullable_to_non_nullable
as int,savingsRatePercent: freezed == savingsRatePercent ? _self.savingsRatePercent : savingsRatePercent // ignore: cast_nullable_to_non_nullable
as int?,avgDailySpendMinor: freezed == avgDailySpendMinor ? _self.avgDailySpendMinor : avgDailySpendMinor // ignore: cast_nullable_to_non_nullable
as int?,top: null == top ? _self._top : top // ignore: cast_nullable_to_non_nullable
as List<TopCategory>,
  ));
}


}

/// @nodoc
mixin _$DonutSlice {

/// The category id, or [donutOtherKey].
 String get key; int get amountMinor; int get percent; Category? get category;/// Categories merged into "Other"; empty for a single category.
 List<String> get memberIds;
/// Create a copy of DonutSlice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DonutSliceCopyWith<DonutSlice> get copyWith => _$DonutSliceCopyWithImpl<DonutSlice>(this as DonutSlice, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DonutSlice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DonutSlice&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.percent, _this.percent) || other.percent == _this.percent)&&(identical(other.category, _this.category) || other.category == _this.category)&&const DeepCollectionEquality().equals(other.memberIds, _this.memberIds));
}


@override
int get hashCode {
  final _this = this as DonutSlice;
  return Object.hash(runtimeType,_this.key,_this.amountMinor,_this.percent,_this.category,const DeepCollectionEquality().hash(_this.memberIds));
}

@override
String toString() {
  final _this = this as DonutSlice;
  return 'DonutSlice(key: ${_this.key}, amountMinor: ${_this.amountMinor}, percent: ${_this.percent}, category: ${_this.category}, memberIds: ${_this.memberIds})';
}


}

/// @nodoc
abstract mixin class $DonutSliceCopyWith<$Res>  {
  factory $DonutSliceCopyWith(DonutSlice value, $Res Function(DonutSlice) _then) = _$DonutSliceCopyWithImpl;
@useResult
$Res call({
 String key, int amountMinor, int percent, Category? category, List<String> memberIds
});


$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$DonutSliceCopyWithImpl<$Res>
    implements $DonutSliceCopyWith<$Res> {
  _$DonutSliceCopyWithImpl(this._self, this._then);

  final DonutSlice _self;
  final $Res Function(DonutSlice) _then;

/// Create a copy of DonutSlice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? amountMinor = null,Object? percent = null,Object? category = freezed,Object? memberIds = null,}) {
  return _then(DonutSlice(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of DonutSlice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [DonutSlice].
extension DonutSlicePatterns on DonutSlice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DonutSlice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DonutSlice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DonutSlice value)  $default,){
final _that = this;
switch (_that) {
case _DonutSlice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DonutSlice value)?  $default,){
final _that = this;
switch (_that) {
case _DonutSlice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  int amountMinor,  int percent,  Category? category,  List<String> memberIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DonutSlice() when $default != null:
return $default(_that.key,_that.amountMinor,_that.percent,_that.category,_that.memberIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  int amountMinor,  int percent,  Category? category,  List<String> memberIds)  $default,) {final _that = this;
switch (_that) {
case _DonutSlice():
return $default(_that.key,_that.amountMinor,_that.percent,_that.category,_that.memberIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  int amountMinor,  int percent,  Category? category,  List<String> memberIds)?  $default,) {final _that = this;
switch (_that) {
case _DonutSlice() when $default != null:
return $default(_that.key,_that.amountMinor,_that.percent,_that.category,_that.memberIds);case _:
  return null;

}
}

}

/// @nodoc


class _DonutSlice extends DonutSlice {
  const _DonutSlice({required this.key, required this.amountMinor, required this.percent, this.category,  List<String> memberIds = const <String>[]}): _memberIds = memberIds,super._();
  

/// The category id, or [donutOtherKey].
@override final  String key;
@override final  int amountMinor;
@override final  int percent;
@override final  Category? category;
/// Categories merged into "Other"; empty for a single category.
 final  List<String> _memberIds;
/// Categories merged into "Other"; empty for a single category.
@override@JsonKey() List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}


/// Create a copy of DonutSlice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DonutSliceCopyWith<_DonutSlice> get copyWith => __$DonutSliceCopyWithImpl<_DonutSlice>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DonutSlice&&(identical(other.key, key) || other.key == key)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.memberIds, _memberIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,amountMinor,percent,category,const DeepCollectionEquality().hash(_memberIds));
}

@override
String toString() {
    return 'DonutSlice(key: $key, amountMinor: $amountMinor, percent: $percent, category: $category, memberIds: $memberIds)';
}


}

/// @nodoc
abstract mixin class _$DonutSliceCopyWith<$Res> implements $DonutSliceCopyWith<$Res> {
  factory _$DonutSliceCopyWith(_DonutSlice value, $Res Function(_DonutSlice) _then) = __$DonutSliceCopyWithImpl;
@override @useResult
$Res call({
 String key, int amountMinor, int percent, Category? category, List<String> memberIds
});


@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$DonutSliceCopyWithImpl<$Res>
    implements _$DonutSliceCopyWith<$Res> {
  __$DonutSliceCopyWithImpl(this._self, this._then);

  final _DonutSlice _self;
  final $Res Function(_DonutSlice) _then;

/// Create a copy of DonutSlice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? amountMinor = null,Object? percent = null,Object? category = freezed,Object? memberIds = null,}) {
  return _then(_DonutSlice(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of DonutSlice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $CategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

/// @nodoc
mixin _$DonutVm {

 int get totalMinor; List<DonutSlice> get slices;
/// Create a copy of DonutVm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DonutVmCopyWith<DonutVm> get copyWith => _$DonutVmCopyWithImpl<DonutVm>(this as DonutVm, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DonutVm;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DonutVm&&(identical(other.totalMinor, _this.totalMinor) || other.totalMinor == _this.totalMinor)&&const DeepCollectionEquality().equals(other.slices, _this.slices));
}


@override
int get hashCode {
  final _this = this as DonutVm;
  return Object.hash(runtimeType,_this.totalMinor,const DeepCollectionEquality().hash(_this.slices));
}

@override
String toString() {
  final _this = this as DonutVm;
  return 'DonutVm(totalMinor: ${_this.totalMinor}, slices: ${_this.slices})';
}


}

/// @nodoc
abstract mixin class $DonutVmCopyWith<$Res>  {
  factory $DonutVmCopyWith(DonutVm value, $Res Function(DonutVm) _then) = _$DonutVmCopyWithImpl;
@useResult
$Res call({
 int totalMinor, List<DonutSlice> slices
});




}
/// @nodoc
class _$DonutVmCopyWithImpl<$Res>
    implements $DonutVmCopyWith<$Res> {
  _$DonutVmCopyWithImpl(this._self, this._then);

  final DonutVm _self;
  final $Res Function(DonutVm) _then;

/// Create a copy of DonutVm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalMinor = null,Object? slices = null,}) {
  return _then(DonutVm(
totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,slices: null == slices ? _self.slices : slices // ignore: cast_nullable_to_non_nullable
as List<DonutSlice>,
  ));
}

}


/// Adds pattern-matching-related methods to [DonutVm].
extension DonutVmPatterns on DonutVm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DonutVm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DonutVm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DonutVm value)  $default,){
final _that = this;
switch (_that) {
case _DonutVm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DonutVm value)?  $default,){
final _that = this;
switch (_that) {
case _DonutVm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalMinor,  List<DonutSlice> slices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DonutVm() when $default != null:
return $default(_that.totalMinor,_that.slices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalMinor,  List<DonutSlice> slices)  $default,) {final _that = this;
switch (_that) {
case _DonutVm():
return $default(_that.totalMinor,_that.slices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalMinor,  List<DonutSlice> slices)?  $default,) {final _that = this;
switch (_that) {
case _DonutVm() when $default != null:
return $default(_that.totalMinor,_that.slices);case _:
  return null;

}
}

}

/// @nodoc


class _DonutVm implements DonutVm {
  const _DonutVm({required this.totalMinor,  List<DonutSlice> slices = const <DonutSlice>[]}): _slices = slices;
  

@override final  int totalMinor;
 final  List<DonutSlice> _slices;
@override@JsonKey() List<DonutSlice> get slices {
  if (_slices is EqualUnmodifiableListView) return _slices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slices);
}


/// Create a copy of DonutVm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DonutVmCopyWith<_DonutVm> get copyWith => __$DonutVmCopyWithImpl<_DonutVm>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DonutVm&&(identical(other.totalMinor, totalMinor) || other.totalMinor == totalMinor)&&const DeepCollectionEquality().equals(other.slices, _slices));
}


@override
int get hashCode {
    return Object.hash(runtimeType,totalMinor,const DeepCollectionEquality().hash(_slices));
}

@override
String toString() {
    return 'DonutVm(totalMinor: $totalMinor, slices: $slices)';
}


}

/// @nodoc
abstract mixin class _$DonutVmCopyWith<$Res> implements $DonutVmCopyWith<$Res> {
  factory _$DonutVmCopyWith(_DonutVm value, $Res Function(_DonutVm) _then) = __$DonutVmCopyWithImpl;
@override @useResult
$Res call({
 int totalMinor, List<DonutSlice> slices
});




}
/// @nodoc
class __$DonutVmCopyWithImpl<$Res>
    implements _$DonutVmCopyWith<$Res> {
  __$DonutVmCopyWithImpl(this._self, this._then);

  final _DonutVm _self;
  final $Res Function(_DonutVm) _then;

/// Create a copy of DonutVm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalMinor = null,Object? slices = null,}) {
  return _then(_DonutVm(
totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,slices: null == slices ? _self._slices : slices // ignore: cast_nullable_to_non_nullable
as List<DonutSlice>,
  ));
}


}

/// @nodoc
mixin _$TrendPoint {

 int get x; int get yMinor;
/// Create a copy of TrendPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendPointCopyWith<TrendPoint> get copyWith => _$TrendPointCopyWithImpl<TrendPoint>(this as TrendPoint, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrendPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendPoint&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.yMinor, _this.yMinor) || other.yMinor == _this.yMinor));
}


@override
int get hashCode {
  final _this = this as TrendPoint;
  return Object.hash(runtimeType,_this.x,_this.yMinor);
}

@override
String toString() {
  final _this = this as TrendPoint;
  return 'TrendPoint(x: ${_this.x}, yMinor: ${_this.yMinor})';
}


}

/// @nodoc
abstract mixin class $TrendPointCopyWith<$Res>  {
  factory $TrendPointCopyWith(TrendPoint value, $Res Function(TrendPoint) _then) = _$TrendPointCopyWithImpl;
@useResult
$Res call({
 int x, int yMinor
});




}
/// @nodoc
class _$TrendPointCopyWithImpl<$Res>
    implements $TrendPointCopyWith<$Res> {
  _$TrendPointCopyWithImpl(this._self, this._then);

  final TrendPoint _self;
  final $Res Function(TrendPoint) _then;

/// Create a copy of TrendPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? yMinor = null,}) {
  return _then(TrendPoint(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as int,yMinor: null == yMinor ? _self.yMinor : yMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendPoint].
extension TrendPointPatterns on TrendPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendPoint value)  $default,){
final _that = this;
switch (_that) {
case _TrendPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendPoint value)?  $default,){
final _that = this;
switch (_that) {
case _TrendPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int x,  int yMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendPoint() when $default != null:
return $default(_that.x,_that.yMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int x,  int yMinor)  $default,) {final _that = this;
switch (_that) {
case _TrendPoint():
return $default(_that.x,_that.yMinor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int x,  int yMinor)?  $default,) {final _that = this;
switch (_that) {
case _TrendPoint() when $default != null:
return $default(_that.x,_that.yMinor);case _:
  return null;

}
}

}

/// @nodoc


class _TrendPoint implements TrendPoint {
  const _TrendPoint({required this.x, required this.yMinor});
  

@override final  int x;
@override final  int yMinor;

/// Create a copy of TrendPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendPointCopyWith<_TrendPoint> get copyWith => __$TrendPointCopyWithImpl<_TrendPoint>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendPoint&&(identical(other.x, x) || other.x == x)&&(identical(other.yMinor, yMinor) || other.yMinor == yMinor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,x,yMinor);
}

@override
String toString() {
    return 'TrendPoint(x: $x, yMinor: $yMinor)';
}


}

/// @nodoc
abstract mixin class _$TrendPointCopyWith<$Res> implements $TrendPointCopyWith<$Res> {
  factory _$TrendPointCopyWith(_TrendPoint value, $Res Function(_TrendPoint) _then) = __$TrendPointCopyWithImpl;
@override @useResult
$Res call({
 int x, int yMinor
});




}
/// @nodoc
class __$TrendPointCopyWithImpl<$Res>
    implements _$TrendPointCopyWith<$Res> {
  __$TrendPointCopyWithImpl(this._self, this._then);

  final _TrendPoint _self;
  final $Res Function(_TrendPoint) _then;

/// Create a copy of TrendPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? yMinor = null,}) {
  return _then(_TrendPoint(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as int,yMinor: null == yMinor ? _self.yMinor : yMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TrendVm {

 TrendGranularity get granularity; List<TrendPoint> get current; List<TrendPoint> get previous; int get maxYMinor; int get currentTotalMinor; int get previousTotalMinor;/// Local start of the current period, for axis labels.
 DateTime get startLocal;
/// Create a copy of TrendVm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendVmCopyWith<TrendVm> get copyWith => _$TrendVmCopyWithImpl<TrendVm>(this as TrendVm, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrendVm;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendVm&&(identical(other.granularity, _this.granularity) || other.granularity == _this.granularity)&&const DeepCollectionEquality().equals(other.current, _this.current)&&const DeepCollectionEquality().equals(other.previous, _this.previous)&&(identical(other.maxYMinor, _this.maxYMinor) || other.maxYMinor == _this.maxYMinor)&&(identical(other.currentTotalMinor, _this.currentTotalMinor) || other.currentTotalMinor == _this.currentTotalMinor)&&(identical(other.previousTotalMinor, _this.previousTotalMinor) || other.previousTotalMinor == _this.previousTotalMinor)&&(identical(other.startLocal, _this.startLocal) || other.startLocal == _this.startLocal));
}


@override
int get hashCode {
  final _this = this as TrendVm;
  return Object.hash(runtimeType,_this.granularity,const DeepCollectionEquality().hash(_this.current),const DeepCollectionEquality().hash(_this.previous),_this.maxYMinor,_this.currentTotalMinor,_this.previousTotalMinor,_this.startLocal);
}

@override
String toString() {
  final _this = this as TrendVm;
  return 'TrendVm(granularity: ${_this.granularity}, current: ${_this.current}, previous: ${_this.previous}, maxYMinor: ${_this.maxYMinor}, currentTotalMinor: ${_this.currentTotalMinor}, previousTotalMinor: ${_this.previousTotalMinor}, startLocal: ${_this.startLocal})';
}


}

/// @nodoc
abstract mixin class $TrendVmCopyWith<$Res>  {
  factory $TrendVmCopyWith(TrendVm value, $Res Function(TrendVm) _then) = _$TrendVmCopyWithImpl;
@useResult
$Res call({
 TrendGranularity granularity, List<TrendPoint> current, List<TrendPoint> previous, int maxYMinor, int currentTotalMinor, int previousTotalMinor, DateTime startLocal
});




}
/// @nodoc
class _$TrendVmCopyWithImpl<$Res>
    implements $TrendVmCopyWith<$Res> {
  _$TrendVmCopyWithImpl(this._self, this._then);

  final TrendVm _self;
  final $Res Function(TrendVm) _then;

/// Create a copy of TrendVm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? granularity = null,Object? current = null,Object? previous = null,Object? maxYMinor = null,Object? currentTotalMinor = null,Object? previousTotalMinor = null,Object? startLocal = null,}) {
  return _then(TrendVm(
granularity: null == granularity ? _self.granularity : granularity // ignore: cast_nullable_to_non_nullable
as TrendGranularity,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as List<TrendPoint>,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as List<TrendPoint>,maxYMinor: null == maxYMinor ? _self.maxYMinor : maxYMinor // ignore: cast_nullable_to_non_nullable
as int,currentTotalMinor: null == currentTotalMinor ? _self.currentTotalMinor : currentTotalMinor // ignore: cast_nullable_to_non_nullable
as int,previousTotalMinor: null == previousTotalMinor ? _self.previousTotalMinor : previousTotalMinor // ignore: cast_nullable_to_non_nullable
as int,startLocal: null == startLocal ? _self.startLocal : startLocal // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendVm].
extension TrendVmPatterns on TrendVm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendVm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendVm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendVm value)  $default,){
final _that = this;
switch (_that) {
case _TrendVm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendVm value)?  $default,){
final _that = this;
switch (_that) {
case _TrendVm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrendGranularity granularity,  List<TrendPoint> current,  List<TrendPoint> previous,  int maxYMinor,  int currentTotalMinor,  int previousTotalMinor,  DateTime startLocal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendVm() when $default != null:
return $default(_that.granularity,_that.current,_that.previous,_that.maxYMinor,_that.currentTotalMinor,_that.previousTotalMinor,_that.startLocal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrendGranularity granularity,  List<TrendPoint> current,  List<TrendPoint> previous,  int maxYMinor,  int currentTotalMinor,  int previousTotalMinor,  DateTime startLocal)  $default,) {final _that = this;
switch (_that) {
case _TrendVm():
return $default(_that.granularity,_that.current,_that.previous,_that.maxYMinor,_that.currentTotalMinor,_that.previousTotalMinor,_that.startLocal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrendGranularity granularity,  List<TrendPoint> current,  List<TrendPoint> previous,  int maxYMinor,  int currentTotalMinor,  int previousTotalMinor,  DateTime startLocal)?  $default,) {final _that = this;
switch (_that) {
case _TrendVm() when $default != null:
return $default(_that.granularity,_that.current,_that.previous,_that.maxYMinor,_that.currentTotalMinor,_that.previousTotalMinor,_that.startLocal);case _:
  return null;

}
}

}

/// @nodoc


class _TrendVm implements TrendVm {
  const _TrendVm({required this.granularity, required  List<TrendPoint> current, required  List<TrendPoint> previous, required this.maxYMinor, required this.currentTotalMinor, required this.previousTotalMinor, required this.startLocal}): _current = current,_previous = previous;
  

@override final  TrendGranularity granularity;
 final  List<TrendPoint> _current;
@override List<TrendPoint> get current {
  if (_current is EqualUnmodifiableListView) return _current;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_current);
}

 final  List<TrendPoint> _previous;
@override List<TrendPoint> get previous {
  if (_previous is EqualUnmodifiableListView) return _previous;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_previous);
}

@override final  int maxYMinor;
@override final  int currentTotalMinor;
@override final  int previousTotalMinor;
/// Local start of the current period, for axis labels.
@override final  DateTime startLocal;

/// Create a copy of TrendVm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendVmCopyWith<_TrendVm> get copyWith => __$TrendVmCopyWithImpl<_TrendVm>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendVm&&(identical(other.granularity, granularity) || other.granularity == granularity)&&const DeepCollectionEquality().equals(other.current, _current)&&const DeepCollectionEquality().equals(other.previous, _previous)&&(identical(other.maxYMinor, maxYMinor) || other.maxYMinor == maxYMinor)&&(identical(other.currentTotalMinor, currentTotalMinor) || other.currentTotalMinor == currentTotalMinor)&&(identical(other.previousTotalMinor, previousTotalMinor) || other.previousTotalMinor == previousTotalMinor)&&(identical(other.startLocal, startLocal) || other.startLocal == startLocal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,granularity,const DeepCollectionEquality().hash(_current),const DeepCollectionEquality().hash(_previous),maxYMinor,currentTotalMinor,previousTotalMinor,startLocal);
}

@override
String toString() {
    return 'TrendVm(granularity: $granularity, current: $current, previous: $previous, maxYMinor: $maxYMinor, currentTotalMinor: $currentTotalMinor, previousTotalMinor: $previousTotalMinor, startLocal: $startLocal)';
}


}

/// @nodoc
abstract mixin class _$TrendVmCopyWith<$Res> implements $TrendVmCopyWith<$Res> {
  factory _$TrendVmCopyWith(_TrendVm value, $Res Function(_TrendVm) _then) = __$TrendVmCopyWithImpl;
@override @useResult
$Res call({
 TrendGranularity granularity, List<TrendPoint> current, List<TrendPoint> previous, int maxYMinor, int currentTotalMinor, int previousTotalMinor, DateTime startLocal
});




}
/// @nodoc
class __$TrendVmCopyWithImpl<$Res>
    implements _$TrendVmCopyWith<$Res> {
  __$TrendVmCopyWithImpl(this._self, this._then);

  final _TrendVm _self;
  final $Res Function(_TrendVm) _then;

/// Create a copy of TrendVm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? granularity = null,Object? current = null,Object? previous = null,Object? maxYMinor = null,Object? currentTotalMinor = null,Object? previousTotalMinor = null,Object? startLocal = null,}) {
  return _then(_TrendVm(
granularity: null == granularity ? _self.granularity : granularity // ignore: cast_nullable_to_non_nullable
as TrendGranularity,current: null == current ? _self._current : current // ignore: cast_nullable_to_non_nullable
as List<TrendPoint>,previous: null == previous ? _self._previous : previous // ignore: cast_nullable_to_non_nullable
as List<TrendPoint>,maxYMinor: null == maxYMinor ? _self.maxYMinor : maxYMinor // ignore: cast_nullable_to_non_nullable
as int,currentTotalMinor: null == currentTotalMinor ? _self.currentTotalMinor : currentTotalMinor // ignore: cast_nullable_to_non_nullable
as int,previousTotalMinor: null == previousTotalMinor ? _self.previousTotalMinor : previousTotalMinor // ignore: cast_nullable_to_non_nullable
as int,startLocal: null == startLocal ? _self.startLocal : startLocal // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$BarItem {

 int get amountMinor; Account? get account; String? get accountId; PaymentMode? get mode;
/// Create a copy of BarItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarItemCopyWith<BarItem> get copyWith => _$BarItemCopyWithImpl<BarItem>(this as BarItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BarItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BarItem&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.mode, _this.mode) || other.mode == _this.mode));
}


@override
int get hashCode {
  final _this = this as BarItem;
  return Object.hash(runtimeType,_this.amountMinor,_this.account,_this.accountId,_this.mode);
}

@override
String toString() {
  final _this = this as BarItem;
  return 'BarItem(amountMinor: ${_this.amountMinor}, account: ${_this.account}, accountId: ${_this.accountId}, mode: ${_this.mode})';
}


}

/// @nodoc
abstract mixin class $BarItemCopyWith<$Res>  {
  factory $BarItemCopyWith(BarItem value, $Res Function(BarItem) _then) = _$BarItemCopyWithImpl;
@useResult
$Res call({
 int amountMinor, Account? account, String? accountId, PaymentMode? mode
});


$AccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$BarItemCopyWithImpl<$Res>
    implements $BarItemCopyWith<$Res> {
  _$BarItemCopyWithImpl(this._self, this._then);

  final BarItem _self;
  final $Res Function(BarItem) _then;

/// Create a copy of BarItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amountMinor = null,Object? account = freezed,Object? accountId = freezed,Object? mode = freezed,}) {
  return _then(BarItem(
amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PaymentMode?,
  ));
}
/// Create a copy of BarItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $AccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [BarItem].
extension BarItemPatterns on BarItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BarItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BarItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BarItem value)  $default,){
final _that = this;
switch (_that) {
case _BarItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BarItem value)?  $default,){
final _that = this;
switch (_that) {
case _BarItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int amountMinor,  Account? account,  String? accountId,  PaymentMode? mode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BarItem() when $default != null:
return $default(_that.amountMinor,_that.account,_that.accountId,_that.mode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int amountMinor,  Account? account,  String? accountId,  PaymentMode? mode)  $default,) {final _that = this;
switch (_that) {
case _BarItem():
return $default(_that.amountMinor,_that.account,_that.accountId,_that.mode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int amountMinor,  Account? account,  String? accountId,  PaymentMode? mode)?  $default,) {final _that = this;
switch (_that) {
case _BarItem() when $default != null:
return $default(_that.amountMinor,_that.account,_that.accountId,_that.mode);case _:
  return null;

}
}

}

/// @nodoc


class _BarItem implements BarItem {
  const _BarItem({required this.amountMinor, this.account, this.accountId, this.mode});
  

@override final  int amountMinor;
@override final  Account? account;
@override final  String? accountId;
@override final  PaymentMode? mode;

/// Create a copy of BarItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BarItemCopyWith<_BarItem> get copyWith => __$BarItemCopyWithImpl<_BarItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BarItem&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.account, account) || other.account == account)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode {
    return Object.hash(runtimeType,amountMinor,account,accountId,mode);
}

@override
String toString() {
    return 'BarItem(amountMinor: $amountMinor, account: $account, accountId: $accountId, mode: $mode)';
}


}

/// @nodoc
abstract mixin class _$BarItemCopyWith<$Res> implements $BarItemCopyWith<$Res> {
  factory _$BarItemCopyWith(_BarItem value, $Res Function(_BarItem) _then) = __$BarItemCopyWithImpl;
@override @useResult
$Res call({
 int amountMinor, Account? account, String? accountId, PaymentMode? mode
});


@override $AccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$BarItemCopyWithImpl<$Res>
    implements _$BarItemCopyWith<$Res> {
  __$BarItemCopyWithImpl(this._self, this._then);

  final _BarItem _self;
  final $Res Function(_BarItem) _then;

/// Create a copy of BarItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amountMinor = null,Object? account = freezed,Object? accountId = freezed,Object? mode = freezed,}) {
  return _then(_BarItem(
amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PaymentMode?,
  ));
}

/// Create a copy of BarItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $AccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}

/// @nodoc
mixin _$BarsVm {

 List<BarItem> get byAccount; List<BarItem> get byPaymentMode; int get maxYMinor;
/// Create a copy of BarsVm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarsVmCopyWith<BarsVm> get copyWith => _$BarsVmCopyWithImpl<BarsVm>(this as BarsVm, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BarsVm;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BarsVm&&const DeepCollectionEquality().equals(other.byAccount, _this.byAccount)&&const DeepCollectionEquality().equals(other.byPaymentMode, _this.byPaymentMode)&&(identical(other.maxYMinor, _this.maxYMinor) || other.maxYMinor == _this.maxYMinor));
}


@override
int get hashCode {
  final _this = this as BarsVm;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.byAccount),const DeepCollectionEquality().hash(_this.byPaymentMode),_this.maxYMinor);
}

@override
String toString() {
  final _this = this as BarsVm;
  return 'BarsVm(byAccount: ${_this.byAccount}, byPaymentMode: ${_this.byPaymentMode}, maxYMinor: ${_this.maxYMinor})';
}


}

/// @nodoc
abstract mixin class $BarsVmCopyWith<$Res>  {
  factory $BarsVmCopyWith(BarsVm value, $Res Function(BarsVm) _then) = _$BarsVmCopyWithImpl;
@useResult
$Res call({
 List<BarItem> byAccount, List<BarItem> byPaymentMode, int maxYMinor
});




}
/// @nodoc
class _$BarsVmCopyWithImpl<$Res>
    implements $BarsVmCopyWith<$Res> {
  _$BarsVmCopyWithImpl(this._self, this._then);

  final BarsVm _self;
  final $Res Function(BarsVm) _then;

/// Create a copy of BarsVm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? byAccount = null,Object? byPaymentMode = null,Object? maxYMinor = null,}) {
  return _then(BarsVm(
byAccount: null == byAccount ? _self.byAccount : byAccount // ignore: cast_nullable_to_non_nullable
as List<BarItem>,byPaymentMode: null == byPaymentMode ? _self.byPaymentMode : byPaymentMode // ignore: cast_nullable_to_non_nullable
as List<BarItem>,maxYMinor: null == maxYMinor ? _self.maxYMinor : maxYMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BarsVm].
extension BarsVmPatterns on BarsVm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BarsVm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BarsVm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BarsVm value)  $default,){
final _that = this;
switch (_that) {
case _BarsVm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BarsVm value)?  $default,){
final _that = this;
switch (_that) {
case _BarsVm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BarItem> byAccount,  List<BarItem> byPaymentMode,  int maxYMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BarsVm() when $default != null:
return $default(_that.byAccount,_that.byPaymentMode,_that.maxYMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BarItem> byAccount,  List<BarItem> byPaymentMode,  int maxYMinor)  $default,) {final _that = this;
switch (_that) {
case _BarsVm():
return $default(_that.byAccount,_that.byPaymentMode,_that.maxYMinor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BarItem> byAccount,  List<BarItem> byPaymentMode,  int maxYMinor)?  $default,) {final _that = this;
switch (_that) {
case _BarsVm() when $default != null:
return $default(_that.byAccount,_that.byPaymentMode,_that.maxYMinor);case _:
  return null;

}
}

}

/// @nodoc


class _BarsVm implements BarsVm {
  const _BarsVm({required  List<BarItem> byAccount, required  List<BarItem> byPaymentMode, required this.maxYMinor}): _byAccount = byAccount,_byPaymentMode = byPaymentMode;
  

 final  List<BarItem> _byAccount;
@override List<BarItem> get byAccount {
  if (_byAccount is EqualUnmodifiableListView) return _byAccount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byAccount);
}

 final  List<BarItem> _byPaymentMode;
@override List<BarItem> get byPaymentMode {
  if (_byPaymentMode is EqualUnmodifiableListView) return _byPaymentMode;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byPaymentMode);
}

@override final  int maxYMinor;

/// Create a copy of BarsVm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BarsVmCopyWith<_BarsVm> get copyWith => __$BarsVmCopyWithImpl<_BarsVm>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BarsVm&&const DeepCollectionEquality().equals(other.byAccount, _byAccount)&&const DeepCollectionEquality().equals(other.byPaymentMode, _byPaymentMode)&&(identical(other.maxYMinor, maxYMinor) || other.maxYMinor == maxYMinor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_byAccount),const DeepCollectionEquality().hash(_byPaymentMode),maxYMinor);
}

@override
String toString() {
    return 'BarsVm(byAccount: $byAccount, byPaymentMode: $byPaymentMode, maxYMinor: $maxYMinor)';
}


}

/// @nodoc
abstract mixin class _$BarsVmCopyWith<$Res> implements $BarsVmCopyWith<$Res> {
  factory _$BarsVmCopyWith(_BarsVm value, $Res Function(_BarsVm) _then) = __$BarsVmCopyWithImpl;
@override @useResult
$Res call({
 List<BarItem> byAccount, List<BarItem> byPaymentMode, int maxYMinor
});




}
/// @nodoc
class __$BarsVmCopyWithImpl<$Res>
    implements _$BarsVmCopyWith<$Res> {
  __$BarsVmCopyWithImpl(this._self, this._then);

  final _BarsVm _self;
  final $Res Function(_BarsVm) _then;

/// Create a copy of BarsVm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? byAccount = null,Object? byPaymentMode = null,Object? maxYMinor = null,}) {
  return _then(_BarsVm(
byAccount: null == byAccount ? _self._byAccount : byAccount // ignore: cast_nullable_to_non_nullable
as List<BarItem>,byPaymentMode: null == byPaymentMode ? _self._byPaymentMode : byPaymentMode // ignore: cast_nullable_to_non_nullable
as List<BarItem>,maxYMinor: null == maxYMinor ? _self.maxYMinor : maxYMinor // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
