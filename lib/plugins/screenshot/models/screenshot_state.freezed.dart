// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'screenshot_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScreenshotState {

 CaptureMode get captureMode; String get format; int get delaySeconds; bool get includeCursor; bool get isCapturing; ScreenshotTool get currentTool; Color get annotationColor; bool get isOverlayVisible; Rect? get selectionRect; List<Annotation> get annotations;
/// Create a copy of ScreenshotState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScreenshotStateCopyWith<ScreenshotState> get copyWith => _$ScreenshotStateCopyWithImpl<ScreenshotState>(this as ScreenshotState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScreenshotState&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.format, format) || other.format == format)&&(identical(other.delaySeconds, delaySeconds) || other.delaySeconds == delaySeconds)&&(identical(other.includeCursor, includeCursor) || other.includeCursor == includeCursor)&&(identical(other.isCapturing, isCapturing) || other.isCapturing == isCapturing)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&(identical(other.isOverlayVisible, isOverlayVisible) || other.isOverlayVisible == isOverlayVisible)&&(identical(other.selectionRect, selectionRect) || other.selectionRect == selectionRect)&&const DeepCollectionEquality().equals(other.annotations, annotations));
}


@override
int get hashCode => Object.hash(runtimeType,captureMode,format,delaySeconds,includeCursor,isCapturing,currentTool,annotationColor,isOverlayVisible,selectionRect,const DeepCollectionEquality().hash(annotations));

@override
String toString() {
  return 'ScreenshotState(captureMode: $captureMode, format: $format, delaySeconds: $delaySeconds, includeCursor: $includeCursor, isCapturing: $isCapturing, currentTool: $currentTool, annotationColor: $annotationColor, isOverlayVisible: $isOverlayVisible, selectionRect: $selectionRect, annotations: $annotations)';
}


}

/// @nodoc
abstract mixin class $ScreenshotStateCopyWith<$Res>  {
  factory $ScreenshotStateCopyWith(ScreenshotState value, $Res Function(ScreenshotState) _then) = _$ScreenshotStateCopyWithImpl;
@useResult
$Res call({
 CaptureMode captureMode, String format, int delaySeconds, bool includeCursor, bool isCapturing, ScreenshotTool currentTool, Color annotationColor, bool isOverlayVisible, Rect? selectionRect, List<Annotation> annotations
});




}
/// @nodoc
class _$ScreenshotStateCopyWithImpl<$Res>
    implements $ScreenshotStateCopyWith<$Res> {
  _$ScreenshotStateCopyWithImpl(this._self, this._then);

  final ScreenshotState _self;
  final $Res Function(ScreenshotState) _then;

/// Create a copy of ScreenshotState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? captureMode = null,Object? format = null,Object? delaySeconds = null,Object? includeCursor = null,Object? isCapturing = null,Object? currentTool = null,Object? annotationColor = null,Object? isOverlayVisible = null,Object? selectionRect = freezed,Object? annotations = null,}) {
  return _then(_self.copyWith(
captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,delaySeconds: null == delaySeconds ? _self.delaySeconds : delaySeconds // ignore: cast_nullable_to_non_nullable
as int,includeCursor: null == includeCursor ? _self.includeCursor : includeCursor // ignore: cast_nullable_to_non_nullable
as bool,isCapturing: null == isCapturing ? _self.isCapturing : isCapturing // ignore: cast_nullable_to_non_nullable
as bool,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,isOverlayVisible: null == isOverlayVisible ? _self.isOverlayVisible : isOverlayVisible // ignore: cast_nullable_to_non_nullable
as bool,selectionRect: freezed == selectionRect ? _self.selectionRect : selectionRect // ignore: cast_nullable_to_non_nullable
as Rect?,annotations: null == annotations ? _self.annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,
  ));
}

}


