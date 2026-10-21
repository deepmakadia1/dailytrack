// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reports_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReportData {

/// Any transaction in the period, transfers included (else the empty
/// state shows).
 bool get hasTransactions; OverviewVm get overview; DonutVm get donut; BarsVm get bars;/// Trends tab only: needs the previous period's ledger.
 TrendVm? get trend;
/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportDataCopyWith<ReportData> get copyWith => _$ReportDataCopyWithImpl<ReportData>(this as ReportData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReportData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportData&&(identical(other.hasTransactions, _this.hasTransactions) || other.hasTransactions == _this.hasTransactions)&&(identical(other.overview, _this.overview) || other.overview == _this.overview)&&(identical(other.donut, _this.donut) || other.donut == _this.donut)&&(identical(other.bars, _this.bars) || other.bars == _this.bars)&&(identical(other.trend, _this.trend) || other.trend == _this.trend));
}


@override
int get hashCode {
  final _this = this as ReportData;
  return Object.hash(runtimeType,_this.hasTransactions,_this.overview,_this.donut,_this.bars,_this.trend);
}

@override
String toString() {
  final _this = this as ReportData;
  return 'ReportData(hasTransactions: ${_this.hasTransactions}, overview: ${_this.overview}, donut: ${_this.donut}, bars: ${_this.bars}, trend: ${_this.trend})';
}


}

