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

 CaptureMode get captureMode; String get format; bool get isCapturing; ScreenshotTool get currentTool; Color get annotationColor; bool get isOverlayVisible; Rect? get selectionRect; List<Annotation> get annotations; bool get isTargetingWindow; Rect? get targetedWindowRect; String? get targetWindowName; int? get targetedWindowHwnd; String? get saveDirectory; Size? get previousWindowSize; Offset? get previousWindowPos; List<Display> get availableDisplays; List<CaptureInfo> get recentCaptures; Display? get lockedDisplay;
/// Create a copy of ScreenshotState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScreenshotStateCopyWith<ScreenshotState> get copyWith => _$ScreenshotStateCopyWithImpl<ScreenshotState>(this as ScreenshotState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScreenshotState&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.format, format) || other.format == format)&&(identical(other.isCapturing, isCapturing) || other.isCapturing == isCapturing)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&(identical(other.isOverlayVisible, isOverlayVisible) || other.isOverlayVisible == isOverlayVisible)&&(identical(other.selectionRect, selectionRect) || other.selectionRect == selectionRect)&&const DeepCollectionEquality().equals(other.annotations, annotations)&&(identical(other.isTargetingWindow, isTargetingWindow) || other.isTargetingWindow == isTargetingWindow)&&(identical(other.targetedWindowRect, targetedWindowRect) || other.targetedWindowRect == targetedWindowRect)&&(identical(other.targetWindowName, targetWindowName) || other.targetWindowName == targetWindowName)&&(identical(other.targetedWindowHwnd, targetedWindowHwnd) || other.targetedWindowHwnd == targetedWindowHwnd)&&(identical(other.saveDirectory, saveDirectory) || other.saveDirectory == saveDirectory)&&(identical(other.previousWindowSize, previousWindowSize) || other.previousWindowSize == previousWindowSize)&&(identical(other.previousWindowPos, previousWindowPos) || other.previousWindowPos == previousWindowPos)&&const DeepCollectionEquality().equals(other.availableDisplays, availableDisplays)&&const DeepCollectionEquality().equals(other.recentCaptures, recentCaptures)&&(identical(other.lockedDisplay, lockedDisplay) || other.lockedDisplay == lockedDisplay));
}


@override
int get hashCode => Object.hash(runtimeType,captureMode,format,isCapturing,currentTool,annotationColor,isOverlayVisible,selectionRect,const DeepCollectionEquality().hash(annotations),isTargetingWindow,targetedWindowRect,targetWindowName,targetedWindowHwnd,saveDirectory,previousWindowSize,previousWindowPos,const DeepCollectionEquality().hash(availableDisplays),const DeepCollectionEquality().hash(recentCaptures),lockedDisplay);

@override
String toString() {
  return 'ScreenshotState(captureMode: $captureMode, format: $format, isCapturing: $isCapturing, currentTool: $currentTool, annotationColor: $annotationColor, isOverlayVisible: $isOverlayVisible, selectionRect: $selectionRect, annotations: $annotations, isTargetingWindow: $isTargetingWindow, targetedWindowRect: $targetedWindowRect, targetWindowName: $targetWindowName, targetedWindowHwnd: $targetedWindowHwnd, saveDirectory: $saveDirectory, previousWindowSize: $previousWindowSize, previousWindowPos: $previousWindowPos, availableDisplays: $availableDisplays, recentCaptures: $recentCaptures, lockedDisplay: $lockedDisplay)';
}


}

