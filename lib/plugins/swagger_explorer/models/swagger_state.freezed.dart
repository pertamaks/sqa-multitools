// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swagger_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SwaggerSecurityScheme {

 String get type;// apiKey, http, oauth2, openIdConnect, basic
 String? get description; String? get name;// Name of the header, query or cookie parameter
@JsonKey(name: 'in') String? get inLocation;// query, header, cookie
 String? get scheme;// bearer, basic, etc.
 String? get bearerFormat;
/// Create a copy of SwaggerSecurityScheme
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwaggerSecuritySchemeCopyWith<SwaggerSecurityScheme> get copyWith => _$SwaggerSecuritySchemeCopyWithImpl<SwaggerSecurityScheme>(this as SwaggerSecurityScheme, _$identity);

  /// Serializes this SwaggerSecurityScheme to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwaggerSecurityScheme&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.name, name) || other.name == name)&&(identical(other.inLocation, inLocation) || other.inLocation == inLocation)&&(identical(other.scheme, scheme) || other.scheme == scheme)&&(identical(other.bearerFormat, bearerFormat) || other.bearerFormat == bearerFormat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,description,name,inLocation,scheme,bearerFormat);

@override
String toString() {
  return 'SwaggerSecurityScheme(type: $type, description: $description, name: $name, inLocation: $inLocation, scheme: $scheme, bearerFormat: $bearerFormat)';
}


}

