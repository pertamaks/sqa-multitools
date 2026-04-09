// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IdentityState {

 IdentityType get selectedType; int get quantity; String get customDomain; FakerLocaleType get locale; bool get includeFormatting; bool get includeExtension; Map<IdentityType, List<String>> get resultsMap;
/// Create a copy of IdentityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentityStateCopyWith<IdentityState> get copyWith => _$IdentityStateCopyWithImpl<IdentityState>(this as IdentityState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentityState&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.customDomain, customDomain) || other.customDomain == customDomain)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.includeFormatting, includeFormatting) || other.includeFormatting == includeFormatting)&&(identical(other.includeExtension, includeExtension) || other.includeExtension == includeExtension)&&const DeepCollectionEquality().equals(other.resultsMap, resultsMap));
}


@override
int get hashCode => Object.hash(runtimeType,selectedType,quantity,customDomain,locale,includeFormatting,includeExtension,const DeepCollectionEquality().hash(resultsMap));

@override
String toString() {
  return 'IdentityState(selectedType: $selectedType, quantity: $quantity, customDomain: $customDomain, locale: $locale, includeFormatting: $includeFormatting, includeExtension: $includeExtension, resultsMap: $resultsMap)';
}


}

/// @nodoc
abstract mixin class $IdentityStateCopyWith<$Res>  {
  factory $IdentityStateCopyWith(IdentityState value, $Res Function(IdentityState) _then) = _$IdentityStateCopyWithImpl;
@useResult
$Res call({
 IdentityType selectedType, int quantity, String customDomain, FakerLocaleType locale, bool includeFormatting, bool includeExtension, Map<IdentityType, List<String>> resultsMap
});




}
/// @nodoc
class _$IdentityStateCopyWithImpl<$Res>
    implements $IdentityStateCopyWith<$Res> {
  _$IdentityStateCopyWithImpl(this._self, this._then);

  final IdentityState _self;
  final $Res Function(IdentityState) _then;

/// Create a copy of IdentityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedType = null,Object? quantity = null,Object? customDomain = null,Object? locale = null,Object? includeFormatting = null,Object? includeExtension = null,Object? resultsMap = null,}) {
  return _then(_self.copyWith(
selectedType: null == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as IdentityType,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,customDomain: null == customDomain ? _self.customDomain : customDomain // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as FakerLocaleType,includeFormatting: null == includeFormatting ? _self.includeFormatting : includeFormatting // ignore: cast_nullable_to_non_nullable
as bool,includeExtension: null == includeExtension ? _self.includeExtension : includeExtension // ignore: cast_nullable_to_non_nullable
as bool,resultsMap: null == resultsMap ? _self.resultsMap : resultsMap // ignore: cast_nullable_to_non_nullable
as Map<IdentityType, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [IdentityState].
extension IdentityStatePatterns on IdentityState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdentityState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdentityState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdentityState value)  $default,){
final _that = this;
switch (_that) {
case _IdentityState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdentityState value)?  $default,){
final _that = this;
switch (_that) {
case _IdentityState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IdentityType selectedType,  int quantity,  String customDomain,  FakerLocaleType locale,  bool includeFormatting,  bool includeExtension,  Map<IdentityType, List<String>> resultsMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdentityState() when $default != null:
return $default(_that.selectedType,_that.quantity,_that.customDomain,_that.locale,_that.includeFormatting,_that.includeExtension,_that.resultsMap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IdentityType selectedType,  int quantity,  String customDomain,  FakerLocaleType locale,  bool includeFormatting,  bool includeExtension,  Map<IdentityType, List<String>> resultsMap)  $default,) {final _that = this;
switch (_that) {
case _IdentityState():
return $default(_that.selectedType,_that.quantity,_that.customDomain,_that.locale,_that.includeFormatting,_that.includeExtension,_that.resultsMap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IdentityType selectedType,  int quantity,  String customDomain,  FakerLocaleType locale,  bool includeFormatting,  bool includeExtension,  Map<IdentityType, List<String>> resultsMap)?  $default,) {final _that = this;
switch (_that) {
case _IdentityState() when $default != null:
return $default(_that.selectedType,_that.quantity,_that.customDomain,_that.locale,_that.includeFormatting,_that.includeExtension,_that.resultsMap);case _:
  return null;

}
}

}

/// @nodoc


class _IdentityState implements IdentityState {
  const _IdentityState({this.selectedType = IdentityType.email, this.quantity = 1, this.customDomain = '', this.locale = FakerLocaleType.en_US, this.includeFormatting = true, this.includeExtension = false, final  Map<IdentityType, List<String>> resultsMap = const {}}): _resultsMap = resultsMap;
  

@override@JsonKey() final  IdentityType selectedType;
@override@JsonKey() final  int quantity;
@override@JsonKey() final  String customDomain;
@override@JsonKey() final  FakerLocaleType locale;
@override@JsonKey() final  bool includeFormatting;
@override@JsonKey() final  bool includeExtension;
 final  Map<IdentityType, List<String>> _resultsMap;
@override@JsonKey() Map<IdentityType, List<String>> get resultsMap {
  if (_resultsMap is EqualUnmodifiableMapView) return _resultsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_resultsMap);
}


/// Create a copy of IdentityState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdentityStateCopyWith<_IdentityState> get copyWith => __$IdentityStateCopyWithImpl<_IdentityState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdentityState&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.customDomain, customDomain) || other.customDomain == customDomain)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.includeFormatting, includeFormatting) || other.includeFormatting == includeFormatting)&&(identical(other.includeExtension, includeExtension) || other.includeExtension == includeExtension)&&const DeepCollectionEquality().equals(other._resultsMap, _resultsMap));
}


@override
int get hashCode => Object.hash(runtimeType,selectedType,quantity,customDomain,locale,includeFormatting,includeExtension,const DeepCollectionEquality().hash(_resultsMap));

@override
String toString() {
  return 'IdentityState(selectedType: $selectedType, quantity: $quantity, customDomain: $customDomain, locale: $locale, includeFormatting: $includeFormatting, includeExtension: $includeExtension, resultsMap: $resultsMap)';
}


}

