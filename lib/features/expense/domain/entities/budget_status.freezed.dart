// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetStatus {

 Budget get budget; int get spentMinor;/// limit − spent; negative when over budget.
 int get remainingMinor;/// Whole percent of the limit used; may exceed 100.
 int get percent; BudgetLevel get level; MonthPhase get monthPhase;/// Null for Overall, or when the category no longer exists.
 Category? get category;/// The category is hidden or deleted (edge case: still shown, marked).
 bool get categoryHidden;/// Days from today to the month's last day, both included (current
/// month), or all days (future month); null for a past month.
 int? get daysLeft;/// remaining ÷ daysLeft rounded down; null when nothing is left or for a
/// past month.
 int? get perDayLeftMinor;
/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<BudgetStatus> get copyWith => _$BudgetStatusCopyWithImpl<BudgetStatus>(this as BudgetStatus, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BudgetStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetStatus&&(identical(other.budget, _this.budget) || other.budget == _this.budget)&&(identical(other.spentMinor, _this.spentMinor) || other.spentMinor == _this.spentMinor)&&(identical(other.remainingMinor, _this.remainingMinor) || other.remainingMinor == _this.remainingMinor)&&(identical(other.percent, _this.percent) || other.percent == _this.percent)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.monthPhase, _this.monthPhase) || other.monthPhase == _this.monthPhase)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.categoryHidden, _this.categoryHidden) || other.categoryHidden == _this.categoryHidden)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft)&&(identical(other.perDayLeftMinor, _this.perDayLeftMinor) || other.perDayLeftMinor == _this.perDayLeftMinor));
}


@override
int get hashCode {
  final _this = this as BudgetStatus;
  return Object.hash(runtimeType,_this.budget,_this.spentMinor,_this.remainingMinor,_this.percent,_this.level,_this.monthPhase,_this.category,_this.categoryHidden,_this.daysLeft,_this.perDayLeftMinor);
}

@override
String toString() {
  final _this = this as BudgetStatus;
  return 'BudgetStatus(budget: ${_this.budget}, spentMinor: ${_this.spentMinor}, remainingMinor: ${_this.remainingMinor}, percent: ${_this.percent}, level: ${_this.level}, monthPhase: ${_this.monthPhase}, category: ${_this.category}, categoryHidden: ${_this.categoryHidden}, daysLeft: ${_this.daysLeft}, perDayLeftMinor: ${_this.perDayLeftMinor})';
}


}

