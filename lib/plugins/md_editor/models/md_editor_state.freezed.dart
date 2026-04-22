// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'md_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MdEditorState {

 List<MdDocument> get documents; MdDocument? get activeDocument; MdEditorViewMode get viewMode; bool get isSaving; String? get errorMessage;
/// Create a copy of MdEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MdEditorStateCopyWith<MdEditorState> get copyWith => _$MdEditorStateCopyWithImpl<MdEditorState>(this as MdEditorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MdEditorState&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.activeDocument, activeDocument) || other.activeDocument == activeDocument)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(documents),activeDocument,viewMode,isSaving,errorMessage);

@override
String toString() {
  return 'MdEditorState(documents: $documents, activeDocument: $activeDocument, viewMode: $viewMode, isSaving: $isSaving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $MdEditorStateCopyWith<$Res>  {
  factory $MdEditorStateCopyWith(MdEditorState value, $Res Function(MdEditorState) _then) = _$MdEditorStateCopyWithImpl;
@useResult
$Res call({
 List<MdDocument> documents, MdDocument? activeDocument, MdEditorViewMode viewMode, bool isSaving, String? errorMessage
});


$MdDocumentCopyWith<$Res>? get activeDocument;

}
/// @nodoc
class _$MdEditorStateCopyWithImpl<$Res>
    implements $MdEditorStateCopyWith<$Res> {
  _$MdEditorStateCopyWithImpl(this._self, this._then);

  final MdEditorState _self;
  final $Res Function(MdEditorState) _then;

/// Create a copy of MdEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documents = null,Object? activeDocument = freezed,Object? viewMode = null,Object? isSaving = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<MdDocument>,activeDocument: freezed == activeDocument ? _self.activeDocument : activeDocument // ignore: cast_nullable_to_non_nullable
as MdDocument?,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as MdEditorViewMode,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MdEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MdDocumentCopyWith<$Res>? get activeDocument {
    if (_self.activeDocument == null) {
    return null;
  }

  return $MdDocumentCopyWith<$Res>(_self.activeDocument!, (value) {
    return _then(_self.copyWith(activeDocument: value));
  });
}
}


/// Adds pattern-matching-related methods to [MdEditorState].
extension MdEditorStatePatterns on MdEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MdEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MdEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MdEditorState value)  $default,){
final _that = this;
switch (_that) {
case _MdEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MdEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _MdEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MdDocument> documents,  MdDocument? activeDocument,  MdEditorViewMode viewMode,  bool isSaving,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MdEditorState() when $default != null:
return $default(_that.documents,_that.activeDocument,_that.viewMode,_that.isSaving,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MdDocument> documents,  MdDocument? activeDocument,  MdEditorViewMode viewMode,  bool isSaving,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _MdEditorState():
return $default(_that.documents,_that.activeDocument,_that.viewMode,_that.isSaving,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MdDocument> documents,  MdDocument? activeDocument,  MdEditorViewMode viewMode,  bool isSaving,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _MdEditorState() when $default != null:
return $default(_that.documents,_that.activeDocument,_that.viewMode,_that.isSaving,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _MdEditorState implements MdEditorState {
  const _MdEditorState({final  List<MdDocument> documents = const [], this.activeDocument, this.viewMode = MdEditorViewMode.list, this.isSaving = false, this.errorMessage}): _documents = documents;
  

 final  List<MdDocument> _documents;
@override@JsonKey() List<MdDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override final  MdDocument? activeDocument;
@override@JsonKey() final  MdEditorViewMode viewMode;
@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;

/// Create a copy of MdEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MdEditorStateCopyWith<_MdEditorState> get copyWith => __$MdEditorStateCopyWithImpl<_MdEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MdEditorState&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.activeDocument, activeDocument) || other.activeDocument == activeDocument)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_documents),activeDocument,viewMode,isSaving,errorMessage);

@override
String toString() {
  return 'MdEditorState(documents: $documents, activeDocument: $activeDocument, viewMode: $viewMode, isSaving: $isSaving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$MdEditorStateCopyWith<$Res> implements $MdEditorStateCopyWith<$Res> {
  factory _$MdEditorStateCopyWith(_MdEditorState value, $Res Function(_MdEditorState) _then) = __$MdEditorStateCopyWithImpl;
@override @useResult
$Res call({
 List<MdDocument> documents, MdDocument? activeDocument, MdEditorViewMode viewMode, bool isSaving, String? errorMessage
});


@override $MdDocumentCopyWith<$Res>? get activeDocument;

}
/// @nodoc
class __$MdEditorStateCopyWithImpl<$Res>
    implements _$MdEditorStateCopyWith<$Res> {
  __$MdEditorStateCopyWithImpl(this._self, this._then);

  final _MdEditorState _self;
  final $Res Function(_MdEditorState) _then;

/// Create a copy of MdEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documents = null,Object? activeDocument = freezed,Object? viewMode = null,Object? isSaving = null,Object? errorMessage = freezed,}) {
  return _then(_MdEditorState(
documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<MdDocument>,activeDocument: freezed == activeDocument ? _self.activeDocument : activeDocument // ignore: cast_nullable_to_non_nullable
as MdDocument?,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as MdEditorViewMode,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MdEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MdDocumentCopyWith<$Res>? get activeDocument {
    if (_self.activeDocument == null) {
    return null;
  }

  return $MdDocumentCopyWith<$Res>(_self.activeDocument!, (value) {
    return _then(_self.copyWith(activeDocument: value));
  });
}
}

// dart format on
