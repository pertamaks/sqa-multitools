// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curl_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurlCommand {

 String get url; String get method; Map<String, String> get headers; Map<String, String> get queryParameters; Set<String> get inactiveHeaders; Set<String> get inactiveQueryParameters; String get body;
/// Create a copy of CurlCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurlCommandCopyWith<CurlCommand> get copyWith => _$CurlCommandCopyWithImpl<CurlCommand>(this as CurlCommand, _$identity);

  /// Serializes this CurlCommand to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurlCommand&&(identical(other.url, url) || other.url == url)&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.headers, headers)&&const DeepCollectionEquality().equals(other.queryParameters, queryParameters)&&const DeepCollectionEquality().equals(other.inactiveHeaders, inactiveHeaders)&&const DeepCollectionEquality().equals(other.inactiveQueryParameters, inactiveQueryParameters)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,method,const DeepCollectionEquality().hash(headers),const DeepCollectionEquality().hash(queryParameters),const DeepCollectionEquality().hash(inactiveHeaders),const DeepCollectionEquality().hash(inactiveQueryParameters),body);

@override
String toString() {
  return 'CurlCommand(url: $url, method: $method, headers: $headers, queryParameters: $queryParameters, inactiveHeaders: $inactiveHeaders, inactiveQueryParameters: $inactiveQueryParameters, body: $body)';
}


}