/// @nodoc
abstract mixin class $SwaggerSecuritySchemeCopyWith<$Res>  {
  factory $SwaggerSecuritySchemeCopyWith(SwaggerSecurityScheme value, $Res Function(SwaggerSecurityScheme) _then) = _$SwaggerSecuritySchemeCopyWithImpl;
@useResult
$Res call({
 String type, String? description, String? name,@JsonKey(name: 'in') String? inLocation, String? scheme, String? bearerFormat
});




}
/// @nodoc
class _$SwaggerSecuritySchemeCopyWithImpl<$Res>
    implements $SwaggerSecuritySchemeCopyWith<$Res> {
  _$SwaggerSecuritySchemeCopyWithImpl(this._self, this._then);

  final SwaggerSecurityScheme _self;
  final $Res Function(SwaggerSecurityScheme) _then;

/// Create a copy of SwaggerSecurityScheme
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? description = freezed,Object? name = freezed,Object? inLocation = freezed,Object? scheme = freezed,Object? bearerFormat = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,inLocation: freezed == inLocation ? _self.inLocation : inLocation // ignore: cast_nullable_to_non_nullable
as String?,scheme: freezed == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as String?,bearerFormat: freezed == bearerFormat ? _self.bearerFormat : bearerFormat // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SwaggerSecurityScheme].
extension SwaggerSecuritySchemePatterns on SwaggerSecurityScheme {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwaggerSecurityScheme value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwaggerSecurityScheme() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwaggerSecurityScheme value)  $default,){
final _that = this;
switch (_that) {
case _SwaggerSecurityScheme():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwaggerSecurityScheme value)?  $default,){
final _that = this;
switch (_that) {
case _SwaggerSecurityScheme() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? description,  String? name, @JsonKey(name: 'in')  String? inLocation,  String? scheme,  String? bearerFormat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwaggerSecurityScheme() when $default != null:
return $default(_that.type,_that.description,_that.name,_that.inLocation,_that.scheme,_that.bearerFormat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? description,  String? name, @JsonKey(name: 'in')  String? inLocation,  String? scheme,  String? bearerFormat)  $default,) {final _that = this;
switch (_that) {
case _SwaggerSecurityScheme():
return $default(_that.type,_that.description,_that.name,_that.inLocation,_that.scheme,_that.bearerFormat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? description,  String? name, @JsonKey(name: 'in')  String? inLocation,  String? scheme,  String? bearerFormat)?  $default,) {final _that = this;
switch (_that) {
case _SwaggerSecurityScheme() when $default != null:
return $default(_that.type,_that.description,_that.name,_that.inLocation,_that.scheme,_that.bearerFormat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwaggerSecurityScheme implements SwaggerSecurityScheme {
  const _SwaggerSecurityScheme({required this.type, this.description, this.name, @JsonKey(name: 'in') this.inLocation, this.scheme, this.bearerFormat});
  factory _SwaggerSecurityScheme.fromJson(Map<String, dynamic> json) => _$SwaggerSecuritySchemeFromJson(json);

@override final  String type;
// apiKey, http, oauth2, openIdConnect, basic
@override final  String? description;
@override final  String? name;
// Name of the header, query or cookie parameter
@override@JsonKey(name: 'in') final  String? inLocation;
// query, header, cookie
@override final  String? scheme;
// bearer, basic, etc.
@override final  String? bearerFormat;

/// Create a copy of SwaggerSecurityScheme
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwaggerSecuritySchemeCopyWith<_SwaggerSecurityScheme> get copyWith => __$SwaggerSecuritySchemeCopyWithImpl<_SwaggerSecurityScheme>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwaggerSecuritySchemeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwaggerSecurityScheme&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.name, name) || other.name == name)&&(identical(other.inLocation, inLocation) || other.inLocation == inLocation)&&(identical(other.scheme, scheme) || other.scheme == scheme)&&(identical(other.bearerFormat, bearerFormat) || other.bearerFormat == bearerFormat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,description,name,inLocation,scheme,bearerFormat);

@override
String toString() {
  return 'SwaggerSecurityScheme(type: $type, description: $description, name: $name, inLocation: $inLocation, scheme: $scheme, bearerFormat: $bearerFormat)';
}


}

/// @nodoc
abstract mixin class _$SwaggerSecuritySchemeCopyWith<$Res> implements $SwaggerSecuritySchemeCopyWith<$Res> {
  factory _$SwaggerSecuritySchemeCopyWith(_SwaggerSecurityScheme value, $Res Function(_SwaggerSecurityScheme) _then) = __$SwaggerSecuritySchemeCopyWithImpl;
@override @useResult
$Res call({
 String type, String? description, String? name,@JsonKey(name: 'in') String? inLocation, String? scheme, String? bearerFormat
});




}
/// @nodoc
class __$SwaggerSecuritySchemeCopyWithImpl<$Res>
    implements _$SwaggerSecuritySchemeCopyWith<$Res> {
  __$SwaggerSecuritySchemeCopyWithImpl(this._self, this._then);

  final _SwaggerSecurityScheme _self;
  final $Res Function(_SwaggerSecurityScheme) _then;

/// Create a copy of SwaggerSecurityScheme
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? description = freezed,Object? name = freezed,Object? inLocation = freezed,Object? scheme = freezed,Object? bearerFormat = freezed,}) {
  return _then(_SwaggerSecurityScheme(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,inLocation: freezed == inLocation ? _self.inLocation : inLocation // ignore: cast_nullable_to_non_nullable
as String?,scheme: freezed == scheme ? _self.scheme : scheme // ignore: cast_nullable_to_non_nullable
as String?,bearerFormat: freezed == bearerFormat ? _self.bearerFormat : bearerFormat // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SwaggerEndpoint {

 String get path; String get method; String get summary; List<String> get tags; List<Map<String, dynamic>>? get parameters; Map<String, dynamic>? get requestBody; Map<String, dynamic>? get responses; List<Map<String, List<String>>>? get security;
/// Create a copy of SwaggerEndpoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwaggerEndpointCopyWith<SwaggerEndpoint> get copyWith => _$SwaggerEndpointCopyWithImpl<SwaggerEndpoint>(this as SwaggerEndpoint, _$identity);

  /// Serializes this SwaggerEndpoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwaggerEndpoint&&(identical(other.path, path) || other.path == path)&&(identical(other.method, method) || other.method == method)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.parameters, parameters)&&const DeepCollectionEquality().equals(other.requestBody, requestBody)&&const DeepCollectionEquality().equals(other.responses, responses)&&const DeepCollectionEquality().equals(other.security, security));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,path,method,summary,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(parameters),const DeepCollectionEquality().hash(requestBody),const DeepCollectionEquality().hash(responses),const DeepCollectionEquality().hash(security));

@override
String toString() {
  return 'SwaggerEndpoint(path: $path, method: $method, summary: $summary, tags: $tags, parameters: $parameters, requestBody: $requestBody, responses: $responses, security: $security)';
}


}

/// @nodoc
abstract mixin class $SwaggerEndpointCopyWith<$Res>  {
  factory $SwaggerEndpointCopyWith(SwaggerEndpoint value, $Res Function(SwaggerEndpoint) _then) = _$SwaggerEndpointCopyWithImpl;
@useResult
$Res call({
 String path, String method, String summary, List<String> tags, List<Map<String, dynamic>>? parameters, Map<String, dynamic>? requestBody, Map<String, dynamic>? responses, List<Map<String, List<String>>>? security
});




}
/// @nodoc
class _$SwaggerEndpointCopyWithImpl<$Res>
    implements $SwaggerEndpointCopyWith<$Res> {
  _$SwaggerEndpointCopyWithImpl(this._self, this._then);

  final SwaggerEndpoint _self;
  final $Res Function(SwaggerEndpoint) _then;

/// Create a copy of SwaggerEndpoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? method = null,Object? summary = null,Object? tags = null,Object? parameters = freezed,Object? requestBody = freezed,Object? responses = freezed,Object? security = freezed,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,parameters: freezed == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,requestBody: freezed == requestBody ? _self.requestBody : requestBody // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,responses: freezed == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,security: freezed == security ? _self.security : security // ignore: cast_nullable_to_non_nullable
as List<Map<String, List<String>>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SwaggerEndpoint].
extension SwaggerEndpointPatterns on SwaggerEndpoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwaggerEndpoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwaggerEndpoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwaggerEndpoint value)  $default,){
final _that = this;
switch (_that) {
case _SwaggerEndpoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwaggerEndpoint value)?  $default,){
final _that = this;
switch (_that) {
case _SwaggerEndpoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String method,  String summary,  List<String> tags,  List<Map<String, dynamic>>? parameters,  Map<String, dynamic>? requestBody,  Map<String, dynamic>? responses,  List<Map<String, List<String>>>? security)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwaggerEndpoint() when $default != null:
return $default(_that.path,_that.method,_that.summary,_that.tags,_that.parameters,_that.requestBody,_that.responses,_that.security);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String method,  String summary,  List<String> tags,  List<Map<String, dynamic>>? parameters,  Map<String, dynamic>? requestBody,  Map<String, dynamic>? responses,  List<Map<String, List<String>>>? security)  $default,) {final _that = this;
switch (_that) {
case _SwaggerEndpoint():
return $default(_that.path,_that.method,_that.summary,_that.tags,_that.parameters,_that.requestBody,_that.responses,_that.security);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String method,  String summary,  List<String> tags,  List<Map<String, dynamic>>? parameters,  Map<String, dynamic>? requestBody,  Map<String, dynamic>? responses,  List<Map<String, List<String>>>? security)?  $default,) {final _that = this;
switch (_that) {
case _SwaggerEndpoint() when $default != null:
return $default(_that.path,_that.method,_that.summary,_that.tags,_that.parameters,_that.requestBody,_that.responses,_that.security);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwaggerEndpoint implements SwaggerEndpoint {
  const _SwaggerEndpoint({required this.path, required this.method, required this.summary, required final  List<String> tags, final  List<Map<String, dynamic>>? parameters, final  Map<String, dynamic>? requestBody, final  Map<String, dynamic>? responses, final  List<Map<String, List<String>>>? security}): _tags = tags,_parameters = parameters,_requestBody = requestBody,_responses = responses,_security = security;
  factory _SwaggerEndpoint.fromJson(Map<String, dynamic> json) => _$SwaggerEndpointFromJson(json);

@override final  String path;
@override final  String method;
@override final  String summary;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<Map<String, dynamic>>? _parameters;
@override List<Map<String, dynamic>>? get parameters {
  final value = _parameters;
  if (value == null) return null;
  if (_parameters is EqualUnmodifiableListView) return _parameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _requestBody;
@override Map<String, dynamic>? get requestBody {
  final value = _requestBody;
  if (value == null) return null;
  if (_requestBody is EqualUnmodifiableMapView) return _requestBody;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _responses;
@override Map<String, dynamic>? get responses {
  final value = _responses;
  if (value == null) return null;
  if (_responses is EqualUnmodifiableMapView) return _responses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<Map<String, List<String>>>? _security;
@override List<Map<String, List<String>>>? get security {
  final value = _security;
  if (value == null) return null;
  if (_security is EqualUnmodifiableListView) return _security;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SwaggerEndpoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwaggerEndpointCopyWith<_SwaggerEndpoint> get copyWith => __$SwaggerEndpointCopyWithImpl<_SwaggerEndpoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwaggerEndpointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwaggerEndpoint&&(identical(other.path, path) || other.path == path)&&(identical(other.method, method) || other.method == method)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._parameters, _parameters)&&const DeepCollectionEquality().equals(other._requestBody, _requestBody)&&const DeepCollectionEquality().equals(other._responses, _responses)&&const DeepCollectionEquality().equals(other._security, _security));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,path,method,summary,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_parameters),const DeepCollectionEquality().hash(_requestBody),const DeepCollectionEquality().hash(_responses),const DeepCollectionEquality().hash(_security));

@override
String toString() {
  return 'SwaggerEndpoint(path: $path, method: $method, summary: $summary, tags: $tags, parameters: $parameters, requestBody: $requestBody, responses: $responses, security: $security)';
}


}

/// @nodoc
abstract mixin class _$SwaggerEndpointCopyWith<$Res> implements $SwaggerEndpointCopyWith<$Res> {
  factory _$SwaggerEndpointCopyWith(_SwaggerEndpoint value, $Res Function(_SwaggerEndpoint) _then) = __$SwaggerEndpointCopyWithImpl;
@override @useResult
$Res call({
 String path, String method, String summary, List<String> tags, List<Map<String, dynamic>>? parameters, Map<String, dynamic>? requestBody, Map<String, dynamic>? responses, List<Map<String, List<String>>>? security
});




}
/// @nodoc
class __$SwaggerEndpointCopyWithImpl<$Res>
    implements _$SwaggerEndpointCopyWith<$Res> {
  __$SwaggerEndpointCopyWithImpl(this._self, this._then);

  final _SwaggerEndpoint _self;
  final $Res Function(_SwaggerEndpoint) _then;

/// Create a copy of SwaggerEndpoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? method = null,Object? summary = null,Object? tags = null,Object? parameters = freezed,Object? requestBody = freezed,Object? responses = freezed,Object? security = freezed,}) {
  return _then(_SwaggerEndpoint(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,parameters: freezed == parameters ? _self._parameters : parameters // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,requestBody: freezed == requestBody ? _self._requestBody : requestBody // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,responses: freezed == responses ? _self._responses : responses // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,security: freezed == security ? _self._security : security // ignore: cast_nullable_to_non_nullable
as List<Map<String, List<String>>>?,
  ));
}


}


/// @nodoc
mixin _$SwaggerSchemaInfo {

 String get title; String get version; String? get description; String? get baseUrl; Map<String, SwaggerSecurityScheme> get securitySchemes; List<Map<String, List<String>>> get security; List<SwaggerEndpoint> get endpoints;
/// Create a copy of SwaggerSchemaInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwaggerSchemaInfoCopyWith<SwaggerSchemaInfo> get copyWith => _$SwaggerSchemaInfoCopyWithImpl<SwaggerSchemaInfo>(this as SwaggerSchemaInfo, _$identity);

  /// Serializes this SwaggerSchemaInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwaggerSchemaInfo&&(identical(other.title, title) || other.title == title)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&const DeepCollectionEquality().equals(other.securitySchemes, securitySchemes)&&const DeepCollectionEquality().equals(other.security, security)&&const DeepCollectionEquality().equals(other.endpoints, endpoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,version,description,baseUrl,const DeepCollectionEquality().hash(securitySchemes),const DeepCollectionEquality().hash(security),const DeepCollectionEquality().hash(endpoints));

@override
String toString() {
  return 'SwaggerSchemaInfo(title: $title, version: $version, description: $description, baseUrl: $baseUrl, securitySchemes: $securitySchemes, security: $security, endpoints: $endpoints)';
}


}

/// @nodoc
abstract mixin class $SwaggerSchemaInfoCopyWith<$Res>  {
  factory $SwaggerSchemaInfoCopyWith(SwaggerSchemaInfo value, $Res Function(SwaggerSchemaInfo) _then) = _$SwaggerSchemaInfoCopyWithImpl;
@useResult
$Res call({
 String title, String version, String? description, String? baseUrl, Map<String, SwaggerSecurityScheme> securitySchemes, List<Map<String, List<String>>> security, List<SwaggerEndpoint> endpoints
});




}
/// @nodoc
class _$SwaggerSchemaInfoCopyWithImpl<$Res>
    implements $SwaggerSchemaInfoCopyWith<$Res> {
  _$SwaggerSchemaInfoCopyWithImpl(this._self, this._then);

  final SwaggerSchemaInfo _self;
  final $Res Function(SwaggerSchemaInfo) _then;

/// Create a copy of SwaggerSchemaInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? version = null,Object? description = freezed,Object? baseUrl = freezed,Object? securitySchemes = null,Object? security = null,Object? endpoints = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,baseUrl: freezed == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String?,securitySchemes: null == securitySchemes ? _self.securitySchemes : securitySchemes // ignore: cast_nullable_to_non_nullable
as Map<String, SwaggerSecurityScheme>,security: null == security ? _self.security : security // ignore: cast_nullable_to_non_nullable
as List<Map<String, List<String>>>,endpoints: null == endpoints ? _self.endpoints : endpoints // ignore: cast_nullable_to_non_nullable
as List<SwaggerEndpoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [SwaggerSchemaInfo].
extension SwaggerSchemaInfoPatterns on SwaggerSchemaInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwaggerSchemaInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwaggerSchemaInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwaggerSchemaInfo value)  $default,){
final _that = this;
switch (_that) {
case _SwaggerSchemaInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwaggerSchemaInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SwaggerSchemaInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String version,  String? description,  String? baseUrl,  Map<String, SwaggerSecurityScheme> securitySchemes,  List<Map<String, List<String>>> security,  List<SwaggerEndpoint> endpoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwaggerSchemaInfo() when $default != null:
return $default(_that.title,_that.version,_that.description,_that.baseUrl,_that.securitySchemes,_that.security,_that.endpoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String version,  String? description,  String? baseUrl,  Map<String, SwaggerSecurityScheme> securitySchemes,  List<Map<String, List<String>>> security,  List<SwaggerEndpoint> endpoints)  $default,) {final _that = this;
switch (_that) {
case _SwaggerSchemaInfo():
return $default(_that.title,_that.version,_that.description,_that.baseUrl,_that.securitySchemes,_that.security,_that.endpoints);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String version,  String? description,  String? baseUrl,  Map<String, SwaggerSecurityScheme> securitySchemes,  List<Map<String, List<String>>> security,  List<SwaggerEndpoint> endpoints)?  $default,) {final _that = this;
switch (_that) {
case _SwaggerSchemaInfo() when $default != null:
return $default(_that.title,_that.version,_that.description,_that.baseUrl,_that.securitySchemes,_that.security,_that.endpoints);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwaggerSchemaInfo implements SwaggerSchemaInfo {
  const _SwaggerSchemaInfo({required this.title, required this.version, this.description, this.baseUrl, final  Map<String, SwaggerSecurityScheme> securitySchemes = const {}, final  List<Map<String, List<String>>> security = const [], final  List<SwaggerEndpoint> endpoints = const []}): _securitySchemes = securitySchemes,_security = security,_endpoints = endpoints;
  factory _SwaggerSchemaInfo.fromJson(Map<String, dynamic> json) => _$SwaggerSchemaInfoFromJson(json);

@override final  String title;
@override final  String version;
@override final  String? description;
@override final  String? baseUrl;
 final  Map<String, SwaggerSecurityScheme> _securitySchemes;
@override@JsonKey() Map<String, SwaggerSecurityScheme> get securitySchemes {
  if (_securitySchemes is EqualUnmodifiableMapView) return _securitySchemes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_securitySchemes);
}

 final  List<Map<String, List<String>>> _security;
@override@JsonKey() List<Map<String, List<String>>> get security {
  if (_security is EqualUnmodifiableListView) return _security;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_security);
}

 final  List<SwaggerEndpoint> _endpoints;
@override@JsonKey() List<SwaggerEndpoint> get endpoints {
  if (_endpoints is EqualUnmodifiableListView) return _endpoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_endpoints);
}


/// Create a copy of SwaggerSchemaInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwaggerSchemaInfoCopyWith<_SwaggerSchemaInfo> get copyWith => __$SwaggerSchemaInfoCopyWithImpl<_SwaggerSchemaInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwaggerSchemaInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwaggerSchemaInfo&&(identical(other.title, title) || other.title == title)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&const DeepCollectionEquality().equals(other._securitySchemes, _securitySchemes)&&const DeepCollectionEquality().equals(other._security, _security)&&const DeepCollectionEquality().equals(other._endpoints, _endpoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,version,description,baseUrl,const DeepCollectionEquality().hash(_securitySchemes),const DeepCollectionEquality().hash(_security),const DeepCollectionEquality().hash(_endpoints));

@override
String toString() {
  return 'SwaggerSchemaInfo(title: $title, version: $version, description: $description, baseUrl: $baseUrl, securitySchemes: $securitySchemes, security: $security, endpoints: $endpoints)';
}


}

/// @nodoc
abstract mixin class _$SwaggerSchemaInfoCopyWith<$Res> implements $SwaggerSchemaInfoCopyWith<$Res> {
  factory _$SwaggerSchemaInfoCopyWith(_SwaggerSchemaInfo value, $Res Function(_SwaggerSchemaInfo) _then) = __$SwaggerSchemaInfoCopyWithImpl;
@override @useResult
$Res call({
 String title, String version, String? description, String? baseUrl, Map<String, SwaggerSecurityScheme> securitySchemes, List<Map<String, List<String>>> security, List<SwaggerEndpoint> endpoints
});




}
/// @nodoc
class __$SwaggerSchemaInfoCopyWithImpl<$Res>
    implements _$SwaggerSchemaInfoCopyWith<$Res> {
  __$SwaggerSchemaInfoCopyWithImpl(this._self, this._then);

  final _SwaggerSchemaInfo _self;
  final $Res Function(_SwaggerSchemaInfo) _then;

/// Create a copy of SwaggerSchemaInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? version = null,Object? description = freezed,Object? baseUrl = freezed,Object? securitySchemes = null,Object? security = null,Object? endpoints = null,}) {
  return _then(_SwaggerSchemaInfo(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,baseUrl: freezed == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String?,securitySchemes: null == securitySchemes ? _self._securitySchemes : securitySchemes // ignore: cast_nullable_to_non_nullable
as Map<String, SwaggerSecurityScheme>,security: null == security ? _self._security : security // ignore: cast_nullable_to_non_nullable
as List<Map<String, List<String>>>,endpoints: null == endpoints ? _self._endpoints : endpoints // ignore: cast_nullable_to_non_nullable
as List<SwaggerEndpoint>,
  ));
}


}


