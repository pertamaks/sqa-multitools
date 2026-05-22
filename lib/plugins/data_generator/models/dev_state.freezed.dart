// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dev_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DevState {

 DevType get selectedType; JsonCategory get selectedJsonCategory; DateCategory get selectedDateCategory; Map<DevType, List<List<String>>> get resultsMap; List<String> get uuidHistory; int get quantity; bool get includeFormatting;
/// Create a copy of DevState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DevStateCopyWith<DevState> get copyWith => _$DevStateCopyWithImpl<DevState>(this as DevState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DevState&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.selectedJsonCategory, selectedJsonCategory) || other.selectedJsonCategory == selectedJsonCategory)&&(identical(other.selectedDateCategory, selectedDateCategory) || other.selectedDateCategory == selectedDateCategory)&&const DeepCollectionEquality().equals(other.resultsMap, resultsMap)&&const DeepCollectionEquality().equals(other.uuidHistory, uuidHistory)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.includeFormatting, includeFormatting) || other.includeFormatting == includeFormatting));
}


@override
int get hashCode => Object.hash(runtimeType,selectedType,selectedJsonCategory,selectedDateCategory,const DeepCollectionEquality().hash(resultsMap),const DeepCollectionEquality().hash(uuidHistory),quantity,includeFormatting);

@override
String toString() {
  return 'DevState(selectedType: $selectedType, selectedJsonCategory: $selectedJsonCategory, selectedDateCategory: $selectedDateCategory, resultsMap: $resultsMap, uuidHistory: $uuidHistory, quantity: $quantity, includeFormatting: $includeFormatting)';
}


}

/// @nodoc
abstract mixin class $DevStateCopyWith<$Res>  {
  factory $DevStateCopyWith(DevState value, $Res Function(DevState) _then) = _$DevStateCopyWithImpl;
@useResult
$Res call({
 DevType selectedType, JsonCategory selectedJsonCategory, DateCategory selectedDateCategory, Map<DevType, List<List<String>>> resultsMap, List<String> uuidHistory, int quantity, bool includeFormatting
});




}
/// @nodoc
class _$DevStateCopyWithImpl<$Res>
    implements $DevStateCopyWith<$Res> {
  _$DevStateCopyWithImpl(this._self, this._then);

  final DevState _self;
  final $Res Function(DevState) _then;

/// Create a copy of DevState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedType = null,Object? selectedJsonCategory = null,Object? selectedDateCategory = null,Object? resultsMap = null,Object? uuidHistory = null,Object? quantity = null,Object? includeFormatting = null,}) {
  return _then(_self.copyWith(
selectedType: null == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as DevType,selectedJsonCategory: null == selectedJsonCategory ? _self.selectedJsonCategory : selectedJsonCategory // ignore: cast_nullable_to_non_nullable
as JsonCategory,selectedDateCategory: null == selectedDateCategory ? _self.selectedDateCategory : selectedDateCategory // ignore: cast_nullable_to_non_nullable
as DateCategory,resultsMap: null == resultsMap ? _self.resultsMap : resultsMap // ignore: cast_nullable_to_non_nullable
as Map<DevType, List<List<String>>>,uuidHistory: null == uuidHistory ? _self.uuidHistory : uuidHistory // ignore: cast_nullable_to_non_nullable
as List<String>,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,includeFormatting: null == includeFormatting ? _self.includeFormatting : includeFormatting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DevState].
extension DevStatePatterns on DevState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DevState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DevState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DevState value)  $default,){
final _that = this;
switch (_that) {
case _DevState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DevState value)?  $default,){
final _that = this;
switch (_that) {
case _DevState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DevType selectedType,  JsonCategory selectedJsonCategory,  DateCategory selectedDateCategory,  Map<DevType, List<List<String>>> resultsMap,  List<String> uuidHistory,  int quantity,  bool includeFormatting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DevState() when $default != null:
return $default(_that.selectedType,_that.selectedJsonCategory,_that.selectedDateCategory,_that.resultsMap,_that.uuidHistory,_that.quantity,_that.includeFormatting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DevType selectedType,  JsonCategory selectedJsonCategory,  DateCategory selectedDateCategory,  Map<DevType, List<List<String>>> resultsMap,  List<String> uuidHistory,  int quantity,  bool includeFormatting)  $default,) {final _that = this;
switch (_that) {
case _DevState():
return $default(_that.selectedType,_that.selectedJsonCategory,_that.selectedDateCategory,_that.resultsMap,_that.uuidHistory,_that.quantity,_that.includeFormatting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DevType selectedType,  JsonCategory selectedJsonCategory,  DateCategory selectedDateCategory,  Map<DevType, List<List<String>>> resultsMap,  List<String> uuidHistory,  int quantity,  bool includeFormatting)?  $default,) {final _that = this;
switch (_that) {
case _DevState() when $default != null:
return $default(_that.selectedType,_that.selectedJsonCategory,_that.selectedDateCategory,_that.resultsMap,_that.uuidHistory,_that.quantity,_that.includeFormatting);case _:
  return null;

}
}

}

/// @nodoc


class _DevState implements DevState {
  const _DevState({this.selectedType = DevType.uuid, this.selectedJsonCategory = JsonCategory.simple, this.selectedDateCategory = DateCategory.past, final  Map<DevType, List<List<String>>> resultsMap = const <DevType, List<List<String>>>{}, final  List<String> uuidHistory = const [], this.quantity = 1, this.includeFormatting = true}): _resultsMap = resultsMap,_uuidHistory = uuidHistory;
  

@override@JsonKey() final  DevType selectedType;
@override@JsonKey() final  JsonCategory selectedJsonCategory;
@override@JsonKey() final  DateCategory selectedDateCategory;
 final  Map<DevType, List<List<String>>> _resultsMap;
@override@JsonKey() Map<DevType, List<List<String>>> get resultsMap {
  if (_resultsMap is EqualUnmodifiableMapView) return _resultsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_resultsMap);
}

 final  List<String> _uuidHistory;
@override@JsonKey() List<String> get uuidHistory {
  if (_uuidHistory is EqualUnmodifiableListView) return _uuidHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uuidHistory);
}

