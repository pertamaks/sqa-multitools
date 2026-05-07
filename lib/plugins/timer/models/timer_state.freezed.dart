// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimerState {

 Duration get initialDuration; Duration get remaining; bool get isRunning; bool get isStopwatch;
/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerStateCopyWith<TimerState> get copyWith => _$TimerStateCopyWithImpl<TimerState>(this as TimerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerState&&(identical(other.initialDuration, initialDuration) || other.initialDuration == initialDuration)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&(identical(other.isStopwatch, isStopwatch) || other.isStopwatch == isStopwatch));
}


@override
int get hashCode => Object.hash(runtimeType,initialDuration,remaining,isRunning,isStopwatch);

@override
String toString() {
  return 'TimerState(initialDuration: $initialDuration, remaining: $remaining, isRunning: $isRunning, isStopwatch: $isStopwatch)';
}


}

/// @nodoc
abstract mixin class $TimerStateCopyWith<$Res>  {
  factory $TimerStateCopyWith(TimerState value, $Res Function(TimerState) _then) = _$TimerStateCopyWithImpl;
@useResult
$Res call({
 Duration initialDuration, Duration remaining, bool isRunning, bool isStopwatch
});




}
/// @nodoc
class _$TimerStateCopyWithImpl<$Res>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._self, this._then);

  final TimerState _self;
  final $Res Function(TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? initialDuration = null,Object? remaining = null,Object? isRunning = null,Object? isStopwatch = null,}) {
  return _then(_self.copyWith(
initialDuration: null == initialDuration ? _self.initialDuration : initialDuration // ignore: cast_nullable_to_non_nullable
as Duration,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Duration,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,isStopwatch: null == isStopwatch ? _self.isStopwatch : isStopwatch // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TimerState].
extension TimerStatePatterns on TimerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimerState value)  $default,){
final _that = this;
switch (_that) {
case _TimerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimerState value)?  $default,){
final _that = this;
switch (_that) {
case _TimerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration initialDuration,  Duration remaining,  bool isRunning,  bool isStopwatch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.initialDuration,_that.remaining,_that.isRunning,_that.isStopwatch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration initialDuration,  Duration remaining,  bool isRunning,  bool isStopwatch)  $default,) {final _that = this;
switch (_that) {
case _TimerState():
return $default(_that.initialDuration,_that.remaining,_that.isRunning,_that.isStopwatch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration initialDuration,  Duration remaining,  bool isRunning,  bool isStopwatch)?  $default,) {final _that = this;
switch (_that) {
case _TimerState() when $default != null:
return $default(_that.initialDuration,_that.remaining,_that.isRunning,_that.isStopwatch);case _:
  return null;

}
}

}

/// @nodoc


class _TimerState implements TimerState {
  const _TimerState({this.initialDuration = Duration.zero, this.remaining = Duration.zero, this.isRunning = false, this.isStopwatch = false});
  

@override@JsonKey() final  Duration initialDuration;
@override@JsonKey() final  Duration remaining;
@override@JsonKey() final  bool isRunning;
@override@JsonKey() final  bool isStopwatch;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimerStateCopyWith<_TimerState> get copyWith => __$TimerStateCopyWithImpl<_TimerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimerState&&(identical(other.initialDuration, initialDuration) || other.initialDuration == initialDuration)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&(identical(other.isStopwatch, isStopwatch) || other.isStopwatch == isStopwatch));
}


@override
int get hashCode => Object.hash(runtimeType,initialDuration,remaining,isRunning,isStopwatch);

@override
String toString() {
  return 'TimerState(initialDuration: $initialDuration, remaining: $remaining, isRunning: $isRunning, isStopwatch: $isStopwatch)';
}


}

/// @nodoc
abstract mixin class _$TimerStateCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory _$TimerStateCopyWith(_TimerState value, $Res Function(_TimerState) _then) = __$TimerStateCopyWithImpl;
@override @useResult
$Res call({
 Duration initialDuration, Duration remaining, bool isRunning, bool isStopwatch
});




}
/// @nodoc
class __$TimerStateCopyWithImpl<$Res>
    implements _$TimerStateCopyWith<$Res> {
  __$TimerStateCopyWithImpl(this._self, this._then);

  final _TimerState _self;
  final $Res Function(_TimerState) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? initialDuration = null,Object? remaining = null,Object? isRunning = null,Object? isStopwatch = null,}) {
  return _then(_TimerState(
initialDuration: null == initialDuration ? _self.initialDuration : initialDuration // ignore: cast_nullable_to_non_nullable
as Duration,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Duration,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,isStopwatch: null == isStopwatch ? _self.isStopwatch : isStopwatch // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