/// @nodoc
mixin _$SwaggerHistoryItem {

 String get id; String get name; String? get url; String? get filePath; DateTime get lastAccessed;
/// Create a copy of SwaggerHistoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwaggerHistoryItemCopyWith<SwaggerHistoryItem> get copyWith => _$SwaggerHistoryItemCopyWithImpl<SwaggerHistoryItem>(this as SwaggerHistoryItem, _$identity);

  /// Serializes this SwaggerHistoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwaggerHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.lastAccessed, lastAccessed) || other.lastAccessed == lastAccessed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,url,filePath,lastAccessed);

@override
String toString() {
  return 'SwaggerHistoryItem(id: $id, name: $name, url: $url, filePath: $filePath, lastAccessed: $lastAccessed)';
}


}

/// @nodoc
abstract mixin class $SwaggerHistoryItemCopyWith<$Res>  {
  factory $SwaggerHistoryItemCopyWith(SwaggerHistoryItem value, $Res Function(SwaggerHistoryItem) _then) = _$SwaggerHistoryItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? url, String? filePath, DateTime lastAccessed
});




}
/// @nodoc
class _$SwaggerHistoryItemCopyWithImpl<$Res>
    implements $SwaggerHistoryItemCopyWith<$Res> {
  _$SwaggerHistoryItemCopyWithImpl(this._self, this._then);

  final SwaggerHistoryItem _self;
  final $Res Function(SwaggerHistoryItem) _then;

/// Create a copy of SwaggerHistoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? url = freezed,Object? filePath = freezed,Object? lastAccessed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,lastAccessed: null == lastAccessed ? _self.lastAccessed : lastAccessed // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SwaggerHistoryItem].
extension SwaggerHistoryItemPatterns on SwaggerHistoryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwaggerHistoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwaggerHistoryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwaggerHistoryItem value)  $default,){
final _that = this;
switch (_that) {
case _SwaggerHistoryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwaggerHistoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _SwaggerHistoryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? url,  String? filePath,  DateTime lastAccessed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwaggerHistoryItem() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.filePath,_that.lastAccessed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? url,  String? filePath,  DateTime lastAccessed)  $default,) {final _that = this;
switch (_that) {
case _SwaggerHistoryItem():
return $default(_that.id,_that.name,_that.url,_that.filePath,_that.lastAccessed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? url,  String? filePath,  DateTime lastAccessed)?  $default,) {final _that = this;
switch (_that) {
case _SwaggerHistoryItem() when $default != null:
return $default(_that.id,_that.name,_that.url,_that.filePath,_that.lastAccessed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwaggerHistoryItem implements SwaggerHistoryItem {
  const _SwaggerHistoryItem({required this.id, required this.name, this.url, this.filePath, required this.lastAccessed});
  factory _SwaggerHistoryItem.fromJson(Map<String, dynamic> json) => _$SwaggerHistoryItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? url;
@override final  String? filePath;
@override final  DateTime lastAccessed;

/// Create a copy of SwaggerHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwaggerHistoryItemCopyWith<_SwaggerHistoryItem> get copyWith => __$SwaggerHistoryItemCopyWithImpl<_SwaggerHistoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwaggerHistoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwaggerHistoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.lastAccessed, lastAccessed) || other.lastAccessed == lastAccessed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,url,filePath,lastAccessed);

@override
String toString() {
  return 'SwaggerHistoryItem(id: $id, name: $name, url: $url, filePath: $filePath, lastAccessed: $lastAccessed)';
}


}

/// @nodoc
abstract mixin class _$SwaggerHistoryItemCopyWith<$Res> implements $SwaggerHistoryItemCopyWith<$Res> {
  factory _$SwaggerHistoryItemCopyWith(_SwaggerHistoryItem value, $Res Function(_SwaggerHistoryItem) _then) = __$SwaggerHistoryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? url, String? filePath, DateTime lastAccessed
});




}
/// @nodoc
class __$SwaggerHistoryItemCopyWithImpl<$Res>
    implements _$SwaggerHistoryItemCopyWith<$Res> {
  __$SwaggerHistoryItemCopyWithImpl(this._self, this._then);

  final _SwaggerHistoryItem _self;
  final $Res Function(_SwaggerHistoryItem) _then;

/// Create a copy of SwaggerHistoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? url = freezed,Object? filePath = freezed,Object? lastAccessed = null,}) {
  return _then(_SwaggerHistoryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,lastAccessed: null == lastAccessed ? _self.lastAccessed : lastAccessed // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SwaggerState {

 SwaggerViewMode get viewMode; List<SwaggerHistoryItem> get history; SwaggerSchemaInfo? get activeSchema; bool get isLoading; String? get errorMessage; SwaggerEndpoint? get activeEndpoint; Map<String, String> get activeSecurityValues;
/// Create a copy of SwaggerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwaggerStateCopyWith<SwaggerState> get copyWith => _$SwaggerStateCopyWithImpl<SwaggerState>(this as SwaggerState, _$identity);

  /// Serializes this SwaggerState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwaggerState&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.activeSchema, activeSchema) || other.activeSchema == activeSchema)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.activeEndpoint, activeEndpoint) || other.activeEndpoint == activeEndpoint)&&const DeepCollectionEquality().equals(other.activeSecurityValues, activeSecurityValues));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,viewMode,const DeepCollectionEquality().hash(history),activeSchema,isLoading,errorMessage,activeEndpoint,const DeepCollectionEquality().hash(activeSecurityValues));

@override
String toString() {
  return 'SwaggerState(viewMode: $viewMode, history: $history, activeSchema: $activeSchema, isLoading: $isLoading, errorMessage: $errorMessage, activeEndpoint: $activeEndpoint, activeSecurityValues: $activeSecurityValues)';
}


}

/// @nodoc
abstract mixin class $SwaggerStateCopyWith<$Res>  {
  factory $SwaggerStateCopyWith(SwaggerState value, $Res Function(SwaggerState) _then) = _$SwaggerStateCopyWithImpl;
@useResult
$Res call({
 SwaggerViewMode viewMode, List<SwaggerHistoryItem> history, SwaggerSchemaInfo? activeSchema, bool isLoading, String? errorMessage, SwaggerEndpoint? activeEndpoint, Map<String, String> activeSecurityValues
});


$SwaggerSchemaInfoCopyWith<$Res>? get activeSchema;$SwaggerEndpointCopyWith<$Res>? get activeEndpoint;

}
/// @nodoc
class _$SwaggerStateCopyWithImpl<$Res>
    implements $SwaggerStateCopyWith<$Res> {
  _$SwaggerStateCopyWithImpl(this._self, this._then);

  final SwaggerState _self;
  final $Res Function(SwaggerState) _then;

/// Create a copy of SwaggerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? viewMode = null,Object? history = null,Object? activeSchema = freezed,Object? isLoading = null,Object? errorMessage = freezed,Object? activeEndpoint = freezed,Object? activeSecurityValues = null,}) {
  return _then(_self.copyWith(
viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as SwaggerViewMode,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<SwaggerHistoryItem>,activeSchema: freezed == activeSchema ? _self.activeSchema : activeSchema // ignore: cast_nullable_to_non_nullable
as SwaggerSchemaInfo?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,activeEndpoint: freezed == activeEndpoint ? _self.activeEndpoint : activeEndpoint // ignore: cast_nullable_to_non_nullable
as SwaggerEndpoint?,activeSecurityValues: null == activeSecurityValues ? _self.activeSecurityValues : activeSecurityValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}
/// Create a copy of SwaggerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwaggerSchemaInfoCopyWith<$Res>? get activeSchema {
    if (_self.activeSchema == null) {
    return null;
  }

  return $SwaggerSchemaInfoCopyWith<$Res>(_self.activeSchema!, (value) {
    return _then(_self.copyWith(activeSchema: value));
  });
}/// Create a copy of SwaggerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwaggerEndpointCopyWith<$Res>? get activeEndpoint {
    if (_self.activeEndpoint == null) {
    return null;
  }

  return $SwaggerEndpointCopyWith<$Res>(_self.activeEndpoint!, (value) {
    return _then(_self.copyWith(activeEndpoint: value));
  });
}
}


/// Adds pattern-matching-related methods to [SwaggerState].
extension SwaggerStatePatterns on SwaggerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SwaggerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SwaggerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SwaggerState value)  $default,){
final _that = this;
switch (_that) {
case _SwaggerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SwaggerState value)?  $default,){
final _that = this;
switch (_that) {
case _SwaggerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SwaggerViewMode viewMode,  List<SwaggerHistoryItem> history,  SwaggerSchemaInfo? activeSchema,  bool isLoading,  String? errorMessage,  SwaggerEndpoint? activeEndpoint,  Map<String, String> activeSecurityValues)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SwaggerState() when $default != null:
return $default(_that.viewMode,_that.history,_that.activeSchema,_that.isLoading,_that.errorMessage,_that.activeEndpoint,_that.activeSecurityValues);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SwaggerViewMode viewMode,  List<SwaggerHistoryItem> history,  SwaggerSchemaInfo? activeSchema,  bool isLoading,  String? errorMessage,  SwaggerEndpoint? activeEndpoint,  Map<String, String> activeSecurityValues)  $default,) {final _that = this;
switch (_that) {
case _SwaggerState():
return $default(_that.viewMode,_that.history,_that.activeSchema,_that.isLoading,_that.errorMessage,_that.activeEndpoint,_that.activeSecurityValues);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SwaggerViewMode viewMode,  List<SwaggerHistoryItem> history,  SwaggerSchemaInfo? activeSchema,  bool isLoading,  String? errorMessage,  SwaggerEndpoint? activeEndpoint,  Map<String, String> activeSecurityValues)?  $default,) {final _that = this;
switch (_that) {
case _SwaggerState() when $default != null:
return $default(_that.viewMode,_that.history,_that.activeSchema,_that.isLoading,_that.errorMessage,_that.activeEndpoint,_that.activeSecurityValues);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SwaggerState implements SwaggerState {
  const _SwaggerState({this.viewMode = SwaggerViewMode.list, final  List<SwaggerHistoryItem> history = const [], this.activeSchema, this.isLoading = false, this.errorMessage, this.activeEndpoint, final  Map<String, String> activeSecurityValues = const {}}): _history = history,_activeSecurityValues = activeSecurityValues;
  factory _SwaggerState.fromJson(Map<String, dynamic> json) => _$SwaggerStateFromJson(json);

@override@JsonKey() final  SwaggerViewMode viewMode;
 final  List<SwaggerHistoryItem> _history;
@override@JsonKey() List<SwaggerHistoryItem> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  SwaggerSchemaInfo? activeSchema;
@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
@override final  SwaggerEndpoint? activeEndpoint;
 final  Map<String, String> _activeSecurityValues;
@override@JsonKey() Map<String, String> get activeSecurityValues {
  if (_activeSecurityValues is EqualUnmodifiableMapView) return _activeSecurityValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_activeSecurityValues);
}


/// Create a copy of SwaggerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwaggerStateCopyWith<_SwaggerState> get copyWith => __$SwaggerStateCopyWithImpl<_SwaggerState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwaggerStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SwaggerState&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.activeSchema, activeSchema) || other.activeSchema == activeSchema)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.activeEndpoint, activeEndpoint) || other.activeEndpoint == activeEndpoint)&&const DeepCollectionEquality().equals(other._activeSecurityValues, _activeSecurityValues));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,viewMode,const DeepCollectionEquality().hash(_history),activeSchema,isLoading,errorMessage,activeEndpoint,const DeepCollectionEquality().hash(_activeSecurityValues));

@override
String toString() {
  return 'SwaggerState(viewMode: $viewMode, history: $history, activeSchema: $activeSchema, isLoading: $isLoading, errorMessage: $errorMessage, activeEndpoint: $activeEndpoint, activeSecurityValues: $activeSecurityValues)';
}


}

/// @nodoc
abstract mixin class _$SwaggerStateCopyWith<$Res> implements $SwaggerStateCopyWith<$Res> {
  factory _$SwaggerStateCopyWith(_SwaggerState value, $Res Function(_SwaggerState) _then) = __$SwaggerStateCopyWithImpl;
@override @useResult
$Res call({
 SwaggerViewMode viewMode, List<SwaggerHistoryItem> history, SwaggerSchemaInfo? activeSchema, bool isLoading, String? errorMessage, SwaggerEndpoint? activeEndpoint, Map<String, String> activeSecurityValues
});


@override $SwaggerSchemaInfoCopyWith<$Res>? get activeSchema;@override $SwaggerEndpointCopyWith<$Res>? get activeEndpoint;

}
/// @nodoc
class __$SwaggerStateCopyWithImpl<$Res>
    implements _$SwaggerStateCopyWith<$Res> {
  __$SwaggerStateCopyWithImpl(this._self, this._then);

  final _SwaggerState _self;
  final $Res Function(_SwaggerState) _then;

/// Create a copy of SwaggerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? viewMode = null,Object? history = null,Object? activeSchema = freezed,Object? isLoading = null,Object? errorMessage = freezed,Object? activeEndpoint = freezed,Object? activeSecurityValues = null,}) {
  return _then(_SwaggerState(
viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as SwaggerViewMode,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<SwaggerHistoryItem>,activeSchema: freezed == activeSchema ? _self.activeSchema : activeSchema // ignore: cast_nullable_to_non_nullable
as SwaggerSchemaInfo?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,activeEndpoint: freezed == activeEndpoint ? _self.activeEndpoint : activeEndpoint // ignore: cast_nullable_to_non_nullable
as SwaggerEndpoint?,activeSecurityValues: null == activeSecurityValues ? _self._activeSecurityValues : activeSecurityValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

/// Create a copy of SwaggerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwaggerSchemaInfoCopyWith<$Res>? get activeSchema {
    if (_self.activeSchema == null) {
    return null;
  }

  return $SwaggerSchemaInfoCopyWith<$Res>(_self.activeSchema!, (value) {
    return _then(_self.copyWith(activeSchema: value));
  });
}/// Create a copy of SwaggerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwaggerEndpointCopyWith<$Res>? get activeEndpoint {
    if (_self.activeEndpoint == null) {
    return null;
  }

  return $SwaggerEndpointCopyWith<$Res>(_self.activeEndpoint!, (value) {
    return _then(_self.copyWith(activeEndpoint: value));
  });
}
}

// dart format on