/// @nodoc
abstract mixin class $CurlCommandCopyWith<$Res>  {
  factory $CurlCommandCopyWith(CurlCommand value, $Res Function(CurlCommand) _then) = _$CurlCommandCopyWithImpl;
@useResult
$Res call({
 String url, String method, Map<String, String> headers, Map<String, String> queryParameters, Set<String> inactiveHeaders, Set<String> inactiveQueryParameters, String body
});




}
/// @nodoc
class _$CurlCommandCopyWithImpl<$Res>
    implements $CurlCommandCopyWith<$Res> {
  _$CurlCommandCopyWithImpl(this._self, this._then);

  final CurlCommand _self;
  final $Res Function(CurlCommand) _then;

/// Create a copy of CurlCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? method = null,Object? headers = null,Object? queryParameters = null,Object? inactiveHeaders = null,Object? inactiveQueryParameters = null,Object? body = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,queryParameters: null == queryParameters ? _self.queryParameters : queryParameters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,inactiveHeaders: null == inactiveHeaders ? _self.inactiveHeaders : inactiveHeaders // ignore: cast_nullable_to_non_nullable
as Set<String>,inactiveQueryParameters: null == inactiveQueryParameters ? _self.inactiveQueryParameters : inactiveQueryParameters // ignore: cast_nullable_to_non_nullable
as Set<String>,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CurlCommand].
extension CurlCommandPatterns on CurlCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurlCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurlCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurlCommand value)  $default,){
final _that = this;
switch (_that) {
case _CurlCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurlCommand value)?  $default,){
final _that = this;
switch (_that) {
case _CurlCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String method,  Map<String, String> headers,  Map<String, String> queryParameters,  Set<String> inactiveHeaders,  Set<String> inactiveQueryParameters,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurlCommand() when $default != null:
return $default(_that.url,_that.method,_that.headers,_that.queryParameters,_that.inactiveHeaders,_that.inactiveQueryParameters,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String method,  Map<String, String> headers,  Map<String, String> queryParameters,  Set<String> inactiveHeaders,  Set<String> inactiveQueryParameters,  String body)  $default,) {final _that = this;
switch (_that) {
case _CurlCommand():
return $default(_that.url,_that.method,_that.headers,_that.queryParameters,_that.inactiveHeaders,_that.inactiveQueryParameters,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String method,  Map<String, String> headers,  Map<String, String> queryParameters,  Set<String> inactiveHeaders,  Set<String> inactiveQueryParameters,  String body)?  $default,) {final _that = this;
switch (_that) {
case _CurlCommand() when $default != null:
return $default(_that.url,_that.method,_that.headers,_that.queryParameters,_that.inactiveHeaders,_that.inactiveQueryParameters,_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurlCommand implements CurlCommand {
  const _CurlCommand({this.url = '', this.method = 'GET', final  Map<String, String> headers = const {}, final  Map<String, String> queryParameters = const {}, final  Set<String> inactiveHeaders = const {}, final  Set<String> inactiveQueryParameters = const {}, this.body = ''}): _headers = headers,_queryParameters = queryParameters,_inactiveHeaders = inactiveHeaders,_inactiveQueryParameters = inactiveQueryParameters;
  factory _CurlCommand.fromJson(Map<String, dynamic> json) => _$CurlCommandFromJson(json);

@override@JsonKey() final  String url;
@override@JsonKey() final  String method;
 final  Map<String, String> _headers;
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}

 final  Map<String, String> _queryParameters;
@override@JsonKey() Map<String, String> get queryParameters {
  if (_queryParameters is EqualUnmodifiableMapView) return _queryParameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_queryParameters);
}

 final  Set<String> _inactiveHeaders;
@override@JsonKey() Set<String> get inactiveHeaders {
  if (_inactiveHeaders is EqualUnmodifiableSetView) return _inactiveHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_inactiveHeaders);
}

 final  Set<String> _inactiveQueryParameters;
@override@JsonKey() Set<String> get inactiveQueryParameters {
  if (_inactiveQueryParameters is EqualUnmodifiableSetView) return _inactiveQueryParameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_inactiveQueryParameters);
}

@override@JsonKey() final  String body;

/// Create a copy of CurlCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurlCommandCopyWith<_CurlCommand> get copyWith => __$CurlCommandCopyWithImpl<_CurlCommand>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurlCommandToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurlCommand&&(identical(other.url, url) || other.url == url)&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other._headers, _headers)&&const DeepCollectionEquality().equals(other._queryParameters, _queryParameters)&&const DeepCollectionEquality().equals(other._inactiveHeaders, _inactiveHeaders)&&const DeepCollectionEquality().equals(other._inactiveQueryParameters, _inactiveQueryParameters)&&(identical(other.body, body) || other.body == body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,method,const DeepCollectionEquality().hash(_headers),const DeepCollectionEquality().hash(_queryParameters),const DeepCollectionEquality().hash(_inactiveHeaders),const DeepCollectionEquality().hash(_inactiveQueryParameters),body);

@override
String toString() {
  return 'CurlCommand(url: $url, method: $method, headers: $headers, queryParameters: $queryParameters, inactiveHeaders: $inactiveHeaders, inactiveQueryParameters: $inactiveQueryParameters, body: $body)';
}


}

/// @nodoc
abstract mixin class _$CurlCommandCopyWith<$Res> implements $CurlCommandCopyWith<$Res> {
  factory _$CurlCommandCopyWith(_CurlCommand value, $Res Function(_CurlCommand) _then) = __$CurlCommandCopyWithImpl;
@override @useResult
$Res call({
 String url, String method, Map<String, String> headers, Map<String, String> queryParameters, Set<String> inactiveHeaders, Set<String> inactiveQueryParameters, String body
});




}
/// @nodoc
class __$CurlCommandCopyWithImpl<$Res>
    implements _$CurlCommandCopyWith<$Res> {
  __$CurlCommandCopyWithImpl(this._self, this._then);

  final _CurlCommand _self;
  final $Res Function(_CurlCommand) _then;

/// Create a copy of CurlCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? method = null,Object? headers = null,Object? queryParameters = null,Object? inactiveHeaders = null,Object? inactiveQueryParameters = null,Object? body = null,}) {
  return _then(_CurlCommand(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,queryParameters: null == queryParameters ? _self._queryParameters : queryParameters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,inactiveHeaders: null == inactiveHeaders ? _self._inactiveHeaders : inactiveHeaders // ignore: cast_nullable_to_non_nullable
as Set<String>,inactiveQueryParameters: null == inactiveQueryParameters ? _self._inactiveQueryParameters : inactiveQueryParameters // ignore: cast_nullable_to_non_nullable
as Set<String>,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
