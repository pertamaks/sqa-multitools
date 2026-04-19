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

 bool get isRecording; bool get isPaused; int get durationSeconds; bool get microphoneEnabled; bool get systemAudioEnabled; bool get showCursor; String get resolution; String get format; CaptureMode get captureMode; String get targetWindowName; bool get isOverlayVisible; bool get isTargetingWindow; Rect? get targetedWindowRect; int? get targetedWindowHwnd; List<String> get availableAudioDevices; String? get selectedAudioDevice; Color get clickFeedbackColor; Color get rightClickFeedbackColor; List<Annotation> get annotations; ScreenshotTool get currentTool; Color get annotationColor; int get delaySeconds; int get countdownSeconds;// Live countdown before recording starts
 int get framerate; String? get saveDirectory; Size? get previousWindowSize; Offset? get previousWindowPos; Rect? get selectionRect; Rect? get captureRect; List<Display> get availableDisplays; Map<String, String> get monitorNames;// id -> friendlyName
 Map<String, String> get displayThumbnails;// id -> filePath
 String? get primaryDisplayId; List<RecordingInfo> get recentRecordings;@JsonKey(includeFromJson: false, includeToJson: false) HotKey? get registeredHotKey;
/// Create a copy of ScreenRecorderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScreenRecorderStateCopyWith<ScreenRecorderState> get copyWith => _$ScreenRecorderStateCopyWithImpl<ScreenRecorderState>(this as ScreenRecorderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScreenRecorderState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.microphoneEnabled, microphoneEnabled) || other.microphoneEnabled == microphoneEnabled)&&(identical(other.systemAudioEnabled, systemAudioEnabled) || other.systemAudioEnabled == systemAudioEnabled)&&(identical(other.showCursor, showCursor) || other.showCursor == showCursor)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.format, format) || other.format == format)&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.targetWindowName, targetWindowName) || other.targetWindowName == targetWindowName)&&(identical(other.isOverlayVisible, isOverlayVisible) || other.isOverlayVisible == isOverlayVisible)&&(identical(other.isTargetingWindow, isTargetingWindow) || other.isTargetingWindow == isTargetingWindow)&&(identical(other.targetedWindowRect, targetedWindowRect) || other.targetedWindowRect == targetedWindowRect)&&(identical(other.targetedWindowHwnd, targetedWindowHwnd) || other.targetedWindowHwnd == targetedWindowHwnd)&&const DeepCollectionEquality().equals(other.availableAudioDevices, availableAudioDevices)&&(identical(other.selectedAudioDevice, selectedAudioDevice) || other.selectedAudioDevice == selectedAudioDevice)&&(identical(other.clickFeedbackColor, clickFeedbackColor) || other.clickFeedbackColor == clickFeedbackColor)&&(identical(other.rightClickFeedbackColor, rightClickFeedbackColor) || other.rightClickFeedbackColor == rightClickFeedbackColor)&&const DeepCollectionEquality().equals(other.annotations, annotations)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&(identical(other.delaySeconds, delaySeconds) || other.delaySeconds == delaySeconds)&&(identical(other.countdownSeconds, countdownSeconds) || other.countdownSeconds == countdownSeconds)&&(identical(other.framerate, framerate) || other.framerate == framerate)&&(identical(other.saveDirectory, saveDirectory) || other.saveDirectory == saveDirectory)&&(identical(other.previousWindowSize, previousWindowSize) || other.previousWindowSize == previousWindowSize)&&(identical(other.previousWindowPos, previousWindowPos) || other.previousWindowPos == previousWindowPos)&&(identical(other.selectionRect, selectionRect) || other.selectionRect == selectionRect)&&(identical(other.captureRect, captureRect) || other.captureRect == captureRect)&&const DeepCollectionEquality().equals(other.availableDisplays, availableDisplays)&&const DeepCollectionEquality().equals(other.monitorNames, monitorNames)&&const DeepCollectionEquality().equals(other.displayThumbnails, displayThumbnails)&&(identical(other.primaryDisplayId, primaryDisplayId) || other.primaryDisplayId == primaryDisplayId)&&const DeepCollectionEquality().equals(other.recentRecordings, recentRecordings)&&(identical(other.registeredHotKey, registeredHotKey) || other.registeredHotKey == registeredHotKey));
}