/// @nodoc
abstract mixin class _$IdentityStateCopyWith<$Res> implements $IdentityStateCopyWith<$Res> {
  factory _$IdentityStateCopyWith(_IdentityState value, $Res Function(_IdentityState) _then) = __$IdentityStateCopyWithImpl;
@override @useResult
$Res call({
 IdentityType selectedType, int quantity, String customDomain, FakerLocaleType locale, bool includeFormatting, bool includeExtension, Map<IdentityType, List<String>> resultsMap
});




}
/// @nodoc
class __$IdentityStateCopyWithImpl<$Res>
    implements _$IdentityStateCopyWith<$Res> {
  __$IdentityStateCopyWithImpl(this._self, this._then);

  final _IdentityState _self;
  final $Res Function(_IdentityState) _then;

/// Create a copy of IdentityState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedType = null,Object? quantity = null,Object? customDomain = null,Object? locale = null,Object? includeFormatting = null,Object? includeExtension = null,Object? resultsMap = null,}) {
  return _then(_IdentityState(
selectedType: null == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as IdentityType,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,customDomain: null == customDomain ? _self.customDomain : customDomain // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as FakerLocaleType,includeFormatting: null == includeFormatting ? _self.includeFormatting : includeFormatting // ignore: cast_nullable_to_non_nullable
as bool,includeExtension: null == includeExtension ? _self.includeExtension : includeExtension // ignore: cast_nullable_to_non_nullable
as bool,resultsMap: null == resultsMap ? _self._resultsMap : resultsMap // ignore: cast_nullable_to_non_nullable
as Map<IdentityType, List<String>>,
  ));
}


}

// dart format on
