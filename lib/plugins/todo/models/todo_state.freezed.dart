// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TodoState {

 List<TodoItem> get todos; TodoTab get currentTab; bool get hasActiveReminder; String? get previousPluginId;
/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoStateCopyWith<TodoState> get copyWith => _$TodoStateCopyWithImpl<TodoState>(this as TodoState, _$identity);

  /// Serializes this TodoState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoState&&const DeepCollectionEquality().equals(other.todos, todos)&&(identical(other.currentTab, currentTab) || other.currentTab == currentTab)&&(identical(other.hasActiveReminder, hasActiveReminder) || other.hasActiveReminder == hasActiveReminder)&&(identical(other.previousPluginId, previousPluginId) || other.previousPluginId == previousPluginId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(todos),currentTab,hasActiveReminder,previousPluginId);

@override
String toString() {
  return 'TodoState(todos: $todos, currentTab: $currentTab, hasActiveReminder: $hasActiveReminder, previousPluginId: $previousPluginId)';
}


}

/// @nodoc
abstract mixin class $TodoStateCopyWith<$Res>  {
  factory $TodoStateCopyWith(TodoState value, $Res Function(TodoState) _then) = _$TodoStateCopyWithImpl;
@useResult
$Res call({
 List<TodoItem> todos, TodoTab currentTab, bool hasActiveReminder, String? previousPluginId
});




}
/// @nodoc
class _$TodoStateCopyWithImpl<$Res>
    implements $TodoStateCopyWith<$Res> {
  _$TodoStateCopyWithImpl(this._self, this._then);

  final TodoState _self;
  final $Res Function(TodoState) _then;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todos = null,Object? currentTab = null,Object? hasActiveReminder = null,Object? previousPluginId = freezed,}) {
  return _then(_self.copyWith(
todos: null == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoItem>,currentTab: null == currentTab ? _self.currentTab : currentTab // ignore: cast_nullable_to_non_nullable
as TodoTab,hasActiveReminder: null == hasActiveReminder ? _self.hasActiveReminder : hasActiveReminder // ignore: cast_nullable_to_non_nullable
as bool,previousPluginId: freezed == previousPluginId ? _self.previousPluginId : previousPluginId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoState].
extension TodoStatePatterns on TodoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoState value)  $default,){
final _that = this;
switch (_that) {
case _TodoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoState value)?  $default,){
final _that = this;
switch (_that) {
case _TodoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TodoItem> todos,  TodoTab currentTab,  bool hasActiveReminder,  String? previousPluginId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that.todos,_that.currentTab,_that.hasActiveReminder,_that.previousPluginId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TodoItem> todos,  TodoTab currentTab,  bool hasActiveReminder,  String? previousPluginId)  $default,) {final _that = this;
switch (_that) {
case _TodoState():
return $default(_that.todos,_that.currentTab,_that.hasActiveReminder,_that.previousPluginId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TodoItem> todos,  TodoTab currentTab,  bool hasActiveReminder,  String? previousPluginId)?  $default,) {final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that.todos,_that.currentTab,_that.hasActiveReminder,_that.previousPluginId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoState implements TodoState {
  const _TodoState({final  List<TodoItem> todos = const [], this.currentTab = TodoTab.today, this.hasActiveReminder = false, this.previousPluginId = null}): _todos = todos;
  factory _TodoState.fromJson(Map<String, dynamic> json) => _$TodoStateFromJson(json);

 final  List<TodoItem> _todos;
@override@JsonKey() List<TodoItem> get todos {
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todos);
}

@override@JsonKey() final  TodoTab currentTab;
@override@JsonKey() final  bool hasActiveReminder;
@override@JsonKey() final  String? previousPluginId;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoStateCopyWith<_TodoState> get copyWith => __$TodoStateCopyWithImpl<_TodoState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodoStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoState&&const DeepCollectionEquality().equals(other._todos, _todos)&&(identical(other.currentTab, currentTab) || other.currentTab == currentTab)&&(identical(other.hasActiveReminder, hasActiveReminder) || other.hasActiveReminder == hasActiveReminder)&&(identical(other.previousPluginId, previousPluginId) || other.previousPluginId == previousPluginId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_todos),currentTab,hasActiveReminder,previousPluginId);

@override
String toString() {
  return 'TodoState(todos: $todos, currentTab: $currentTab, hasActiveReminder: $hasActiveReminder, previousPluginId: $previousPluginId)';
}


}

/// @nodoc
abstract mixin class _$TodoStateCopyWith<$Res> implements $TodoStateCopyWith<$Res> {
  factory _$TodoStateCopyWith(_TodoState value, $Res Function(_TodoState) _then) = __$TodoStateCopyWithImpl;
@override @useResult
$Res call({
 List<TodoItem> todos, TodoTab currentTab, bool hasActiveReminder, String? previousPluginId
});




}
/// @nodoc
class __$TodoStateCopyWithImpl<$Res>
    implements _$TodoStateCopyWith<$Res> {
  __$TodoStateCopyWithImpl(this._self, this._then);

  final _TodoState _self;
  final $Res Function(_TodoState) _then;

/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todos = null,Object? currentTab = null,Object? hasActiveReminder = null,Object? previousPluginId = freezed,}) {
  return _then(_TodoState(
todos: null == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoItem>,currentTab: null == currentTab ? _self.currentTab : currentTab // ignore: cast_nullable_to_non_nullable
as TodoTab,hasActiveReminder: null == hasActiveReminder ? _self.hasActiveReminder : hasActiveReminder // ignore: cast_nullable_to_non_nullable
as bool,previousPluginId: freezed == previousPluginId ? _self.previousPluginId : previousPluginId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