@override
int get hashCode => Object.hashAll([runtimeType,isRecording,isPaused,durationSeconds,microphoneEnabled,systemAudioEnabled,showCursor,resolution,format,captureMode,targetWindowName,isOverlayVisible,isTargetingWindow,targetedWindowRect,targetedWindowHwnd,const DeepCollectionEquality().hash(availableAudioDevices),selectedAudioDevice,clickFeedbackColor,rightClickFeedbackColor,const DeepCollectionEquality().hash(annotations),currentTool,annotationColor,delaySeconds,countdownSeconds,framerate,saveDirectory,previousWindowSize,previousWindowPos,selectionRect,captureRect,const DeepCollectionEquality().hash(availableDisplays),const DeepCollectionEquality().hash(monitorNames),const DeepCollectionEquality().hash(displayThumbnails),primaryDisplayId,const DeepCollectionEquality().hash(recentRecordings),registeredHotKey]);

@override
String toString() {
  return 'ScreenRecorderState(isRecording: $isRecording, isPaused: $isPaused, durationSeconds: $durationSeconds, microphoneEnabled: $microphoneEnabled, systemAudioEnabled: $systemAudioEnabled, showCursor: $showCursor, resolution: $resolution, format: $format, captureMode: $captureMode, targetWindowName: $targetWindowName, isOverlayVisible: $isOverlayVisible, isTargetingWindow: $isTargetingWindow, targetedWindowRect: $targetedWindowRect, targetedWindowHwnd: $targetedWindowHwnd, availableAudioDevices: $availableAudioDevices, selectedAudioDevice: $selectedAudioDevice, clickFeedbackColor: $clickFeedbackColor, rightClickFeedbackColor: $rightClickFeedbackColor, annotations: $annotations, currentTool: $currentTool, annotationColor: $annotationColor, delaySeconds: $delaySeconds, countdownSeconds: $countdownSeconds, framerate: $framerate, saveDirectory: $saveDirectory, previousWindowSize: $previousWindowSize, previousWindowPos: $previousWindowPos, selectionRect: $selectionRect, captureRect: $captureRect, availableDisplays: $availableDisplays, monitorNames: $monitorNames, displayThumbnails: $displayThumbnails, primaryDisplayId: $primaryDisplayId, recentRecordings: $recentRecordings, registeredHotKey: $registeredHotKey)';
}


}

