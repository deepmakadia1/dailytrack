// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetFormArgs {

 String get monthKey; String? get budgetId; String? get categoryId;
/// Create a copy of BudgetFormArgs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetFormArgsCopyWith<BudgetFormArgs> get copyWith => _$BudgetFormArgsCopyWithImpl<BudgetFormArgs>(this as BudgetFormArgs, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BudgetFormArgs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetFormArgs&&(identical(other.monthKey, _this.monthKey) || other.monthKey == _this.monthKey)&&(identical(other.budgetId, _this.budgetId) || other.budgetId == _this.budgetId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId));
}


@override
int get hashCode {
  final _this = this as BudgetFormArgs;
  return Object.hash(runtimeType,_this.monthKey,_this.budgetId,_this.categoryId);
}

@override
String toString() {
  final _this = this as BudgetFormArgs;
  return 'BudgetFormArgs(monthKey: ${_this.monthKey}, budgetId: ${_this.budgetId}, categoryId: ${_this.categoryId})';
}


}

/// @nodoc
abstract mixin class $BudgetFormArgsCopyWith<$Res>  {
  factory $BudgetFormArgsCopyWith(BudgetFormArgs value, $Res Function(BudgetFormArgs) _then) = _$BudgetFormArgsCopyWithImpl;
@useResult
$Res call({
 String monthKey, String? budgetId, String? categoryId
});




}
/// @nodoc
class _$BudgetFormArgsCopyWithImpl<$Res>
    implements $BudgetFormArgsCopyWith<$Res> {
  _$BudgetFormArgsCopyWithImpl(this._self, this._then);

  final BudgetFormArgs _self;
  final $Res Function(BudgetFormArgs) _then;

/// Create a copy of BudgetFormArgs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthKey = null,Object? budgetId = freezed,Object? categoryId = freezed,}) {
  return _then(BudgetFormArgs(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,budgetId: freezed == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetFormArgs].
extension BudgetFormArgsPatterns on BudgetFormArgs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetFormArgs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetFormArgs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetFormArgs value)  $default,){
final _that = this;
switch (_that) {
case _BudgetFormArgs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetFormArgs value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetFormArgs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String monthKey,  String? budgetId,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetFormArgs() when $default != null:
return $default(_that.monthKey,_that.budgetId,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String monthKey,  String? budgetId,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _BudgetFormArgs():
return $default(_that.monthKey,_that.budgetId,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String monthKey,  String? budgetId,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _BudgetFormArgs() when $default != null:
return $default(_that.monthKey,_that.budgetId,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetFormArgs implements BudgetFormArgs {
  const _BudgetFormArgs({required this.monthKey, this.budgetId, this.categoryId});
  

@override final  String monthKey;
@override final  String? budgetId;
@override final  String? categoryId;

/// Create a copy of BudgetFormArgs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetFormArgsCopyWith<_BudgetFormArgs> get copyWith => __$BudgetFormArgsCopyWithImpl<_BudgetFormArgs>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetFormArgs&&(identical(other.monthKey, monthKey) || other.monthKey == monthKey)&&(identical(other.budgetId, budgetId) || other.budgetId == budgetId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,monthKey,budgetId,categoryId);
}

@override
String toString() {
    return 'BudgetFormArgs(monthKey: $monthKey, budgetId: $budgetId, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$BudgetFormArgsCopyWith<$Res> implements $BudgetFormArgsCopyWith<$Res> {
  factory _$BudgetFormArgsCopyWith(_BudgetFormArgs value, $Res Function(_BudgetFormArgs) _then) = __$BudgetFormArgsCopyWithImpl;
@override @useResult
$Res call({
 String monthKey, String? budgetId, String? categoryId
});




}
/// @nodoc
class __$BudgetFormArgsCopyWithImpl<$Res>
    implements _$BudgetFormArgsCopyWith<$Res> {
  __$BudgetFormArgsCopyWithImpl(this._self, this._then);

  final _BudgetFormArgs _self;
  final $Res Function(_BudgetFormArgs) _then;

/// Create a copy of BudgetFormArgs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthKey = null,Object? budgetId = freezed,Object? categoryId = freezed,}) {
  return _then(_BudgetFormArgs(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,budgetId: freezed == budgetId ? _self.budgetId : budgetId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$BudgetSlot {

 Category? get category;
/// Create a copy of BudgetSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSlotCopyWith<BudgetSlot> get copyWith => _$BudgetSlotCopyWithImpl<BudgetSlot>(this as BudgetSlot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BudgetSlot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSlot&&(identical(other.category, _this.category) || other.category == _this.category));
}


@override
int get hashCode {
  final _this = this as BudgetSlot;
  return Object.hash(runtimeType,_this.category);
}

@override
String toString() {
  final _this = this as BudgetSlot;
  return 'BudgetSlot(category: ${_this.category})';
}


}

/// @nodoc
abstract mixin class $BudgetSlotCopyWith<$Res>  {
  factory $BudgetSlotCopyWith(BudgetSlot value, $Res Function(BudgetSlot) _then) = _$BudgetSlotCopyWithImpl;
@useResult
$Res call({
 Category? category
});


$CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$BudgetSlotCopyWithImpl<$Res>
    implements $BudgetSlotCopyWith<$Res> {
  _$BudgetSlotCopyWithImpl(this._self, this._then);

  final BudgetSlot _self;
  final $Res Function(BudgetSlot) _then;

/// Create a copy of BudgetSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = freezed,}) {
  return _then(BudgetSlot(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}
/// Create a copy of BudgetSlot
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


/// Adds pattern-matching-related methods to [BudgetSlot].
extension BudgetSlotPatterns on BudgetSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetSlot value)  $default,){
final _that = this;
switch (_that) {
case _BudgetSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetSlot value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSlot() when $default != null:
return $default(_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category? category)  $default,) {final _that = this;
switch (_that) {
case _BudgetSlot():
return $default(_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category? category)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSlot() when $default != null:
return $default(_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetSlot extends BudgetSlot {
  const _BudgetSlot({this.category}): super._();
  

@override final  Category? category;

/// Create a copy of BudgetSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSlotCopyWith<_BudgetSlot> get copyWith => __$BudgetSlotCopyWithImpl<_BudgetSlot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSlot&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode {
    return Object.hash(runtimeType,category);
}

@override
String toString() {
    return 'BudgetSlot(category: $category)';
}


}

/// @nodoc
abstract mixin class _$BudgetSlotCopyWith<$Res> implements $BudgetSlotCopyWith<$Res> {
  factory _$BudgetSlotCopyWith(_BudgetSlot value, $Res Function(_BudgetSlot) _then) = __$BudgetSlotCopyWithImpl;
@override @useResult
$Res call({
 Category? category
});


@override $CategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$BudgetSlotCopyWithImpl<$Res>
    implements _$BudgetSlotCopyWith<$Res> {
  __$BudgetSlotCopyWithImpl(this._self, this._then);

  final _BudgetSlot _self;
  final $Res Function(_BudgetSlot) _then;

/// Create a copy of BudgetSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = freezed,}) {
  return _then(_BudgetSlot(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category?,
  ));
}

/// Create a copy of BudgetSlot
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
mixin _$BudgetFormState {

 BudgetFormStatus get status;/// The selected slot.
 BudgetSlot get slot;/// New mode: Overall (if free) plus expense categories without a
/// budget that month. Edit mode: the fixed slot only.
 List<BudgetSlot> get availableSlots;/// Keypad input; empty = no amount yet.
 String get expression; bool get rollover; bool get keypadOpen; Set<BudgetError> get errors; bool get saving; bool get saveFailed;/// The budget being edited; null for a new one.
 Budget? get original;
/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetFormStateCopyWith<BudgetFormState> get copyWith => _$BudgetFormStateCopyWithImpl<BudgetFormState>(this as BudgetFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BudgetFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetFormState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.slot, _this.slot) || other.slot == _this.slot)&&const DeepCollectionEquality().equals(other.availableSlots, _this.availableSlots)&&(identical(other.expression, _this.expression) || other.expression == _this.expression)&&(identical(other.rollover, _this.rollover) || other.rollover == _this.rollover)&&(identical(other.keypadOpen, _this.keypadOpen) || other.keypadOpen == _this.keypadOpen)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&(identical(other.saving, _this.saving) || other.saving == _this.saving)&&(identical(other.saveFailed, _this.saveFailed) || other.saveFailed == _this.saveFailed)&&(identical(other.original, _this.original) || other.original == _this.original));
}


@override
int get hashCode {
  final _this = this as BudgetFormState;
  return Object.hash(runtimeType,_this.status,_this.slot,const DeepCollectionEquality().hash(_this.availableSlots),_this.expression,_this.rollover,_this.keypadOpen,const DeepCollectionEquality().hash(_this.errors),_this.saving,_this.saveFailed,_this.original);
}

@override
String toString() {
  final _this = this as BudgetFormState;
  return 'BudgetFormState(status: ${_this.status}, slot: ${_this.slot}, availableSlots: ${_this.availableSlots}, expression: ${_this.expression}, rollover: ${_this.rollover}, keypadOpen: ${_this.keypadOpen}, errors: ${_this.errors}, saving: ${_this.saving}, saveFailed: ${_this.saveFailed}, original: ${_this.original})';
}


}

/// @nodoc
abstract mixin class $BudgetFormStateCopyWith<$Res>  {
  factory $BudgetFormStateCopyWith(BudgetFormState value, $Res Function(BudgetFormState) _then) = _$BudgetFormStateCopyWithImpl;
@useResult
$Res call({
 BudgetFormStatus status, BudgetSlot slot, List<BudgetSlot> availableSlots, String expression, bool rollover, bool keypadOpen, Set<BudgetError> errors, bool saving, bool saveFailed, Budget? original
});


$BudgetSlotCopyWith<$Res> get slot;$BudgetCopyWith<$Res>? get original;

}
/// @nodoc
class _$BudgetFormStateCopyWithImpl<$Res>
    implements $BudgetFormStateCopyWith<$Res> {
  _$BudgetFormStateCopyWithImpl(this._self, this._then);

  final BudgetFormState _self;
  final $Res Function(BudgetFormState) _then;

/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? slot = null,Object? availableSlots = null,Object? expression = null,Object? rollover = null,Object? keypadOpen = null,Object? errors = null,Object? saving = null,Object? saveFailed = null,Object? original = freezed,}) {
  return _then(BudgetFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetFormStatus,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as BudgetSlot,availableSlots: null == availableSlots ? _self.availableSlots : availableSlots // ignore: cast_nullable_to_non_nullable
as List<BudgetSlot>,expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as String,rollover: null == rollover ? _self.rollover : rollover // ignore: cast_nullable_to_non_nullable
as bool,keypadOpen: null == keypadOpen ? _self.keypadOpen : keypadOpen // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Set<BudgetError>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Budget?,
  ));
}
/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetSlotCopyWith<$Res> get slot {
  
  return $BudgetSlotCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $BudgetCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetFormState].
extension BudgetFormStatePatterns on BudgetFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetFormState value)  $default,){
final _that = this;
switch (_that) {
case _BudgetFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetFormState value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BudgetFormStatus status,  BudgetSlot slot,  List<BudgetSlot> availableSlots,  String expression,  bool rollover,  bool keypadOpen,  Set<BudgetError> errors,  bool saving,  bool saveFailed,  Budget? original)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetFormState() when $default != null:
return $default(_that.status,_that.slot,_that.availableSlots,_that.expression,_that.rollover,_that.keypadOpen,_that.errors,_that.saving,_that.saveFailed,_that.original);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BudgetFormStatus status,  BudgetSlot slot,  List<BudgetSlot> availableSlots,  String expression,  bool rollover,  bool keypadOpen,  Set<BudgetError> errors,  bool saving,  bool saveFailed,  Budget? original)  $default,) {final _that = this;
switch (_that) {
case _BudgetFormState():
return $default(_that.status,_that.slot,_that.availableSlots,_that.expression,_that.rollover,_that.keypadOpen,_that.errors,_that.saving,_that.saveFailed,_that.original);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BudgetFormStatus status,  BudgetSlot slot,  List<BudgetSlot> availableSlots,  String expression,  bool rollover,  bool keypadOpen,  Set<BudgetError> errors,  bool saving,  bool saveFailed,  Budget? original)?  $default,) {final _that = this;
switch (_that) {
case _BudgetFormState() when $default != null:
return $default(_that.status,_that.slot,_that.availableSlots,_that.expression,_that.rollover,_that.keypadOpen,_that.errors,_that.saving,_that.saveFailed,_that.original);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetFormState extends BudgetFormState {
  const _BudgetFormState({required this.status, this.slot = const BudgetSlot(),  List<BudgetSlot> availableSlots = const <BudgetSlot>[], this.expression = '', this.rollover = true, this.keypadOpen = true,  Set<BudgetError> errors = const <BudgetError>{}, this.saving = false, this.saveFailed = false, this.original}): _availableSlots = availableSlots,_errors = errors,super._();
  

@override final  BudgetFormStatus status;
/// The selected slot.
@override@JsonKey() final  BudgetSlot slot;
/// New mode: Overall (if free) plus expense categories without a
/// budget that month. Edit mode: the fixed slot only.
 final  List<BudgetSlot> _availableSlots;
/// New mode: Overall (if free) plus expense categories without a
/// budget that month. Edit mode: the fixed slot only.
@override@JsonKey() List<BudgetSlot> get availableSlots {
  if (_availableSlots is EqualUnmodifiableListView) return _availableSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableSlots);
}

/// Keypad input; empty = no amount yet.
@override@JsonKey() final  String expression;
@override@JsonKey() final  bool rollover;
@override@JsonKey() final  bool keypadOpen;
 final  Set<BudgetError> _errors;
@override@JsonKey() Set<BudgetError> get errors {
  if (_errors is EqualUnmodifiableSetView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_errors);
}

@override@JsonKey() final  bool saving;
@override@JsonKey() final  bool saveFailed;
/// The budget being edited; null for a new one.
@override final  Budget? original;

/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetFormStateCopyWith<_BudgetFormState> get copyWith => __$BudgetFormStateCopyWithImpl<_BudgetFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetFormState&&(identical(other.status, status) || other.status == status)&&(identical(other.slot, slot) || other.slot == slot)&&const DeepCollectionEquality().equals(other.availableSlots, _availableSlots)&&(identical(other.expression, expression) || other.expression == expression)&&(identical(other.rollover, rollover) || other.rollover == rollover)&&(identical(other.keypadOpen, keypadOpen) || other.keypadOpen == keypadOpen)&&const DeepCollectionEquality().equals(other.errors, _errors)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.saveFailed, saveFailed) || other.saveFailed == saveFailed)&&(identical(other.original, original) || other.original == original));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,slot,const DeepCollectionEquality().hash(_availableSlots),expression,rollover,keypadOpen,const DeepCollectionEquality().hash(_errors),saving,saveFailed,original);
}

@override
String toString() {
    return 'BudgetFormState(status: $status, slot: $slot, availableSlots: $availableSlots, expression: $expression, rollover: $rollover, keypadOpen: $keypadOpen, errors: $errors, saving: $saving, saveFailed: $saveFailed, original: $original)';
}


}

