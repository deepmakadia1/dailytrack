// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Budget {

 String get id;/// Local month `yyyy-MM`.
 String get monthKey; int get limitMinor;/// "Repeat every month" (rollover, research R7).
 bool get rollover;/// UTC.
 DateTime get createdAt; DateTime get updatedAt;/// Null = Overall.
 String? get categoryId;/// UTC moments the 80% and 100% alerts were sent.
 DateTime? get alert80SentAt; DateTime? get alert100SentAt;
/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetCopyWith<Budget> get copyWith => _$BudgetCopyWithImpl<Budget>(this as Budget, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Budget;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Budget&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.monthKey, _this.monthKey) || other.monthKey == _this.monthKey)&&(identical(other.limitMinor, _this.limitMinor) || other.limitMinor == _this.limitMinor)&&(identical(other.rollover, _this.rollover) || other.rollover == _this.rollover)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.alert80SentAt, _this.alert80SentAt) || other.alert80SentAt == _this.alert80SentAt)&&(identical(other.alert100SentAt, _this.alert100SentAt) || other.alert100SentAt == _this.alert100SentAt));
}


@override
int get hashCode {
  final _this = this as Budget;
  return Object.hash(runtimeType,_this.id,_this.monthKey,_this.limitMinor,_this.rollover,_this.createdAt,_this.updatedAt,_this.categoryId,_this.alert80SentAt,_this.alert100SentAt);
}

@override
String toString() {
  final _this = this as Budget;
  return 'Budget(id: ${_this.id}, monthKey: ${_this.monthKey}, limitMinor: ${_this.limitMinor}, rollover: ${_this.rollover}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, categoryId: ${_this.categoryId}, alert80SentAt: ${_this.alert80SentAt}, alert100SentAt: ${_this.alert100SentAt})';
}


}

/// @nodoc
abstract mixin class $BudgetCopyWith<$Res>  {
  factory $BudgetCopyWith(Budget value, $Res Function(Budget) _then) = _$BudgetCopyWithImpl;
@useResult
$Res call({
 String id, String monthKey, int limitMinor, bool rollover, DateTime createdAt, DateTime updatedAt, String? categoryId, DateTime? alert80SentAt, DateTime? alert100SentAt
});




}
/// @nodoc
class _$BudgetCopyWithImpl<$Res>
    implements $BudgetCopyWith<$Res> {
  _$BudgetCopyWithImpl(this._self, this._then);

  final Budget _self;
  final $Res Function(Budget) _then;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? monthKey = null,Object? limitMinor = null,Object? rollover = null,Object? createdAt = null,Object? updatedAt = null,Object? categoryId = freezed,Object? alert80SentAt = freezed,Object? alert100SentAt = freezed,}) {
  return _then(Budget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,limitMinor: null == limitMinor ? _self.limitMinor : limitMinor // ignore: cast_nullable_to_non_nullable
as int,rollover: null == rollover ? _self.rollover : rollover // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,alert80SentAt: freezed == alert80SentAt ? _self.alert80SentAt : alert80SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,alert100SentAt: freezed == alert100SentAt ? _self.alert100SentAt : alert100SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Budget].
extension BudgetPatterns on Budget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Budget value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Budget() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Budget value)  $default,){
final _that = this;
switch (_that) {
case _Budget():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Budget value)?  $default,){
final _that = this;
switch (_that) {
case _Budget() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String monthKey,  int limitMinor,  bool rollover,  DateTime createdAt,  DateTime updatedAt,  String? categoryId,  DateTime? alert80SentAt,  DateTime? alert100SentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Budget() when $default != null:
return $default(_that.id,_that.monthKey,_that.limitMinor,_that.rollover,_that.createdAt,_that.updatedAt,_that.categoryId,_that.alert80SentAt,_that.alert100SentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String monthKey,  int limitMinor,  bool rollover,  DateTime createdAt,  DateTime updatedAt,  String? categoryId,  DateTime? alert80SentAt,  DateTime? alert100SentAt)  $default,) {final _that = this;
switch (_that) {
case _Budget():
return $default(_that.id,_that.monthKey,_that.limitMinor,_that.rollover,_that.createdAt,_that.updatedAt,_that.categoryId,_that.alert80SentAt,_that.alert100SentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String monthKey,  int limitMinor,  bool rollover,  DateTime createdAt,  DateTime updatedAt,  String? categoryId,  DateTime? alert80SentAt,  DateTime? alert100SentAt)?  $default,) {final _that = this;
switch (_that) {
case _Budget() when $default != null:
return $default(_that.id,_that.monthKey,_that.limitMinor,_that.rollover,_that.createdAt,_that.updatedAt,_that.categoryId,_that.alert80SentAt,_that.alert100SentAt);case _:
  return null;

}
}

}

/// @nodoc


class _Budget extends Budget {
  const _Budget({required this.id, required this.monthKey, required this.limitMinor, required this.rollover, required this.createdAt, required this.updatedAt, this.categoryId, this.alert80SentAt, this.alert100SentAt}): super._();
  

@override final  String id;
/// Local month `yyyy-MM`.
@override final  String monthKey;
@override final  int limitMinor;
/// "Repeat every month" (rollover, research R7).
@override final  bool rollover;
/// UTC.
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
/// Null = Overall.
@override final  String? categoryId;
/// UTC moments the 80% and 100% alerts were sent.
@override final  DateTime? alert80SentAt;
@override final  DateTime? alert100SentAt;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetCopyWith<_Budget> get copyWith => __$BudgetCopyWithImpl<_Budget>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Budget&&(identical(other.id, id) || other.id == id)&&(identical(other.monthKey, monthKey) || other.monthKey == monthKey)&&(identical(other.limitMinor, limitMinor) || other.limitMinor == limitMinor)&&(identical(other.rollover, rollover) || other.rollover == rollover)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.alert80SentAt, alert80SentAt) || other.alert80SentAt == alert80SentAt)&&(identical(other.alert100SentAt, alert100SentAt) || other.alert100SentAt == alert100SentAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,monthKey,limitMinor,rollover,createdAt,updatedAt,categoryId,alert80SentAt,alert100SentAt);
}