/// @nodoc
abstract mixin class $ScreenRecorderStateCopyWith<$Res>  {
  factory $ScreenRecorderStateCopyWith(ScreenRecorderState value, $Res Function(ScreenRecorderState) _then) = _$ScreenRecorderStateCopyWithImpl;
@useResult
$Res call({
 bool isRecording, bool isPaused, int durationSeconds, bool microphoneEnabled, bool systemAudioEnabled, bool showCursor, String resolution, String format, CaptureMode captureMode, String targetWindowName, bool isOverlayVisible, bool isTargetingWindow, Rect? targetedWindowRect, int? targetedWindowHwnd, List<String> availableAudioDevices, String? selectedAudioDevice, Color clickFeedbackColor, Color rightClickFeedbackColor, List<Annotation> annotations, ScreenshotTool currentTool, Color annotationColor, int delaySeconds, int countdownSeconds, int framerate, String? saveDirectory, Size? previousWindowSize, Offset? previousWindowPos, Rect? selectionRect, Rect? captureRect, List<Display> availableDisplays, Map<String, String> monitorNames, Map<String, String> displayThumbnails, String? primaryDisplayId, List<RecordingInfo> recentRecordings,@JsonKey(includeFromJson: false, includeToJson: false) HotKey? registeredHotKey
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
@pragma('vm:prefer-inline') @override $Res call({Object? isRecording = null,Object? isPaused = null,Object? durationSeconds = null,Object? microphoneEnabled = null,Object? systemAudioEnabled = null,Object? showCursor = null,Object? resolution = null,Object? format = null,Object? captureMode = null,Object? targetWindowName = null,Object? isOverlayVisible = null,Object? isTargetingWindow = null,Object? targetedWindowRect = freezed,Object? targetedWindowHwnd = freezed,Object? availableAudioDevices = null,Object? selectedAudioDevice = freezed,Object? clickFeedbackColor = null,Object? rightClickFeedbackColor = null,Object? annotations = null,Object? currentTool = null,Object? annotationColor = null,Object? delaySeconds = null,Object? countdownSeconds = null,Object? framerate = null,Object? saveDirectory = freezed,Object? previousWindowSize = freezed,Object? previousWindowPos = freezed,Object? selectionRect = freezed,Object? captureRect = freezed,Object? availableDisplays = null,Object? monitorNames = null,Object? displayThumbnails = null,Object? primaryDisplayId = freezed,Object? recentRecordings = null,Object? registeredHotKey = freezed,}) {
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
as bool,isTargetingWindow: null == isTargetingWindow ? _self.isTargetingWindow : isTargetingWindow // ignore: cast_nullable_to_non_nullable
as bool,targetedWindowRect: freezed == targetedWindowRect ? _self.targetedWindowRect : targetedWindowRect // ignore: cast_nullable_to_non_nullable
as Rect?,targetedWindowHwnd: freezed == targetedWindowHwnd ? _self.targetedWindowHwnd : targetedWindowHwnd // ignore: cast_nullable_to_non_nullable
as int?,availableAudioDevices: null == availableAudioDevices ? _self.availableAudioDevices : availableAudioDevices // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAudioDevice: freezed == selectedAudioDevice ? _self.selectedAudioDevice : selectedAudioDevice // ignore: cast_nullable_to_non_nullable
as String?,clickFeedbackColor: null == clickFeedbackColor ? _self.clickFeedbackColor : clickFeedbackColor // ignore: cast_nullable_to_non_nullable
as Color,rightClickFeedbackColor: null == rightClickFeedbackColor ? _self.rightClickFeedbackColor : rightClickFeedbackColor // ignore: cast_nullable_to_non_nullable
as Color,annotations: null == annotations ? _self.annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,delaySeconds: null == delaySeconds ? _self.delaySeconds : delaySeconds // ignore: cast_nullable_to_non_nullable
as int,countdownSeconds: null == countdownSeconds ? _self.countdownSeconds : countdownSeconds // ignore: cast_nullable_to_non_nullable
as int,framerate: null == framerate ? _self.framerate : framerate // ignore: cast_nullable_to_non_nullable
as int,saveDirectory: freezed == saveDirectory ? _self.saveDirectory : saveDirectory // ignore: cast_nullable_to_non_nullable
as String?,previousWindowSize: freezed == previousWindowSize ? _self.previousWindowSize : previousWindowSize // ignore: cast_nullable_to_non_nullable
as Size?,previousWindowPos: freezed == previousWindowPos ? _self.previousWindowPos : previousWindowPos // ignore: cast_nullable_to_non_nullable
as Offset?,selectionRect: freezed == selectionRect ? _self.selectionRect : selectionRect // ignore: cast_nullable_to_non_nullable
as Rect?,captureRect: freezed == captureRect ? _self.captureRect : captureRect // ignore: cast_nullable_to_non_nullable
as Rect?,availableDisplays: null == availableDisplays ? _self.availableDisplays : availableDisplays // ignore: cast_nullable_to_non_nullable
as List<Display>,monitorNames: null == monitorNames ? _self.monitorNames : monitorNames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,displayThumbnails: null == displayThumbnails ? _self.displayThumbnails : displayThumbnails // ignore: cast_nullable_to_non_nullable
as Map<String, String>,primaryDisplayId: freezed == primaryDisplayId ? _self.primaryDisplayId : primaryDisplayId // ignore: cast_nullable_to_non_nullable
as String?,recentRecordings: null == recentRecordings ? _self.recentRecordings : recentRecordings // ignore: cast_nullable_to_non_nullable
as List<RecordingInfo>,registeredHotKey: freezed == registeredHotKey ? _self.registeredHotKey : registeredHotKey // ignore: cast_nullable_to_non_nullable
as HotKey?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRecording,  bool isPaused,  int durationSeconds,  bool microphoneEnabled,  bool systemAudioEnabled,  bool showCursor,  String resolution,  String format,  CaptureMode captureMode,  String targetWindowName,  bool isOverlayVisible,  bool isTargetingWindow,  Rect? targetedWindowRect,  int? targetedWindowHwnd,  List<String> availableAudioDevices,  String? selectedAudioDevice,  Color clickFeedbackColor,  Color rightClickFeedbackColor,  List<Annotation> annotations,  ScreenshotTool currentTool,  Color annotationColor,  int delaySeconds,  int countdownSeconds,  int framerate,  String? saveDirectory,  Size? previousWindowSize,  Offset? previousWindowPos,  Rect? selectionRect,  Rect? captureRect,  List<Display> availableDisplays,  Map<String, String> monitorNames,  Map<String, String> displayThumbnails,  String? primaryDisplayId,  List<RecordingInfo> recentRecordings, @JsonKey(includeFromJson: false, includeToJson: false)  HotKey? registeredHotKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScreenRecorderState() when $default != null:
return $default(_that.isRecording,_that.isPaused,_that.durationSeconds,_that.microphoneEnabled,_that.systemAudioEnabled,_that.showCursor,_that.resolution,_that.format,_that.captureMode,_that.targetWindowName,_that.isOverlayVisible,_that.isTargetingWindow,_that.targetedWindowRect,_that.targetedWindowHwnd,_that.availableAudioDevices,_that.selectedAudioDevice,_that.clickFeedbackColor,_that.rightClickFeedbackColor,_that.annotations,_that.currentTool,_that.annotationColor,_that.delaySeconds,_that.countdownSeconds,_that.framerate,_that.saveDirectory,_that.previousWindowSize,_that.previousWindowPos,_that.selectionRect,_that.captureRect,_that.availableDisplays,_that.monitorNames,_that.displayThumbnails,_that.primaryDisplayId,_that.recentRecordings,_that.registeredHotKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRecording,  bool isPaused,  int durationSeconds,  bool microphoneEnabled,  bool systemAudioEnabled,  bool showCursor,  String resolution,  String format,  CaptureMode captureMode,  String targetWindowName,  bool isOverlayVisible,  bool isTargetingWindow,  Rect? targetedWindowRect,  int? targetedWindowHwnd,  List<String> availableAudioDevices,  String? selectedAudioDevice,  Color clickFeedbackColor,  Color rightClickFeedbackColor,  List<Annotation> annotations,  ScreenshotTool currentTool,  Color annotationColor,  int delaySeconds,  int countdownSeconds,  int framerate,  String? saveDirectory,  Size? previousWindowSize,  Offset? previousWindowPos,  Rect? selectionRect,  Rect? captureRect,  List<Display> availableDisplays,  Map<String, String> monitorNames,  Map<String, String> displayThumbnails,  String? primaryDisplayId,  List<RecordingInfo> recentRecordings, @JsonKey(includeFromJson: false, includeToJson: false)  HotKey? registeredHotKey)  $default,) {final _that = this;
switch (_that) {
case _ScreenRecorderState():
return $default(_that.isRecording,_that.isPaused,_that.durationSeconds,_that.microphoneEnabled,_that.systemAudioEnabled,_that.showCursor,_that.resolution,_that.format,_that.captureMode,_that.targetWindowName,_that.isOverlayVisible,_that.isTargetingWindow,_that.targetedWindowRect,_that.targetedWindowHwnd,_that.availableAudioDevices,_that.selectedAudioDevice,_that.clickFeedbackColor,_that.rightClickFeedbackColor,_that.annotations,_that.currentTool,_that.annotationColor,_that.delaySeconds,_that.countdownSeconds,_that.framerate,_that.saveDirectory,_that.previousWindowSize,_that.previousWindowPos,_that.selectionRect,_that.captureRect,_that.availableDisplays,_that.monitorNames,_that.displayThumbnails,_that.primaryDisplayId,_that.recentRecordings,_that.registeredHotKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRecording,  bool isPaused,  int durationSeconds,  bool microphoneEnabled,  bool systemAudioEnabled,  bool showCursor,  String resolution,  String format,  CaptureMode captureMode,  String targetWindowName,  bool isOverlayVisible,  bool isTargetingWindow,  Rect? targetedWindowRect,  int? targetedWindowHwnd,  List<String> availableAudioDevices,  String? selectedAudioDevice,  Color clickFeedbackColor,  Color rightClickFeedbackColor,  List<Annotation> annotations,  ScreenshotTool currentTool,  Color annotationColor,  int delaySeconds,  int countdownSeconds,  int framerate,  String? saveDirectory,  Size? previousWindowSize,  Offset? previousWindowPos,  Rect? selectionRect,  Rect? captureRect,  List<Display> availableDisplays,  Map<String, String> monitorNames,  Map<String, String> displayThumbnails,  String? primaryDisplayId,  List<RecordingInfo> recentRecordings, @JsonKey(includeFromJson: false, includeToJson: false)  HotKey? registeredHotKey)?  $default,) {final _that = this;
switch (_that) {
case _ScreenRecorderState() when $default != null:
return $default(_that.isRecording,_that.isPaused,_that.durationSeconds,_that.microphoneEnabled,_that.systemAudioEnabled,_that.showCursor,_that.resolution,_that.format,_that.captureMode,_that.targetWindowName,_that.isOverlayVisible,_that.isTargetingWindow,_that.targetedWindowRect,_that.targetedWindowHwnd,_that.availableAudioDevices,_that.selectedAudioDevice,_that.clickFeedbackColor,_that.rightClickFeedbackColor,_that.annotations,_that.currentTool,_that.annotationColor,_that.delaySeconds,_that.countdownSeconds,_that.framerate,_that.saveDirectory,_that.previousWindowSize,_that.previousWindowPos,_that.selectionRect,_that.captureRect,_that.availableDisplays,_that.monitorNames,_that.displayThumbnails,_that.primaryDisplayId,_that.recentRecordings,_that.registeredHotKey);case _:
  return null;

}
}

}

/// @nodoc


class _ScreenRecorderState implements ScreenRecorderState {
  const _ScreenRecorderState({this.isRecording = false, this.isPaused = false, this.durationSeconds = 0, this.microphoneEnabled = true, this.systemAudioEnabled = true, this.showCursor = true, this.resolution = '1080p', this.format = 'MP4', this.captureMode = CaptureMode.fullScreen, this.targetWindowName = 'Active Window', this.isOverlayVisible = false, this.isTargetingWindow = false, this.targetedWindowRect, this.targetedWindowHwnd, final  List<String> availableAudioDevices = const [], this.selectedAudioDevice, this.clickFeedbackColor = Colors.white, this.rightClickFeedbackColor = Colors.amber, final  List<Annotation> annotations = const [], this.currentTool = ScreenshotTool.pen, this.annotationColor = Colors.red, this.delaySeconds = 0, this.countdownSeconds = 0, this.framerate = 30, this.saveDirectory, this.previousWindowSize, this.previousWindowPos, this.selectionRect, this.captureRect, final  List<Display> availableDisplays = const [], final  Map<String, String> monitorNames = const {}, final  Map<String, String> displayThumbnails = const {}, this.primaryDisplayId, final  List<RecordingInfo> recentRecordings = const [], @JsonKey(includeFromJson: false, includeToJson: false) this.registeredHotKey}): _availableAudioDevices = availableAudioDevices,_annotations = annotations,_availableDisplays = availableDisplays,_monitorNames = monitorNames,_displayThumbnails = displayThumbnails,_recentRecordings = recentRecordings;
  

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
@override@JsonKey() final  bool isTargetingWindow;
@override final  Rect? targetedWindowRect;
@override final  int? targetedWindowHwnd;
 final  List<String> _availableAudioDevices;
@override@JsonKey() List<String> get availableAudioDevices {
  if (_availableAudioDevices is EqualUnmodifiableListView) return _availableAudioDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableAudioDevices);
}

@override final  String? selectedAudioDevice;
@override@JsonKey() final  Color clickFeedbackColor;
@override@JsonKey() final  Color rightClickFeedbackColor;
 final  List<Annotation> _annotations;
@override@JsonKey() List<Annotation> get annotations {
  if (_annotations is EqualUnmodifiableListView) return _annotations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_annotations);
}

@override@JsonKey() final  ScreenshotTool currentTool;
@override@JsonKey() final  Color annotationColor;
@override@JsonKey() final  int delaySeconds;
@override@JsonKey() final  int countdownSeconds;
// Live countdown before recording starts
@override@JsonKey() final  int framerate;
@override final  String? saveDirectory;
@override final  Size? previousWindowSize;
@override final  Offset? previousWindowPos;
@override final  Rect? selectionRect;
@override final  Rect? captureRect;
 final  List<Display> _availableDisplays;
@override@JsonKey() List<Display> get availableDisplays {
  if (_availableDisplays is EqualUnmodifiableListView) return _availableDisplays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableDisplays);
}

 final  Map<String, String> _monitorNames;
@override@JsonKey() Map<String, String> get monitorNames {
  if (_monitorNames is EqualUnmodifiableMapView) return _monitorNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_monitorNames);
}