/// @nodoc
abstract mixin class $BudgetStatusCopyWith<$Res>  {
  factory $BudgetStatusCopyWith(BudgetStatus value, $Res Function(BudgetStatus) _then) = _$BudgetStatusCopyWithImpl;
@useResult
$Res call({
 Budget budget, int spentMinor, int remainingMinor, int percent, BudgetLevel level, MonthPhase monthPhase, Category? category, bool categoryHidden, int? daysLeft, int? perDayLeftMinor
});


$BudgetCopyWith<$Res> get budget;$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$BudgetStatusCopyWithImpl<$Res>
    implements $BudgetStatusCopyWith<$Res> {
  _$BudgetStatusCopyWithImpl(this._self, this._then);

  final BudgetStatus _self;
  final $Res Function(BudgetStatus) _then;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budget = null,Object? spentMinor = null,Object? remainingMinor = null,Object? percent = null,Object? level = null,Object? monthPhase = null,Object? category = freezed,Object? categoryHidden = null,Object? daysLeft = freezed,Object? perDayLeftMinor = freezed,}) {
  return _then(BudgetStatus(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,spentMinor: null == spentMinor ? _self.spentMinor : spentMinor // ignore: cast_nullable_to_non_nullable
as int,remainingMinor: null == remainingMinor ? _self.remainingMinor : remainingMinor // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as BudgetLevel,monthPhase: null == monthPhase ? _self.monthPhase : monthPhase // ignore: cast_nullable_to_non_nullable
as MonthPhase,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,categoryHidden: null == categoryHidden ? _self.categoryHidden : categoryHidden // ignore: cast_nullable_to_non_nullable
as bool,daysLeft: freezed == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int?,perDayLeftMinor: freezed == perDayLeftMinor ? _self.perDayLeftMinor : perDayLeftMinor // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetCopyWith<$Res> get budget {
  
  return $BudgetCopyWith<$Res>(_self.budget, (value) {
    return _then(_self.copyWith(budget: value));
  });
}/// Create a copy of BudgetStatus
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


/// Adds pattern-matching-related methods to [BudgetStatus].
extension BudgetStatusPatterns on BudgetStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetStatus value)  $default,){
final _that = this;
switch (_that) {
case _BudgetStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetStatus value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Budget budget,  int spentMinor,  int remainingMinor,  int percent,  BudgetLevel level,  MonthPhase monthPhase,  Category? category,  bool categoryHidden,  int? daysLeft,  int? perDayLeftMinor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
return $default(_that.budget,_that.spentMinor,_that.remainingMinor,_that.percent,_that.level,_that.monthPhase,_that.category,_that.categoryHidden,_that.daysLeft,_that.perDayLeftMinor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Budget budget,  int spentMinor,  int remainingMinor,  int percent,  BudgetLevel level,  MonthPhase monthPhase,  Category? category,  bool categoryHidden,  int? daysLeft,  int? perDayLeftMinor)  $default,) {final _that = this;
switch (_that) {
case _BudgetStatus():
return $default(_that.budget,_that.spentMinor,_that.remainingMinor,_that.percent,_that.level,_that.monthPhase,_that.category,_that.categoryHidden,_that.daysLeft,_that.perDayLeftMinor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Budget budget,  int spentMinor,  int remainingMinor,  int percent,  BudgetLevel level,  MonthPhase monthPhase,  Category? category,  bool categoryHidden,  int? daysLeft,  int? perDayLeftMinor)?  $default,) {final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
return $default(_that.budget,_that.spentMinor,_that.remainingMinor,_that.percent,_that.level,_that.monthPhase,_that.category,_that.categoryHidden,_that.daysLeft,_that.perDayLeftMinor);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetStatus implements BudgetStatus {
  const _BudgetStatus({required this.budget, required this.spentMinor, required this.remainingMinor, required this.percent, required this.level, required this.monthPhase, this.category, this.categoryHidden = false, this.daysLeft, this.perDayLeftMinor});
  

@override final  Budget budget;
@override final  int spentMinor;
/// limit − spent; negative when over budget.
@override final  int remainingMinor;
/// Whole percent of the limit used; may exceed 100.
@override final  int percent;
@override final  BudgetLevel level;
@override final  MonthPhase monthPhase;
/// Null for Overall, or when the category no longer exists.
@override final  Category? category;
/// The category is hidden or deleted (edge case: still shown, marked).
@override@JsonKey() final  bool categoryHidden;
/// Days from today to the month's last day, both included (current
/// month), or all days (future month); null for a past month.
@override final  int? daysLeft;
/// remaining ÷ daysLeft rounded down; null when nothing is left or for a
/// past month.
@override final  int? perDayLeftMinor;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetStatusCopyWith<_BudgetStatus> get copyWith => __$BudgetStatusCopyWithImpl<_BudgetStatus>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetStatus&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.spentMinor, spentMinor) || other.spentMinor == spentMinor)&&(identical(other.remainingMinor, remainingMinor) || other.remainingMinor == remainingMinor)&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.level, level) || other.level == level)&&(identical(other.monthPhase, monthPhase) || other.monthPhase == monthPhase)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryHidden, categoryHidden) || other.categoryHidden == categoryHidden)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.perDayLeftMinor, perDayLeftMinor) || other.perDayLeftMinor == perDayLeftMinor));
}


@override
int get hashCode {
    return Object.hash(runtimeType,budget,spentMinor,remainingMinor,percent,level,monthPhase,category,categoryHidden,daysLeft,perDayLeftMinor);
}

@override
String toString() {
    return 'BudgetStatus(budget: $budget, spentMinor: $spentMinor, remainingMinor: $remainingMinor, percent: $percent, level: $level, monthPhase: $monthPhase, category: $category, categoryHidden: $categoryHidden, daysLeft: $daysLeft, perDayLeftMinor: $perDayLeftMinor)';
}


}

