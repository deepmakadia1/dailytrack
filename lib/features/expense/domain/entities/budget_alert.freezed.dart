// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetAlert {

 String get budgetId;/// `yyyy-MM`; tapping the notification opens EXP-08 for this month.
 String get monthKey; BudgetThreshold get threshold;/// Whole percent of the limit used.
 int get percent;/// Null = Overall.
 String? get categoryId;
/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetAlertCopyWith<BudgetAlert> get copyWith => _$BudgetAlertCopyWithImpl<BudgetAlert>(this as BudgetAlert, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BudgetAlert;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetAlert&&(identical(other.budgetId, _this.budgetId) || other.budgetId == _this.budgetId)&&(identical(other.monthKey, _this.monthKey) || other.monthKey == _this.monthKey)&&(identical(other.threshold, _this.threshold) || other.threshold == _this.threshold)&&(identical(other.percent, _this.percent) || other.percent == _this.percent)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId));
}


@override
int get hashCode {
  final _this = this as BudgetAlert;
  return Object.hash(runtimeType,_this.budgetId,_this.monthKey,_this.threshold,_this.percent,_this.categoryId);
}

@override
String toString() {
  final _this = this as BudgetAlert;
  return 'BudgetAlert(budgetId: ${_this.budgetId}, monthKey: ${_this.monthKey}, threshold: ${_this.threshold}, percent: ${_this.percent}, categoryId: ${_this.categoryId})';
}


}

/// @nodoc
abstract mixin class $BudgetAlertCopyWith<$Res>  {
  factory $BudgetAlertCopyWith(BudgetAlert value, $Res Function(BudgetAlert) _then) = _$BudgetAlertCopyWithImpl;
@useResult
$Res call({
 String budgetId, String monthKey, BudgetThreshold threshold, int percent, String? categoryId
});




}
/// @nodoc
class _$BudgetAlertCopyWithImpl<$Res>
    implements $BudgetAlertCopyWith<$Res> {
  _$BudgetAlertCopyWithImpl(this._self, this._then);

  final BudgetAlert _self;
  final $Res Function(BudgetAlert) _then;

/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budgetId = null,Object? monthKey = null,Object? threshold = null,Object? percent = null,Object? categoryId = freezed,}) {
  return _then(BudgetAlert(
budgetId: null == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String,monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as BudgetThreshold,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetAlert].
extension BudgetAlertPatterns on BudgetAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetAlert value)  $default,){
final _that = this;
switch (_that) {
case _BudgetAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetAlert value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String budgetId,  String monthKey,  BudgetThreshold threshold,  int percent,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetAlert() when $default != null:
return $default(_that.budgetId,_that.monthKey,_that.threshold,_that.percent,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String budgetId,  String monthKey,  BudgetThreshold threshold,  int percent,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _BudgetAlert():
return $default(_that.budgetId,_that.monthKey,_that.threshold,_that.percent,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String budgetId,  String monthKey,  BudgetThreshold threshold,  int percent,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _BudgetAlert() when $default != null:
return $default(_that.budgetId,_that.monthKey,_that.threshold,_that.percent,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetAlert implements BudgetAlert {
  const _BudgetAlert({required this.budgetId, required this.monthKey, required this.threshold, required this.percent, this.categoryId});
  

@override final  String budgetId;
/// `yyyy-MM`; tapping the notification opens EXP-08 for this month.
@override final  String monthKey;
@override final  BudgetThreshold threshold;
/// Whole percent of the limit used.
@override final  int percent;
/// Null = Overall.
@override final  String? categoryId;

/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetAlertCopyWith<_BudgetAlert> get copyWith => __$BudgetAlertCopyWithImpl<_BudgetAlert>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetAlert&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.monthKey, monthKey) || other.monthKey == monthKey)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,budgetId,monthKey,threshold,percent,categoryId);
}

@override
String toString() {
    return 'BudgetAlert(budgetId: $budgetId, monthKey: $monthKey, threshold: $threshold, percent: $percent, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$BudgetAlertCopyWith<$Res> implements $BudgetAlertCopyWith<$Res> {
  factory _$BudgetAlertCopyWith(_BudgetAlert value, $Res Function(_BudgetAlert) _then) = __$BudgetAlertCopyWithImpl;
@override @useResult
$Res call({
 String budgetId, String monthKey, BudgetThreshold threshold, int percent, String? categoryId
});




}
/// @nodoc
class __$BudgetAlertCopyWithImpl<$Res>
    implements _$BudgetAlertCopyWith<$Res> {
  __$BudgetAlertCopyWithImpl(this._self, this._then);

  final _BudgetAlert _self;
  final $Res Function(_BudgetAlert) _then;

/// Create a copy of BudgetAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budgetId = null,Object? monthKey = null,Object? threshold = null,Object? percent = null,Object? categoryId = freezed,}) {
  return _then(_BudgetAlert(
budgetId: null == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String,monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as BudgetThreshold,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