// id -> friendlyName
 final  Map<String, String> _displayThumbnails;
// id -> friendlyName
@override@JsonKey() Map<String, String> get displayThumbnails {
  if (_displayThumbnails is EqualUnmodifiableMapView) return _displayThumbnails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_displayThumbnails);
}

// id -> filePath
@override final  String? primaryDisplayId;
 final  List<RecordingInfo> _recentRecordings;
@override@JsonKey() List<RecordingInfo> get recentRecordings {
  if (_recentRecordings is EqualUnmodifiableListView) return _recentRecordings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentRecordings);
}

@override@JsonKey(includeFromJson: false, includeToJson: false) final  HotKey? registeredHotKey;

/// Create a copy of ScreenRecorderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScreenRecorderStateCopyWith<_ScreenRecorderState> get copyWith => __$ScreenRecorderStateCopyWithImpl<_ScreenRecorderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScreenRecorderState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.microphoneEnabled, microphoneEnabled) || other.microphoneEnabled == microphoneEnabled)&&(identical(other.systemAudioEnabled, systemAudioEnabled) || other.systemAudioEnabled == systemAudioEnabled)&&(identical(other.showCursor, showCursor) || other.showCursor == showCursor)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.format, format) || other.format == format)&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.targetWindowName, targetWindowName) || other.targetWindowName == targetWindowName)&&(identical(other.isOverlayVisible, isOverlayVisible) || other.isOverlayVisible == isOverlayVisible)&&(identical(other.isTargetingWindow, isTargetingWindow) || other.isTargetingWindow == isTargetingWindow)&&(identical(other.targetedWindowRect, targetedWindowRect) || other.targetedWindowRect == targetedWindowRect)&&(identical(other.targetedWindowHwnd, targetedWindowHwnd) || other.targetedWindowHwnd == targetedWindowHwnd)&&const DeepCollectionEquality().equals(other._availableAudioDevices, _availableAudioDevices)&&(identical(other.selectedAudioDevice, selectedAudioDevice) || other.selectedAudioDevice == selectedAudioDevice)&&(identical(other.clickFeedbackColor, clickFeedbackColor) || other.clickFeedbackColor == clickFeedbackColor)&&(identical(other.rightClickFeedbackColor, rightClickFeedbackColor) || other.rightClickFeedbackColor == rightClickFeedbackColor)&&const DeepCollectionEquality().equals(other._annotations, _annotations)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&(identical(other.delaySeconds, delaySeconds) || other.delaySeconds == delaySeconds)&&(identical(other.countdownSeconds, countdownSeconds) || other.countdownSeconds == countdownSeconds)&&(identical(other.framerate, framerate) || other.framerate == framerate)&&(identical(other.saveDirectory, saveDirectory) || other.saveDirectory == saveDirectory)&&(identical(other.previousWindowSize, previousWindowSize) || other.previousWindowSize == previousWindowSize)&&(identical(other.previousWindowPos, previousWindowPos) || other.previousWindowPos == previousWindowPos)&&(identical(other.selectionRect, selectionRect) || other.selectionRect == selectionRect)&&(identical(other.captureRect, captureRect) || other.captureRect == captureRect)&&const DeepCollectionEquality().equals(other._availableDisplays, _availableDisplays)&&const DeepCollectionEquality().equals(other._monitorNames, _monitorNames)&&const DeepCollectionEquality().equals(other._displayThumbnails, _displayThumbnails)&&(identical(other.primaryDisplayId, primaryDisplayId) || other.primaryDisplayId == primaryDisplayId)&&const DeepCollectionEquality().equals(other._recentRecordings, _recentRecordings)&&(identical(other.registeredHotKey, registeredHotKey) || other.registeredHotKey == registeredHotKey));
}


