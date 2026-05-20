// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'obfuscator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ObfuscatorState {

 ObfuscatorWorkspace? get activeWorkspace; List<ObfuscatorWorkspace> get workspaces; List<ImportedDocument> get documents; List<DictionaryEntry> get dictionary; ImportedDocument? get activeDocument; ObfuscatorViewMode get viewMode; ObfuscatorMode get mode; bool get showObfuscatedPreview; String? get deobfuscatedContent; int get lastRestoredCount; bool get isLoading; bool get isSaving; String? get errorMessage; String? get savePath; String get searchQuery;
/// Create a copy of ObfuscatorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObfuscatorStateCopyWith<ObfuscatorState> get copyWith => _$ObfuscatorStateCopyWithImpl<ObfuscatorState>(this as ObfuscatorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ObfuscatorState&&(identical(other.activeWorkspace, activeWorkspace) || other.activeWorkspace == activeWorkspace)&&const DeepCollectionEquality().equals(other.workspaces, workspaces)&&const DeepCollectionEquality().equals(other.documents, documents)&&const DeepCollectionEquality().equals(other.dictionary, dictionary)&&(identical(other.activeDocument, activeDocument) || other.activeDocument == activeDocument)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.showObfuscatedPreview, showObfuscatedPreview) || other.showObfuscatedPreview == showObfuscatedPreview)&&(identical(other.deobfuscatedContent, deobfuscatedContent) || other.deobfuscatedContent == deobfuscatedContent)&&(identical(other.lastRestoredCount, lastRestoredCount) || other.lastRestoredCount == lastRestoredCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.savePath, savePath) || other.savePath == savePath)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,activeWorkspace,const DeepCollectionEquality().hash(workspaces),const DeepCollectionEquality().hash(documents),const DeepCollectionEquality().hash(dictionary),activeDocument,viewMode,mode,showObfuscatedPreview,deobfuscatedContent,lastRestoredCount,isLoading,isSaving,errorMessage,savePath,searchQuery);

@override
String toString() {
  return 'ObfuscatorState(activeWorkspace: $activeWorkspace, workspaces: $workspaces, documents: $documents, dictionary: $dictionary, activeDocument: $activeDocument, viewMode: $viewMode, mode: $mode, showObfuscatedPreview: $showObfuscatedPreview, deobfuscatedContent: $deobfuscatedContent, lastRestoredCount: $lastRestoredCount, isLoading: $isLoading, isSaving: $isSaving, errorMessage: $errorMessage, savePath: $savePath, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $ObfuscatorStateCopyWith<$Res>  {
  factory $ObfuscatorStateCopyWith(ObfuscatorState value, $Res Function(ObfuscatorState) _then) = _$ObfuscatorStateCopyWithImpl;
@useResult
$Res call({
 ObfuscatorWorkspace? activeWorkspace, List<ObfuscatorWorkspace> workspaces, List<ImportedDocument> documents, List<DictionaryEntry> dictionary, ImportedDocument? activeDocument, ObfuscatorViewMode viewMode, ObfuscatorMode mode, bool showObfuscatedPreview, String? deobfuscatedContent, int lastRestoredCount, bool isLoading, bool isSaving, String? errorMessage, String? savePath, String searchQuery
});


$ObfuscatorWorkspaceCopyWith<$Res>? get activeWorkspace;$ImportedDocumentCopyWith<$Res>? get activeDocument;

}
/// @nodoc
class _$ObfuscatorStateCopyWithImpl<$Res>
    implements $ObfuscatorStateCopyWith<$Res> {
  _$ObfuscatorStateCopyWithImpl(this._self, this._then);

  final ObfuscatorState _self;
  final $Res Function(ObfuscatorState) _then;

/// Create a copy of ObfuscatorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeWorkspace = freezed,Object? workspaces = null,Object? documents = null,Object? dictionary = null,Object? activeDocument = freezed,Object? viewMode = null,Object? mode = null,Object? showObfuscatedPreview = null,Object? deobfuscatedContent = freezed,Object? lastRestoredCount = null,Object? isLoading = null,Object? isSaving = null,Object? errorMessage = freezed,Object? savePath = freezed,Object? searchQuery = null,}) {
  return _then(_self.copyWith(
activeWorkspace: freezed == activeWorkspace ? _self.activeWorkspace : activeWorkspace // ignore: cast_nullable_to_non_nullable
as ObfuscatorWorkspace?,workspaces: null == workspaces ? _self.workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<ObfuscatorWorkspace>,documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as List<ImportedDocument>,dictionary: null == dictionary ? _self.dictionary : dictionary // ignore: cast_nullable_to_non_nullable
as List<DictionaryEntry>,activeDocument: freezed == activeDocument ? _self.activeDocument : activeDocument // ignore: cast_nullable_to_non_nullable
as ImportedDocument?,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ObfuscatorViewMode,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ObfuscatorMode,showObfuscatedPreview: null == showObfuscatedPreview ? _self.showObfuscatedPreview : showObfuscatedPreview // ignore: cast_nullable_to_non_nullable
as bool,deobfuscatedContent: freezed == deobfuscatedContent ? _self.deobfuscatedContent : deobfuscatedContent // ignore: cast_nullable_to_non_nullable
as String?,lastRestoredCount: null == lastRestoredCount ? _self.lastRestoredCount : lastRestoredCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,savePath: freezed == savePath ? _self.savePath : savePath // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ObfuscatorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ObfuscatorWorkspaceCopyWith<$Res>? get activeWorkspace {
    if (_self.activeWorkspace == null) {
    return null;
  }

  return $ObfuscatorWorkspaceCopyWith<$Res>(_self.activeWorkspace!, (value) {
    return _then(_self.copyWith(activeWorkspace: value));
  });
}/// Create a copy of ObfuscatorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportedDocumentCopyWith<$Res>? get activeDocument {
    if (_self.activeDocument == null) {
    return null;
  }

  return $ImportedDocumentCopyWith<$Res>(_self.activeDocument!, (value) {
    return _then(_self.copyWith(activeDocument: value));
  });
}
}


