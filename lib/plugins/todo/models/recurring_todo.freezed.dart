// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_todo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringTodo {

 String get id; String get title; int get hour; int get minute; TodoDurationPreset get durationPreset; TodoPriority get priority; RecurrenceType get recurrenceType; int get everyNDays; List<int> get weeklyDays; String get category; String get notes; bool get isActive; DateTime? get lastGeneratedDate;
/// Create a copy of RecurringTodo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringTodoCopyWith<RecurringTodo> get copyWith => _$RecurringTodoCopyWithImpl<RecurringTodo>(this as RecurringTodo, _$identity);

  /// Serializes this RecurringTodo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringTodo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.durationPreset, durationPreset) || other.durationPreset == durationPreset)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.recurrenceType, recurrenceType) || other.recurrenceType == recurrenceType)&&(identical(other.everyNDays, everyNDays) || other.everyNDays == everyNDays)&&const DeepCollectionEquality().equals(other.weeklyDays, weeklyDays)&&(identical(other.category, category) || other.category == category)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.lastGeneratedDate, lastGeneratedDate) || other.lastGeneratedDate == lastGeneratedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,hour,minute,durationPreset,priority,recurrenceType,everyNDays,const DeepCollectionEquality().hash(weeklyDays),category,notes,isActive,lastGeneratedDate);

@override
String toString() {
  return 'RecurringTodo(id: $id, title: $title, hour: $hour, minute: $minute, durationPreset: $durationPreset, priority: $priority, recurrenceType: $recurrenceType, everyNDays: $everyNDays, weeklyDays: $weeklyDays, category: $category, notes: $notes, isActive: $isActive, lastGeneratedDate: $lastGeneratedDate)';
}


}