@override
int get hashCode => Object.hashAll([runtimeType,isRecording,isPaused,durationSeconds,microphoneEnabled,systemAudioEnabled,showCursor,resolution,format,captureMode,targetWindowName,isOverlayVisible,isTargetingWindow,targetedWindowRect,targetedWindowHwnd,const DeepCollectionEquality().hash(_availableAudioDevices),selectedAudioDevice,clickFeedbackColor,rightClickFeedbackColor,const DeepCollectionEquality().hash(_annotations),currentTool,annotationColor,delaySeconds,countdownSeconds,framerate,saveDirectory,previousWindowSize,previousWindowPos,selectionRect,captureRect,const DeepCollectionEquality().hash(_availableDisplays),const DeepCollectionEquality().hash(_monitorNames),const DeepCollectionEquality().hash(_displayThumbnails),primaryDisplayId,const DeepCollectionEquality().hash(_recentRecordings),registeredHotKey]);

@override
String toString() {
  return 'ScreenRecorderState(isRecording: $isRecording, isPaused: $isPaused, durationSeconds: $durationSeconds, microphoneEnabled: $microphoneEnabled, systemAudioEnabled: $systemAudioEnabled, showCursor: $showCursor, resolution: $resolution, format: $format, captureMode: $captureMode, targetWindowName: $targetWindowName, isOverlayVisible: $isOverlayVisible, isTargetingWindow: $isTargetingWindow, targetedWindowRect: $targetedWindowRect, targetedWindowHwnd: $targetedWindowHwnd, availableAudioDevices: $availableAudioDevices, selectedAudioDevice: $selectedAudioDevice, clickFeedbackColor: $clickFeedbackColor, rightClickFeedbackColor: $rightClickFeedbackColor, annotations: $annotations, currentTool: $currentTool, annotationColor: $annotationColor, delaySeconds: $delaySeconds, countdownSeconds: $countdownSeconds, framerate: $framerate, saveDirectory: $saveDirectory, previousWindowSize: $previousWindowSize, previousWindowPos: $previousWindowPos, selectionRect: $selectionRect, captureRect: $captureRect, availableDisplays: $availableDisplays, monitorNames: $monitorNames, displayThumbnails: $displayThumbnails, primaryDisplayId: $primaryDisplayId, recentRecordings: $recentRecordings, registeredHotKey: $registeredHotKey)';
}


}

