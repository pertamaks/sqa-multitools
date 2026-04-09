// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TextState {

 TextType get selectedType; int get size; Map<TextType, List<String>> get resultsMap; bool get includeFormatting;
/// Create a copy of TextState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextStateCopyWith<TextState> get copyWith => _$TextStateCopyWithImpl<TextState>(this as TextState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextState&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.resultsMap, resultsMap)&&(identical(other.includeFormatting, includeFormatting) || other.includeFormatting == includeFormatting));
}


@override
int get hashCode => Object.hash(runtimeType,selectedType,size,const DeepCollectionEquality().hash(resultsMap),includeFormatting);

@override
String toString() {
  return 'TextState(selectedType: $selectedType, size: $size, resultsMap: $resultsMap, includeFormatting: $includeFormatting)';
}


}

/// @nodoc
abstract mixin class $TextStateCopyWith<$Res>  {
  factory $TextStateCopyWith(TextState value, $Res Function(TextState) _then) = _$TextStateCopyWithImpl;
@useResult
$Res call({
 TextType selectedType, int size, Map<TextType, List<String>> resultsMap, bool includeFormatting
});




}
/// @nodoc
class _$TextStateCopyWithImpl<$Res>
    implements $TextStateCopyWith<$Res> {
  _$TextStateCopyWithImpl(this._self, this._then);

  final TextState _self;
  final $Res Function(TextState) _then;

/// Create a copy of TextState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedType = null,Object? size = null,Object? resultsMap = null,Object? includeFormatting = null,}) {
  return _then(_self.copyWith(
selectedType: null == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as TextType,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,resultsMap: null == resultsMap ? _self.resultsMap : resultsMap // ignore: cast_nullable_to_non_nullable
as Map<TextType, List<String>>,includeFormatting: null == includeFormatting ? _self.includeFormatting : includeFormatting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TextState].
extension TextStatePatterns on TextState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextState value)  $default,){
final _that = this;
switch (_that) {
case _TextState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextState value)?  $default,){
final _that = this;
switch (_that) {
case _TextState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TextType selectedType,  int size,  Map<TextType, List<String>> resultsMap,  bool includeFormatting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextState() when $default != null:
return $default(_that.selectedType,_that.size,_that.resultsMap,_that.includeFormatting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TextType selectedType,  int size,  Map<TextType, List<String>> resultsMap,  bool includeFormatting)  $default,) {final _that = this;
switch (_that) {
case _TextState():
return $default(_that.selectedType,_that.size,_that.resultsMap,_that.includeFormatting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TextType selectedType,  int size,  Map<TextType, List<String>> resultsMap,  bool includeFormatting)?  $default,) {final _that = this;
switch (_that) {
case _TextState() when $default != null:
return $default(_that.selectedType,_that.size,_that.resultsMap,_that.includeFormatting);case _:
  return null;

}
}

}

/// @nodoc


class _TextState implements TextState {
  const _TextState({this.selectedType = TextType.bytes, this.size = 100, final  Map<TextType, List<String>> resultsMap = const {}, this.includeFormatting = true}): _resultsMap = resultsMap;
  

@override@JsonKey() final  TextType selectedType;
@override@JsonKey() final  int size;
 final  Map<TextType, List<String>> _resultsMap;
@override@JsonKey() Map<TextType, List<String>> get resultsMap {
  if (_resultsMap is EqualUnmodifiableMapView) return _resultsMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_resultsMap);
}

@override@JsonKey() final  bool includeFormatting;

/// Create a copy of TextState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextStateCopyWith<_TextState> get copyWith => __$TextStateCopyWithImpl<_TextState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextState&&(identical(other.selectedType, selectedType) || other.selectedType == selectedType)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other._resultsMap, _resultsMap)&&(identical(other.includeFormatting, includeFormatting) || other.includeFormatting == includeFormatting));
}


@override
int get hashCode => Object.hash(runtimeType,selectedType,size,const DeepCollectionEquality().hash(_resultsMap),includeFormatting);

@override
String toString() {
  return 'TextState(selectedType: $selectedType, size: $size, resultsMap: $resultsMap, includeFormatting: $includeFormatting)';
}


}

/// @nodoc
abstract mixin class _$TextStateCopyWith<$Res> implements $TextStateCopyWith<$Res> {
  factory _$TextStateCopyWith(_TextState value, $Res Function(_TextState) _then) = __$TextStateCopyWithImpl;
@override @useResult
$Res call({
 TextType selectedType, int size, Map<TextType, List<String>> resultsMap, bool includeFormatting
});




}
/// @nodoc
class __$TextStateCopyWithImpl<$Res>
    implements _$TextStateCopyWith<$Res> {
  __$TextStateCopyWithImpl(this._self, this._then);

  final _TextState _self;
  final $Res Function(_TextState) _then;

/// Create a copy of TextState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedType = null,Object? size = null,Object? resultsMap = null,Object? includeFormatting = null,}) {
  return _then(_TextState(
selectedType: null == selectedType ? _self.selectedType : selectedType // ignore: cast_nullable_to_non_nullable
as TextType,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,resultsMap: null == resultsMap ? _self._resultsMap : resultsMap // ignore: cast_nullable_to_non_nullable
as Map<TextType, List<String>>,includeFormatting: null == includeFormatting ? _self.includeFormatting : includeFormatting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