/// @nodoc
abstract mixin class $ReportDataCopyWith<$Res>  {
  factory $ReportDataCopyWith(ReportData value, $Res Function(ReportData) _then) = _$ReportDataCopyWithImpl;
@useResult
$Res call({
 bool hasTransactions, OverviewVm overview, DonutVm donut, BarsVm bars, TrendVm? trend
});


$OverviewVmCopyWith<$Res> get overview;$DonutVmCopyWith<$Res> get donut;$BarsVmCopyWith<$Res> get bars;$TrendVmCopyWith<$Res>? get trend;

}
/// @nodoc
class _$ReportDataCopyWithImpl<$Res>
    implements $ReportDataCopyWith<$Res> {
  _$ReportDataCopyWithImpl(this._self, this._then);

  final ReportData _self;
  final $Res Function(ReportData) _then;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasTransactions = null,Object? overview = null,Object? donut = null,Object? bars = null,Object? trend = freezed,}) {
  return _then(ReportData(
hasTransactions: null == hasTransactions ? _self.hasTransactions : hasTransactions // ignore: cast_nullable_to_non_nullable
as bool,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as OverviewVm,donut: null == donut ? _self.donut : donut // ignore: cast_nullable_to_non_nullable
as DonutVm,bars: null == bars ? _self.bars : bars // ignore: cast_nullable_to_non_nullable
as BarsVm,trend: freezed == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as TrendVm?,
  ));
}
/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverviewVmCopyWith<$Res> get overview {
  
  return $OverviewVmCopyWith<$Res>(_self.overview, (value) {
    return _then(_self.copyWith(overview: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DonutVmCopyWith<$Res> get donut {
  
  return $DonutVmCopyWith<$Res>(_self.donut, (value) {
    return _then(_self.copyWith(donut: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BarsVmCopyWith<$Res> get bars {
  
  return $BarsVmCopyWith<$Res>(_self.bars, (value) {
    return _then(_self.copyWith(bars: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrendVmCopyWith<$Res>? get trend {
    if (_self.trend == null) {
    return null;
  }

  return $TrendVmCopyWith<$Res>(_self.trend!, (value) {
    return _then(_self.copyWith(trend: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReportData].
extension ReportDataPatterns on ReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportData value)  $default,){
final _that = this;
switch (_that) {
case _ReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportData value)?  $default,){
final _that = this;
switch (_that) {
case _ReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasTransactions,  OverviewVm overview,  DonutVm donut,  BarsVm bars,  TrendVm? trend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportData() when $default != null:
return $default(_that.hasTransactions,_that.overview,_that.donut,_that.bars,_that.trend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasTransactions,  OverviewVm overview,  DonutVm donut,  BarsVm bars,  TrendVm? trend)  $default,) {final _that = this;
switch (_that) {
case _ReportData():
return $default(_that.hasTransactions,_that.overview,_that.donut,_that.bars,_that.trend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasTransactions,  OverviewVm overview,  DonutVm donut,  BarsVm bars,  TrendVm? trend)?  $default,) {final _that = this;
switch (_that) {
case _ReportData() when $default != null:
return $default(_that.hasTransactions,_that.overview,_that.donut,_that.bars,_that.trend);case _:
  return null;

}
}

}

/// @nodoc


class _ReportData implements ReportData {
  const _ReportData({required this.hasTransactions, required this.overview, required this.donut, required this.bars, this.trend});
  

/// Any transaction in the period, transfers included (else the empty
/// state shows).
@override final  bool hasTransactions;
@override final  OverviewVm overview;
@override final  DonutVm donut;
@override final  BarsVm bars;
/// Trends tab only: needs the previous period's ledger.
@override final  TrendVm? trend;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportDataCopyWith<_ReportData> get copyWith => __$ReportDataCopyWithImpl<_ReportData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportData&&(identical(other.hasTransactions, hasTransactions) || other.hasTransactions == hasTransactions)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.donut, donut) || other.donut == donut)&&(identical(other.bars, bars) || other.bars == bars)&&(identical(other.trend, trend) || other.trend == trend));
}


@override
int get hashCode {
    return Object.hash(runtimeType,hasTransactions,overview,donut,bars,trend);
}

@override
String toString() {
    return 'ReportData(hasTransactions: $hasTransactions, overview: $overview, donut: $donut, bars: $bars, trend: $trend)';
}


}

/// @nodoc
abstract mixin class _$ReportDataCopyWith<$Res> implements $ReportDataCopyWith<$Res> {
  factory _$ReportDataCopyWith(_ReportData value, $Res Function(_ReportData) _then) = __$ReportDataCopyWithImpl;
@override @useResult
$Res call({
 bool hasTransactions, OverviewVm overview, DonutVm donut, BarsVm bars, TrendVm? trend
});


@override $OverviewVmCopyWith<$Res> get overview;@override $DonutVmCopyWith<$Res> get donut;@override $BarsVmCopyWith<$Res> get bars;@override $TrendVmCopyWith<$Res>? get trend;

}
/// @nodoc
class __$ReportDataCopyWithImpl<$Res>
    implements _$ReportDataCopyWith<$Res> {
  __$ReportDataCopyWithImpl(this._self, this._then);

  final _ReportData _self;
  final $Res Function(_ReportData) _then;

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasTransactions = null,Object? overview = null,Object? donut = null,Object? bars = null,Object? trend = freezed,}) {
  return _then(_ReportData(
hasTransactions: null == hasTransactions ? _self.hasTransactions : hasTransactions // ignore: cast_nullable_to_non_nullable
as bool,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as OverviewVm,donut: null == donut ? _self.donut : donut // ignore: cast_nullable_to_non_nullable
as DonutVm,bars: null == bars ? _self.bars : bars // ignore: cast_nullable_to_non_nullable
as BarsVm,trend: freezed == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as TrendVm?,
  ));
}

/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverviewVmCopyWith<$Res> get overview {
  
  return $OverviewVmCopyWith<$Res>(_self.overview, (value) {
    return _then(_self.copyWith(overview: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DonutVmCopyWith<$Res> get donut {
  
  return $DonutVmCopyWith<$Res>(_self.donut, (value) {
    return _then(_self.copyWith(donut: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BarsVmCopyWith<$Res> get bars {
  
  return $BarsVmCopyWith<$Res>(_self.bars, (value) {
    return _then(_self.copyWith(bars: value));
  });
}/// Create a copy of ReportData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrendVmCopyWith<$Res>? get trend {
    if (_self.trend == null) {
    return null;
  }

  return $TrendVmCopyWith<$Res>(_self.trend!, (value) {
    return _then(_self.copyWith(trend: value));
  });
}
}

/// @nodoc
mixin _$ReportsState {

 Period get period; ReportTab get tab;/// From `FeatureGate.watch(advancedReports)`.
 bool get advancedUnlocked;/// The current tab and period need the unlock and it is missing.
 bool get locked;/// The selected donut slice key (a category id or "Other").
 String? get selectedKey;/// The selected slice's transactions, newest first.
 List<TransactionView> get selected; AsyncValue<ReportData> get data;
/// Create a copy of ReportsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportsStateCopyWith<ReportsState> get copyWith => _$ReportsStateCopyWithImpl<ReportsState>(this as ReportsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReportsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportsState&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.tab, _this.tab) || other.tab == _this.tab)&&(identical(other.advancedUnlocked, _this.advancedUnlocked) || other.advancedUnlocked == _this.advancedUnlocked)&&(identical(other.locked, _this.locked) || other.locked == _this.locked)&&(identical(other.selectedKey, _this.selectedKey) || other.selectedKey == _this.selectedKey)&&const DeepCollectionEquality().equals(other.selected, _this.selected)&&(identical(other.data, _this.data) || other.data == _this.data));
}


@override
int get hashCode {
  final _this = this as ReportsState;
  return Object.hash(runtimeType,_this.period,_this.tab,_this.advancedUnlocked,_this.locked,_this.selectedKey,const DeepCollectionEquality().hash(_this.selected),_this.data);
}

@override
String toString() {
  final _this = this as ReportsState;
  return 'ReportsState(period: ${_this.period}, tab: ${_this.tab}, advancedUnlocked: ${_this.advancedUnlocked}, locked: ${_this.locked}, selectedKey: ${_this.selectedKey}, selected: ${_this.selected}, data: ${_this.data})';
}


}

/// @nodoc
abstract mixin class $ReportsStateCopyWith<$Res>  {
  factory $ReportsStateCopyWith(ReportsState value, $Res Function(ReportsState) _then) = _$ReportsStateCopyWithImpl;
@useResult
$Res call({
 Period period, ReportTab tab, bool advancedUnlocked, bool locked, String? selectedKey, List<TransactionView> selected, AsyncValue<ReportData> data
});




}
/// @nodoc
class _$ReportsStateCopyWithImpl<$Res>
    implements $ReportsStateCopyWith<$Res> {
  _$ReportsStateCopyWithImpl(this._self, this._then);

  final ReportsState _self;
  final $Res Function(ReportsState) _then;

/// Create a copy of ReportsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? tab = null,Object? advancedUnlocked = null,Object? locked = null,Object? selectedKey = freezed,Object? selected = null,Object? data = null,}) {
  return _then(ReportsState(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as ReportTab,advancedUnlocked: null == advancedUnlocked ? _self.advancedUnlocked : advancedUnlocked // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,selectedKey: freezed == selectedKey ? _self.selectedKey : selectedKey // ignore: cast_nullable_to_non_nullable
as String?,selected: null == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as List<TransactionView>,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AsyncValue<ReportData>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportsState].
extension ReportsStatePatterns on ReportsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportsState value)  $default,){
final _that = this;
switch (_that) {
case _ReportsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportsState value)?  $default,){
final _that = this;
switch (_that) {
case _ReportsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Period period,  ReportTab tab,  bool advancedUnlocked,  bool locked,  String? selectedKey,  List<TransactionView> selected,  AsyncValue<ReportData> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportsState() when $default != null:
return $default(_that.period,_that.tab,_that.advancedUnlocked,_that.locked,_that.selectedKey,_that.selected,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Period period,  ReportTab tab,  bool advancedUnlocked,  bool locked,  String? selectedKey,  List<TransactionView> selected,  AsyncValue<ReportData> data)  $default,) {final _that = this;
switch (_that) {
case _ReportsState():
return $default(_that.period,_that.tab,_that.advancedUnlocked,_that.locked,_that.selectedKey,_that.selected,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Period period,  ReportTab tab,  bool advancedUnlocked,  bool locked,  String? selectedKey,  List<TransactionView> selected,  AsyncValue<ReportData> data)?  $default,) {final _that = this;
switch (_that) {
case _ReportsState() when $default != null:
return $default(_that.period,_that.tab,_that.advancedUnlocked,_that.locked,_that.selectedKey,_that.selected,_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _ReportsState extends ReportsState {
  const _ReportsState({required this.period, this.tab = ReportTab.overview, this.advancedUnlocked = false, this.locked = false, this.selectedKey,  List<TransactionView> selected = const <TransactionView>[], this.data = const AsyncLoading<ReportData>()}): _selected = selected,super._();
  

@override final  Period period;
@override@JsonKey() final  ReportTab tab;
/// From `FeatureGate.watch(advancedReports)`.
@override@JsonKey() final  bool advancedUnlocked;
/// The current tab and period need the unlock and it is missing.
@override@JsonKey() final  bool locked;
/// The selected donut slice key (a category id or "Other").
@override final  String? selectedKey;
/// The selected slice's transactions, newest first.
 final  List<TransactionView> _selected;
/// The selected slice's transactions, newest first.
@override@JsonKey() List<TransactionView> get selected {
  if (_selected is EqualUnmodifiableListView) return _selected;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selected);
}

@override@JsonKey() final  AsyncValue<ReportData> data;

/// Create a copy of ReportsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportsStateCopyWith<_ReportsState> get copyWith => __$ReportsStateCopyWithImpl<_ReportsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportsState&&(identical(other.period, period) || other.period == period)&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.advancedUnlocked, advancedUnlocked) || other.advancedUnlocked == advancedUnlocked)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.selectedKey, selectedKey) || other.selectedKey == selectedKey)&&const DeepCollectionEquality().equals(other.selected, _selected)&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode {
    return Object.hash(runtimeType,period,tab,advancedUnlocked,locked,selectedKey,const DeepCollectionEquality().hash(_selected),data);
}

@override
String toString() {
    return 'ReportsState(period: $period, tab: $tab, advancedUnlocked: $advancedUnlocked, locked: $locked, selectedKey: $selectedKey, selected: $selected, data: $data)';
}


}

/// @nodoc
abstract mixin class _$ReportsStateCopyWith<$Res> implements $ReportsStateCopyWith<$Res> {
  factory _$ReportsStateCopyWith(_ReportsState value, $Res Function(_ReportsState) _then) = __$ReportsStateCopyWithImpl;
@override @useResult
$Res call({
 Period period, ReportTab tab, bool advancedUnlocked, bool locked, String? selectedKey, List<TransactionView> selected, AsyncValue<ReportData> data
});




}
/// @nodoc
class __$ReportsStateCopyWithImpl<$Res>
    implements _$ReportsStateCopyWith<$Res> {
  __$ReportsStateCopyWithImpl(this._self, this._then);

  final _ReportsState _self;
  final $Res Function(_ReportsState) _then;

/// Create a copy of ReportsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? tab = null,Object? advancedUnlocked = null,Object? locked = null,Object? selectedKey = freezed,Object? selected = null,Object? data = null,}) {
  return _then(_ReportsState(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as ReportTab,advancedUnlocked: null == advancedUnlocked ? _self.advancedUnlocked : advancedUnlocked // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,selectedKey: freezed == selectedKey ? _self.selectedKey : selectedKey // ignore: cast_nullable_to_non_nullable
as String?,selected: null == selected ? _self._selected : selected // ignore: cast_nullable_to_non_nullable
as List<TransactionView>,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as AsyncValue<ReportData>,
  ));
}


}

// dart format on
