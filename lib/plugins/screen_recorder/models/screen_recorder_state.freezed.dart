// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'screen_recorder_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScreenRecorderState {

 bool get isRecording; bool get isPaused; int get durationSeconds; bool get microphoneEnabled; bool get systemAudioEnabled; bool get showCursor; String get resolution; String get format; CaptureMode get captureMode; String get targetWindowName; bool get isOverlayVisible; List<Annotation> get annotations; ScreenshotTool get currentTool; Color get annotationColor; int get delaySeconds; Rect? get selectionRect;
/// Create a copy of ScreenRecorderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScreenRecorderStateCopyWith<ScreenRecorderState> get copyWith => _$ScreenRecorderStateCopyWithImpl<ScreenRecorderState>(this as ScreenRecorderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScreenRecorderState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.microphoneEnabled, microphoneEnabled) || other.microphoneEnabled == microphoneEnabled)&&(identical(other.systemAudioEnabled, systemAudioEnabled) || other.systemAudioEnabled == systemAudioEnabled)&&(identical(other.showCursor, showCursor) || other.showCursor == showCursor)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.format, format) || other.format == format)&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.targetWindowName, targetWindowName) || other.targetWindowName == targetWindowName)&&(identical(other.isOverlayVisible, isOverlayVisible) || other.isOverlayVisible == isOverlayVisible)&&const DeepCollectionEquality().equals(other.annotations, annotations)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&(identical(other.delaySeconds, delaySeconds) || other.delaySeconds == delaySeconds)&&(identical(other.selectionRect, selectionRect) || other.selectionRect == selectionRect));
}


@override
int get hashCode => Object.hash(runtimeType,isRecording,isPaused,durationSeconds,microphoneEnabled,systemAudioEnabled,showCursor,resolution,format,captureMode,targetWindowName,isOverlayVisible,const DeepCollectionEquality().hash(annotations),currentTool,annotationColor,delaySeconds,selectionRect);

@override
String toString() {
  return 'ScreenRecorderState(isRecording: $isRecording, isPaused: $isPaused, durationSeconds: $durationSeconds, microphoneEnabled: $microphoneEnabled, systemAudioEnabled: $systemAudioEnabled, showCursor: $showCursor, resolution: $resolution, format: $format, captureMode: $captureMode, targetWindowName: $targetWindowName, isOverlayVisible: $isOverlayVisible, annotations: $annotations, currentTool: $currentTool, annotationColor: $annotationColor, delaySeconds: $delaySeconds, selectionRect: $selectionRect)';
}


}

