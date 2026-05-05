// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curl_requester_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CurlRequesterState {

 CurlCommand get currentCommand; List<CurlTransaction> get history; bool get isLoading; String? get lastError;
/// Create a copy of CurlRequesterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurlRequesterStateCopyWith<CurlRequesterState> get copyWith => _$CurlRequesterStateCopyWithImpl<CurlRequesterState>(this as CurlRequesterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurlRequesterState&&(identical(other.currentCommand, currentCommand) || other.currentCommand == currentCommand)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode => Object.hash(runtimeType,currentCommand,const DeepCollectionEquality().hash(history),isLoading,lastError);

@override
String toString() {
  return 'CurlRequesterState(currentCommand: $currentCommand, history: $history, isLoading: $isLoading, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class $CurlRequesterStateCopyWith<$Res>  {
  factory $CurlRequesterStateCopyWith(CurlRequesterState value, $Res Function(CurlRequesterState) _then) = _$CurlRequesterStateCopyWithImpl;
@useResult
$Res call({
 CurlCommand currentCommand, List<CurlTransaction> history, bool isLoading, String? lastError
});


$CurlCommandCopyWith<$Res> get currentCommand;

}
/// @nodoc
class _$CurlRequesterStateCopyWithImpl<$Res>
    implements $CurlRequesterStateCopyWith<$Res> {
  _$CurlRequesterStateCopyWithImpl(this._self, this._then);

  final CurlRequesterState _self;
  final $Res Function(CurlRequesterState) _then;

/// Create a copy of CurlRequesterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentCommand = null,Object? history = null,Object? isLoading = null,Object? lastError = freezed,}) {
  return _then(_self.copyWith(
currentCommand: null == currentCommand ? _self.currentCommand : currentCommand // ignore: cast_nullable_to_non_nullable
as CurlCommand,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<CurlTransaction>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CurlRequesterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurlCommandCopyWith<$Res> get currentCommand {
  
  return $CurlCommandCopyWith<$Res>(_self.currentCommand, (value) {
    return _then(_self.copyWith(currentCommand: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurlRequesterState].
extension CurlRequesterStatePatterns on CurlRequesterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurlRequesterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurlRequesterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurlRequesterState value)  $default,){
final _that = this;
switch (_that) {
case _CurlRequesterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurlRequesterState value)?  $default,){
final _that = this;
switch (_that) {
case _CurlRequesterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CurlCommand currentCommand,  List<CurlTransaction> history,  bool isLoading,  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurlRequesterState() when $default != null:
return $default(_that.currentCommand,_that.history,_that.isLoading,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CurlCommand currentCommand,  List<CurlTransaction> history,  bool isLoading,  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _CurlRequesterState():
return $default(_that.currentCommand,_that.history,_that.isLoading,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CurlCommand currentCommand,  List<CurlTransaction> history,  bool isLoading,  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _CurlRequesterState() when $default != null:
return $default(_that.currentCommand,_that.history,_that.isLoading,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc


class _CurlRequesterState implements CurlRequesterState {
  const _CurlRequesterState({this.currentCommand = const CurlCommand(), final  List<CurlTransaction> history = const [], this.isLoading = false, this.lastError}): _history = history;
  

@override@JsonKey() final  CurlCommand currentCommand;
 final  List<CurlTransaction> _history;
@override@JsonKey() List<CurlTransaction> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override@JsonKey() final  bool isLoading;
@override final  String? lastError;

/// Create a copy of CurlRequesterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurlRequesterStateCopyWith<_CurlRequesterState> get copyWith => __$CurlRequesterStateCopyWithImpl<_CurlRequesterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurlRequesterState&&(identical(other.currentCommand, currentCommand) || other.currentCommand == currentCommand)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}


@override
int get hashCode => Object.hash(runtimeType,currentCommand,const DeepCollectionEquality().hash(_history),isLoading,lastError);

@override
String toString() {
  return 'CurlRequesterState(currentCommand: $currentCommand, history: $history, isLoading: $isLoading, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$CurlRequesterStateCopyWith<$Res> implements $CurlRequesterStateCopyWith<$Res> {
  factory _$CurlRequesterStateCopyWith(_CurlRequesterState value, $Res Function(_CurlRequesterState) _then) = __$CurlRequesterStateCopyWithImpl;
@override @useResult
$Res call({
 CurlCommand currentCommand, List<CurlTransaction> history, bool isLoading, String? lastError
});


@override $CurlCommandCopyWith<$Res> get currentCommand;

}
/// @nodoc
class __$CurlRequesterStateCopyWithImpl<$Res>
    implements _$CurlRequesterStateCopyWith<$Res> {
  __$CurlRequesterStateCopyWithImpl(this._self, this._then);

  final _CurlRequesterState _self;
  final $Res Function(_CurlRequesterState) _then;

/// Create a copy of CurlRequesterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentCommand = null,Object? history = null,Object? isLoading = null,Object? lastError = freezed,}) {
  return _then(_CurlRequesterState(
currentCommand: null == currentCommand ? _self.currentCommand : currentCommand // ignore: cast_nullable_to_non_nullable
as CurlCommand,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<CurlTransaction>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CurlRequesterState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CurlCommandCopyWith<$Res> get currentCommand {
  
  return $CurlCommandCopyWith<$Res>(_self.currentCommand, (value) {
    return _then(_self.copyWith(currentCommand: value));
  });
}
}

// dart format on
