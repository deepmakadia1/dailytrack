// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accounts_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountsData {

/// Sum of non-archived balances.
 int get totalMinor; List<AccountWithBalance> get active; List<AccountWithBalance> get archived;
/// Create a copy of AccountsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountsDataCopyWith<AccountsData> get copyWith => _$AccountsDataCopyWithImpl<AccountsData>(this as AccountsData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountsData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountsData&&(identical(other.totalMinor, _this.totalMinor) || other.totalMinor == _this.totalMinor)&&const DeepCollectionEquality().equals(other.active, _this.active)&&const DeepCollectionEquality().equals(other.archived, _this.archived));
}


@override
int get hashCode {
  final _this = this as AccountsData;
  return Object.hash(runtimeType,_this.totalMinor,const DeepCollectionEquality().hash(_this.active),const DeepCollectionEquality().hash(_this.archived));
}

@override
String toString() {
  final _this = this as AccountsData;
  return 'AccountsData(totalMinor: ${_this.totalMinor}, active: ${_this.active}, archived: ${_this.archived})';
}


}

/// @nodoc
abstract mixin class $AccountsDataCopyWith<$Res>  {
  factory $AccountsDataCopyWith(AccountsData value, $Res Function(AccountsData) _then) = _$AccountsDataCopyWithImpl;
@useResult
$Res call({
 int totalMinor, List<AccountWithBalance> active, List<AccountWithBalance> archived
});




}
/// @nodoc
class _$AccountsDataCopyWithImpl<$Res>
    implements $AccountsDataCopyWith<$Res> {
  _$AccountsDataCopyWithImpl(this._self, this._then);

  final AccountsData _self;
  final $Res Function(AccountsData) _then;

/// Create a copy of AccountsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalMinor = null,Object? active = null,Object? archived = null,}) {
  return _then(AccountsData(
totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as List<AccountWithBalance>,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as List<AccountWithBalance>,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountsData].
extension AccountsDataPatterns on AccountsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountsData value)  $default,){
final _that = this;
switch (_that) {
case _AccountsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountsData value)?  $default,){
final _that = this;
switch (_that) {
case _AccountsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalMinor,  List<AccountWithBalance> active,  List<AccountWithBalance> archived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountsData() when $default != null:
return $default(_that.totalMinor,_that.active,_that.archived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalMinor,  List<AccountWithBalance> active,  List<AccountWithBalance> archived)  $default,) {final _that = this;
switch (_that) {
case _AccountsData():
return $default(_that.totalMinor,_that.active,_that.archived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalMinor,  List<AccountWithBalance> active,  List<AccountWithBalance> archived)?  $default,) {final _that = this;
switch (_that) {
case _AccountsData() when $default != null:
return $default(_that.totalMinor,_that.active,_that.archived);case _:
  return null;

}
}

}

/// @nodoc


class _AccountsData extends AccountsData {
  const _AccountsData({required this.totalMinor, required  List<AccountWithBalance> active, required  List<AccountWithBalance> archived}): _active = active,_archived = archived,super._();
  

/// Sum of non-archived balances.
@override final  int totalMinor;
 final  List<AccountWithBalance> _active;
@override List<AccountWithBalance> get active {
  if (_active is EqualUnmodifiableListView) return _active;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_active);
}

 final  List<AccountWithBalance> _archived;
@override List<AccountWithBalance> get archived {
  if (_archived is EqualUnmodifiableListView) return _archived;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_archived);
}


/// Create a copy of AccountsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountsDataCopyWith<_AccountsData> get copyWith => __$AccountsDataCopyWithImpl<_AccountsData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountsData&&(identical(other.totalMinor, totalMinor) || other.totalMinor == totalMinor)&&const DeepCollectionEquality().equals(other.active, _active)&&const DeepCollectionEquality().equals(other.archived, _archived));
}


@override
int get hashCode {
    return Object.hash(runtimeType,totalMinor,const DeepCollectionEquality().hash(_active),const DeepCollectionEquality().hash(_archived));
}

@override
String toString() {
    return 'AccountsData(totalMinor: $totalMinor, active: $active, archived: $archived)';
}


}

/// @nodoc
abstract mixin class _$AccountsDataCopyWith<$Res> implements $AccountsDataCopyWith<$Res> {
  factory _$AccountsDataCopyWith(_AccountsData value, $Res Function(_AccountsData) _then) = __$AccountsDataCopyWithImpl;
@override @useResult
$Res call({
 int totalMinor, List<AccountWithBalance> active, List<AccountWithBalance> archived
});




}
/// @nodoc
class __$AccountsDataCopyWithImpl<$Res>
    implements _$AccountsDataCopyWith<$Res> {
  __$AccountsDataCopyWithImpl(this._self, this._then);

  final _AccountsData _self;
  final $Res Function(_AccountsData) _then;

/// Create a copy of AccountsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalMinor = null,Object? active = null,Object? archived = null,}) {
  return _then(_AccountsData(
totalMinor: null == totalMinor ? _self.totalMinor : totalMinor // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self._active : active // ignore: cast_nullable_to_non_nullable
as List<AccountWithBalance>,archived: null == archived ? _self._archived : archived // ignore: cast_nullable_to_non_nullable
as List<AccountWithBalance>,
  ));
}


}

// dart format on