/// @nodoc
abstract mixin class _$ScreenRecorderStateCopyWith<$Res> implements $ScreenRecorderStateCopyWith<$Res> {
  factory _$ScreenRecorderStateCopyWith(_ScreenRecorderState value, $Res Function(_ScreenRecorderState) _then) = __$ScreenRecorderStateCopyWithImpl;
@override @useResult
$Res call({
 bool isRecording, bool isPaused, int durationSeconds, bool microphoneEnabled, bool systemAudioEnabled, bool showCursor, String resolution, String format, CaptureMode captureMode, String targetWindowName, bool isOverlayVisible, bool isTargetingWindow, Rect? targetedWindowRect, int? targetedWindowHwnd, List<String> availableAudioDevices, String? selectedAudioDevice, Color clickFeedbackColor, Color rightClickFeedbackColor, List<Annotation> annotations, ScreenshotTool currentTool, Color annotationColor, int delaySeconds, int countdownSeconds, int framerate, String? saveDirectory, Size? previousWindowSize, Offset? previousWindowPos, Rect? selectionRect, Rect? captureRect, List<Display> availableDisplays, Map<String, String> monitorNames, Map<String, String> displayThumbnails, String? primaryDisplayId, List<RecordingInfo> recentRecordings,@JsonKey(includeFromJson: false, includeToJson: false) HotKey? registeredHotKey
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
@override @pragma('vm:prefer-inline') $Res call({Object? isRecording = null,Object? isPaused = null,Object? durationSeconds = null,Object? microphoneEnabled = null,Object? systemAudioEnabled = null,Object? showCursor = null,Object? resolution = null,Object? format = null,Object? captureMode = null,Object? targetWindowName = null,Object? isOverlayVisible = null,Object? isTargetingWindow = null,Object? targetedWindowRect = freezed,Object? targetedWindowHwnd = freezed,Object? availableAudioDevices = null,Object? selectedAudioDevice = freezed,Object? clickFeedbackColor = null,Object? rightClickFeedbackColor = null,Object? annotations = null,Object? currentTool = null,Object? annotationColor = null,Object? delaySeconds = null,Object? countdownSeconds = null,Object? framerate = null,Object? saveDirectory = freezed,Object? previousWindowSize = freezed,Object? previousWindowPos = freezed,Object? selectionRect = freezed,Object? captureRect = freezed,Object? availableDisplays = null,Object? monitorNames = null,Object? displayThumbnails = null,Object? primaryDisplayId = freezed,Object? recentRecordings = null,Object? registeredHotKey = freezed,}) {
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
as bool,isTargetingWindow: null == isTargetingWindow ? _self.isTargetingWindow : isTargetingWindow // ignore: cast_nullable_to_non_nullable
as bool,targetedWindowRect: freezed == targetedWindowRect ? _self.targetedWindowRect : targetedWindowRect // ignore: cast_nullable_to_non_nullable
as Rect?,targetedWindowHwnd: freezed == targetedWindowHwnd ? _self.targetedWindowHwnd : targetedWindowHwnd // ignore: cast_nullable_to_non_nullable
as int?,availableAudioDevices: null == availableAudioDevices ? _self._availableAudioDevices : availableAudioDevices // ignore: cast_nullable_to_non_nullable
as List<String>,selectedAudioDevice: freezed == selectedAudioDevice ? _self.selectedAudioDevice : selectedAudioDevice // ignore: cast_nullable_to_non_nullable
as String?,clickFeedbackColor: null == clickFeedbackColor ? _self.clickFeedbackColor : clickFeedbackColor // ignore: cast_nullable_to_non_nullable
as Color,rightClickFeedbackColor: null == rightClickFeedbackColor ? _self.rightClickFeedbackColor : rightClickFeedbackColor // ignore: cast_nullable_to_non_nullable
as Color,annotations: null == annotations ? _self._annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,delaySeconds: null == delaySeconds ? _self.delaySeconds : delaySeconds // ignore: cast_nullable_to_non_nullable
as int,countdownSeconds: null == countdownSeconds ? _self.countdownSeconds : countdownSeconds // ignore: cast_nullable_to_non_nullable
as int,framerate: null == framerate ? _self.framerate : framerate // ignore: cast_nullable_to_non_nullable
as int,saveDirectory: freezed == saveDirectory ? _self.saveDirectory : saveDirectory // ignore: cast_nullable_to_non_nullable
as String?,previousWindowSize: freezed == previousWindowSize ? _self.previousWindowSize : previousWindowSize // ignore: cast_nullable_to_non_nullable
as Size?,previousWindowPos: freezed == previousWindowPos ? _self.previousWindowPos : previousWindowPos // ignore: cast_nullable_to_non_nullable
as Offset?,selectionRect: freezed == selectionRect ? _self.selectionRect : selectionRect // ignore: cast_nullable_to_non_nullable
as Rect?,captureRect: freezed == captureRect ? _self.captureRect : captureRect // ignore: cast_nullable_to_non_nullable
as Rect?,availableDisplays: null == availableDisplays ? _self._availableDisplays : availableDisplays // ignore: cast_nullable_to_non_nullable
as List<Display>,monitorNames: null == monitorNames ? _self._monitorNames : monitorNames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,displayThumbnails: null == displayThumbnails ? _self._displayThumbnails : displayThumbnails // ignore: cast_nullable_to_non_nullable
as Map<String, String>,primaryDisplayId: freezed == primaryDisplayId ? _self.primaryDisplayId : primaryDisplayId // ignore: cast_nullable_to_non_nullable
as String?,recentRecordings: null == recentRecordings ? _self._recentRecordings : recentRecordings // ignore: cast_nullable_to_non_nullable
as List<RecordingInfo>,registeredHotKey: freezed == registeredHotKey ? _self.registeredHotKey : registeredHotKey // ignore: cast_nullable_to_non_nullable
as HotKey?,
  ));
}


}

