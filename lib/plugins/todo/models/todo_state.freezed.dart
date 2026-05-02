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

 List<TodoItem> get todos; List<RecurringTodo> get recurringTodos; TodoTab get currentTab; bool get hasActiveReminder; String? get previousPluginId; String get searchQuery; HistoryFilter get historyFilter;@JsonKey(includeFromJson: false, includeToJson: false) DateTimeRange? get customDateRange;
/// Create a copy of TodoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoStateCopyWith<TodoState> get copyWith => _$TodoStateCopyWithImpl<TodoState>(this as TodoState, _$identity);

  /// Serializes this TodoState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoState&&const DeepCollectionEquality().equals(other.todos, todos)&&const DeepCollectionEquality().equals(other.recurringTodos, recurringTodos)&&(identical(other.currentTab, currentTab) || other.currentTab == currentTab)&&(identical(other.hasActiveReminder, hasActiveReminder) || other.hasActiveReminder == hasActiveReminder)&&(identical(other.previousPluginId, previousPluginId) || other.previousPluginId == previousPluginId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.historyFilter, historyFilter) || other.historyFilter == historyFilter)&&(identical(other.customDateRange, customDateRange) || other.customDateRange == customDateRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(todos),const DeepCollectionEquality().hash(recurringTodos),currentTab,hasActiveReminder,previousPluginId,searchQuery,historyFilter,customDateRange);

@override
String toString() {
  return 'TodoState(todos: $todos, recurringTodos: $recurringTodos, currentTab: $currentTab, hasActiveReminder: $hasActiveReminder, previousPluginId: $previousPluginId, searchQuery: $searchQuery, historyFilter: $historyFilter, customDateRange: $customDateRange)';
}


}