/// @nodoc
abstract mixin class $RecurringTodoCopyWith<$Res>  {
  factory $RecurringTodoCopyWith(RecurringTodo value, $Res Function(RecurringTodo) _then) = _$RecurringTodoCopyWithImpl;
@useResult
$Res call({
 String id, String title, int hour, int minute, TodoDurationPreset durationPreset, TodoPriority priority, RecurrenceType recurrenceType, int everyNDays, List<int> weeklyDays, String category, String notes, bool isActive, DateTime? lastGeneratedDate
});




}
/// @nodoc
class _$RecurringTodoCopyWithImpl<$Res>
    implements $RecurringTodoCopyWith<$Res> {
  _$RecurringTodoCopyWithImpl(this._self, this._then);

  final RecurringTodo _self;
  final $Res Function(RecurringTodo) _then;

/// Create a copy of RecurringTodo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? hour = null,Object? minute = null,Object? durationPreset = null,Object? priority = null,Object? recurrenceType = null,Object? everyNDays = null,Object? weeklyDays = null,Object? category = null,Object? notes = null,Object? isActive = null,Object? lastGeneratedDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,durationPreset: null == durationPreset ? _self.durationPreset : durationPreset // ignore: cast_nullable_to_non_nullable
as TodoDurationPreset,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority,recurrenceType: null == recurrenceType ? _self.recurrenceType : recurrenceType // ignore: cast_nullable_to_non_nullable
as RecurrenceType,everyNDays: null == everyNDays ? _self.everyNDays : everyNDays // ignore: cast_nullable_to_non_nullable
as int,weeklyDays: null == weeklyDays ? _self.weeklyDays : weeklyDays // ignore: cast_nullable_to_non_nullable
as List<int>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,lastGeneratedDate: freezed == lastGeneratedDate ? _self.lastGeneratedDate : lastGeneratedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringTodo].
extension RecurringTodoPatterns on RecurringTodo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringTodo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringTodo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringTodo value)  $default,){
final _that = this;
switch (_that) {
case _RecurringTodo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringTodo value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringTodo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int hour,  int minute,  TodoDurationPreset durationPreset,  TodoPriority priority,  RecurrenceType recurrenceType,  int everyNDays,  List<int> weeklyDays,  String category,  String notes,  bool isActive,  DateTime? lastGeneratedDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringTodo() when $default != null:
return $default(_that.id,_that.title,_that.hour,_that.minute,_that.durationPreset,_that.priority,_that.recurrenceType,_that.everyNDays,_that.weeklyDays,_that.category,_that.notes,_that.isActive,_that.lastGeneratedDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int hour,  int minute,  TodoDurationPreset durationPreset,  TodoPriority priority,  RecurrenceType recurrenceType,  int everyNDays,  List<int> weeklyDays,  String category,  String notes,  bool isActive,  DateTime? lastGeneratedDate)  $default,) {final _that = this;
switch (_that) {
case _RecurringTodo():
return $default(_that.id,_that.title,_that.hour,_that.minute,_that.durationPreset,_that.priority,_that.recurrenceType,_that.everyNDays,_that.weeklyDays,_that.category,_that.notes,_that.isActive,_that.lastGeneratedDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int hour,  int minute,  TodoDurationPreset durationPreset,  TodoPriority priority,  RecurrenceType recurrenceType,  int everyNDays,  List<int> weeklyDays,  String category,  String notes,  bool isActive,  DateTime? lastGeneratedDate)?  $default,) {final _that = this;
switch (_that) {
case _RecurringTodo() when $default != null:
return $default(_that.id,_that.title,_that.hour,_that.minute,_that.durationPreset,_that.priority,_that.recurrenceType,_that.everyNDays,_that.weeklyDays,_that.category,_that.notes,_that.isActive,_that.lastGeneratedDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringTodo implements RecurringTodo {
  const _RecurringTodo({required this.id, required this.title, required this.hour, required this.minute, this.durationPreset = TodoDurationPreset.min25, this.priority = TodoPriority.normal, this.recurrenceType = RecurrenceType.daily, this.everyNDays = 1, final  List<int> weeklyDays = const [], this.category = '', this.notes = '', this.isActive = true, this.lastGeneratedDate}): _weeklyDays = weeklyDays;
  factory _RecurringTodo.fromJson(Map<String, dynamic> json) => _$RecurringTodoFromJson(json);

@override final  String id;
@override final  String title;
@override final  int hour;
@override final  int minute;
@override@JsonKey() final  TodoDurationPreset durationPreset;
@override@JsonKey() final  TodoPriority priority;
@override@JsonKey() final  RecurrenceType recurrenceType;
@override@JsonKey() final  int everyNDays;
 final  List<int> _weeklyDays;
@override@JsonKey() List<int> get weeklyDays {
  if (_weeklyDays is EqualUnmodifiableListView) return _weeklyDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeklyDays);
}

@override@JsonKey() final  String category;
@override@JsonKey() final  String notes;
@override@JsonKey() final  bool isActive;
@override final  DateTime? lastGeneratedDate;

/// Create a copy of RecurringTodo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringTodoCopyWith<_RecurringTodo> get copyWith => __$RecurringTodoCopyWithImpl<_RecurringTodo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringTodoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringTodo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.durationPreset, durationPreset) || other.durationPreset == durationPreset)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.recurrenceType, recurrenceType) || other.recurrenceType == recurrenceType)&&(identical(other.everyNDays, everyNDays) || other.everyNDays == everyNDays)&&const DeepCollectionEquality().equals(other._weeklyDays, _weeklyDays)&&(identical(other.category, category) || other.category == category)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.lastGeneratedDate, lastGeneratedDate) || other.lastGeneratedDate == lastGeneratedDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,hour,minute,durationPreset,priority,recurrenceType,everyNDays,const DeepCollectionEquality().hash(_weeklyDays),category,notes,isActive,lastGeneratedDate);

@override
String toString() {
  return 'RecurringTodo(id: $id, title: $title, hour: $hour, minute: $minute, durationPreset: $durationPreset, priority: $priority, recurrenceType: $recurrenceType, everyNDays: $everyNDays, weeklyDays: $weeklyDays, category: $category, notes: $notes, isActive: $isActive, lastGeneratedDate: $lastGeneratedDate)';
}


}

/// @nodoc
abstract mixin class _$RecurringTodoCopyWith<$Res> implements $RecurringTodoCopyWith<$Res> {
  factory _$RecurringTodoCopyWith(_RecurringTodo value, $Res Function(_RecurringTodo) _then) = __$RecurringTodoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int hour, int minute, TodoDurationPreset durationPreset, TodoPriority priority, RecurrenceType recurrenceType, int everyNDays, List<int> weeklyDays, String category, String notes, bool isActive, DateTime? lastGeneratedDate
});




}
/// @nodoc
class __$RecurringTodoCopyWithImpl<$Res>
    implements _$RecurringTodoCopyWith<$Res> {
  __$RecurringTodoCopyWithImpl(this._self, this._then);

  final _RecurringTodo _self;
  final $Res Function(_RecurringTodo) _then;

/// Create a copy of RecurringTodo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? hour = null,Object? minute = null,Object? durationPreset = null,Object? priority = null,Object? recurrenceType = null,Object? everyNDays = null,Object? weeklyDays = null,Object? category = null,Object? notes = null,Object? isActive = null,Object? lastGeneratedDate = freezed,}) {
  return _then(_RecurringTodo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,durationPreset: null == durationPreset ? _self.durationPreset : durationPreset // ignore: cast_nullable_to_non_nullable
as TodoDurationPreset,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority,recurrenceType: null == recurrenceType ? _self.recurrenceType : recurrenceType // ignore: cast_nullable_to_non_nullable
as RecurrenceType,everyNDays: null == everyNDays ? _self.everyNDays : everyNDays // ignore: cast_nullable_to_non_nullable
as int,weeklyDays: null == weeklyDays ? _self._weeklyDays : weeklyDays // ignore: cast_nullable_to_non_nullable
as List<int>,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,lastGeneratedDate: freezed == lastGeneratedDate ? _self.lastGeneratedDate : lastGeneratedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
