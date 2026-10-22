// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExportState {

/// The enabled modules' datasets, in module order.
 List<ExportDataset> get datasets; String get datasetId; Period get period; ExportFormat get format;/// Filter id → chosen option ids; empty means all.
 Map<String, Set<String>> get filters;/// Whether each format is unlocked, live from the feature gate.
 Map<ExportFormat, bool> get unlocked; int get firstDayOfWeek; bool get running;
/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportStateCopyWith<ExportState> get copyWith => _$ExportStateCopyWithImpl<ExportState>(this as ExportState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExportState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportState&&const DeepCollectionEquality().equals(other.datasets, _this.datasets)&&(identical(other.datasetId, _this.datasetId) || other.datasetId == _this.datasetId)&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.format, _this.format) || other.format == _this.format)&&const DeepCollectionEquality().equals(other.filters, _this.filters)&&const DeepCollectionEquality().equals(other.unlocked, _this.unlocked)&&(identical(other.firstDayOfWeek, _this.firstDayOfWeek) || other.firstDayOfWeek == _this.firstDayOfWeek)&&(identical(other.running, _this.running) || other.running == _this.running));
}


@override
int get hashCode {
  final _this = this as ExportState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.datasets),_this.datasetId,_this.period,_this.format,const DeepCollectionEquality().hash(_this.filters),const DeepCollectionEquality().hash(_this.unlocked),_this.firstDayOfWeek,_this.running);
}

@override
String toString() {
  final _this = this as ExportState;
  return 'ExportState(datasets: ${_this.datasets}, datasetId: ${_this.datasetId}, period: ${_this.period}, format: ${_this.format}, filters: ${_this.filters}, unlocked: ${_this.unlocked}, firstDayOfWeek: ${_this.firstDayOfWeek}, running: ${_this.running})';
}


}

/// @nodoc
abstract mixin class $ExportStateCopyWith<$Res>  {
  factory $ExportStateCopyWith(ExportState value, $Res Function(ExportState) _then) = _$ExportStateCopyWithImpl;
@useResult
$Res call({
 List<ExportDataset> datasets, String datasetId, Period period, ExportFormat format, Map<String, Set<String>> filters, Map<ExportFormat, bool> unlocked, int firstDayOfWeek, bool running
});




}
/// @nodoc
class _$ExportStateCopyWithImpl<$Res>
    implements $ExportStateCopyWith<$Res> {
  _$ExportStateCopyWithImpl(this._self, this._then);

  final ExportState _self;
  final $Res Function(ExportState) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? datasets = null,Object? datasetId = null,Object? period = null,Object? format = null,Object? filters = null,Object? unlocked = null,Object? firstDayOfWeek = null,Object? running = null,}) {
  return _then(ExportState(
datasets: null == datasets ? _self.datasets : datasets // ignore: cast_nullable_to_non_nullable
as List<ExportDataset>,datasetId: null == datasetId ? _self.datasetId : datasetId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, Set<String>>,unlocked: null == unlocked ? _self.unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as Map<ExportFormat, bool>,firstDayOfWeek: null == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportState].
extension ExportStatePatterns on ExportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportState value)  $default,){
final _that = this;
switch (_that) {
case _ExportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportState value)?  $default,){
final _that = this;
switch (_that) {
case _ExportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ExportDataset> datasets,  String datasetId,  Period period,  ExportFormat format,  Map<String, Set<String>> filters,  Map<ExportFormat, bool> unlocked,  int firstDayOfWeek,  bool running)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportState() when $default != null:
return $default(_that.datasets,_that.datasetId,_that.period,_that.format,_that.filters,_that.unlocked,_that.firstDayOfWeek,_that.running);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ExportDataset> datasets,  String datasetId,  Period period,  ExportFormat format,  Map<String, Set<String>> filters,  Map<ExportFormat, bool> unlocked,  int firstDayOfWeek,  bool running)  $default,) {final _that = this;
switch (_that) {
case _ExportState():
return $default(_that.datasets,_that.datasetId,_that.period,_that.format,_that.filters,_that.unlocked,_that.firstDayOfWeek,_that.running);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ExportDataset> datasets,  String datasetId,  Period period,  ExportFormat format,  Map<String, Set<String>> filters,  Map<ExportFormat, bool> unlocked,  int firstDayOfWeek,  bool running)?  $default,) {final _that = this;
switch (_that) {
case _ExportState() when $default != null:
return $default(_that.datasets,_that.datasetId,_that.period,_that.format,_that.filters,_that.unlocked,_that.firstDayOfWeek,_that.running);case _:
  return null;

}
}

}