/// @nodoc
abstract mixin class $TodoStateCopyWith<$Res>  {
  factory $TodoStateCopyWith(TodoState value, $Res Function(TodoState) _then) = _$TodoStateCopyWithImpl;
@useResult
$Res call({
 List<TodoItem> todos, List<RecurringTodo> recurringTodos, TodoTab currentTab, bool hasActiveReminder, String? previousPluginId, String searchQuery, HistoryFilter historyFilter,@JsonKey(includeFromJson: false, includeToJson: false) DateTimeRange? customDateRange
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
@pragma('vm:prefer-inline') @override $Res call({Object? todos = null,Object? recurringTodos = null,Object? currentTab = null,Object? hasActiveReminder = null,Object? previousPluginId = freezed,Object? searchQuery = null,Object? historyFilter = null,Object? customDateRange = freezed,}) {
  return _then(_self.copyWith(
todos: null == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoItem>,recurringTodos: null == recurringTodos ? _self.recurringTodos : recurringTodos // ignore: cast_nullable_to_non_nullable
as List<RecurringTodo>,currentTab: null == currentTab ? _self.currentTab : currentTab // ignore: cast_nullable_to_non_nullable
as TodoTab,hasActiveReminder: null == hasActiveReminder ? _self.hasActiveReminder : hasActiveReminder // ignore: cast_nullable_to_non_nullable
as bool,previousPluginId: freezed == previousPluginId ? _self.previousPluginId : previousPluginId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,historyFilter: null == historyFilter ? _self.historyFilter : historyFilter // ignore: cast_nullable_to_non_nullable
as HistoryFilter,customDateRange: freezed == customDateRange ? _self.customDateRange : customDateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TodoItem> todos,  List<RecurringTodo> recurringTodos,  TodoTab currentTab,  bool hasActiveReminder,  String? previousPluginId,  String searchQuery,  HistoryFilter historyFilter, @JsonKey(includeFromJson: false, includeToJson: false)  DateTimeRange? customDateRange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that.todos,_that.recurringTodos,_that.currentTab,_that.hasActiveReminder,_that.previousPluginId,_that.searchQuery,_that.historyFilter,_that.customDateRange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TodoItem> todos,  List<RecurringTodo> recurringTodos,  TodoTab currentTab,  bool hasActiveReminder,  String? previousPluginId,  String searchQuery,  HistoryFilter historyFilter, @JsonKey(includeFromJson: false, includeToJson: false)  DateTimeRange? customDateRange)  $default,) {final _that = this;
switch (_that) {
case _TodoState():
return $default(_that.todos,_that.recurringTodos,_that.currentTab,_that.hasActiveReminder,_that.previousPluginId,_that.searchQuery,_that.historyFilter,_that.customDateRange);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TodoItem> todos,  List<RecurringTodo> recurringTodos,  TodoTab currentTab,  bool hasActiveReminder,  String? previousPluginId,  String searchQuery,  HistoryFilter historyFilter, @JsonKey(includeFromJson: false, includeToJson: false)  DateTimeRange? customDateRange)?  $default,) {final _that = this;
switch (_that) {
case _TodoState() when $default != null:
return $default(_that.todos,_that.recurringTodos,_that.currentTab,_that.hasActiveReminder,_that.previousPluginId,_that.searchQuery,_that.historyFilter,_that.customDateRange);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoState implements TodoState {
  const _TodoState({final  List<TodoItem> todos = const [], final  List<RecurringTodo> recurringTodos = const [], this.currentTab = TodoTab.today, this.hasActiveReminder = false, this.previousPluginId = null, this.searchQuery = '', this.historyFilter = HistoryFilter.last7Days, @JsonKey(includeFromJson: false, includeToJson: false) this.customDateRange}): _todos = todos,_recurringTodos = recurringTodos;
  factory _TodoState.fromJson(Map<String, dynamic> json) => _$TodoStateFromJson(json);

 final  List<TodoItem> _todos;
@override@JsonKey() List<TodoItem> get todos {
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todos);
}

 final  List<RecurringTodo> _recurringTodos;
@override@JsonKey() List<RecurringTodo> get recurringTodos {
  if (_recurringTodos is EqualUnmodifiableListView) return _recurringTodos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recurringTodos);
}

@override@JsonKey() final  TodoTab currentTab;
@override@JsonKey() final  bool hasActiveReminder;
@override@JsonKey() final  String? previousPluginId;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  HistoryFilter historyFilter;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  DateTimeRange? customDateRange;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoState&&const DeepCollectionEquality().equals(other._todos, _todos)&&const DeepCollectionEquality().equals(other._recurringTodos, _recurringTodos)&&(identical(other.currentTab, currentTab) || other.currentTab == currentTab)&&(identical(other.hasActiveReminder, hasActiveReminder) || other.hasActiveReminder == hasActiveReminder)&&(identical(other.previousPluginId, previousPluginId) || other.previousPluginId == previousPluginId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.historyFilter, historyFilter) || other.historyFilter == historyFilter)&&(identical(other.customDateRange, customDateRange) || other.customDateRange == customDateRange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_todos),const DeepCollectionEquality().hash(_recurringTodos),currentTab,hasActiveReminder,previousPluginId,searchQuery,historyFilter,customDateRange);

@override
String toString() {
  return 'TodoState(todos: $todos, recurringTodos: $recurringTodos, currentTab: $currentTab, hasActiveReminder: $hasActiveReminder, previousPluginId: $previousPluginId, searchQuery: $searchQuery, historyFilter: $historyFilter, customDateRange: $customDateRange)';
}


}

/// @nodoc
abstract mixin class _$TodoStateCopyWith<$Res> implements $TodoStateCopyWith<$Res> {
  factory _$TodoStateCopyWith(_TodoState value, $Res Function(_TodoState) _then) = __$TodoStateCopyWithImpl;
@override @useResult
$Res call({
 List<TodoItem> todos, List<RecurringTodo> recurringTodos, TodoTab currentTab, bool hasActiveReminder, String? previousPluginId, String searchQuery, HistoryFilter historyFilter,@JsonKey(includeFromJson: false, includeToJson: false) DateTimeRange? customDateRange
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
@override @pragma('vm:prefer-inline') $Res call({Object? todos = null,Object? recurringTodos = null,Object? currentTab = null,Object? hasActiveReminder = null,Object? previousPluginId = freezed,Object? searchQuery = null,Object? historyFilter = null,Object? customDateRange = freezed,}) {
  return _then(_TodoState(
todos: null == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoItem>,recurringTodos: null == recurringTodos ? _self._recurringTodos : recurringTodos // ignore: cast_nullable_to_non_nullable
as List<RecurringTodo>,currentTab: null == currentTab ? _self.currentTab : currentTab // ignore: cast_nullable_to_non_nullable
as TodoTab,hasActiveReminder: null == hasActiveReminder ? _self.hasActiveReminder : hasActiveReminder // ignore: cast_nullable_to_non_nullable
as bool,previousPluginId: freezed == previousPluginId ? _self.previousPluginId : previousPluginId // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,historyFilter: null == historyFilter ? _self.historyFilter : historyFilter // ignore: cast_nullable_to_non_nullable
as HistoryFilter,customDateRange: freezed == customDateRange ? _self.customDateRange : customDateRange // ignore: cast_nullable_to_non_nullable
as DateTimeRange?,
  ));
}


}

// dart format on
