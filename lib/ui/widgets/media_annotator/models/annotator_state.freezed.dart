// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'annotator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnnotatorState {

 String get filePath; String get format; ScreenshotTool get currentTool; Color get annotationColor; List<Annotation> get annotations; bool get isProcessing; bool get textHasBackground;
/// Create a copy of AnnotatorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnotatorStateCopyWith<AnnotatorState> get copyWith => _$AnnotatorStateCopyWithImpl<AnnotatorState>(this as AnnotatorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnnotatorState&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.format, format) || other.format == format)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&const DeepCollectionEquality().equals(other.annotations, annotations)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&(identical(other.textHasBackground, textHasBackground) || other.textHasBackground == textHasBackground));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,format,currentTool,annotationColor,const DeepCollectionEquality().hash(annotations),isProcessing,textHasBackground);

@override
String toString() {
  return 'AnnotatorState(filePath: $filePath, format: $format, currentTool: $currentTool, annotationColor: $annotationColor, annotations: $annotations, isProcessing: $isProcessing, textHasBackground: $textHasBackground)';
}


}

/// @nodoc
abstract mixin class $AnnotatorStateCopyWith<$Res>  {
  factory $AnnotatorStateCopyWith(AnnotatorState value, $Res Function(AnnotatorState) _then) = _$AnnotatorStateCopyWithImpl;
@useResult
$Res call({
 String filePath, String format, ScreenshotTool currentTool, Color annotationColor, List<Annotation> annotations, bool isProcessing, bool textHasBackground
});




}
/// @nodoc
class _$AnnotatorStateCopyWithImpl<$Res>
    implements $AnnotatorStateCopyWith<$Res> {
  _$AnnotatorStateCopyWithImpl(this._self, this._then);

  final AnnotatorState _self;
  final $Res Function(AnnotatorState) _then;

/// Create a copy of AnnotatorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePath = null,Object? format = null,Object? currentTool = null,Object? annotationColor = null,Object? annotations = null,Object? isProcessing = null,Object? textHasBackground = null,}) {
  return _then(_self.copyWith(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,annotations: null == annotations ? _self.annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,textHasBackground: null == textHasBackground ? _self.textHasBackground : textHasBackground // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AnnotatorState].
extension AnnotatorStatePatterns on AnnotatorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnnotatorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnnotatorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnnotatorState value)  $default,){
final _that = this;
switch (_that) {
case _AnnotatorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnnotatorState value)?  $default,){
final _that = this;
switch (_that) {
case _AnnotatorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String filePath,  String format,  ScreenshotTool currentTool,  Color annotationColor,  List<Annotation> annotations,  bool isProcessing,  bool textHasBackground)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnnotatorState() when $default != null:
return $default(_that.filePath,_that.format,_that.currentTool,_that.annotationColor,_that.annotations,_that.isProcessing,_that.textHasBackground);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String filePath,  String format,  ScreenshotTool currentTool,  Color annotationColor,  List<Annotation> annotations,  bool isProcessing,  bool textHasBackground)  $default,) {final _that = this;
switch (_that) {
case _AnnotatorState():
return $default(_that.filePath,_that.format,_that.currentTool,_that.annotationColor,_that.annotations,_that.isProcessing,_that.textHasBackground);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String filePath,  String format,  ScreenshotTool currentTool,  Color annotationColor,  List<Annotation> annotations,  bool isProcessing,  bool textHasBackground)?  $default,) {final _that = this;
switch (_that) {
case _AnnotatorState() when $default != null:
return $default(_that.filePath,_that.format,_that.currentTool,_that.annotationColor,_that.annotations,_that.isProcessing,_that.textHasBackground);case _:
  return null;

}
}

}

/// @nodoc


class _AnnotatorState implements AnnotatorState {
  const _AnnotatorState({required this.filePath, required this.format, this.currentTool = ScreenshotTool.pen, this.annotationColor = Colors.red, final  List<Annotation> annotations = const [], this.isProcessing = false, this.textHasBackground = false}): _annotations = annotations;
  

@override final  String filePath;
@override final  String format;
@override@JsonKey() final  ScreenshotTool currentTool;
@override@JsonKey() final  Color annotationColor;
 final  List<Annotation> _annotations;
@override@JsonKey() List<Annotation> get annotations {
  if (_annotations is EqualUnmodifiableListView) return _annotations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_annotations);
}

@override@JsonKey() final  bool isProcessing;
@override@JsonKey() final  bool textHasBackground;

/// Create a copy of AnnotatorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnotatorStateCopyWith<_AnnotatorState> get copyWith => __$AnnotatorStateCopyWithImpl<_AnnotatorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnnotatorState&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.format, format) || other.format == format)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&const DeepCollectionEquality().equals(other._annotations, _annotations)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&(identical(other.textHasBackground, textHasBackground) || other.textHasBackground == textHasBackground));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,format,currentTool,annotationColor,const DeepCollectionEquality().hash(_annotations),isProcessing,textHasBackground);

@override
String toString() {
  return 'AnnotatorState(filePath: $filePath, format: $format, currentTool: $currentTool, annotationColor: $annotationColor, annotations: $annotations, isProcessing: $isProcessing, textHasBackground: $textHasBackground)';
}


}

/// @nodoc
abstract mixin class _$AnnotatorStateCopyWith<$Res> implements $AnnotatorStateCopyWith<$Res> {
  factory _$AnnotatorStateCopyWith(_AnnotatorState value, $Res Function(_AnnotatorState) _then) = __$AnnotatorStateCopyWithImpl;
@override @useResult
$Res call({
 String filePath, String format, ScreenshotTool currentTool, Color annotationColor, List<Annotation> annotations, bool isProcessing, bool textHasBackground
});




}
/// @nodoc
class __$AnnotatorStateCopyWithImpl<$Res>
    implements _$AnnotatorStateCopyWith<$Res> {
  __$AnnotatorStateCopyWithImpl(this._self, this._then);

  final _AnnotatorState _self;
  final $Res Function(_AnnotatorState) _then;

/// Create a copy of AnnotatorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? format = null,Object? currentTool = null,Object? annotationColor = null,Object? annotations = null,Object? isProcessing = null,Object? textHasBackground = null,}) {
  return _then(_AnnotatorState(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,annotations: null == annotations ? _self._annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,textHasBackground: null == textHasBackground ? _self.textHasBackground : textHasBackground // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