@override
String toString() {
    return 'Budget(id: $id, monthKey: $monthKey, limitMinor: $limitMinor, rollover: $rollover, createdAt: $createdAt, updatedAt: $updatedAt, categoryId: $categoryId, alert80SentAt: $alert80SentAt, alert100SentAt: $alert100SentAt)';
}


}

/// @nodoc
abstract mixin class _$BudgetCopyWith<$Res> implements $BudgetCopyWith<$Res> {
  factory _$BudgetCopyWith(_Budget value, $Res Function(_Budget) _then) = __$BudgetCopyWithImpl;
@override @useResult
$Res call({
 String id, String monthKey, int limitMinor, bool rollover, DateTime createdAt, DateTime updatedAt, String? categoryId, DateTime? alert80SentAt, DateTime? alert100SentAt
});




}
/// @nodoc
class __$BudgetCopyWithImpl<$Res>
    implements _$BudgetCopyWith<$Res> {
  __$BudgetCopyWithImpl(this._self, this._then);

  final _Budget _self;
  final $Res Function(_Budget) _then;

/// Create a copy of Budget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? monthKey = null,Object? limitMinor = null,Object? rollover = null,Object? createdAt = null,Object? updatedAt = null,Object? categoryId = freezed,Object? alert80SentAt = freezed,Object? alert100SentAt = freezed,}) {
  return _then(_Budget(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,limitMinor: null == limitMinor ? _self.limitMinor : limitMinor // ignore: cast_nullable_to_non_nullable
as int,rollover: null == rollover ? _self.rollover : rollover // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,alert80SentAt: freezed == alert80SentAt ? _self.alert80SentAt : alert80SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,alert100SentAt: freezed == alert100SentAt ? _self.alert100SentAt : alert100SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$BudgetDraft {

 String get monthKey; int get limitMinor; bool get rollover;/// Null = Overall.
 String? get categoryId;
/// Create a copy of BudgetDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetDraftCopyWith<BudgetDraft> get copyWith => _$BudgetDraftCopyWithImpl<BudgetDraft>(this as BudgetDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BudgetDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetDraft&&(identical(other.monthKey, _this.monthKey) || other.monthKey == _this.monthKey)&&(identical(other.limitMinor, _this.limitMinor) || other.limitMinor == _this.limitMinor)&&(identical(other.rollover, _this.rollover) || other.rollover == _this.rollover)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId));
}


@override
int get hashCode {
  final _this = this as BudgetDraft;
  return Object.hash(runtimeType,_this.monthKey,_this.limitMinor,_this.rollover,_this.categoryId);
}

@override
String toString() {
  final _this = this as BudgetDraft;
  return 'BudgetDraft(monthKey: ${_this.monthKey}, limitMinor: ${_this.limitMinor}, rollover: ${_this.rollover}, categoryId: ${_this.categoryId})';
}


}

/// @nodoc
abstract mixin class $BudgetDraftCopyWith<$Res>  {
  factory $BudgetDraftCopyWith(BudgetDraft value, $Res Function(BudgetDraft) _then) = _$BudgetDraftCopyWithImpl;
@useResult
$Res call({
 String monthKey, int limitMinor, bool rollover, String? categoryId
});




}
/// @nodoc
class _$BudgetDraftCopyWithImpl<$Res>
    implements $BudgetDraftCopyWith<$Res> {
  _$BudgetDraftCopyWithImpl(this._self, this._then);

  final BudgetDraft _self;
  final $Res Function(BudgetDraft) _then;

/// Create a copy of BudgetDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthKey = null,Object? limitMinor = null,Object? rollover = null,Object? categoryId = freezed,}) {
  return _then(BudgetDraft(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,limitMinor: null == limitMinor ? _self.limitMinor : limitMinor // ignore: cast_nullable_to_non_nullable
as int,rollover: null == rollover ? _self.rollover : rollover // ignore: cast_nullable_to_non_nullable
as bool,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetDraft].
extension BudgetDraftPatterns on BudgetDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetDraft value)  $default,){
final _that = this;
switch (_that) {
case _BudgetDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetDraft value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String monthKey,  int limitMinor,  bool rollover,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetDraft() when $default != null:
return $default(_that.monthKey,_that.limitMinor,_that.rollover,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String monthKey,  int limitMinor,  bool rollover,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _BudgetDraft():
return $default(_that.monthKey,_that.limitMinor,_that.rollover,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String monthKey,  int limitMinor,  bool rollover,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _BudgetDraft() when $default != null:
return $default(_that.monthKey,_that.limitMinor,_that.rollover,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetDraft implements BudgetDraft {
  const _BudgetDraft({required this.monthKey, required this.limitMinor, required this.rollover, this.categoryId});
  

@override final  String monthKey;
@override final  int limitMinor;
@override final  bool rollover;
/// Null = Overall.
@override final  String? categoryId;

/// Create a copy of BudgetDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetDraftCopyWith<_BudgetDraft> get copyWith => __$BudgetDraftCopyWithImpl<_BudgetDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetDraft&&(identical(other.monthKey, monthKey) || other.monthKey == monthKey)&&(identical(other.limitMinor, limitMinor) || other.limitMinor == limitMinor)&&(identical(other.rollover, rollover) || other.rollover == rollover)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,monthKey,limitMinor,rollover,categoryId);
}

@override
String toString() {
    return 'BudgetDraft(monthKey: $monthKey, limitMinor: $limitMinor, rollover: $rollover, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$BudgetDraftCopyWith<$Res> implements $BudgetDraftCopyWith<$Res> {
  factory _$BudgetDraftCopyWith(_BudgetDraft value, $Res Function(_BudgetDraft) _then) = __$BudgetDraftCopyWithImpl;
@override @useResult
$Res call({
 String monthKey, int limitMinor, bool rollover, String? categoryId
});




}
/// @nodoc
class __$BudgetDraftCopyWithImpl<$Res>
    implements _$BudgetDraftCopyWith<$Res> {
  __$BudgetDraftCopyWithImpl(this._self, this._then);

  final _BudgetDraft _self;
  final $Res Function(_BudgetDraft) _then;

/// Create a copy of BudgetDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthKey = null,Object? limitMinor = null,Object? rollover = null,Object? categoryId = freezed,}) {
  return _then(_BudgetDraft(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,limitMinor: null == limitMinor ? _self.limitMinor : limitMinor // ignore: cast_nullable_to_non_nullable
as int,rollover: null == rollover ? _self.rollover : rollover // ignore: cast_nullable_to_non_nullable
as bool,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
