// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cheatsheet_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheatsheetCategory {

 String get name; String get description; IconData get icon; List<CheatsheetSection> get sections;
/// Create a copy of CheatsheetCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheatsheetCategoryCopyWith<CheatsheetCategory> get copyWith => _$CheatsheetCategoryCopyWithImpl<CheatsheetCategory>(this as CheatsheetCategory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheatsheetCategory&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.sections, sections));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,icon,const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'CheatsheetCategory(name: $name, description: $description, icon: $icon, sections: $sections)';
}


}

/// @nodoc
abstract mixin class $CheatsheetCategoryCopyWith<$Res>  {
  factory $CheatsheetCategoryCopyWith(CheatsheetCategory value, $Res Function(CheatsheetCategory) _then) = _$CheatsheetCategoryCopyWithImpl;
@useResult
$Res call({
 String name, String description, IconData icon, List<CheatsheetSection> sections
});




}
/// @nodoc
class _$CheatsheetCategoryCopyWithImpl<$Res>
    implements $CheatsheetCategoryCopyWith<$Res> {
  _$CheatsheetCategoryCopyWithImpl(this._self, this._then);

  final CheatsheetCategory _self;
  final $Res Function(CheatsheetCategory) _then;

/// Create a copy of CheatsheetCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? icon = null,Object? sections = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<CheatsheetSection>,
  ));
}

}


/// Adds pattern-matching-related methods to [CheatsheetCategory].
extension CheatsheetCategoryPatterns on CheatsheetCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheatsheetCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheatsheetCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheatsheetCategory value)  $default,){
final _that = this;
switch (_that) {
case _CheatsheetCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheatsheetCategory value)?  $default,){
final _that = this;
switch (_that) {
case _CheatsheetCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  IconData icon,  List<CheatsheetSection> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheatsheetCategory() when $default != null:
return $default(_that.name,_that.description,_that.icon,_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  IconData icon,  List<CheatsheetSection> sections)  $default,) {final _that = this;
switch (_that) {
case _CheatsheetCategory():
return $default(_that.name,_that.description,_that.icon,_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  IconData icon,  List<CheatsheetSection> sections)?  $default,) {final _that = this;
switch (_that) {
case _CheatsheetCategory() when $default != null:
return $default(_that.name,_that.description,_that.icon,_that.sections);case _:
  return null;

}
}

}

/// @nodoc


class _CheatsheetCategory implements CheatsheetCategory {
  const _CheatsheetCategory({required this.name, required this.description, required this.icon, required final  List<CheatsheetSection> sections}): _sections = sections;
  

@override final  String name;
@override final  String description;
@override final  IconData icon;
 final  List<CheatsheetSection> _sections;
@override List<CheatsheetSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of CheatsheetCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheatsheetCategoryCopyWith<_CheatsheetCategory> get copyWith => __$CheatsheetCategoryCopyWithImpl<_CheatsheetCategory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheatsheetCategory&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other._sections, _sections));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,icon,const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'CheatsheetCategory(name: $name, description: $description, icon: $icon, sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$CheatsheetCategoryCopyWith<$Res> implements $CheatsheetCategoryCopyWith<$Res> {
  factory _$CheatsheetCategoryCopyWith(_CheatsheetCategory value, $Res Function(_CheatsheetCategory) _then) = __$CheatsheetCategoryCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, IconData icon, List<CheatsheetSection> sections
});




}
/// @nodoc
class __$CheatsheetCategoryCopyWithImpl<$Res>
    implements _$CheatsheetCategoryCopyWith<$Res> {
  __$CheatsheetCategoryCopyWithImpl(this._self, this._then);

  final _CheatsheetCategory _self;
  final $Res Function(_CheatsheetCategory) _then;

/// Create a copy of CheatsheetCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? icon = null,Object? sections = null,}) {
  return _then(_CheatsheetCategory(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<CheatsheetSection>,
  ));
}


}

/// @nodoc
mixin _$CheatsheetSection {

 String get id; String get title; IconData get icon; String get markdown;
/// Create a copy of CheatsheetSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheatsheetSectionCopyWith<CheatsheetSection> get copyWith => _$CheatsheetSectionCopyWithImpl<CheatsheetSection>(this as CheatsheetSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheatsheetSection&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.markdown, markdown) || other.markdown == markdown));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,icon,markdown);

@override
String toString() {
  return 'CheatsheetSection(id: $id, title: $title, icon: $icon, markdown: $markdown)';
}


}

/// @nodoc
abstract mixin class $CheatsheetSectionCopyWith<$Res>  {
  factory $CheatsheetSectionCopyWith(CheatsheetSection value, $Res Function(CheatsheetSection) _then) = _$CheatsheetSectionCopyWithImpl;
@useResult
$Res call({
 String id, String title, IconData icon, String markdown
});




}
/// @nodoc
class _$CheatsheetSectionCopyWithImpl<$Res>
    implements $CheatsheetSectionCopyWith<$Res> {
  _$CheatsheetSectionCopyWithImpl(this._self, this._then);

  final CheatsheetSection _self;
  final $Res Function(CheatsheetSection) _then;

/// Create a copy of CheatsheetSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? icon = null,Object? markdown = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,markdown: null == markdown ? _self.markdown : markdown // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CheatsheetSection].
extension CheatsheetSectionPatterns on CheatsheetSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheatsheetSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheatsheetSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheatsheetSection value)  $default,){
final _that = this;
switch (_that) {
case _CheatsheetSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheatsheetSection value)?  $default,){
final _that = this;
switch (_that) {
case _CheatsheetSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  IconData icon,  String markdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheatsheetSection() when $default != null:
return $default(_that.id,_that.title,_that.icon,_that.markdown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  IconData icon,  String markdown)  $default,) {final _that = this;
switch (_that) {
case _CheatsheetSection():
return $default(_that.id,_that.title,_that.icon,_that.markdown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  IconData icon,  String markdown)?  $default,) {final _that = this;
switch (_that) {
case _CheatsheetSection() when $default != null:
return $default(_that.id,_that.title,_that.icon,_that.markdown);case _:
  return null;

}
}

}

/// @nodoc


class _CheatsheetSection implements CheatsheetSection {
  const _CheatsheetSection({required this.id, required this.title, required this.icon, required this.markdown});
  

@override final  String id;
@override final  String title;
@override final  IconData icon;
@override final  String markdown;

/// Create a copy of CheatsheetSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheatsheetSectionCopyWith<_CheatsheetSection> get copyWith => __$CheatsheetSectionCopyWithImpl<_CheatsheetSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheatsheetSection&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.markdown, markdown) || other.markdown == markdown));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,icon,markdown);

@override
String toString() {
  return 'CheatsheetSection(id: $id, title: $title, icon: $icon, markdown: $markdown)';
}


}

/// @nodoc
abstract mixin class _$CheatsheetSectionCopyWith<$Res> implements $CheatsheetSectionCopyWith<$Res> {
  factory _$CheatsheetSectionCopyWith(_CheatsheetSection value, $Res Function(_CheatsheetSection) _then) = __$CheatsheetSectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, IconData icon, String markdown
});




}
/// @nodoc
class __$CheatsheetSectionCopyWithImpl<$Res>
    implements _$CheatsheetSectionCopyWith<$Res> {
  __$CheatsheetSectionCopyWithImpl(this._self, this._then);

  final _CheatsheetSection _self;
  final $Res Function(_CheatsheetSection) _then;

/// Create a copy of CheatsheetSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? icon = null,Object? markdown = null,}) {
  return _then(_CheatsheetSection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,markdown: null == markdown ? _self.markdown : markdown // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
