// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'md_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MdDocument {

 String get id; String get name; String get content; DateTime get lastModified; MdTemplateType get templateType;
/// Create a copy of MdDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MdDocumentCopyWith<MdDocument> get copyWith => _$MdDocumentCopyWithImpl<MdDocument>(this as MdDocument, _$identity);

  /// Serializes this MdDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MdDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.content, content) || other.content == content)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.templateType, templateType) || other.templateType == templateType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,content,lastModified,templateType);

@override
String toString() {
  return 'MdDocument(id: $id, name: $name, content: $content, lastModified: $lastModified, templateType: $templateType)';
}


}

/// @nodoc
abstract mixin class $MdDocumentCopyWith<$Res>  {
  factory $MdDocumentCopyWith(MdDocument value, $Res Function(MdDocument) _then) = _$MdDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String name, String content, DateTime lastModified, MdTemplateType templateType
});




}
/// @nodoc
class _$MdDocumentCopyWithImpl<$Res>
    implements $MdDocumentCopyWith<$Res> {
  _$MdDocumentCopyWithImpl(this._self, this._then);

  final MdDocument _self;
  final $Res Function(MdDocument) _then;

/// Create a copy of MdDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? content = null,Object? lastModified = null,Object? templateType = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,templateType: null == templateType ? _self.templateType : templateType // ignore: cast_nullable_to_non_nullable
as MdTemplateType,
  ));
}

}


/// Adds pattern-matching-related methods to [MdDocument].
extension MdDocumentPatterns on MdDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MdDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MdDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MdDocument value)  $default,){
final _that = this;
switch (_that) {
case _MdDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MdDocument value)?  $default,){
final _that = this;
switch (_that) {
case _MdDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String content,  DateTime lastModified,  MdTemplateType templateType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MdDocument() when $default != null:
return $default(_that.id,_that.name,_that.content,_that.lastModified,_that.templateType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String content,  DateTime lastModified,  MdTemplateType templateType)  $default,) {final _that = this;
switch (_that) {
case _MdDocument():
return $default(_that.id,_that.name,_that.content,_that.lastModified,_that.templateType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String content,  DateTime lastModified,  MdTemplateType templateType)?  $default,) {final _that = this;
switch (_that) {
case _MdDocument() when $default != null:
return $default(_that.id,_that.name,_that.content,_that.lastModified,_that.templateType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MdDocument implements MdDocument {
  const _MdDocument({required this.id, required this.name, required this.content, required this.lastModified, this.templateType = MdTemplateType.empty});
  factory _MdDocument.fromJson(Map<String, dynamic> json) => _$MdDocumentFromJson(json);

@override final  String id;
@override final  String name;
@override final  String content;
@override final  DateTime lastModified;
@override@JsonKey() final  MdTemplateType templateType;

/// Create a copy of MdDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MdDocumentCopyWith<_MdDocument> get copyWith => __$MdDocumentCopyWithImpl<_MdDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MdDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MdDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.content, content) || other.content == content)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.templateType, templateType) || other.templateType == templateType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,content,lastModified,templateType);

@override
String toString() {
  return 'MdDocument(id: $id, name: $name, content: $content, lastModified: $lastModified, templateType: $templateType)';
}


}

/// @nodoc
abstract mixin class _$MdDocumentCopyWith<$Res> implements $MdDocumentCopyWith<$Res> {
  factory _$MdDocumentCopyWith(_MdDocument value, $Res Function(_MdDocument) _then) = __$MdDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String content, DateTime lastModified, MdTemplateType templateType
});




}
/// @nodoc
class __$MdDocumentCopyWithImpl<$Res>
    implements _$MdDocumentCopyWith<$Res> {
  __$MdDocumentCopyWithImpl(this._self, this._then);

  final _MdDocument _self;
  final $Res Function(_MdDocument) _then;

/// Create a copy of MdDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? content = null,Object? lastModified = null,Object? templateType = null,}) {
  return _then(_MdDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,templateType: null == templateType ? _self.templateType : templateType // ignore: cast_nullable_to_non_nullable
as MdTemplateType,
  ));
}


}

// dart format on
