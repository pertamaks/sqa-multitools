// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unix_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UnixState {

 DateTime get manualDateTime; String get manualTimestampString; bool get isLive; bool get lastInteractionWasDateTime;
/// Create a copy of UnixState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnixStateCopyWith<UnixState> get copyWith => _$UnixStateCopyWithImpl<UnixState>(this as UnixState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnixState&&(identical(other.manualDateTime, manualDateTime) || other.manualDateTime == manualDateTime)&&(identical(other.manualTimestampString, manualTimestampString) || other.manualTimestampString == manualTimestampString)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.lastInteractionWasDateTime, lastInteractionWasDateTime) || other.lastInteractionWasDateTime == lastInteractionWasDateTime));
}


@override
int get hashCode => Object.hash(runtimeType,manualDateTime,manualTimestampString,isLive,lastInteractionWasDateTime);

@override
String toString() {
  return 'UnixState(manualDateTime: $manualDateTime, manualTimestampString: $manualTimestampString, isLive: $isLive, lastInteractionWasDateTime: $lastInteractionWasDateTime)';
}


}

/// @nodoc
abstract mixin class $UnixStateCopyWith<$Res>  {
  factory $UnixStateCopyWith(UnixState value, $Res Function(UnixState) _then) = _$UnixStateCopyWithImpl;
@useResult
$Res call({
 DateTime manualDateTime, String manualTimestampString, bool isLive, bool lastInteractionWasDateTime
});




}
/// @nodoc
class _$UnixStateCopyWithImpl<$Res>
    implements $UnixStateCopyWith<$Res> {
  _$UnixStateCopyWithImpl(this._self, this._then);

  final UnixState _self;
  final $Res Function(UnixState) _then;

/// Create a copy of UnixState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? manualDateTime = null,Object? manualTimestampString = null,Object? isLive = null,Object? lastInteractionWasDateTime = null,}) {
  return _then(_self.copyWith(
manualDateTime: null == manualDateTime ? _self.manualDateTime : manualDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,manualTimestampString: null == manualTimestampString ? _self.manualTimestampString : manualTimestampString // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,lastInteractionWasDateTime: null == lastInteractionWasDateTime ? _self.lastInteractionWasDateTime : lastInteractionWasDateTime // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UnixState].
extension UnixStatePatterns on UnixState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnixState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnixState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnixState value)  $default,){
final _that = this;
switch (_that) {
case _UnixState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnixState value)?  $default,){
final _that = this;
switch (_that) {
case _UnixState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime manualDateTime,  String manualTimestampString,  bool isLive,  bool lastInteractionWasDateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnixState() when $default != null:
return $default(_that.manualDateTime,_that.manualTimestampString,_that.isLive,_that.lastInteractionWasDateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime manualDateTime,  String manualTimestampString,  bool isLive,  bool lastInteractionWasDateTime)  $default,) {final _that = this;
switch (_that) {
case _UnixState():
return $default(_that.manualDateTime,_that.manualTimestampString,_that.isLive,_that.lastInteractionWasDateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime manualDateTime,  String manualTimestampString,  bool isLive,  bool lastInteractionWasDateTime)?  $default,) {final _that = this;
switch (_that) {
case _UnixState() when $default != null:
return $default(_that.manualDateTime,_that.manualTimestampString,_that.isLive,_that.lastInteractionWasDateTime);case _:
  return null;

}
}

}

/// @nodoc


class _UnixState implements UnixState {
  const _UnixState({required this.manualDateTime, required this.manualTimestampString, this.isLive = true, this.lastInteractionWasDateTime = false});
  

@override final  DateTime manualDateTime;
@override final  String manualTimestampString;
@override@JsonKey() final  bool isLive;
@override@JsonKey() final  bool lastInteractionWasDateTime;

/// Create a copy of UnixState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnixStateCopyWith<_UnixState> get copyWith => __$UnixStateCopyWithImpl<_UnixState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnixState&&(identical(other.manualDateTime, manualDateTime) || other.manualDateTime == manualDateTime)&&(identical(other.manualTimestampString, manualTimestampString) || other.manualTimestampString == manualTimestampString)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.lastInteractionWasDateTime, lastInteractionWasDateTime) || other.lastInteractionWasDateTime == lastInteractionWasDateTime));
}


@override
int get hashCode => Object.hash(runtimeType,manualDateTime,manualTimestampString,isLive,lastInteractionWasDateTime);

@override
String toString() {
  return 'UnixState(manualDateTime: $manualDateTime, manualTimestampString: $manualTimestampString, isLive: $isLive, lastInteractionWasDateTime: $lastInteractionWasDateTime)';
}


}

/// @nodoc
abstract mixin class _$UnixStateCopyWith<$Res> implements $UnixStateCopyWith<$Res> {
  factory _$UnixStateCopyWith(_UnixState value, $Res Function(_UnixState) _then) = __$UnixStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime manualDateTime, String manualTimestampString, bool isLive, bool lastInteractionWasDateTime
});




}
/// @nodoc
class __$UnixStateCopyWithImpl<$Res>
    implements _$UnixStateCopyWith<$Res> {
  __$UnixStateCopyWithImpl(this._self, this._then);

  final _UnixState _self;
  final $Res Function(_UnixState) _then;

/// Create a copy of UnixState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? manualDateTime = null,Object? manualTimestampString = null,Object? isLive = null,Object? lastInteractionWasDateTime = null,}) {
  return _then(_UnixState(
manualDateTime: null == manualDateTime ? _self.manualDateTime : manualDateTime // ignore: cast_nullable_to_non_nullable
as DateTime,manualTimestampString: null == manualTimestampString ? _self.manualTimestampString : manualTimestampString // ignore: cast_nullable_to_non_nullable
as String,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,lastInteractionWasDateTime: null == lastInteractionWasDateTime ? _self.lastInteractionWasDateTime : lastInteractionWasDateTime // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
