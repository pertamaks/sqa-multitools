// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'glyphs_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GlyphsState {

 GlyphsCategory get selectedCategory; TextType get selectedType; int get size; Map<GlyphsCategory, List<String>> get resultsMap;
/// Create a copy of GlyphsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GlyphsStateCopyWith<GlyphsState> get copyWith => _$GlyphsStateCopyWithImpl<GlyphsState>(this as GlyphsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlyphsState&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.resultsMap, resultsMap));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCategory,selectedType,size,const DeepCollectionEquality().hash(resultsMap));

@override
String toString() {
  return 'GlyphsState(selectedCategory: $selectedCategory, selectedType: $selectedType, size: $size, resultsMap: $resultsMap)';
}


}

/// @nodoc
abstract mixin class $GlyphsStateCopyWith<$Res>  {
  factory $GlyphsStateCopyWith(GlyphsState value, $Res Function(GlyphsState) _then) = _$GlyphsStateCopyWithImpl;
@useResult
$Res call({
 GlyphsCategory selectedCategory, TextType selectedType, int size, Map<GlyphsCategory, List<String>> resultsMap
});




}
/// @nodoc
class _$GlyphsStateCopyWithImpl<$Res>
    implements $GlyphsStateCopyWith<$Res> {
  _$GlyphsStateCopyWithImpl(this._self, this._then);

  final GlyphsState _self;
  final $Res Function(GlyphsState) _then;

/// Create a copy of GlyphsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedCategory = null,Object? selectedType = null,Object? size = null,Object? resultsMap = null,}) {
  return _then(_self.copyWith(
selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as GlyphsCategory,selectedType: null == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as TextType,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,resultsMap: null == resultsMap ? _self.resultsMap : resultsMap // ignore: cast_nullable_to_non_nullable
as Map<GlyphsCategory, List<String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [GlyphsState].
extension GlyphsStatePatterns on GlyphsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GlyphsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GlyphsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GlyphsState value)  $default,){
final _that = this;
switch (_that) {
case _GlyphsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GlyphsState value)?  $default,){
final _that = this;
switch (_that) {
case _GlyphsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GlyphsCategory selectedCategory,  TextType selectedType,  int size,  Map<GlyphsCategory, List<String>> resultsMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GlyphsState() when $default != null:
return $default(_that.selectedCategory,_that.selectedType,_that.size,_that.resultsMap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GlyphsCategory selectedCategory,  TextType selectedType,  int size,  Map<GlyphsCategory, List<String>> resultsMap)  $default,) {final _that = this;
switch (_that) {
case _GlyphsState():
return $default(_that.selectedCategory,_that.selectedType,_that.size,_that.resultsMap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GlyphsCategory selectedCategory,  TextType selectedType,  int size,  Map<GlyphsCategory, List<String>> resultsMap)?  $default,) {final _that = this;
switch (_that) {
case _GlyphsState() when $default != null:
return $default(_that.selectedCategory,_that.selectedType,_that.size,_that.resultsMap);case _:
  return null;

}
}

}

/// @nodoc


class _GlyphsState implements GlyphsState {
  const _GlyphsState({this.selectedCategory = GlyphsCategory.specials, this.selectedType = TextType.bytes, this.size = 100, final  Map<GlyphsCategory, List<String>> resultsMap = const {}}): _resultsMap = resultsMap;
  

@override@JsonKey() final  GlyphsCategory selectedCategory;
@override@JsonKey() final  TextType selectedType;
@override@JsonKey() final  int size;
 final  Map<GlyphsCategory, List<String>> _resultsMap;
@override@JsonKey() Map<GlyphsCategory, List<String>> get resultsMap {
  if (_resultsMap is EqualUnmodifiableMapView) return _resultsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_resultsMap);
}


/// Create a copy of GlyphsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GlyphsStateCopyWith<_GlyphsState> get copyWith => __$GlyphsStateCopyWithImpl<_GlyphsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GlyphsState&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other._resultsMap, _resultsMap));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCategory,selectedType,size,const DeepCollectionEquality().hash(_resultsMap));

@override
String toString() {
  return 'GlyphsState(selectedCategory: $selectedCategory, selectedType: $selectedType, size: $size, resultsMap: $resultsMap)';
}


}

/// @nodoc
abstract mixin class _$GlyphsStateCopyWith<$Res> implements $GlyphsStateCopyWith<$Res> {
  factory _$GlyphsStateCopyWith(_GlyphsState value, $Res Function(_GlyphsState) _then) = __$GlyphsStateCopyWithImpl;
@override @useResult
$Res call({
 GlyphsCategory selectedCategory, TextType selectedType, int size, Map<GlyphsCategory, List<String>> resultsMap
});




}
/// @nodoc
class __$GlyphsStateCopyWithImpl<$Res>
    implements _$GlyphsStateCopyWith<$Res> {
  __$GlyphsStateCopyWithImpl(this._self, this._then);

  final _GlyphsState _self;
  final $Res Function(_GlyphsState) _then;

/// Create a copy of GlyphsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedCategory = null,Object? selectedType = null,Object? size = null,Object? resultsMap = null,}) {
  return _then(_GlyphsState(
selectedCategory: null == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as GlyphsCategory,selectedType: null == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as TextType,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,resultsMap: null == resultsMap ? _self._resultsMap : resultsMap // ignore: cast_nullable_to_non_nullable
as Map<GlyphsCategory, List<String>>,
  ));
}


}

// dart format on