/// @nodoc
abstract mixin class _$BudgetStatusCopyWith<$Res> implements $BudgetStatusCopyWith<$Res> {
  factory _$BudgetStatusCopyWith(_BudgetStatus value, $Res Function(_BudgetStatus) _then) = __$BudgetStatusCopyWithImpl;
@override @useResult
$Res call({
 Budget budget, int spentMinor, int remainingMinor, int percent, BudgetLevel level, MonthPhase monthPhase, Category? category, bool categoryHidden, int? daysLeft, int? perDayLeftMinor
});


@override $BudgetCopyWith<$Res> get budget;@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$BudgetStatusCopyWithImpl<$Res>
    implements _$BudgetStatusCopyWith<$Res> {
  __$BudgetStatusCopyWithImpl(this._self, this._then);

  final _BudgetStatus _self;
  final $Res Function(_BudgetStatus) _then;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budget = null,Object? spentMinor = null,Object? remainingMinor = null,Object? percent = null,Object? level = null,Object? monthPhase = null,Object? category = freezed,Object? categoryHidden = null,Object? daysLeft = freezed,Object? perDayLeftMinor = freezed,}) {
  return _then(_BudgetStatus(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,spentMinor: null == spentMinor ? _self.spentMinor : spentMinor // ignore: cast_nullable_to_non_nullable
as int,remainingMinor: null == remainingMinor ? _self.remainingMinor : remainingMinor // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as BudgetLevel,monthPhase: null == monthPhase ? _self.monthPhase : monthPhase // ignore: cast_nullable_to_non_nullable
as MonthPhase,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,categoryHidden: null == categoryHidden ? _self.categoryHidden : categoryHidden // ignore: cast_nullable_to_non_nullable
as bool,daysLeft: freezed == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int?,perDayLeftMinor: freezed == perDayLeftMinor ? _self.perDayLeftMinor : perDayLeftMinor // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetCopyWith<$Res> get budget {
  
  return $BudgetCopyWith<$Res>(_self.budget, (value) {
    return _then(_self.copyWith(budget: value));
  });
}/// Create a copy of BudgetStatus
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
mixin _$BudgetsOverview {

 String get monthKey; MonthPhase get monthPhase; BudgetStatus? get overall;/// Category budgets, highest percent first.
 List<BudgetStatus> get categories;/// Non-hidden expense categories with no budget this month.
 List<Category> get withoutBudget;
/// Create a copy of BudgetsOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetsOverviewCopyWith<BudgetsOverview> get copyWith => _$BudgetsOverviewCopyWithImpl<BudgetsOverview>(this as BudgetsOverview, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BudgetsOverview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetsOverview&&(identical(other.monthKey, _this.monthKey) || other.monthKey == _this.monthKey)&&(identical(other.monthPhase, _this.monthPhase) || other.monthPhase == _this.monthPhase)&&(identical(other.overall, _this.overall) || other.overall == _this.overall)&&const DeepCollectionEquality().equals(other.categories, _this.categories)&&const DeepCollectionEquality().equals(other.withoutBudget, _this.withoutBudget));
}


@override
int get hashCode {
  final _this = this as BudgetsOverview;
  return Object.hash(runtimeType,_this.monthKey,_this.monthPhase,_this.overall,const DeepCollectionEquality().hash(_this.categories),const DeepCollectionEquality().hash(_this.withoutBudget));
}

@override
String toString() {
  final _this = this as BudgetsOverview;
  return 'BudgetsOverview(monthKey: ${_this.monthKey}, monthPhase: ${_this.monthPhase}, overall: ${_this.overall}, categories: ${_this.categories}, withoutBudget: ${_this.withoutBudget})';
}


}

/// @nodoc
abstract mixin class $BudgetsOverviewCopyWith<$Res>  {
  factory $BudgetsOverviewCopyWith(BudgetsOverview value, $Res Function(BudgetsOverview) _then) = _$BudgetsOverviewCopyWithImpl;
@useResult
$Res call({
 String monthKey, MonthPhase monthPhase, BudgetStatus? overall, List<BudgetStatus> categories, List<Category> withoutBudget
});


$BudgetStatusCopyWith<$Res>? get overall;

}
/// @nodoc
class _$BudgetsOverviewCopyWithImpl<$Res>
    implements $BudgetsOverviewCopyWith<$Res> {
  _$BudgetsOverviewCopyWithImpl(this._self, this._then);

  final BudgetsOverview _self;
  final $Res Function(BudgetsOverview) _then;

/// Create a copy of BudgetsOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthKey = null,Object? monthPhase = null,Object? overall = freezed,Object? categories = null,Object? withoutBudget = null,}) {
  return _then(BudgetsOverview(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,monthPhase: null == monthPhase ? _self.monthPhase : monthPhase // ignore: cast_nullable_to_non_nullable
as MonthPhase,overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as BudgetStatus?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<BudgetStatus>,withoutBudget: null == withoutBudget ? _self.withoutBudget : withoutBudget // ignore: cast_nullable_to_non_nullable
as List<Category>,
  ));
}
/// Create a copy of BudgetsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $BudgetStatusCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetsOverview].
extension BudgetsOverviewPatterns on BudgetsOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetsOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetsOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetsOverview value)  $default,){
final _that = this;
switch (_that) {
case _BudgetsOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetsOverview value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetsOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String monthKey,  MonthPhase monthPhase,  BudgetStatus? overall,  List<BudgetStatus> categories,  List<Category> withoutBudget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetsOverview() when $default != null:
return $default(_that.monthKey,_that.monthPhase,_that.overall,_that.categories,_that.withoutBudget);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String monthKey,  MonthPhase monthPhase,  BudgetStatus? overall,  List<BudgetStatus> categories,  List<Category> withoutBudget)  $default,) {final _that = this;
switch (_that) {
case _BudgetsOverview():
return $default(_that.monthKey,_that.monthPhase,_that.overall,_that.categories,_that.withoutBudget);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String monthKey,  MonthPhase monthPhase,  BudgetStatus? overall,  List<BudgetStatus> categories,  List<Category> withoutBudget)?  $default,) {final _that = this;
switch (_that) {
case _BudgetsOverview() when $default != null:
return $default(_that.monthKey,_that.monthPhase,_that.overall,_that.categories,_that.withoutBudget);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetsOverview extends BudgetsOverview {
  const _BudgetsOverview({required this.monthKey, required this.monthPhase, this.overall,  List<BudgetStatus> categories = const <BudgetStatus>[],  List<Category> withoutBudget = const <Category>[]}): _categories = categories,_withoutBudget = withoutBudget,super._();
  

@override final  String monthKey;
@override final  MonthPhase monthPhase;
@override final  BudgetStatus? overall;
/// Category budgets, highest percent first.
 final  List<BudgetStatus> _categories;
/// Category budgets, highest percent first.
@override@JsonKey() List<BudgetStatus> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

/// Non-hidden expense categories with no budget this month.
 final  List<Category> _withoutBudget;
/// Non-hidden expense categories with no budget this month.
@override@JsonKey() List<Category> get withoutBudget {
  if (_withoutBudget is EqualUnmodifiableListView) return _withoutBudget;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_withoutBudget);
}


/// Create a copy of BudgetsOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetsOverviewCopyWith<_BudgetsOverview> get copyWith => __$BudgetsOverviewCopyWithImpl<_BudgetsOverview>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetsOverview&&(identical(other.monthKey, monthKey) || other.monthKey == monthKey)&&(identical(other.monthPhase, monthPhase) || other.monthPhase == monthPhase)&&(identical(other.overall, overall) || other.overall == overall)&&const DeepCollectionEquality().equals(other.categories, _categories)&&const DeepCollectionEquality().equals(other.withoutBudget, _withoutBudget));
}


@override
int get hashCode {
    return Object.hash(runtimeType,monthKey,monthPhase,overall,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_withoutBudget));
}

