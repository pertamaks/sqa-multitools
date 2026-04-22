// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TextDocument {

 String get id; String get name; String get content; DateTime get lastModified; TextTemplateType get templateType; bool get isPinned;
/// Create a copy of TextDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextDocumentCopyWith<TextDocument> get copyWith => _$TextDocumentCopyWithImpl<TextDocument>(this as TextDocument, _$identity);

  /// Serializes this TextDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.content, content) || other.content == content)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.templateType, templateType) || other.templateType == templateType)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,content,lastModified,templateType,isPinned);

@override
String toString() {
  return 'TextDocument(id: $id, name: $name, content: $content, lastModified: $lastModified, templateType: $templateType, isPinned: $isPinned)';
}


}

/// @nodoc
abstract mixin class $TextDocumentCopyWith<$Res>  {
  factory $TextDocumentCopyWith(TextDocument value, $Res Function(TextDocument) _then) = _$TextDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String name, String content, DateTime lastModified, TextTemplateType templateType, bool isPinned
});




}
/// @nodoc
class _$TextDocumentCopyWithImpl<$Res>
    implements $TextDocumentCopyWith<$Res> {
  _$TextDocumentCopyWithImpl(this._self, this._then);

  final TextDocument _self;
  final $Res Function(TextDocument) _then;

/// Create a copy of TextDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? content = null,Object? lastModified = null,Object? templateType = null,Object? isPinned = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,templateType: null == templateType ? _self.templateType : templateType // ignore: cast_nullable_to_non_nullable
as TextTemplateType,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TextDocument].
extension TextDocumentPatterns on TextDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextDocument value)  $default,){
final _that = this;
switch (_that) {
case _TextDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextDocument value)?  $default,){
final _that = this;
switch (_that) {
case _TextDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String content,  DateTime lastModified,  TextTemplateType templateType,  bool isPinned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextDocument() when $default != null:
return $default(_that.id,_that.name,_that.content,_that.lastModified,_that.templateType,_that.isPinned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String content,  DateTime lastModified,  TextTemplateType templateType,  bool isPinned)  $default,) {final _that = this;
switch (_that) {
case _TextDocument():
return $default(_that.id,_that.name,_that.content,_that.lastModified,_that.templateType,_that.isPinned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String content,  DateTime lastModified,  TextTemplateType templateType,  bool isPinned)?  $default,) {final _that = this;
switch (_that) {
case _TextDocument() when $default != null:
return $default(_that.id,_that.name,_that.content,_that.lastModified,_that.templateType,_that.isPinned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextDocument implements TextDocument {
  const _TextDocument({required this.id, required this.name, required this.content, required this.lastModified, this.templateType = TextTemplateType.empty, this.isPinned = false});
  factory _TextDocument.fromJson(Map<String, dynamic> json) => _$TextDocumentFromJson(json);

@override final  String id;
@override final  String name;
@override final  String content;
@override final  DateTime lastModified;
@override@JsonKey() final  TextTemplateType templateType;
@override@JsonKey() final  bool isPinned;

/// Create a copy of TextDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextDocumentCopyWith<_TextDocument> get copyWith => __$TextDocumentCopyWithImpl<_TextDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.content, content) || other.content == content)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.templateType, templateType) || other.templateType == templateType)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,content,lastModified,templateType,isPinned);

@override
String toString() {
  return 'TextDocument(id: $id, name: $name, content: $content, lastModified: $lastModified, templateType: $templateType, isPinned: $isPinned)';
}


}

/// @nodoc
abstract mixin class _$TextDocumentCopyWith<$Res> implements $TextDocumentCopyWith<$Res> {
  factory _$TextDocumentCopyWith(_TextDocument value, $Res Function(_TextDocument) _then) = __$TextDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String content, DateTime lastModified, TextTemplateType templateType, bool isPinned
});




}
/// @nodoc
class __$TextDocumentCopyWithImpl<$Res>
    implements _$TextDocumentCopyWith<$Res> {
  __$TextDocumentCopyWithImpl(this._self, this._then);

  final _TextDocument _self;
  final $Res Function(_TextDocument) _then;

/// Create a copy of TextDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? content = null,Object? lastModified = null,Object? templateType = null,Object? isPinned = null,}) {
  return _then(_TextDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,templateType: null == templateType ? _self.templateType : templateType // ignore: cast_nullable_to_non_nullable
as TextTemplateType,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