/// @nodoc
abstract mixin class $ScreenRecorderStateCopyWith<$Res>  {
  factory $ScreenRecorderStateCopyWith(ScreenRecorderState value, $Res Function(ScreenRecorderState) _then) = _$ScreenRecorderStateCopyWithImpl;
@useResult
$Res call({
 bool isRecording, bool isPaused, int durationSeconds, bool microphoneEnabled, bool systemAudioEnabled, bool showCursor, String resolution, String format, CaptureMode captureMode, String targetWindowName, bool isOverlayVisible, List<Annotation> annotations, ScreenshotTool currentTool, Color annotationColor, int delaySeconds, Rect? selectionRect
});




}
/// @nodoc
class _$ScreenRecorderStateCopyWithImpl<$Res>
    implements $ScreenRecorderStateCopyWith<$Res> {
  _$ScreenRecorderStateCopyWithImpl(this._self, this._then);

  final ScreenRecorderState _self;
  final $Res Function(ScreenRecorderState) _then;

/// Create a copy of ScreenRecorderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRecording = null,Object? isPaused = null,Object? durationSeconds = null,Object? microphoneEnabled = null,Object? systemAudioEnabled = null,Object? showCursor = null,Object? resolution = null,Object? format = null,Object? captureMode = null,Object? targetWindowName = null,Object? isOverlayVisible = null,Object? annotations = null,Object? currentTool = null,Object? annotationColor = null,Object? delaySeconds = null,Object? selectionRect = freezed,}) {
  return _then(_self.copyWith(
isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,microphoneEnabled: null == microphoneEnabled ? _self.microphoneEnabled : microphoneEnabled // ignore: cast_nullable_to_non_nullable
as bool,systemAudioEnabled: null == systemAudioEnabled ? _self.systemAudioEnabled : systemAudioEnabled // ignore: cast_nullable_to_non_nullable
as bool,showCursor: null == showCursor ? _self.showCursor : showCursor // ignore: cast_nullable_to_non_nullable
as bool,resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,targetWindowName: null == targetWindowName ? _self.targetWindowName : targetWindowName // ignore: cast_nullable_to_non_nullable
as String,isOverlayVisible: null == isOverlayVisible ? _self.isOverlayVisible : isOverlayVisible // ignore: cast_nullable_to_non_nullable
as bool,annotations: null == annotations ? _self.annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,delaySeconds: null == delaySeconds ? _self.delaySeconds : delaySeconds // ignore: cast_nullable_to_non_nullable
as int,selectionRect: freezed == selectionRect ? _self.selectionRect : selectionRect // ignore: cast_nullable_to_non_nullable
as Rect?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScreenRecorderState].
extension ScreenRecorderStatePatterns on ScreenRecorderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScreenRecorderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScreenRecorderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScreenRecorderState value)  $default,){
final _that = this;
switch (_that) {
case _ScreenRecorderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScreenRecorderState value)?  $default,){
final _that = this;
switch (_that) {
case _ScreenRecorderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRecording,  bool isPaused,  int durationSeconds,  bool microphoneEnabled,  bool systemAudioEnabled,  bool showCursor,  String resolution,  String format,  CaptureMode captureMode,  String targetWindowName,  bool isOverlayVisible,  List<Annotation> annotations,  ScreenshotTool currentTool,  Color annotationColor,  int delaySeconds,  Rect? selectionRect)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScreenRecorderState() when $default != null:
return $default(_that.isRecording,_that.isPaused,_that.durationSeconds,_that.microphoneEnabled,_that.systemAudioEnabled,_that.showCursor,_that.resolution,_that.format,_that.captureMode,_that.targetWindowName,_that.isOverlayVisible,_that.annotations,_that.currentTool,_that.annotationColor,_that.delaySeconds,_that.selectionRect);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRecording,  bool isPaused,  int durationSeconds,  bool microphoneEnabled,  bool systemAudioEnabled,  bool showCursor,  String resolution,  String format,  CaptureMode captureMode,  String targetWindowName,  bool isOverlayVisible,  List<Annotation> annotations,  ScreenshotTool currentTool,  Color annotationColor,  int delaySeconds,  Rect? selectionRect)  $default,) {final _that = this;
switch (_that) {
case _ScreenRecorderState():
return $default(_that.isRecording,_that.isPaused,_that.durationSeconds,_that.microphoneEnabled,_that.systemAudioEnabled,_that.showCursor,_that.resolution,_that.format,_that.captureMode,_that.targetWindowName,_that.isOverlayVisible,_that.annotations,_that.currentTool,_that.annotationColor,_that.delaySeconds,_that.selectionRect);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRecording,  bool isPaused,  int durationSeconds,  bool microphoneEnabled,  bool systemAudioEnabled,  bool showCursor,  String resolution,  String format,  CaptureMode captureMode,  String targetWindowName,  bool isOverlayVisible,  List<Annotation> annotations,  ScreenshotTool currentTool,  Color annotationColor,  int delaySeconds,  Rect? selectionRect)?  $default,) {final _that = this;
switch (_that) {
case _ScreenRecorderState() when $default != null:
return $default(_that.isRecording,_that.isPaused,_that.durationSeconds,_that.microphoneEnabled,_that.systemAudioEnabled,_that.showCursor,_that.resolution,_that.format,_that.captureMode,_that.targetWindowName,_that.isOverlayVisible,_that.annotations,_that.currentTool,_that.annotationColor,_that.delaySeconds,_that.selectionRect);case _:
  return null;

}
}

}

/// @nodoc


class _ScreenRecorderState implements ScreenRecorderState {
  const _ScreenRecorderState({this.isRecording = false, this.isPaused = false, this.durationSeconds = 0, this.microphoneEnabled = true, this.systemAudioEnabled = true, this.showCursor = true, this.resolution = '1080p', this.format = 'MP4', this.captureMode = CaptureMode.fullScreen, this.targetWindowName = 'Active Window', this.isOverlayVisible = false, final  List<Annotation> annotations = const [], this.currentTool = ScreenshotTool.pen, this.annotationColor = Colors.red, this.delaySeconds = 0, this.selectionRect}): _annotations = annotations;
  

@override@JsonKey() final  bool isRecording;
@override@JsonKey() final  bool isPaused;
@override@JsonKey() final  int durationSeconds;
@override@JsonKey() final  bool microphoneEnabled;
@override@JsonKey() final  bool systemAudioEnabled;
@override@JsonKey() final  bool showCursor;
@override@JsonKey() final  String resolution;
@override@JsonKey() final  String format;
@override@JsonKey() final  CaptureMode captureMode;
@override@JsonKey() final  String targetWindowName;
@override@JsonKey() final  bool isOverlayVisible;
 final  List<Annotation> _annotations;
@override@JsonKey() List<Annotation> get annotations {
  if (_annotations is EqualUnmodifiableListView) return _annotations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_annotations);
}

@override@JsonKey() final  ScreenshotTool currentTool;
@override@JsonKey() final  Color annotationColor;
@override@JsonKey() final  int delaySeconds;
@override final  Rect? selectionRect;