/// @nodoc
abstract mixin class $ScreenshotStateCopyWith<$Res>  {
  factory $ScreenshotStateCopyWith(ScreenshotState value, $Res Function(ScreenshotState) _then) = _$ScreenshotStateCopyWithImpl;
@useResult
$Res call({
 CaptureMode captureMode, String format, bool isCapturing, ScreenshotTool currentTool, Color annotationColor, bool isOverlayVisible, Rect? selectionRect, List<Annotation> annotations, bool isTargetingWindow, Rect? targetedWindowRect, String? targetWindowName, int? targetedWindowHwnd, String? saveDirectory, Size? previousWindowSize, Offset? previousWindowPos, List<Display> availableDisplays, List<CaptureInfo> recentCaptures, Display? lockedDisplay
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
@pragma('vm:prefer-inline') @override $Res call({Object? captureMode = null,Object? format = null,Object? isCapturing = null,Object? currentTool = null,Object? annotationColor = null,Object? isOverlayVisible = null,Object? selectionRect = freezed,Object? annotations = null,Object? isTargetingWindow = null,Object? targetedWindowRect = freezed,Object? targetWindowName = freezed,Object? targetedWindowHwnd = freezed,Object? saveDirectory = freezed,Object? previousWindowSize = freezed,Object? previousWindowPos = freezed,Object? availableDisplays = null,Object? recentCaptures = null,Object? lockedDisplay = freezed,}) {
  return _then(_self.copyWith(
captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,isCapturing: null == isCapturing ? _self.isCapturing : isCapturing // ignore: cast_nullable_to_non_nullable
as bool,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,isOverlayVisible: null == isOverlayVisible ? _self.isOverlayVisible : isOverlayVisible // ignore: cast_nullable_to_non_nullable
as bool,selectionRect: freezed == selectionRect ? _self.selectionRect : selectionRect // ignore: cast_nullable_to_non_nullable
as Rect?,annotations: null == annotations ? _self.annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,isTargetingWindow: null == isTargetingWindow ? _self.isTargetingWindow : isTargetingWindow // ignore: cast_nullable_to_non_nullable
as bool,targetedWindowRect: freezed == targetedWindowRect ? _self.targetedWindowRect : targetedWindowRect // ignore: cast_nullable_to_non_nullable
as Rect?,targetWindowName: freezed == targetWindowName ? _self.targetWindowName : targetWindowName // ignore: cast_nullable_to_non_nullable
as String?,targetedWindowHwnd: freezed == targetedWindowHwnd ? _self.targetedWindowHwnd : targetedWindowHwnd // ignore: cast_nullable_to_non_nullable
as int?,saveDirectory: freezed == saveDirectory ? _self.saveDirectory : saveDirectory // ignore: cast_nullable_to_non_nullable
as String?,previousWindowSize: freezed == previousWindowSize ? _self.previousWindowSize : previousWindowSize // ignore: cast_nullable_to_non_nullable
as Size?,previousWindowPos: freezed == previousWindowPos ? _self.previousWindowPos : previousWindowPos // ignore: cast_nullable_to_non_nullable
as Offset?,availableDisplays: null == availableDisplays ? _self.availableDisplays : availableDisplays // ignore: cast_nullable_to_non_nullable
as List<Display>,recentCaptures: null == recentCaptures ? _self.recentCaptures : recentCaptures // ignore: cast_nullable_to_non_nullable
as List<CaptureInfo>,lockedDisplay: freezed == lockedDisplay ? _self.lockedDisplay : lockedDisplay // ignore: cast_nullable_to_non_nullable
as Display?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CaptureMode captureMode,  String format,  bool isCapturing,  ScreenshotTool currentTool,  Color annotationColor,  bool isOverlayVisible,  Rect? selectionRect,  List<Annotation> annotations,  bool isTargetingWindow,  Rect? targetedWindowRect,  String? targetWindowName,  int? targetedWindowHwnd,  String? saveDirectory,  Size? previousWindowSize,  Offset? previousWindowPos,  List<Display> availableDisplays,  List<CaptureInfo> recentCaptures,  Display? lockedDisplay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScreenshotState() when $default != null:
return $default(_that.captureMode,_that.format,_that.isCapturing,_that.currentTool,_that.annotationColor,_that.isOverlayVisible,_that.selectionRect,_that.annotations,_that.isTargetingWindow,_that.targetedWindowRect,_that.targetWindowName,_that.targetedWindowHwnd,_that.saveDirectory,_that.previousWindowSize,_that.previousWindowPos,_that.availableDisplays,_that.recentCaptures,_that.lockedDisplay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CaptureMode captureMode,  String format,  bool isCapturing,  ScreenshotTool currentTool,  Color annotationColor,  bool isOverlayVisible,  Rect? selectionRect,  List<Annotation> annotations,  bool isTargetingWindow,  Rect? targetedWindowRect,  String? targetWindowName,  int? targetedWindowHwnd,  String? saveDirectory,  Size? previousWindowSize,  Offset? previousWindowPos,  List<Display> availableDisplays,  List<CaptureInfo> recentCaptures,  Display? lockedDisplay)  $default,) {final _that = this;
switch (_that) {
case _ScreenshotState():
return $default(_that.captureMode,_that.format,_that.isCapturing,_that.currentTool,_that.annotationColor,_that.isOverlayVisible,_that.selectionRect,_that.annotations,_that.isTargetingWindow,_that.targetedWindowRect,_that.targetWindowName,_that.targetedWindowHwnd,_that.saveDirectory,_that.previousWindowSize,_that.previousWindowPos,_that.availableDisplays,_that.recentCaptures,_that.lockedDisplay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CaptureMode captureMode,  String format,  bool isCapturing,  ScreenshotTool currentTool,  Color annotationColor,  bool isOverlayVisible,  Rect? selectionRect,  List<Annotation> annotations,  bool isTargetingWindow,  Rect? targetedWindowRect,  String? targetWindowName,  int? targetedWindowHwnd,  String? saveDirectory,  Size? previousWindowSize,  Offset? previousWindowPos,  List<Display> availableDisplays,  List<CaptureInfo> recentCaptures,  Display? lockedDisplay)?  $default,) {final _that = this;
switch (_that) {
case _ScreenshotState() when $default != null:
return $default(_that.captureMode,_that.format,_that.isCapturing,_that.currentTool,_that.annotationColor,_that.isOverlayVisible,_that.selectionRect,_that.annotations,_that.isTargetingWindow,_that.targetedWindowRect,_that.targetWindowName,_that.targetedWindowHwnd,_that.saveDirectory,_that.previousWindowSize,_that.previousWindowPos,_that.availableDisplays,_that.recentCaptures,_that.lockedDisplay);case _:
  return null;

}
}

}

/// @nodoc


class _ScreenshotState implements ScreenshotState {
  const _ScreenshotState({this.captureMode = CaptureMode.area, this.format = 'PNG', this.isCapturing = false, this.currentTool = ScreenshotTool.pointer, this.annotationColor = Colors.red, this.isOverlayVisible = false, this.selectionRect = null, final  List<Annotation> annotations = const [], this.isTargetingWindow = false, this.targetedWindowRect, this.targetWindowName, this.targetedWindowHwnd, this.saveDirectory, this.previousWindowSize, this.previousWindowPos, final  List<Display> availableDisplays = const [], final  List<CaptureInfo> recentCaptures = const [], this.lockedDisplay}): _annotations = annotations,_availableDisplays = availableDisplays,_recentCaptures = recentCaptures;
  

@override@JsonKey() final  CaptureMode captureMode;
@override@JsonKey() final  String format;
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

@override@JsonKey() final  bool isTargetingWindow;
@override final  Rect? targetedWindowRect;
@override final  String? targetWindowName;
@override final  int? targetedWindowHwnd;
@override final  String? saveDirectory;
@override final  Size? previousWindowSize;
@override final  Offset? previousWindowPos;
 final  List<Display> _availableDisplays;
@override@JsonKey() List<Display> get availableDisplays {
  if (_availableDisplays is EqualUnmodifiableListView) return _availableDisplays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableDisplays);
}

 final  List<CaptureInfo> _recentCaptures;
@override@JsonKey() List<CaptureInfo> get recentCaptures {
  if (_recentCaptures is EqualUnmodifiableListView) return _recentCaptures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentCaptures);
}

@override final  Display? lockedDisplay;

/// Create a copy of ScreenshotState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScreenshotStateCopyWith<_ScreenshotState> get copyWith => __$ScreenshotStateCopyWithImpl<_ScreenshotState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScreenshotState&&(identical(other.captureMode, captureMode) || other.captureMode == captureMode)&&(identical(other.format, format) || other.format == format)&&(identical(other.isCapturing, isCapturing) || other.isCapturing == isCapturing)&&(identical(other.currentTool, currentTool) || other.currentTool == currentTool)&&(identical(other.annotationColor, annotationColor) || other.annotationColor == annotationColor)&&(identical(other.isOverlayVisible, isOverlayVisible) || other.isOverlayVisible == isOverlayVisible)&&(identical(other.selectionRect, selectionRect) || other.selectionRect == selectionRect)&&const DeepCollectionEquality().equals(other._annotations, _annotations)&&(identical(other.isTargetingWindow, isTargetingWindow) || other.isTargetingWindow == isTargetingWindow)&&(identical(other.targetedWindowRect, targetedWindowRect) || other.targetedWindowRect == targetedWindowRect)&&(identical(other.targetWindowName, targetWindowName) || other.targetWindowName == targetWindowName)&&(identical(other.targetedWindowHwnd, targetedWindowHwnd) || other.targetedWindowHwnd == targetedWindowHwnd)&&(identical(other.saveDirectory, saveDirectory) || other.saveDirectory == saveDirectory)&&(identical(other.previousWindowSize, previousWindowSize) || other.previousWindowSize == previousWindowSize)&&(identical(other.previousWindowPos, previousWindowPos) || other.previousWindowPos == previousWindowPos)&&const DeepCollectionEquality().equals(other._availableDisplays, _availableDisplays)&&const DeepCollectionEquality().equals(other._recentCaptures, _recentCaptures)&&(identical(other.lockedDisplay, lockedDisplay) || other.lockedDisplay == lockedDisplay));
}


@override
int get hashCode => Object.hash(runtimeType,captureMode,format,isCapturing,currentTool,annotationColor,isOverlayVisible,selectionRect,const DeepCollectionEquality().hash(_annotations),isTargetingWindow,targetedWindowRect,targetWindowName,targetedWindowHwnd,saveDirectory,previousWindowSize,previousWindowPos,const DeepCollectionEquality().hash(_availableDisplays),const DeepCollectionEquality().hash(_recentCaptures),lockedDisplay);

@override
String toString() {
  return 'ScreenshotState(captureMode: $captureMode, format: $format, isCapturing: $isCapturing, currentTool: $currentTool, annotationColor: $annotationColor, isOverlayVisible: $isOverlayVisible, selectionRect: $selectionRect, annotations: $annotations, isTargetingWindow: $isTargetingWindow, targetedWindowRect: $targetedWindowRect, targetWindowName: $targetWindowName, targetedWindowHwnd: $targetedWindowHwnd, saveDirectory: $saveDirectory, previousWindowSize: $previousWindowSize, previousWindowPos: $previousWindowPos, availableDisplays: $availableDisplays, recentCaptures: $recentCaptures, lockedDisplay: $lockedDisplay)';
}


}

/// @nodoc
abstract mixin class _$ScreenshotStateCopyWith<$Res> implements $ScreenshotStateCopyWith<$Res> {
  factory _$ScreenshotStateCopyWith(_ScreenshotState value, $Res Function(_ScreenshotState) _then) = __$ScreenshotStateCopyWithImpl;
@override @useResult
$Res call({
 CaptureMode captureMode, String format, bool isCapturing, ScreenshotTool currentTool, Color annotationColor, bool isOverlayVisible, Rect? selectionRect, List<Annotation> annotations, bool isTargetingWindow, Rect? targetedWindowRect, String? targetWindowName, int? targetedWindowHwnd, String? saveDirectory, Size? previousWindowSize, Offset? previousWindowPos, List<Display> availableDisplays, List<CaptureInfo> recentCaptures, Display? lockedDisplay
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
@override @pragma('vm:prefer-inline') $Res call({Object? captureMode = null,Object? format = null,Object? isCapturing = null,Object? currentTool = null,Object? annotationColor = null,Object? isOverlayVisible = null,Object? selectionRect = freezed,Object? annotations = null,Object? isTargetingWindow = null,Object? targetedWindowRect = freezed,Object? targetWindowName = freezed,Object? targetedWindowHwnd = freezed,Object? saveDirectory = freezed,Object? previousWindowSize = freezed,Object? previousWindowPos = freezed,Object? availableDisplays = null,Object? recentCaptures = null,Object? lockedDisplay = freezed,}) {
  return _then(_ScreenshotState(
captureMode: null == captureMode ? _self.captureMode : captureMode // ignore: cast_nullable_to_non_nullable
as CaptureMode,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,isCapturing: null == isCapturing ? _self.isCapturing : isCapturing // ignore: cast_nullable_to_non_nullable
as bool,currentTool: null == currentTool ? _self.currentTool : currentTool // ignore: cast_nullable_to_non_nullable
as ScreenshotTool,annotationColor: null == annotationColor ? _self.annotationColor : annotationColor // ignore: cast_nullable_to_non_nullable
as Color,isOverlayVisible: null == isOverlayVisible ? _self.isOverlayVisible : isOverlayVisible // ignore: cast_nullable_to_non_nullable
as bool,selectionRect: freezed == selectionRect ? _self.selectionRect : selectionRect // ignore: cast_nullable_to_non_nullable
as Rect?,annotations: null == annotations ? _self._annotations : annotations // ignore: cast_nullable_to_non_nullable
as List<Annotation>,isTargetingWindow: null == isTargetingWindow ? _self.isTargetingWindow : isTargetingWindow // ignore: cast_nullable_to_non_nullable
as bool,targetedWindowRect: freezed == targetedWindowRect ? _self.targetedWindowRect : targetedWindowRect // ignore: cast_nullable_to_non_nullable
as Rect?,targetWindowName: freezed == targetWindowName ? _self.targetWindowName : targetWindowName // ignore: cast_nullable_to_non_nullable
as String?,targetedWindowHwnd: freezed == targetedWindowHwnd ? _self.targetedWindowHwnd : targetedWindowHwnd // ignore: cast_nullable_to_non_nullable
as int?,saveDirectory: freezed == saveDirectory ? _self.saveDirectory : saveDirectory // ignore: cast_nullable_to_non_nullable
as String?,previousWindowSize: freezed == previousWindowSize ? _self.previousWindowSize : previousWindowSize // ignore: cast_nullable_to_non_nullable
as Size?,previousWindowPos: freezed == previousWindowPos ? _self.previousWindowPos : previousWindowPos // ignore: cast_nullable_to_non_nullable
as Offset?,availableDisplays: null == availableDisplays ? _self._availableDisplays : availableDisplays // ignore: cast_nullable_to_non_nullable
as List<Display>,recentCaptures: null == recentCaptures ? _self._recentCaptures : recentCaptures // ignore: cast_nullable_to_non_nullable
as List<CaptureInfo>,lockedDisplay: freezed == lockedDisplay ? _self.lockedDisplay : lockedDisplay // ignore: cast_nullable_to_non_nullable
as Display?,
  ));
}


}

/// @nodoc
mixin _$CaptureInfo {

 File get file; int get size; DateTime get modified;
/// Create a copy of CaptureInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaptureInfoCopyWith<CaptureInfo> get copyWith => _$CaptureInfoCopyWithImpl<CaptureInfo>(this as CaptureInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaptureInfo&&(identical(other.file, file) || other.file == file)&&(identical(other.size, size) || other.size == size)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hash(runtimeType,file,size,modified);

@override
String toString() {
  return 'CaptureInfo(file: $file, size: $size, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $CaptureInfoCopyWith<$Res>  {
  factory $CaptureInfoCopyWith(CaptureInfo value, $Res Function(CaptureInfo) _then) = _$CaptureInfoCopyWithImpl;
@useResult
$Res call({
 File file, int size, DateTime modified
});




}
/// @nodoc
class _$CaptureInfoCopyWithImpl<$Res>
    implements $CaptureInfoCopyWith<$Res> {
  _$CaptureInfoCopyWithImpl(this._self, this._then);

  final CaptureInfo _self;
  final $Res Function(CaptureInfo) _then;

/// Create a copy of CaptureInfo
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


/// Adds pattern-matching-related methods to [CaptureInfo].
extension CaptureInfoPatterns on CaptureInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaptureInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaptureInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaptureInfo value)  $default,){
final _that = this;
switch (_that) {
case _CaptureInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaptureInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CaptureInfo() when $default != null:
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
case _CaptureInfo() when $default != null:
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
case _CaptureInfo():
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
case _CaptureInfo() when $default != null:
return $default(_that.file,_that.size,_that.modified);case _:
  return null;

}
}

}

/// @nodoc


class _CaptureInfo implements CaptureInfo {
  const _CaptureInfo({required this.file, required this.size, required this.modified});
  

@override final  File file;
@override final  int size;
@override final  DateTime modified;

/// Create a copy of CaptureInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaptureInfoCopyWith<_CaptureInfo> get copyWith => __$CaptureInfoCopyWithImpl<_CaptureInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaptureInfo&&(identical(other.file, file) || other.file == file)&&(identical(other.size, size) || other.size == size)&&(identical(other.modified, modified) || other.modified == modified));
}


@override
int get hashCode => Object.hash(runtimeType,file,size,modified);

@override
String toString() {
  return 'CaptureInfo(file: $file, size: $size, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$CaptureInfoCopyWith<$Res> implements $CaptureInfoCopyWith<$Res> {
  factory _$CaptureInfoCopyWith(_CaptureInfo value, $Res Function(_CaptureInfo) _then) = __$CaptureInfoCopyWithImpl;
@override @useResult
$Res call({
 File file, int size, DateTime modified
});




}
/// @nodoc
class __$CaptureInfoCopyWithImpl<$Res>
    implements _$CaptureInfoCopyWith<$Res> {
  __$CaptureInfoCopyWithImpl(this._self, this._then);

  final _CaptureInfo _self;
  final $Res Function(_CaptureInfo) _then;

/// Create a copy of CaptureInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? file = null,Object? size = null,Object? modified = null,}) {
  return _then(_CaptureInfo(
file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as File,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
