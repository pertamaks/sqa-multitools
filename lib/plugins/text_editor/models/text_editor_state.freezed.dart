// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TextEditorState {

 List<TextDocument> get documents; TextDocument? get activeDocument; TextEditorViewMode get viewMode; bool get isSaving; bool get isLoading; bool get hasUnsavedChanges; String? get errorMessage; String? get savePath; String get searchQuery;
/// Create a copy of TextEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextEditorStateCopyWith<TextEditorState> get copyWith => _$TextEditorStateCopyWithImpl<TextEditorState>(this as TextEditorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextEditorState&&const DeepCollectionEquality().equals(other.documents, documents)&&(identical(other.activeDocument, activeDocument) || other.activeDocument == activeDocument)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.savePath, savePath) || other.savePath == savePath)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(documents),activeDocument,viewMode,isSaving,isLoading,hasUnsavedChanges,errorMessage,savePath,searchQuery);

@override
String toString() {
  return 'TextEditorState(documents: $documents, activeDocument: $activeDocument, viewMode: $viewMode, isSaving: $isSaving, isLoading: $isLoading, hasUnsavedChanges: $hasUnsavedChanges, errorMessage: $errorMessage, savePath: $savePath, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $TextEditorStateCopyWith<$Res>  {
  factory $TextEditorStateCopyWith(TextEditorState value, $Res Function(TextEditorState) _then) = _$TextEditorStateCopyWithImpl;
@useResult
$Res call({
 List<TextDocument> documents, TextDocument? activeDocument, TextEditorViewMode viewMode, bool isSaving, bool isLoading, bool hasUnsavedChanges, String? errorMessage, String? savePath, String searchQuery
});


$TextDocumentCopyWith<$Res>? get activeDocument;

}
/// @nodoc
class _$TextEditorStateCopyWithImpl<$Res>
    implements $TextEditorStateCopyWith<$Res> {
  _$TextEditorStateCopyWithImpl(this._self, this._then);

  final TextEditorState _self;
  final $Res Function(TextEditorState) _then;

/// Create a copy of TextEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documents = null,Object? activeDocument = freezed,Object? viewMode = null,Object? isSaving = null,Object? isLoading = null,Object? hasUnsavedChanges = null,Object? errorMessage = freezed,Object? savePath = freezed,Object? searchQuery = null,}) {
  return _then(_self.copyWith(
documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<TextDocument>,activeDocument: freezed == activeDocument ? _self.activeDocument : activeDocument // ignore: cast_nullable_to_non_nullable
as TextDocument?,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as TextEditorViewMode,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,savePath: freezed == savePath ? _self.savePath : savePath // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of TextEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextDocumentCopyWith<$Res>? get activeDocument {
    if (_self.activeDocument == null) {
    return null;
  }

  return $TextDocumentCopyWith<$Res>(_self.activeDocument!, (value) {
    return _then(_self.copyWith(activeDocument: value));
  });
}
}


/// Adds pattern-matching-related methods to [TextEditorState].
extension TextEditorStatePatterns on TextEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextEditorState value)  $default,){
final _that = this;
switch (_that) {
case _TextEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _TextEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TextDocument> documents,  TextDocument? activeDocument,  TextEditorViewMode viewMode,  bool isSaving,  bool isLoading,  bool hasUnsavedChanges,  String? errorMessage,  String? savePath,  String searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextEditorState() when $default != null:
return $default(_that.documents,_that.activeDocument,_that.viewMode,_that.isSaving,_that.isLoading,_that.hasUnsavedChanges,_that.errorMessage,_that.savePath,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TextDocument> documents,  TextDocument? activeDocument,  TextEditorViewMode viewMode,  bool isSaving,  bool isLoading,  bool hasUnsavedChanges,  String? errorMessage,  String? savePath,  String searchQuery)  $default,) {final _that = this;
switch (_that) {
case _TextEditorState():
return $default(_that.documents,_that.activeDocument,_that.viewMode,_that.isSaving,_that.isLoading,_that.hasUnsavedChanges,_that.errorMessage,_that.savePath,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TextDocument> documents,  TextDocument? activeDocument,  TextEditorViewMode viewMode,  bool isSaving,  bool isLoading,  bool hasUnsavedChanges,  String? errorMessage,  String? savePath,  String searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _TextEditorState() when $default != null:
return $default(_that.documents,_that.activeDocument,_that.viewMode,_that.isSaving,_that.isLoading,_that.hasUnsavedChanges,_that.errorMessage,_that.savePath,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _TextEditorState implements TextEditorState {
  const _TextEditorState({final  List<TextDocument> documents = const [], this.activeDocument, this.viewMode = TextEditorViewMode.list, this.isSaving = false, this.isLoading = false, this.hasUnsavedChanges = false, this.errorMessage, this.savePath, this.searchQuery = ''}): _documents = documents;
  

 final  List<TextDocument> _documents;
@override@JsonKey() List<TextDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

@override final  TextDocument? activeDocument;
@override@JsonKey() final  TextEditorViewMode viewMode;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool hasUnsavedChanges;
@override final  String? errorMessage;
@override final  String? savePath;
@override@JsonKey() final  String searchQuery;

/// Create a copy of TextEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextEditorStateCopyWith<_TextEditorState> get copyWith => __$TextEditorStateCopyWithImpl<_TextEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextEditorState&&const DeepCollectionEquality().equals(other._documents, _documents)&&(identical(other.activeDocument, activeDocument) || other.activeDocument == activeDocument)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.hasUnsavedChanges, hasUnsavedChanges) || other.hasUnsavedChanges == hasUnsavedChanges)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.savePath, savePath) || other.savePath == savePath)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_documents),activeDocument,viewMode,isSaving,isLoading,hasUnsavedChanges,errorMessage,savePath,searchQuery);

@override
String toString() {
  return 'TextEditorState(documents: $documents, activeDocument: $activeDocument, viewMode: $viewMode, isSaving: $isSaving, isLoading: $isLoading, hasUnsavedChanges: $hasUnsavedChanges, errorMessage: $errorMessage, savePath: $savePath, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$TextEditorStateCopyWith<$Res> implements $TextEditorStateCopyWith<$Res> {
  factory _$TextEditorStateCopyWith(_TextEditorState value, $Res Function(_TextEditorState) _then) = __$TextEditorStateCopyWithImpl;
@override @useResult
$Res call({
 List<TextDocument> documents, TextDocument? activeDocument, TextEditorViewMode viewMode, bool isSaving, bool isLoading, bool hasUnsavedChanges, String? errorMessage, String? savePath, String searchQuery
});


@override $TextDocumentCopyWith<$Res>? get activeDocument;

}
/// @nodoc
class __$TextEditorStateCopyWithImpl<$Res>
    implements _$TextEditorStateCopyWith<$Res> {
  __$TextEditorStateCopyWithImpl(this._self, this._then);

  final _TextEditorState _self;
  final $Res Function(_TextEditorState) _then;

/// Create a copy of TextEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documents = null,Object? activeDocument = freezed,Object? viewMode = null,Object? isSaving = null,Object? isLoading = null,Object? hasUnsavedChanges = null,Object? errorMessage = freezed,Object? savePath = freezed,Object? searchQuery = null,}) {
  return _then(_TextEditorState(
documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<TextDocument>,activeDocument: freezed == activeDocument ? _self.activeDocument : activeDocument // ignore: cast_nullable_to_non_nullable
as TextDocument?,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as TextEditorViewMode,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,hasUnsavedChanges: null == hasUnsavedChanges ? _self.hasUnsavedChanges : hasUnsavedChanges // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,savePath: freezed == savePath ? _self.savePath : savePath // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of TextEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextDocumentCopyWith<$Res>? get activeDocument {
    if (_self.activeDocument == null) {
    return null;
  }

  return $TextDocumentCopyWith<$Res>(_self.activeDocument!, (value) {
    return _then(_self.copyWith(activeDocument: value));
  });
}
}

// dart format on