/// Adds pattern-matching-related methods to [ScreenshotState].
extension ScreenshotStatePatterns on ScreenshotState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScreenshotState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScreenshotState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScreenshotState value)  $default,){
final _that = this;
switch (_that) {
case _ScreenshotState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScreenshotState value)?  $default,){
final _that = this;
switch (_that) {
case _ScreenshotState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CaptureMode captureMode,  String format,  int delaySeconds,  bool includeCursor,  bool isCapturing,  ScreenshotTool currentTool,  Color annotationColor,  bool isOverlayVisible,  Rect? selectionRect,  List<Annotation> annotations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScreenshotState() when $default != null:
return $default(_that.captureMode,_that.format,_that.delaySeconds,_that.includeCursor,_that.isCapturing,_that.currentTool,_that.annotationColor,_that.isOverlayVisible,_that.selectionRect,_that.annotations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CaptureMode captureMode,  String format,  int delaySeconds,  bool includeCursor,  bool isCapturing,  ScreenshotTool currentTool,  Color annotationColor,  bool isOverlayVisible,  Rect? selectionRect,  List<Annotation> annotations)  $default,) {final _that = this;
switch (_that) {
case _ScreenshotState():
return $default(_that.captureMode,_that.format,_that.delaySeconds,_that.includeCursor,_that.isCapturing,_that.currentTool,_that.annotationColor,_that.isOverlayVisible,_that.selectionRect,_that.annotations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CaptureMode captureMode,  String format,  int delaySeconds,  bool includeCursor,  bool isCapturing,  ScreenshotTool currentTool,  Color annotationColor,  bool isOverlayVisible,  Rect? selectionRect,  List<Annotation> annotations)?  $default,) {final _that = this;
switch (_that) {
case _ScreenshotState() when $default != null:
return $default(_that.captureMode,_that.format,_that.delaySeconds,_that.includeCursor,_that.isCapturing,_that.currentTool,_that.annotationColor,_that.isOverlayVisible,_that.selectionRect,_that.annotations);case _:
  return null;

}
}

}

/// @nodoc


class _ScreenshotState implements ScreenshotState {
  const _ScreenshotState({this.captureMode = CaptureMode.area, this.format = 'PNG', this.delaySeconds = 0, this.includeCursor = true, this.isCapturing = false, this.currentTool = ScreenshotTool.pen, this.annotationColor = Colors.red, this.isOverlayVisible = false, this.selectionRect = null, final  List<Annotation> annotations = const []}): _annotations = annotations;
  

@override@JsonKey() final  CaptureMode captureMode;
@override@JsonKey() final  String format;
@override@JsonKey() final  int delaySeconds;
@override@JsonKey() final  bool includeCursor;
@override@JsonKey() final  bool isCapturing;
@override@JsonKey() final  ScreenshotTool currentTool;
@override@JsonKey() final  Color annotationColor;
@override@JsonKey() final  bool isOverlayVisible;
@override@JsonKey() final  Rect? selectionRect;
 final  List<Annotation> _annotations;
@override@JsonKey() List<Annotation> get annotations {
  if (_annotations is EqualUnmodifiableListView) return _annotations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_annotations);
}


/// Create a copy of ScreenshotState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScreenshotStateCopyWith<_ScreenshotState> get copyWith => __$ScreenshotStateCopyWithImpl<_ScreenshotState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScreenshotState&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.format, format) || other.format == format)&&(identical(other.delaySeconds, delaySeconds) || other.delaySeconds == delaySeconds)&&(identical(other.includeCursor, includeCursor) || other.includeCursor == includeCursor)&&(identical(other.isCapturing, isCapturing) || other.isCapturing == isCapturing)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&(identical(other.isOverlayVisible, isOverlayVisible) || other.isOverlayVisible == isOverlayVisible)&&(identical(other.selectionRect, selectionRect) || other.selectionRect == selectionRect)&&const DeepCollectionEquality().equals(other._annotations, _annotations));
}


@override
int get hashCode => Object.hash(runtimeType,captureMode,format,delaySeconds,includeCursor,isCapturing,currentTool,annotationColor,isOverlayVisible,selectionRect,const DeepCollectionEquality().hash(_annotations));

@override
String toString() {
  return 'ScreenshotState(captureMode: $captureMode, format: $format, delaySeconds: $delaySeconds, includeCursor: $includeCursor, isCapturing: $isCapturing, currentTool: $currentTool, annotationColor: $annotationColor, isOverlayVisible: $isOverlayVisible, selectionRect: $selectionRect, annotations: $annotations)';
}


}

/// @nodoc
abstract mixin class _$ScreenshotStateCopyWith<$Res> implements $ScreenshotStateCopyWith<$Res> {
  factory _$ScreenshotStateCopyWith(_ScreenshotState value, $Res Function(_ScreenshotState) _then) = __$ScreenshotStateCopyWithImpl;
@override @useResult
$Res call({
 CaptureMode captureMode, String format, int delaySeconds, bool includeCursor, bool isCapturing, ScreenshotTool currentTool, Color annotationColor, bool isOverlayVisible, Rect? selectionRect, List<Annotation> annotations
});




}
/// @nodoc
class __$ScreenshotStateCopyWithImpl<$Res>
    implements _$ScreenshotStateCopyWith<$Res> {
  __$ScreenshotStateCopyWithImpl(this._self, this._then);

  final _ScreenshotState _self;
  final $Res Function(_ScreenshotState) _then;

/// Create a copy of ScreenshotState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? captureMode = null,Object? format = null,Object? delaySeconds = null,Object? includeCursor = null,Object? isCapturing = null,Object? currentTool = null,Object? annotationColor = null,Object? isOverlayVisible = null,Object? selectionRect = freezed,Object? annotations = null,}) {
  return _then(_ScreenshotState(
captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,delaySeconds: null == delaySeconds ? _self.delaySeconds : delaySeconds // ignore: cast_nullable_to_non_nullable
as int,includeCursor: null == includeCursor ? _self.includeCursor : includeCursor // ignore: cast_nullable_to_non_nullable
as bool,isCapturing: null == isCapturing ? _self.isCapturing : isCapturing // ignore: cast_nullable_to_non_nullable
as bool,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,isOverlayVisible: null == isOverlayVisible ? _self.isOverlayVisible : isOverlayVisible // ignore: cast_nullable_to_non_nullable
as bool,selectionRect: freezed == selectionRect ? _self.selectionRect : selectionRect // ignore: cast_nullable_to_non_nullable
as Rect?,annotations: null == annotations ? _self._annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,
  ));
}


}

// dart format on