/// @nodoc


class _ExportState extends ExportState {
  const _ExportState({required  List<ExportDataset> datasets, required this.datasetId, required this.period, required this.format, required  Map<String, Set<String>> filters, required  Map<ExportFormat, bool> unlocked, required this.firstDayOfWeek, this.running = false}): _datasets = datasets,_filters = filters,_unlocked = unlocked,super._();
  

/// The enabled modules' datasets, in module order.
 final  List<ExportDataset> _datasets;
/// The enabled modules' datasets, in module order.
@override List<ExportDataset> get datasets {
  if (_datasets is EqualUnmodifiableListView) return _datasets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_datasets);
}

@override final  String datasetId;
@override final  Period period;
@override final  ExportFormat format;
/// Filter id → chosen option ids; empty means all.
 final  Map<String, Set<String>> _filters;
/// Filter id → chosen option ids; empty means all.
@override Map<String, Set<String>> get filters {
  if (_filters is EqualUnmodifiableMapView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_filters);
}

/// Whether each format is unlocked, live from the feature gate.
 final  Map<ExportFormat, bool> _unlocked;
/// Whether each format is unlocked, live from the feature gate.
@override Map<ExportFormat, bool> get unlocked {
  if (_unlocked is EqualUnmodifiableMapView) return _unlocked;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unlocked);
}

@override final  int firstDayOfWeek;
@override@JsonKey() final  bool running;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportStateCopyWith<_ExportState> get copyWith => __$ExportStateCopyWithImpl<_ExportState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportState&&const DeepCollectionEquality().equals(other.datasets, _datasets)&&(identical(other.datasetId, datasetId) || other.datasetId == datasetId)&&(identical(other.period, period) || other.period == period)&&(identical(other.format, format) || other.format == format)&&const DeepCollectionEquality().equals(other.filters, _filters)&&const DeepCollectionEquality().equals(other.unlocked, _unlocked)&&(identical(other.firstDayOfWeek, firstDayOfWeek) || other.firstDayOfWeek == firstDayOfWeek)&&(identical(other.running, running) || other.running == running));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_datasets),datasetId,period,format,const DeepCollectionEquality().hash(_filters),const DeepCollectionEquality().hash(_unlocked),firstDayOfWeek,running);
}

@override
String toString() {
    return 'ExportState(datasets: $datasets, datasetId: $datasetId, period: $period, format: $format, filters: $filters, unlocked: $unlocked, firstDayOfWeek: $firstDayOfWeek, running: $running)';
}


}

/// @nodoc
abstract mixin class _$ExportStateCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory _$ExportStateCopyWith(_ExportState value, $Res Function(_ExportState) _then) = __$ExportStateCopyWithImpl;
@override @useResult
$Res call({
 List<ExportDataset> datasets, String datasetId, Period period, ExportFormat format, Map<String, Set<String>> filters, Map<ExportFormat, bool> unlocked, int firstDayOfWeek, bool running
});




}
/// @nodoc
class __$ExportStateCopyWithImpl<$Res>
    implements _$ExportStateCopyWith<$Res> {
  __$ExportStateCopyWithImpl(this._self, this._then);

  final _ExportState _self;
  final $Res Function(_ExportState) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? datasets = null,Object? datasetId = null,Object? period = null,Object? format = null,Object? filters = null,Object? unlocked = null,Object? firstDayOfWeek = null,Object? running = null,}) {
  return _then(_ExportState(
datasets: null == datasets ? _self._datasets : datasets // ignore: cast_nullable_to_non_nullable
as List<ExportDataset>,datasetId: null == datasetId ? _self.datasetId : datasetId // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as Period,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormat,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, Set<String>>,unlocked: null == unlocked ? _self._unlocked : unlocked // ignore: cast_nullable_to_non_nullable
as Map<ExportFormat, bool>,firstDayOfWeek: null == firstDayOfWeek ? _self.firstDayOfWeek : firstDayOfWeek // ignore: cast_nullable_to_non_nullable
as int,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