/// Create a copy of ScreenRecorderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScreenRecorderStateCopyWith<_ScreenRecorderState> get copyWith => __$ScreenRecorderStateCopyWithImpl<_ScreenRecorderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScreenRecorderState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.microphoneEnabled, microphoneEnabled) || other.microphoneEnabled == microphoneEnabled)&&(identical(other.systemAudioEnabled, systemAudioEnabled) || other.systemAudioEnabled == systemAudioEnabled)&&(identical(other.showCursor, showCursor) || other.showCursor == showCursor)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.format, format) || other.format == format)&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.targetWindowName, targetWindowName) || other.targetWindowName == targetWindowName)&&(identical(other.isOverlayVisible, isOverlayVisible) || other.isOverlayVisible == isOverlayVisible)&&const DeepCollectionEquality().equals(other._annotations, _annotations)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&(identical(other.delaySeconds, delaySeconds) || other.delaySeconds == delaySeconds)&&(identical(other.selectionRect, selectionRect) || other.selectionRect == selectionRect));
}


@override
int get hashCode => Object.hash(runtimeType,isRecording,isPaused,durationSeconds,microphoneEnabled,systemAudioEnabled,showCursor,resolution,format,captureMode,targetWindowName,isOverlayVisible,const DeepCollectionEquality().hash(_annotations),currentTool,annotationColor,delaySeconds,selectionRect);

@override
String toString() {
  return 'ScreenRecorderState(isRecording: $isRecording, isPaused: $isPaused, durationSeconds: $durationSeconds, microphoneEnabled: $microphoneEnabled, systemAudioEnabled: $systemAudioEnabled, showCursor: $showCursor, resolution: $resolution, format: $format, captureMode: $captureMode, targetWindowName: $targetWindowName, isOverlayVisible: $isOverlayVisible, annotations: $annotations, currentTool: $currentTool, annotationColor: $annotationColor, delaySeconds: $delaySeconds, selectionRect: $selectionRect)';
}


}

/// @nodoc
abstract mixin class _$ScreenRecorderStateCopyWith<$Res> implements $ScreenRecorderStateCopyWith<$Res> {
  factory _$ScreenRecorderStateCopyWith(_ScreenRecorderState value, $Res Function(_ScreenRecorderState) _then) = __$ScreenRecorderStateCopyWithImpl;
@override @useResult
$Res call({
 bool isRecording, bool isPaused, int durationSeconds, bool microphoneEnabled, bool systemAudioEnabled, bool showCursor, String resolution, String format, CaptureMode captureMode, String targetWindowName, bool isOverlayVisible, List<Annotation> annotations, ScreenshotTool currentTool, Color annotationColor, int delaySeconds, Rect? selectionRect
});




}
/// @nodoc
class __$ScreenRecorderStateCopyWithImpl<$Res>
    implements _$ScreenRecorderStateCopyWith<$Res> {
  __$ScreenRecorderStateCopyWithImpl(this._self, this._then);

  final _ScreenRecorderState _self;
  final $Res Function(_ScreenRecorderState) _then;

/// Create a copy of ScreenRecorderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRecording = null,Object? isPaused = null,Object? durationSeconds = null,Object? microphoneEnabled = null,Object? systemAudioEnabled = null,Object? showCursor = null,Object? resolution = null,Object? format = null,Object? captureMode = null,Object? targetWindowName = null,Object? isOverlayVisible = null,Object? annotations = null,Object? currentTool = null,Object? annotationColor = null,Object? delaySeconds = null,Object? selectionRect = freezed,}) {
  return _then(_ScreenRecorderState(
isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,microphoneEnabled: null == microphoneEnabled ? _self.microphoneEnabled : microphoneEnabled // ignore: cast_nullable_to_non_nullable
as bool,systemAudioEnabled: null == systemAudioEnabled ? _self.systemAudioEnabled : systemAudioEnabled // ignore: cast_nullable_to_non_nullable
as bool,showCursor: null == showCursor ? _self.showCursor : showCursor // ignore: cast_nullable_to_non_nullable
as bool,resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,targetWindowName: null == targetWindowName ? _self.targetWindowName : targetWindowName // ignore: cast_nullable_to_non_nullable
as String,isOverlayVisible: null == isOverlayVisible ? _self.isOverlayVisible : isOverlayVisible // ignore: cast_nullable_to_non_nullable
as bool,annotations: null == annotations ? _self._annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,delaySeconds: null == delaySeconds ? _self.delaySeconds : delaySeconds // ignore: cast_nullable_to_non_nullable
as int,selectionRect: freezed == selectionRect ? _self.selectionRect : selectionRect // ignore: cast_nullable_to_non_nullable
as Rect?,
  ));
}


}

// dart format on
