// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'obfuscator_workspace.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ObfuscatorWorkspace {

 String get id; String get name; DateTime get createdAt; SubstitutionStrategy get strategy; int get dictionarySize; int get totalProcessed;
/// Create a copy of ObfuscatorWorkspace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObfuscatorWorkspaceCopyWith<ObfuscatorWorkspace> get copyWith => _$ObfuscatorWorkspaceCopyWithImpl<ObfuscatorWorkspace>(this as ObfuscatorWorkspace, _$identity);

  /// Serializes this ObfuscatorWorkspace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ObfuscatorWorkspace&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.dictionarySize, dictionarySize) || other.dictionarySize == dictionarySize)&&(identical(other.totalProcessed, totalProcessed) || other.totalProcessed == totalProcessed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,strategy,dictionarySize,totalProcessed);

@override
String toString() {
  return 'ObfuscatorWorkspace(id: $id, name: $name, createdAt: $createdAt, strategy: $strategy, dictionarySize: $dictionarySize, totalProcessed: $totalProcessed)';
}


}

/// @nodoc
abstract mixin class $ObfuscatorWorkspaceCopyWith<$Res>  {
  factory $ObfuscatorWorkspaceCopyWith(ObfuscatorWorkspace value, $Res Function(ObfuscatorWorkspace) _then) = _$ObfuscatorWorkspaceCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime createdAt, SubstitutionStrategy strategy, int dictionarySize, int totalProcessed
});




}
/// @nodoc
class _$ObfuscatorWorkspaceCopyWithImpl<$Res>
    implements $ObfuscatorWorkspaceCopyWith<$Res> {
  _$ObfuscatorWorkspaceCopyWithImpl(this._self, this._then);

  final ObfuscatorWorkspace _self;
  final $Res Function(ObfuscatorWorkspace) _then;

/// Create a copy of ObfuscatorWorkspace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? strategy = null,Object? dictionarySize = null,Object? totalProcessed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as SubstitutionStrategy,dictionarySize: null == dictionarySize ? _self.dictionarySize : dictionarySize // ignore: cast_nullable_to_non_nullable
as int,totalProcessed: null == totalProcessed ? _self.totalProcessed : totalProcessed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ObfuscatorWorkspace].
extension ObfuscatorWorkspacePatterns on ObfuscatorWorkspace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ObfuscatorWorkspace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ObfuscatorWorkspace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ObfuscatorWorkspace value)  $default,){
final _that = this;
switch (_that) {
case _ObfuscatorWorkspace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ObfuscatorWorkspace value)?  $default,){
final _that = this;
switch (_that) {
case _ObfuscatorWorkspace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  SubstitutionStrategy strategy,  int dictionarySize,  int totalProcessed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ObfuscatorWorkspace() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.strategy,_that.dictionarySize,_that.totalProcessed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  SubstitutionStrategy strategy,  int dictionarySize,  int totalProcessed)  $default,) {final _that = this;
switch (_that) {
case _ObfuscatorWorkspace():
return $default(_that.id,_that.name,_that.createdAt,_that.strategy,_that.dictionarySize,_that.totalProcessed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime createdAt,  SubstitutionStrategy strategy,  int dictionarySize,  int totalProcessed)?  $default,) {final _that = this;
switch (_that) {
case _ObfuscatorWorkspace() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.strategy,_that.dictionarySize,_that.totalProcessed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ObfuscatorWorkspace implements ObfuscatorWorkspace {
  const _ObfuscatorWorkspace({required this.id, required this.name, required this.createdAt, this.strategy = SubstitutionStrategy.semantic, this.dictionarySize = 0, this.totalProcessed = 0});
  factory _ObfuscatorWorkspace.fromJson(Map<String, dynamic> json) => _$ObfuscatorWorkspaceFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime createdAt;
@override@JsonKey() final  SubstitutionStrategy strategy;
@override@JsonKey() final  int dictionarySize;
@override@JsonKey() final  int totalProcessed;

/// Create a copy of ObfuscatorWorkspace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ObfuscatorWorkspaceCopyWith<_ObfuscatorWorkspace> get copyWith => __$ObfuscatorWorkspaceCopyWithImpl<_ObfuscatorWorkspace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObfuscatorWorkspaceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ObfuscatorWorkspace&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.strategy, strategy) || other.strategy == strategy)&&(identical(other.dictionarySize, dictionarySize) || other.dictionarySize == dictionarySize)&&(identical(other.totalProcessed, totalProcessed) || other.totalProcessed == totalProcessed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,strategy,dictionarySize,totalProcessed);

@override
String toString() {
  return 'ObfuscatorWorkspace(id: $id, name: $name, createdAt: $createdAt, strategy: $strategy, dictionarySize: $dictionarySize, totalProcessed: $totalProcessed)';
}


}

/// @nodoc
abstract mixin class _$ObfuscatorWorkspaceCopyWith<$Res> implements $ObfuscatorWorkspaceCopyWith<$Res> {
  factory _$ObfuscatorWorkspaceCopyWith(_ObfuscatorWorkspace value, $Res Function(_ObfuscatorWorkspace) _then) = __$ObfuscatorWorkspaceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime createdAt, SubstitutionStrategy strategy, int dictionarySize, int totalProcessed
});




}
/// @nodoc
class __$ObfuscatorWorkspaceCopyWithImpl<$Res>
    implements _$ObfuscatorWorkspaceCopyWith<$Res> {
  __$ObfuscatorWorkspaceCopyWithImpl(this._self, this._then);

  final _ObfuscatorWorkspace _self;
  final $Res Function(_ObfuscatorWorkspace) _then;

/// Create a copy of ObfuscatorWorkspace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? strategy = null,Object? dictionarySize = null,Object? totalProcessed = null,}) {
  return _then(_ObfuscatorWorkspace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,strategy: null == strategy ? _self.strategy : strategy // ignore: cast_nullable_to_non_nullable
as SubstitutionStrategy,dictionarySize: null == dictionarySize ? _self.dictionarySize : dictionarySize // ignore: cast_nullable_to_non_nullable
as int,totalProcessed: null == totalProcessed ? _self.totalProcessed : totalProcessed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
