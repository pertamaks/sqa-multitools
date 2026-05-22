// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'imported_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImportedDocument {

 String get id; String get fileName; String get content; DateTime get importedAt; int get matchedTerms;
/// Create a copy of ImportedDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportedDocumentCopyWith<ImportedDocument> get copyWith => _$ImportedDocumentCopyWithImpl<ImportedDocument>(this as ImportedDocument, _$identity);

  /// Serializes this ImportedDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportedDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.content, content) || other.content == content)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.matchedTerms, matchedTerms) || other.matchedTerms == matchedTerms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileName,content,importedAt,matchedTerms);

@override
String toString() {
  return 'ImportedDocument(id: $id, fileName: $fileName, content: $content, importedAt: $importedAt, matchedTerms: $matchedTerms)';
}


}

/// @nodoc
abstract mixin class $ImportedDocumentCopyWith<$Res>  {
  factory $ImportedDocumentCopyWith(ImportedDocument value, $Res Function(ImportedDocument) _then) = _$ImportedDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String fileName, String content, DateTime importedAt, int matchedTerms
});




}
/// @nodoc
class _$ImportedDocumentCopyWithImpl<$Res>
    implements $ImportedDocumentCopyWith<$Res> {
  _$ImportedDocumentCopyWithImpl(this._self, this._then);

  final ImportedDocument _self;
  final $Res Function(ImportedDocument) _then;

/// Create a copy of ImportedDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fileName = null,Object? content = null,Object? importedAt = null,Object? matchedTerms = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,matchedTerms: null == matchedTerms ? _self.matchedTerms : matchedTerms // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportedDocument].
extension ImportedDocumentPatterns on ImportedDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportedDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportedDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportedDocument value)  $default,){
final _that = this;
switch (_that) {
case _ImportedDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportedDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ImportedDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fileName,  String content,  DateTime importedAt,  int matchedTerms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportedDocument() when $default != null:
return $default(_that.id,_that.fileName,_that.content,_that.importedAt,_that.matchedTerms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fileName,  String content,  DateTime importedAt,  int matchedTerms)  $default,) {final _that = this;
switch (_that) {
case _ImportedDocument():
return $default(_that.id,_that.fileName,_that.content,_that.importedAt,_that.matchedTerms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fileName,  String content,  DateTime importedAt,  int matchedTerms)?  $default,) {final _that = this;
switch (_that) {
case _ImportedDocument() when $default != null:
return $default(_that.id,_that.fileName,_that.content,_that.importedAt,_that.matchedTerms);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportedDocument implements ImportedDocument {
  const _ImportedDocument({required this.id, required this.fileName, required this.content, required this.importedAt, this.matchedTerms = 0});
  factory _ImportedDocument.fromJson(Map<String, dynamic> json) => _$ImportedDocumentFromJson(json);

@override final  String id;
@override final  String fileName;
@override final  String content;
@override final  DateTime importedAt;
@override@JsonKey() final  int matchedTerms;

/// Create a copy of ImportedDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportedDocumentCopyWith<_ImportedDocument> get copyWith => __$ImportedDocumentCopyWithImpl<_ImportedDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportedDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportedDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.content, content) || other.content == content)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.matchedTerms, matchedTerms) || other.matchedTerms == matchedTerms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileName,content,importedAt,matchedTerms);

@override
String toString() {
  return 'ImportedDocument(id: $id, fileName: $fileName, content: $content, importedAt: $importedAt, matchedTerms: $matchedTerms)';
}


}

/// @nodoc
abstract mixin class _$ImportedDocumentCopyWith<$Res> implements $ImportedDocumentCopyWith<$Res> {
  factory _$ImportedDocumentCopyWith(_ImportedDocument value, $Res Function(_ImportedDocument) _then) = __$ImportedDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String fileName, String content, DateTime importedAt, int matchedTerms
});




}
/// @nodoc
class __$ImportedDocumentCopyWithImpl<$Res>
    implements _$ImportedDocumentCopyWith<$Res> {
  __$ImportedDocumentCopyWithImpl(this._self, this._then);

  final _ImportedDocument _self;
  final $Res Function(_ImportedDocument) _then;

/// Create a copy of ImportedDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fileName = null,Object? content = null,Object? importedAt = null,Object? matchedTerms = null,}) {
  return _then(_ImportedDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,matchedTerms: null == matchedTerms ? _self.matchedTerms : matchedTerms // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
