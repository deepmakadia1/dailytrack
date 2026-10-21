// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 Greeting get greeting;/// Local midnight of today.
 DateTime get today;/// Visible modules, in the user's order (SET-06).
 List<TrackerModule> get modules;/// The + menu: every visible module's quick adds, in module order.
 List<QuickAddAction> get quickAdds;/// Empty once the Coming soon card is dismissed.
 List<ComingSoonModule> get comingSoon;/// Today's insight. Replaced alone by refreshes; keeps its previous value
/// while a new pick is computed.
 AsyncValue<InsightPick> get insight;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HomeState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.greeting, _this.greeting) || other.greeting == _this.greeting)&&(identical(other.today, _this.today) || other.today == _this.today)&&const DeepCollectionEquality().equals(other.modules, _this.modules)&&const DeepCollectionEquality().equals(other.quickAdds, _this.quickAdds)&&const DeepCollectionEquality().equals(other.comingSoon, _this.comingSoon)&&(identical(other.insight, _this.insight) || other.insight == _this.insight));
}


@override
int get hashCode {
  final _this = this as HomeState;
  return Object.hash(runtimeType,_this.greeting,_this.today,const DeepCollectionEquality().hash(_this.modules),const DeepCollectionEquality().hash(_this.quickAdds),const DeepCollectionEquality().hash(_this.comingSoon),_this.insight);
}

@override
String toString() {
  final _this = this as HomeState;
  return 'HomeState(greeting: ${_this.greeting}, today: ${_this.today}, modules: ${_this.modules}, quickAdds: ${_this.quickAdds}, comingSoon: ${_this.comingSoon}, insight: ${_this.insight})';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 Greeting greeting, DateTime today, List<TrackerModule> modules, List<QuickAddAction> quickAdds, List<ComingSoonModule> comingSoon, AsyncValue<InsightPick> insight
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? greeting = null,Object? today = null,Object? modules = null,Object? quickAdds = null,Object? comingSoon = null,Object? insight = null,}) {
  return _then(HomeState(
greeting: null == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as Greeting,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateTime,modules: null == modules ? _self.modules : modules // ignore: cast_nullable_to_non_nullable
as List<TrackerModule>,quickAdds: null == quickAdds ? _self.quickAdds : quickAdds // ignore: cast_nullable_to_non_nullable
as List<QuickAddAction>,comingSoon: null == comingSoon ? _self.comingSoon : comingSoon // ignore: cast_nullable_to_non_nullable
as List<ComingSoonModule>,insight: null == insight ? _self.insight : insight // ignore: cast_nullable_to_non_nullable
as AsyncValue<InsightPick>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Greeting greeting,  DateTime today,  List<TrackerModule> modules,  List<QuickAddAction> quickAdds,  List<ComingSoonModule> comingSoon,  AsyncValue<InsightPick> insight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.greeting,_that.today,_that.modules,_that.quickAdds,_that.comingSoon,_that.insight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Greeting greeting,  DateTime today,  List<TrackerModule> modules,  List<QuickAddAction> quickAdds,  List<ComingSoonModule> comingSoon,  AsyncValue<InsightPick> insight)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.greeting,_that.today,_that.modules,_that.quickAdds,_that.comingSoon,_that.insight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Greeting greeting,  DateTime today,  List<TrackerModule> modules,  List<QuickAddAction> quickAdds,  List<ComingSoonModule> comingSoon,  AsyncValue<InsightPick> insight)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.greeting,_that.today,_that.modules,_that.quickAdds,_that.comingSoon,_that.insight);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({required this.greeting, required this.today, required  List<TrackerModule> modules, required  List<QuickAddAction> quickAdds, required  List<ComingSoonModule> comingSoon, required this.insight}): _modules = modules,_quickAdds = quickAdds,_comingSoon = comingSoon;
  

@override final  Greeting greeting;
/// Local midnight of today.
@override final  DateTime today;
/// Visible modules, in the user's order (SET-06).
 final  List<TrackerModule> _modules;
/// Visible modules, in the user's order (SET-06).
@override List<TrackerModule> get modules {
  if (_modules is EqualUnmodifiableListView) return _modules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modules);
}

/// The + menu: every visible module's quick adds, in module order.
 final  List<QuickAddAction> _quickAdds;
/// The + menu: every visible module's quick adds, in module order.
@override List<QuickAddAction> get quickAdds {
  if (_quickAdds is EqualUnmodifiableListView) return _quickAdds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quickAdds);
}

/// Empty once the Coming soon card is dismissed.
 final  List<ComingSoonModule> _comingSoon;
/// Empty once the Coming soon card is dismissed.
@override List<ComingSoonModule> get comingSoon {
  if (_comingSoon is EqualUnmodifiableListView) return _comingSoon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comingSoon);
}

/// Today's insight. Replaced alone by refreshes; keeps its previous value
/// while a new pick is computed.
@override final  AsyncValue<InsightPick> insight;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.today, today) || other.today == today)&&const DeepCollectionEquality().equals(other.modules, _modules)&&const DeepCollectionEquality().equals(other.quickAdds, _quickAdds)&&const DeepCollectionEquality().equals(other.comingSoon, _comingSoon)&&(identical(other.insight, insight) || other.insight == insight));
}


@override
int get hashCode {
    return Object.hash(runtimeType,greeting,today,const DeepCollectionEquality().hash(_modules),const DeepCollectionEquality().hash(_quickAdds),const DeepCollectionEquality().hash(_comingSoon),insight);
}

@override
String toString() {
    return 'HomeState(greeting: $greeting, today: $today, modules: $modules, quickAdds: $quickAdds, comingSoon: $comingSoon, insight: $insight)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 Greeting greeting, DateTime today, List<TrackerModule> modules, List<QuickAddAction> quickAdds, List<ComingSoonModule> comingSoon, AsyncValue<InsightPick> insight
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? greeting = null,Object? today = null,Object? modules = null,Object? quickAdds = null,Object? comingSoon = null,Object? insight = null,}) {
  return _then(_HomeState(
greeting: null == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as Greeting,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateTime,modules: null == modules ? _self._modules : modules // ignore: cast_nullable_to_non_nullable
as List<TrackerModule>,quickAdds: null == quickAdds ? _self._quickAdds : quickAdds // ignore: cast_nullable_to_non_nullable
as List<QuickAddAction>,comingSoon: null == comingSoon ? _self._comingSoon : comingSoon // ignore: cast_nullable_to_non_nullable
as List<ComingSoonModule>,insight: null == insight ? _self.insight : insight // ignore: cast_nullable_to_non_nullable
as AsyncValue<InsightPick>,
  ));
}


}

// dart format on