@override
String toString() {
    return 'BudgetsOverview(monthKey: $monthKey, monthPhase: $monthPhase, overall: $overall, categories: $categories, withoutBudget: $withoutBudget)';
}


}

/// @nodoc
abstract mixin class _$BudgetsOverviewCopyWith<$Res> implements $BudgetsOverviewCopyWith<$Res> {
  factory _$BudgetsOverviewCopyWith(_BudgetsOverview value, $Res Function(_BudgetsOverview) _then) = __$BudgetsOverviewCopyWithImpl;
@override @useResult
$Res call({
 String monthKey, MonthPhase monthPhase, BudgetStatus? overall, List<BudgetStatus> categories, List<Category> withoutBudget
});


@override $BudgetStatusCopyWith<$Res>? get overall;

}
/// @nodoc
class __$BudgetsOverviewCopyWithImpl<$Res>
    implements _$BudgetsOverviewCopyWith<$Res> {
  __$BudgetsOverviewCopyWithImpl(this._self, this._then);

  final _BudgetsOverview _self;
  final $Res Function(_BudgetsOverview) _then;

/// Create a copy of BudgetsOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthKey = null,Object? monthPhase = null,Object? overall = freezed,Object? categories = null,Object? withoutBudget = null,}) {
  return _then(_BudgetsOverview(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,monthPhase: null == monthPhase ? _self.monthPhase : monthPhase // ignore: cast_nullable_to_non_nullable
as MonthPhase,overall: freezed == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as BudgetStatus?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<BudgetStatus>,withoutBudget: null == withoutBudget ? _self._withoutBudget : withoutBudget // ignore: cast_nullable_to_non_nullable
as List<Category>,
  ));
}

/// Create a copy of BudgetsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<$Res>? get overall {
    if (_self.overall == null) {
    return null;
  }

  return $BudgetStatusCopyWith<$Res>(_self.overall!, (value) {
    return _then(_self.copyWith(overall: value));
  });
}
}

// dart format on
