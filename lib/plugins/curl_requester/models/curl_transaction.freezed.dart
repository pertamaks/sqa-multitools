// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curl_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurlTransaction {

 String get id; CurlCommand get request; int get statusCode; String get responseBody; Duration get latency; int get responseSize; DateTime get timestamp;
/// Create a copy of CurlTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurlTransactionCopyWith<CurlTransaction> get copyWith => _$CurlTransactionCopyWithImpl<CurlTransaction>(this as CurlTransaction, _$identity);

  /// Serializes this CurlTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurlTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.request, request) || other.request == request)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.responseBody, responseBody) || other.responseBody == responseBody)&&(identical(other.latency, latency) || other.latency == latency)&&(identical(other.responseSize, responseSize) || other.responseSize == responseSize)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,request,statusCode,responseBody,latency,responseSize,timestamp);

@override
String toString() {
  return 'CurlTransaction(id: $id, request: $request, statusCode: $statusCode, responseBody: $responseBody, latency: $latency, responseSize: $responseSize, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $CurlTransactionCopyWith<$Res>  {
  factory $CurlTransactionCopyWith(CurlTransaction value, $Res Function(CurlTransaction) _then) = _$CurlTransactionCopyWithImpl;
@useResult
$Res call({
 String id, CurlCommand request, int statusCode, String responseBody, Duration latency, int responseSize, DateTime timestamp
});


$CurlCommandCopyWith<$Res> get request;

}
/// @nodoc
class _$CurlTransactionCopyWithImpl<$Res>
    implements $CurlTransactionCopyWith<$Res> {
  _$CurlTransactionCopyWithImpl(this._self, this._then);

  final CurlTransaction _self;
  final $Res Function(CurlTransaction) _then;

/// Create a copy of CurlTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? request = null,Object? statusCode = null,Object? responseBody = null,Object? latency = null,Object? responseSize = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as CurlCommand,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,responseBody: null == responseBody ? _self.responseBody : responseBody // ignore: cast_nullable_to_non_nullable
as String,latency: null == latency ? _self.latency : latency // ignore: cast_nullable_to_non_nullable
as Duration,responseSize: null == responseSize ? _self.responseSize : responseSize // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of CurlTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurlCommandCopyWith<$Res> get request {
  
  return $CurlCommandCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurlTransaction].
extension CurlTransactionPatterns on CurlTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurlTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurlTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurlTransaction value)  $default,){
final _that = this;
switch (_that) {
case _CurlTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurlTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _CurlTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  CurlCommand request,  int statusCode,  String responseBody,  Duration latency,  int responseSize,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurlTransaction() when $default != null:
return $default(_that.id,_that.request,_that.statusCode,_that.responseBody,_that.latency,_that.responseSize,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  CurlCommand request,  int statusCode,  String responseBody,  Duration latency,  int responseSize,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _CurlTransaction():
return $default(_that.id,_that.request,_that.statusCode,_that.responseBody,_that.latency,_that.responseSize,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  CurlCommand request,  int statusCode,  String responseBody,  Duration latency,  int responseSize,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _CurlTransaction() when $default != null:
return $default(_that.id,_that.request,_that.statusCode,_that.responseBody,_that.latency,_that.responseSize,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurlTransaction implements CurlTransaction {
  const _CurlTransaction({required this.id, required this.request, required this.statusCode, required this.responseBody, required this.latency, required this.responseSize, required this.timestamp});
  factory _CurlTransaction.fromJson(Map<String, dynamic> json) => _$CurlTransactionFromJson(json);

@override final  String id;
@override final  CurlCommand request;
@override final  int statusCode;
@override final  String responseBody;
@override final  Duration latency;
@override final  int responseSize;
@override final  DateTime timestamp;

/// Create a copy of CurlTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurlTransactionCopyWith<_CurlTransaction> get copyWith => __$CurlTransactionCopyWithImpl<_CurlTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurlTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurlTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.request, request) || other.request == request)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.responseBody, responseBody) || other.responseBody == responseBody)&&(identical(other.latency, latency) || other.latency == latency)&&(identical(other.responseSize, responseSize) || other.responseSize == responseSize)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,request,statusCode,responseBody,latency,responseSize,timestamp);

@override
String toString() {
  return 'CurlTransaction(id: $id, request: $request, statusCode: $statusCode, responseBody: $responseBody, latency: $latency, responseSize: $responseSize, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$CurlTransactionCopyWith<$Res> implements $CurlTransactionCopyWith<$Res> {
  factory _$CurlTransactionCopyWith(_CurlTransaction value, $Res Function(_CurlTransaction) _then) = __$CurlTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, CurlCommand request, int statusCode, String responseBody, Duration latency, int responseSize, DateTime timestamp
});


@override $CurlCommandCopyWith<$Res> get request;

}
/// @nodoc
class __$CurlTransactionCopyWithImpl<$Res>
    implements _$CurlTransactionCopyWith<$Res> {
  __$CurlTransactionCopyWithImpl(this._self, this._then);

  final _CurlTransaction _self;
  final $Res Function(_CurlTransaction) _then;

/// Create a copy of CurlTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? request = null,Object? statusCode = null,Object? responseBody = null,Object? latency = null,Object? responseSize = null,Object? timestamp = null,}) {
  return _then(_CurlTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,request: null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as CurlCommand,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,responseBody: null == responseBody ? _self.responseBody : responseBody // ignore: cast_nullable_to_non_nullable
as String,latency: null == latency ? _self.latency : latency // ignore: cast_nullable_to_non_nullable
as Duration,responseSize: null == responseSize ? _self.responseSize : responseSize // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of CurlTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurlCommandCopyWith<$Res> get request {
  
  return $CurlCommandCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

// dart format on