/// @nodoc
mixin _$RecordingInfo {

 File get file; int get size; DateTime get modified;
/// Create a copy of RecordingInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecordingInfoCopyWith<RecordingInfo> get copyWith => _$RecordingInfoCopyWithImpl<RecordingInfo>(this as RecordingInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecordingInfo&&(identical(other.file, file) || other.file == file)&&(identical(other.size, size) || other.size == size)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hash(runtimeType,file,size,modified);

@override
String toString() {
  return 'RecordingInfo(file: $file, size: $size, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $RecordingInfoCopyWith<$Res>  {
  factory $RecordingInfoCopyWith(RecordingInfo value, $Res Function(RecordingInfo) _then) = _$RecordingInfoCopyWithImpl;
@useResult
$Res call({
 File file, int size, DateTime modified
});




}
/// @nodoc
class _$RecordingInfoCopyWithImpl<$Res>
    implements $RecordingInfoCopyWith<$Res> {
  _$RecordingInfoCopyWithImpl(this._self, this._then);

  final RecordingInfo _self;
  final $Res Function(RecordingInfo) _then;

/// Create a copy of RecordingInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? file = null,Object? size = null,Object? modified = null,}) {
  return _then(_self.copyWith(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as File,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecordingInfo].
extension RecordingInfoPatterns on RecordingInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecordingInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecordingInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecordingInfo value)  $default,){
final _that = this;
switch (_that) {
case _RecordingInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecordingInfo value)?  $default,){
final _that = this;
switch (_that) {
case _RecordingInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( File file,  int size,  DateTime modified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecordingInfo() when $default != null:
return $default(_that.file,_that.size,_that.modified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( File file,  int size,  DateTime modified)  $default,) {final _that = this;
switch (_that) {
case _RecordingInfo():
return $default(_that.file,_that.size,_that.modified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( File file,  int size,  DateTime modified)?  $default,) {final _that = this;
switch (_that) {
case _RecordingInfo() when $default != null:
return $default(_that.file,_that.size,_that.modified);case _:
  return null;

}
}

}

/// @nodoc


class _RecordingInfo implements RecordingInfo {
  const _RecordingInfo({required this.file, required this.size, required this.modified});
  

@override final  File file;
@override final  int size;
@override final  DateTime modified;

/// Create a copy of RecordingInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecordingInfoCopyWith<_RecordingInfo> get copyWith => __$RecordingInfoCopyWithImpl<_RecordingInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecordingInfo&&(identical(other.file, file) || other.file == file)&&(identical(other.size, size) || other.size == size)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hash(runtimeType,file,size,modified);

@override
String toString() {
  return 'RecordingInfo(file: $file, size: $size, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$RecordingInfoCopyWith<$Res> implements $RecordingInfoCopyWith<$Res> {
  factory _$RecordingInfoCopyWith(_RecordingInfo value, $Res Function(_RecordingInfo) _then) = __$RecordingInfoCopyWithImpl;
@override @useResult
$Res call({
 File file, int size, DateTime modified
});




}
/// @nodoc
class __$RecordingInfoCopyWithImpl<$Res>
    implements _$RecordingInfoCopyWith<$Res> {
  __$RecordingInfoCopyWithImpl(this._self, this._then);

  final _RecordingInfo _self;
  final $Res Function(_RecordingInfo) _then;

/// Create a copy of RecordingInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? file = null,Object? size = null,Object? modified = null,}) {
  return _then(_RecordingInfo(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as File,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
