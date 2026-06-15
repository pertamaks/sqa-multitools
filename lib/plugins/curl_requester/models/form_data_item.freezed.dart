// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'form_data_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FormDataItem {

 String get id; String get key; String get value; String? get filePath; bool get isFile; bool get isActive;
/// Create a copy of FormDataItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormDataItemCopyWith<FormDataItem> get copyWith => _$FormDataItemCopyWithImpl<FormDataItem>(this as FormDataItem, _$identity);

  /// Serializes this FormDataItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FormDataItem&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.isFile, isFile) || other.isFile == isFile)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,value,filePath,isFile,isActive);

@override
String toString() {
  return 'FormDataItem(id: $id, key: $key, value: $value, filePath: $filePath, isFile: $isFile, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $FormDataItemCopyWith<$Res>  {
  factory $FormDataItemCopyWith(FormDataItem value, $Res Function(FormDataItem) _then) = _$FormDataItemCopyWithImpl;
@useResult
$Res call({
 String id, String key, String value, String? filePath, bool isFile, bool isActive
});




}
/// @nodoc
class _$FormDataItemCopyWithImpl<$Res>
    implements $FormDataItemCopyWith<$Res> {
  _$FormDataItemCopyWithImpl(this._self, this._then);

  final FormDataItem _self;
  final $Res Function(FormDataItem) _then;

/// Create a copy of FormDataItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? key = null,Object? value = null,Object? filePath = freezed,Object? isFile = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,isFile: null == isFile ? _self.isFile : isFile // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FormDataItem].
extension FormDataItemPatterns on FormDataItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FormDataItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FormDataItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FormDataItem value)  $default,){
final _that = this;
switch (_that) {
case _FormDataItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FormDataItem value)?  $default,){
final _that = this;
switch (_that) {
case _FormDataItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String key,  String value,  String? filePath,  bool isFile,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FormDataItem() when $default != null:
return $default(_that.id,_that.key,_that.value,_that.filePath,_that.isFile,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String key,  String value,  String? filePath,  bool isFile,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _FormDataItem():
return $default(_that.id,_that.key,_that.value,_that.filePath,_that.isFile,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String key,  String value,  String? filePath,  bool isFile,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _FormDataItem() when $default != null:
return $default(_that.id,_that.key,_that.value,_that.filePath,_that.isFile,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FormDataItem implements FormDataItem {
  const _FormDataItem({required this.id, this.key = '', this.value = '', this.filePath, this.isFile = false, this.isActive = true});
  factory _FormDataItem.fromJson(Map<String, dynamic> json) => _$FormDataItemFromJson(json);

@override final  String id;
@override@JsonKey() final  String key;
@override@JsonKey() final  String value;
@override final  String? filePath;
@override@JsonKey() final  bool isFile;
@override@JsonKey() final  bool isActive;

/// Create a copy of FormDataItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FormDataItemCopyWith<_FormDataItem> get copyWith => __$FormDataItemCopyWithImpl<_FormDataItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FormDataItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FormDataItem&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.isFile, isFile) || other.isFile == isFile)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,key,value,filePath,isFile,isActive);

@override
String toString() {
  return 'FormDataItem(id: $id, key: $key, value: $value, filePath: $filePath, isFile: $isFile, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$FormDataItemCopyWith<$Res> implements $FormDataItemCopyWith<$Res> {
  factory _$FormDataItemCopyWith(_FormDataItem value, $Res Function(_FormDataItem) _then) = __$FormDataItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String key, String value, String? filePath, bool isFile, bool isActive
});




}
/// @nodoc
class __$FormDataItemCopyWithImpl<$Res>
    implements _$FormDataItemCopyWith<$Res> {
  __$FormDataItemCopyWithImpl(this._self, this._then);

  final _FormDataItem _self;
  final $Res Function(_FormDataItem) _then;

/// Create a copy of FormDataItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? key = null,Object? value = null,Object? filePath = freezed,Object? isFile = null,Object? isActive = null,}) {
  return _then(_FormDataItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,isFile: null == isFile ? _self.isFile : isFile // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
