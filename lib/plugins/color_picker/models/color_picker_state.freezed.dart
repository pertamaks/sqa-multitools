// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'color_picker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ColorPickerState {

 Color get activeColor; List<Color> get history;
/// Create a copy of ColorPickerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorPickerStateCopyWith<ColorPickerState> get copyWith => _$ColorPickerStateCopyWithImpl<ColorPickerState>(this as ColorPickerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorPickerState&&(identical(other.activeColor, activeColor) || other.activeColor == activeColor)&&const DeepCollectionEquality().equals(other.history, history));
}


@override
int get hashCode => Object.hash(runtimeType,activeColor,const DeepCollectionEquality().hash(history));

@override
String toString() {
  return 'ColorPickerState(activeColor: $activeColor, history: $history)';
}


}

/// @nodoc
abstract mixin class $ColorPickerStateCopyWith<$Res>  {
  factory $ColorPickerStateCopyWith(ColorPickerState value, $Res Function(ColorPickerState) _then) = _$ColorPickerStateCopyWithImpl;
@useResult
$Res call({
 Color activeColor, List<Color> history
});




}
/// @nodoc
class _$ColorPickerStateCopyWithImpl<$Res>
    implements $ColorPickerStateCopyWith<$Res> {
  _$ColorPickerStateCopyWithImpl(this._self, this._then);

  final ColorPickerState _self;
  final $Res Function(ColorPickerState) _then;

/// Create a copy of ColorPickerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeColor = null,Object? history = null,}) {
  return _then(_self.copyWith(
activeColor: null == activeColor ? _self.activeColor : activeColor // ignore: cast_nullable_to_non_nullable
as Color,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<Color>,
  ));
}

}


/// Adds pattern-matching-related methods to [ColorPickerState].
extension ColorPickerStatePatterns on ColorPickerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColorPickerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColorPickerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColorPickerState value)  $default,){
final _that = this;
switch (_that) {
case _ColorPickerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColorPickerState value)?  $default,){
final _that = this;
switch (_that) {
case _ColorPickerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Color activeColor,  List<Color> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColorPickerState() when $default != null:
return $default(_that.activeColor,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Color activeColor,  List<Color> history)  $default,) {final _that = this;
switch (_that) {
case _ColorPickerState():
return $default(_that.activeColor,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Color activeColor,  List<Color> history)?  $default,) {final _that = this;
switch (_that) {
case _ColorPickerState() when $default != null:
return $default(_that.activeColor,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _ColorPickerState implements ColorPickerState {
  const _ColorPickerState({required this.activeColor, final  List<Color> history = const []}): _history = history;
  

@override final  Color activeColor;
 final  List<Color> _history;
@override@JsonKey() List<Color> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of ColorPickerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColorPickerStateCopyWith<_ColorPickerState> get copyWith => __$ColorPickerStateCopyWithImpl<_ColorPickerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColorPickerState&&(identical(other.activeColor, activeColor) || other.activeColor == activeColor)&&const DeepCollectionEquality().equals(other._history, _history));
}


@override
int get hashCode => Object.hash(runtimeType,activeColor,const DeepCollectionEquality().hash(_history));

@override
String toString() {
  return 'ColorPickerState(activeColor: $activeColor, history: $history)';
}


}

/// @nodoc
abstract mixin class _$ColorPickerStateCopyWith<$Res> implements $ColorPickerStateCopyWith<$Res> {
  factory _$ColorPickerStateCopyWith(_ColorPickerState value, $Res Function(_ColorPickerState) _then) = __$ColorPickerStateCopyWithImpl;
@override @useResult
$Res call({
 Color activeColor, List<Color> history
});




}
/// @nodoc
class __$ColorPickerStateCopyWithImpl<$Res>
    implements _$ColorPickerStateCopyWith<$Res> {
  __$ColorPickerStateCopyWithImpl(this._self, this._then);

  final _ColorPickerState _self;
  final $Res Function(_ColorPickerState) _then;

/// Create a copy of ColorPickerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeColor = null,Object? history = null,}) {
  return _then(_ColorPickerState(
activeColor: null == activeColor ? _self.activeColor : activeColor // ignore: cast_nullable_to_non_nullable
as Color,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<Color>,
  ));
}


}

// dart format on
