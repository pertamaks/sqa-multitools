// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateInfo {

 String get version; String get downloadUrl; String get releaseNotes; bool get isCritical; DateTime? get releaseDate;
/// Create a copy of UpdateInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateInfoCopyWith<UpdateInfo> get copyWith => _$UpdateInfoCopyWithImpl<UpdateInfo>(this as UpdateInfo, _$identity);

  /// Serializes this UpdateInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateInfo&&(identical(other.version, version) || other.version == version)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,downloadUrl,releaseNotes,isCritical,releaseDate);

@override
String toString() {
  return 'UpdateInfo(version: $version, downloadUrl: $downloadUrl, releaseNotes: $releaseNotes, isCritical: $isCritical, releaseDate: $releaseDate)';
}


}

/// @nodoc
abstract mixin class $UpdateInfoCopyWith<$Res>  {
  factory $UpdateInfoCopyWith(UpdateInfo value, $Res Function(UpdateInfo) _then) = _$UpdateInfoCopyWithImpl;
@useResult
$Res call({
 String version, String downloadUrl, String releaseNotes, bool isCritical, DateTime? releaseDate
});




}
/// @nodoc
class _$UpdateInfoCopyWithImpl<$Res>
    implements $UpdateInfoCopyWith<$Res> {
  _$UpdateInfoCopyWithImpl(this._self, this._then);

  final UpdateInfo _self;
  final $Res Function(UpdateInfo) _then;

/// Create a copy of UpdateInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? downloadUrl = null,Object? releaseNotes = null,Object? isCritical = null,Object? releaseDate = freezed,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,releaseNotes: null == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateInfo].
extension UpdateInfoPatterns on UpdateInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateInfo value)  $default,){
final _that = this;
switch (_that) {
case _UpdateInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String downloadUrl,  String releaseNotes,  bool isCritical,  DateTime? releaseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateInfo() when $default != null:
return $default(_that.version,_that.downloadUrl,_that.releaseNotes,_that.isCritical,_that.releaseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String downloadUrl,  String releaseNotes,  bool isCritical,  DateTime? releaseDate)  $default,) {final _that = this;
switch (_that) {
case _UpdateInfo():
return $default(_that.version,_that.downloadUrl,_that.releaseNotes,_that.isCritical,_that.releaseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String downloadUrl,  String releaseNotes,  bool isCritical,  DateTime? releaseDate)?  $default,) {final _that = this;
switch (_that) {
case _UpdateInfo() when $default != null:
return $default(_that.version,_that.downloadUrl,_that.releaseNotes,_that.isCritical,_that.releaseDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateInfo implements UpdateInfo {
  const _UpdateInfo({required this.version, required this.downloadUrl, required this.releaseNotes, this.isCritical = false, this.releaseDate});
  factory _UpdateInfo.fromJson(Map<String, dynamic> json) => _$UpdateInfoFromJson(json);

@override final  String version;
@override final  String downloadUrl;
@override final  String releaseNotes;
@override@JsonKey() final  bool isCritical;
@override final  DateTime? releaseDate;

/// Create a copy of UpdateInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateInfoCopyWith<_UpdateInfo> get copyWith => __$UpdateInfoCopyWithImpl<_UpdateInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateInfo&&(identical(other.version, version) || other.version == version)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.releaseNotes, releaseNotes) || other.releaseNotes == releaseNotes)&&(identical(other.isCritical, isCritical) || other.isCritical == isCritical)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,downloadUrl,releaseNotes,isCritical,releaseDate);

@override
String toString() {
  return 'UpdateInfo(version: $version, downloadUrl: $downloadUrl, releaseNotes: $releaseNotes, isCritical: $isCritical, releaseDate: $releaseDate)';
}


}

/// @nodoc
abstract mixin class _$UpdateInfoCopyWith<$Res> implements $UpdateInfoCopyWith<$Res> {
  factory _$UpdateInfoCopyWith(_UpdateInfo value, $Res Function(_UpdateInfo) _then) = __$UpdateInfoCopyWithImpl;
@override @useResult
$Res call({
 String version, String downloadUrl, String releaseNotes, bool isCritical, DateTime? releaseDate
});




}
/// @nodoc
class __$UpdateInfoCopyWithImpl<$Res>
    implements _$UpdateInfoCopyWith<$Res> {
  __$UpdateInfoCopyWithImpl(this._self, this._then);

  final _UpdateInfo _self;
  final $Res Function(_UpdateInfo) _then;

/// Create a copy of UpdateInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? downloadUrl = null,Object? releaseNotes = null,Object? isCritical = null,Object? releaseDate = freezed,}) {
  return _then(_UpdateInfo(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,releaseNotes: null == releaseNotes ? _self.releaseNotes : releaseNotes // ignore: cast_nullable_to_non_nullable
as String,isCritical: null == isCritical ? _self.isCritical : isCritical // ignore: cast_nullable_to_non_nullable
as bool,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