/// Adds pattern-matching-related methods to [ObfuscatorState].
extension ObfuscatorStatePatterns on ObfuscatorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ObfuscatorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ObfuscatorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ObfuscatorState value)  $default,){
final _that = this;
switch (_that) {
case _ObfuscatorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ObfuscatorState value)?  $default,){
final _that = this;
switch (_that) {
case _ObfuscatorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ObfuscatorWorkspace? activeWorkspace,  List<ObfuscatorWorkspace> workspaces,  List<ImportedDocument> documents,  List<DictionaryEntry> dictionary,  ImportedDocument? activeDocument,  ObfuscatorViewMode viewMode,  ObfuscatorMode mode,  bool showObfuscatedPreview,  String? deobfuscatedContent,  int lastRestoredCount,  bool isLoading,  bool isSaving,  String? errorMessage,  String? savePath,  String searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ObfuscatorState() when $default != null:
return $default(_that.activeWorkspace,_that.workspaces,_that.documents,_that.dictionary,_that.activeDocument,_that.viewMode,_that.mode,_that.showObfuscatedPreview,_that.deobfuscatedContent,_that.lastRestoredCount,_that.isLoading,_that.isSaving,_that.errorMessage,_that.savePath,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ObfuscatorWorkspace? activeWorkspace,  List<ObfuscatorWorkspace> workspaces,  List<ImportedDocument> documents,  List<DictionaryEntry> dictionary,  ImportedDocument? activeDocument,  ObfuscatorViewMode viewMode,  ObfuscatorMode mode,  bool showObfuscatedPreview,  String? deobfuscatedContent,  int lastRestoredCount,  bool isLoading,  bool isSaving,  String? errorMessage,  String? savePath,  String searchQuery)  $default,) {final _that = this;
switch (_that) {
case _ObfuscatorState():
return $default(_that.activeWorkspace,_that.workspaces,_that.documents,_that.dictionary,_that.activeDocument,_that.viewMode,_that.mode,_that.showObfuscatedPreview,_that.deobfuscatedContent,_that.lastRestoredCount,_that.isLoading,_that.isSaving,_that.errorMessage,_that.savePath,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ObfuscatorWorkspace? activeWorkspace,  List<ObfuscatorWorkspace> workspaces,  List<ImportedDocument> documents,  List<DictionaryEntry> dictionary,  ImportedDocument? activeDocument,  ObfuscatorViewMode viewMode,  ObfuscatorMode mode,  bool showObfuscatedPreview,  String? deobfuscatedContent,  int lastRestoredCount,  bool isLoading,  bool isSaving,  String? errorMessage,  String? savePath,  String searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _ObfuscatorState() when $default != null:
return $default(_that.activeWorkspace,_that.workspaces,_that.documents,_that.dictionary,_that.activeDocument,_that.viewMode,_that.mode,_that.showObfuscatedPreview,_that.deobfuscatedContent,_that.lastRestoredCount,_that.isLoading,_that.isSaving,_that.errorMessage,_that.savePath,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _ObfuscatorState implements ObfuscatorState {
  const _ObfuscatorState({this.activeWorkspace = null, final  List<ObfuscatorWorkspace> workspaces = const [], final  List<ImportedDocument> documents = const [], final  List<DictionaryEntry> dictionary = const [], this.activeDocument = null, this.viewMode = ObfuscatorViewMode.list, this.mode = ObfuscatorMode.obfuscate, this.showObfuscatedPreview = false, this.deobfuscatedContent = null, this.lastRestoredCount = 0, this.isLoading = false, this.isSaving = false, this.errorMessage, this.savePath, this.searchQuery = ''}): _workspaces = workspaces,_documents = documents,_dictionary = dictionary;
  

@override@JsonKey() final  ObfuscatorWorkspace? activeWorkspace;
 final  List<ObfuscatorWorkspace> _workspaces;
@override@JsonKey() List<ObfuscatorWorkspace> get workspaces {
  if (_workspaces is EqualUnmodifiableListView) return _workspaces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workspaces);
}

 final  List<ImportedDocument> _documents;
@override@JsonKey() List<ImportedDocument> get documents {
  if (_documents is EqualUnmodifiableListView) return _documents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_documents);
}

 final  List<DictionaryEntry> _dictionary;
@override@JsonKey() List<DictionaryEntry> get dictionary {
  if (_dictionary is EqualUnmodifiableListView) return _dictionary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dictionary);
}

@override@JsonKey() final  ImportedDocument? activeDocument;
@override@JsonKey() final  ObfuscatorViewMode viewMode;
@override@JsonKey() final  ObfuscatorMode mode;
@override@JsonKey() final  bool showObfuscatedPreview;
@override@JsonKey() final  String? deobfuscatedContent;
@override@JsonKey() final  int lastRestoredCount;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;
@override final  String? savePath;
@override@JsonKey() final  String searchQuery;

/// Create a copy of ObfuscatorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ObfuscatorStateCopyWith<_ObfuscatorState> get copyWith => __$ObfuscatorStateCopyWithImpl<_ObfuscatorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ObfuscatorState&&(identical(other.activeWorkspace, activeWorkspace) || other.activeWorkspace == activeWorkspace)&&const DeepCollectionEquality().equals(other._workspaces, _workspaces)&&const DeepCollectionEquality().equals(other._documents, _documents)&&const DeepCollectionEquality().equals(other._dictionary, _dictionary)&&(identical(other.activeDocument, activeDocument) || other.activeDocument == activeDocument)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.showObfuscatedPreview, showObfuscatedPreview) || other.showObfuscatedPreview == showObfuscatedPreview)&&(identical(other.deobfuscatedContent, deobfuscatedContent) || other.deobfuscatedContent == deobfuscatedContent)&&(identical(other.lastRestoredCount, lastRestoredCount) || other.lastRestoredCount == lastRestoredCount)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.savePath, savePath) || other.savePath == savePath)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,activeWorkspace,const DeepCollectionEquality().hash(_workspaces),const DeepCollectionEquality().hash(_documents),const DeepCollectionEquality().hash(_dictionary),activeDocument,viewMode,mode,showObfuscatedPreview,deobfuscatedContent,lastRestoredCount,isLoading,isSaving,errorMessage,savePath,searchQuery);

@override
String toString() {
  return 'ObfuscatorState(activeWorkspace: $activeWorkspace, workspaces: $workspaces, documents: $documents, dictionary: $dictionary, activeDocument: $activeDocument, viewMode: $viewMode, mode: $mode, showObfuscatedPreview: $showObfuscatedPreview, deobfuscatedContent: $deobfuscatedContent, lastRestoredCount: $lastRestoredCount, isLoading: $isLoading, isSaving: $isSaving, errorMessage: $errorMessage, savePath: $savePath, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$ObfuscatorStateCopyWith<$Res> implements $ObfuscatorStateCopyWith<$Res> {
  factory _$ObfuscatorStateCopyWith(_ObfuscatorState value, $Res Function(_ObfuscatorState) _then) = __$ObfuscatorStateCopyWithImpl;
@override @useResult
$Res call({
 ObfuscatorWorkspace? activeWorkspace, List<ObfuscatorWorkspace> workspaces, List<ImportedDocument> documents, List<DictionaryEntry> dictionary, ImportedDocument? activeDocument, ObfuscatorViewMode viewMode, ObfuscatorMode mode, bool showObfuscatedPreview, String? deobfuscatedContent, int lastRestoredCount, bool isLoading, bool isSaving, String? errorMessage, String? savePath, String searchQuery
});


@override $ObfuscatorWorkspaceCopyWith<$Res>? get activeWorkspace;@override $ImportedDocumentCopyWith<$Res>? get activeDocument;

}
/// @nodoc
class __$ObfuscatorStateCopyWithImpl<$Res>
    implements _$ObfuscatorStateCopyWith<$Res> {
  __$ObfuscatorStateCopyWithImpl(this._self, this._then);

  final _ObfuscatorState _self;
  final $Res Function(_ObfuscatorState) _then;

/// Create a copy of ObfuscatorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeWorkspace = freezed,Object? workspaces = null,Object? documents = null,Object? dictionary = null,Object? activeDocument = freezed,Object? viewMode = null,Object? mode = null,Object? showObfuscatedPreview = null,Object? deobfuscatedContent = freezed,Object? lastRestoredCount = null,Object? isLoading = null,Object? isSaving = null,Object? errorMessage = freezed,Object? savePath = freezed,Object? searchQuery = null,}) {
  return _then(_ObfuscatorState(
activeWorkspace: freezed == activeWorkspace ? _self.activeWorkspace : activeWorkspace // ignore: cast_nullable_to_non_nullable
as ObfuscatorWorkspace?,workspaces: null == workspaces ? _self._workspaces : workspaces // ignore: cast_nullable_to_non_nullable
as List<ObfuscatorWorkspace>,documents: null == documents ? _self._documents : documents // ignore: cast_nullable_to_non_nullable
as List<ImportedDocument>,dictionary: null == dictionary ? _self._dictionary : dictionary // ignore: cast_nullable_to_non_nullable
as List<DictionaryEntry>,activeDocument: freezed == activeDocument ? _self.activeDocument : activeDocument // ignore: cast_nullable_to_non_nullable
as ImportedDocument?,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ObfuscatorViewMode,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ObfuscatorMode,showObfuscatedPreview: null == showObfuscatedPreview ? _self.showObfuscatedPreview : showObfuscatedPreview // ignore: cast_nullable_to_non_nullable
as bool,deobfuscatedContent: freezed == deobfuscatedContent ? _self.deobfuscatedContent : deobfuscatedContent // ignore: cast_nullable_to_non_nullable
as String?,lastRestoredCount: null == lastRestoredCount ? _self.lastRestoredCount : lastRestoredCount // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,savePath: freezed == savePath ? _self.savePath : savePath // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ObfuscatorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ObfuscatorWorkspaceCopyWith<$Res>? get activeWorkspace {
    if (_self.activeWorkspace == null) {
    return null;
  }

  return $ObfuscatorWorkspaceCopyWith<$Res>(_self.activeWorkspace!, (value) {
    return _then(_self.copyWith(activeWorkspace: value));
  });
}/// Create a copy of ObfuscatorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportedDocumentCopyWith<$Res>? get activeDocument {
    if (_self.activeDocument == null) {
    return null;
  }

  return $ImportedDocumentCopyWith<$Res>(_self.activeDocument!, (value) {
    return _then(_self.copyWith(activeDocument: value));
  });
}
}

// dart format on