/// @nodoc
abstract mixin class _$BudgetFormStateCopyWith<$Res> implements $BudgetFormStateCopyWith<$Res> {
  factory _$BudgetFormStateCopyWith(_BudgetFormState value, $Res Function(_BudgetFormState) _then) = __$BudgetFormStateCopyWithImpl;
@override @useResult
$Res call({
 BudgetFormStatus status, BudgetSlot slot, List<BudgetSlot> availableSlots, String expression, bool rollover, bool keypadOpen, Set<BudgetError> errors, bool saving, bool saveFailed, Budget? original
});


@override $BudgetSlotCopyWith<$Res> get slot;@override $BudgetCopyWith<$Res>? get original;

}
/// @nodoc
class __$BudgetFormStateCopyWithImpl<$Res>
    implements _$BudgetFormStateCopyWith<$Res> {
  __$BudgetFormStateCopyWithImpl(this._self, this._then);

  final _BudgetFormState _self;
  final $Res Function(_BudgetFormState) _then;

/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? slot = null,Object? availableSlots = null,Object? expression = null,Object? rollover = null,Object? keypadOpen = null,Object? errors = null,Object? saving = null,Object? saveFailed = null,Object? original = freezed,}) {
  return _then(_BudgetFormState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetFormStatus,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as BudgetSlot,availableSlots: null == availableSlots ? _self._availableSlots : availableSlots // ignore: cast_nullable_to_non_nullable
as List<BudgetSlot>,expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as String,rollover: null == rollover ? _self.rollover : rollover // ignore: cast_nullable_to_non_nullable
as bool,keypadOpen: null == keypadOpen ? _self.keypadOpen : keypadOpen // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Set<BudgetError>,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,saveFailed: null == saveFailed ? _self.saveFailed : saveFailed // ignore: cast_nullable_to_non_nullable
as bool,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as Budget?,
  ));
}

/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetSlotCopyWith<$Res> get slot {
  
  return $BudgetSlotCopyWith<$Res>(_self.slot, (value) {
    return _then(_self.copyWith(slot: value));
  });
}/// Create a copy of BudgetFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $BudgetCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