@override@JsonKey() final  int quantity;
@override@JsonKey() final  bool includeFormatting;

/// Create a copy of DevState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DevStateCopyWith<_DevState> get copyWith => __$DevStateCopyWithImpl<_DevState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DevState&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.selectedJsonCategory, selectedJsonCategory) || other.selectedJsonCategory == selectedJsonCategory)&&(identical(other.selectedDateCategory, selectedDateCategory) || other.selectedDateCategory == selectedDateCategory)&&const DeepCollectionEquality().equals(other._resultsMap, _resultsMap)&&const DeepCollectionEquality().equals(other._uuidHistory, _uuidHistory)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.includeFormatting, includeFormatting) || other.includeFormatting == includeFormatting));
}


@override
int get hashCode => Object.hash(runtimeType,selectedType,selectedJsonCategory,selectedDateCategory,const DeepCollectionEquality().hash(_resultsMap),const DeepCollectionEquality().hash(_uuidHistory),quantity,includeFormatting);

@override
String toString() {
  return 'DevState(selectedType: $selectedType, selectedJsonCategory: $selectedJsonCategory, selectedDateCategory: $selectedDateCategory, resultsMap: $resultsMap, uuidHistory: $uuidHistory, quantity: $quantity, includeFormatting: $includeFormatting)';
}


}

/// @nodoc
abstract mixin class _$DevStateCopyWith<$Res> implements $DevStateCopyWith<$Res> {
  factory _$DevStateCopyWith(_DevState value, $Res Function(_DevState) _then) = __$DevStateCopyWithImpl;
@override @useResult
$Res call({
 DevType selectedType, JsonCategory selectedJsonCategory, DateCategory selectedDateCategory, Map<DevType, List<List<String>>> resultsMap, List<String> uuidHistory, int quantity, bool includeFormatting
});




}
/// @nodoc
class __$DevStateCopyWithImpl<$Res>
    implements _$DevStateCopyWith<$Res> {
  __$DevStateCopyWithImpl(this._self, this._then);

  final _DevState _self;
  final $Res Function(_DevState) _then;

/// Create a copy of DevState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedType = null,Object? selectedJsonCategory = null,Object? selectedDateCategory = null,Object? resultsMap = null,Object? uuidHistory = null,Object? quantity = null,Object? includeFormatting = null,}) {
  return _then(_DevState(
selectedType: null == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as DevType,selectedJsonCategory: null == selectedJsonCategory ? _self.selectedJsonCategory : selectedJsonCategory // ignore: cast_nullable_to_non_nullable
as JsonCategory,selectedDateCategory: null == selectedDateCategory ? _self.selectedDateCategory : selectedDateCategory // ignore: cast_nullable_to_non_nullable
as DateCategory,resultsMap: null == resultsMap ? _self._resultsMap : resultsMap // ignore: cast_nullable_to_non_nullable
as Map<DevType, List<List<String>>>,uuidHistory: null == uuidHistory ? _self._uuidHistory : uuidHistory // ignore: cast_nullable_to_non_nullable
as List<String>,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,includeFormatting: null == includeFormatting ? _self.includeFormatting : includeFormatting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
