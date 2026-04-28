// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TodoItem {

 String get id; String get title; TodoTimeBlock get timeBlock; TodoDurationPreset get durationPreset; TodoPriority get priority; TodoStatus get status; String get category; String get notes; String get delegatedTo; DateTime get createdAt; DateTime? get completedAt; DateTime? get deferredUntil; String? get recurringTodoId;
/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoItemCopyWith<TodoItem> get copyWith => _$TodoItemCopyWithImpl<TodoItem>(this as TodoItem, _$identity);

  /// Serializes this TodoItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.timeBlock, timeBlock) || other.timeBlock == timeBlock)&&(identical(other.durationPreset, durationPreset) || other.durationPreset == durationPreset)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.delegatedTo, delegatedTo) || other.delegatedTo == delegatedTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.deferredUntil, deferredUntil) || other.deferredUntil == deferredUntil)&&(identical(other.recurringTodoId, recurringTodoId) || other.recurringTodoId == recurringTodoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,timeBlock,durationPreset,priority,status,category,notes,delegatedTo,createdAt,completedAt,deferredUntil,recurringTodoId);

@override
String toString() {
  return 'TodoItem(id: $id, title: $title, timeBlock: $timeBlock, durationPreset: $durationPreset, priority: $priority, status: $status, category: $category, notes: $notes, delegatedTo: $delegatedTo, createdAt: $createdAt, completedAt: $completedAt, deferredUntil: $deferredUntil, recurringTodoId: $recurringTodoId)';
}


}

/// @nodoc
abstract mixin class $TodoItemCopyWith<$Res>  {
  factory $TodoItemCopyWith(TodoItem value, $Res Function(TodoItem) _then) = _$TodoItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, TodoTimeBlock timeBlock, TodoDurationPreset durationPreset, TodoPriority priority, TodoStatus status, String category, String notes, String delegatedTo, DateTime createdAt, DateTime? completedAt, DateTime? deferredUntil, String? recurringTodoId
});




}
/// @nodoc
class _$TodoItemCopyWithImpl<$Res>
    implements $TodoItemCopyWith<$Res> {
  _$TodoItemCopyWithImpl(this._self, this._then);

  final TodoItem _self;
  final $Res Function(TodoItem) _then;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? timeBlock = null,Object? durationPreset = null,Object? priority = null,Object? status = null,Object? category = null,Object? notes = null,Object? delegatedTo = null,Object? createdAt = null,Object? completedAt = freezed,Object? deferredUntil = freezed,Object? recurringTodoId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timeBlock: null == timeBlock ? _self.timeBlock : timeBlock // ignore: cast_nullable_to_non_nullable
as TodoTimeBlock,durationPreset: null == durationPreset ? _self.durationPreset : durationPreset // ignore: cast_nullable_to_non_nullable
as TodoDurationPreset,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TodoStatus,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,delegatedTo: null == delegatedTo ? _self.delegatedTo : delegatedTo // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deferredUntil: freezed == deferredUntil ? _self.deferredUntil : deferredUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,recurringTodoId: freezed == recurringTodoId ? _self.recurringTodoId : recurringTodoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoItem].
extension TodoItemPatterns on TodoItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoItem value)  $default,){
final _that = this;
switch (_that) {
case _TodoItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoItem value)?  $default,){
final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  TodoTimeBlock timeBlock,  TodoDurationPreset durationPreset,  TodoPriority priority,  TodoStatus status,  String category,  String notes,  String delegatedTo,  DateTime createdAt,  DateTime? completedAt,  DateTime? deferredUntil,  String? recurringTodoId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
return $default(_that.id,_that.title,_that.timeBlock,_that.durationPreset,_that.priority,_that.status,_that.category,_that.notes,_that.delegatedTo,_that.createdAt,_that.completedAt,_that.deferredUntil,_that.recurringTodoId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  TodoTimeBlock timeBlock,  TodoDurationPreset durationPreset,  TodoPriority priority,  TodoStatus status,  String category,  String notes,  String delegatedTo,  DateTime createdAt,  DateTime? completedAt,  DateTime? deferredUntil,  String? recurringTodoId)  $default,) {final _that = this;
switch (_that) {
case _TodoItem():
return $default(_that.id,_that.title,_that.timeBlock,_that.durationPreset,_that.priority,_that.status,_that.category,_that.notes,_that.delegatedTo,_that.createdAt,_that.completedAt,_that.deferredUntil,_that.recurringTodoId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  TodoTimeBlock timeBlock,  TodoDurationPreset durationPreset,  TodoPriority priority,  TodoStatus status,  String category,  String notes,  String delegatedTo,  DateTime createdAt,  DateTime? completedAt,  DateTime? deferredUntil,  String? recurringTodoId)?  $default,) {final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
return $default(_that.id,_that.title,_that.timeBlock,_that.durationPreset,_that.priority,_that.status,_that.category,_that.notes,_that.delegatedTo,_that.createdAt,_that.completedAt,_that.deferredUntil,_that.recurringTodoId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoItem implements TodoItem {
  const _TodoItem({required this.id, required this.title, this.timeBlock = TodoTimeBlock.current, this.durationPreset = TodoDurationPreset.min25, this.priority = TodoPriority.normal, this.status = TodoStatus.todo, this.category = '', this.notes = '', this.delegatedTo = '', required this.createdAt, this.completedAt, this.deferredUntil, this.recurringTodoId});
  factory _TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  TodoTimeBlock timeBlock;
@override@JsonKey() final  TodoDurationPreset durationPreset;
@override@JsonKey() final  TodoPriority priority;
@override@JsonKey() final  TodoStatus status;
@override@JsonKey() final  String category;
@override@JsonKey() final  String notes;
@override@JsonKey() final  String delegatedTo;
@override final  DateTime createdAt;
@override final  DateTime? completedAt;
@override final  DateTime? deferredUntil;
@override final  String? recurringTodoId;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoItemCopyWith<_TodoItem> get copyWith => __$TodoItemCopyWithImpl<_TodoItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodoItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.timeBlock, timeBlock) || other.timeBlock == timeBlock)&&(identical(other.durationPreset, durationPreset) || other.durationPreset == durationPreset)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.delegatedTo, delegatedTo) || other.delegatedTo == delegatedTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.deferredUntil, deferredUntil) || other.deferredUntil == deferredUntil)&&(identical(other.recurringTodoId, recurringTodoId) || other.recurringTodoId == recurringTodoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,timeBlock,durationPreset,priority,status,category,notes,delegatedTo,createdAt,completedAt,deferredUntil,recurringTodoId);

@override
String toString() {
  return 'TodoItem(id: $id, title: $title, timeBlock: $timeBlock, durationPreset: $durationPreset, priority: $priority, status: $status, category: $category, notes: $notes, delegatedTo: $delegatedTo, createdAt: $createdAt, completedAt: $completedAt, deferredUntil: $deferredUntil, recurringTodoId: $recurringTodoId)';
}


}

/// @nodoc
abstract mixin class _$TodoItemCopyWith<$Res> implements $TodoItemCopyWith<$Res> {
  factory _$TodoItemCopyWith(_TodoItem value, $Res Function(_TodoItem) _then) = __$TodoItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, TodoTimeBlock timeBlock, TodoDurationPreset durationPreset, TodoPriority priority, TodoStatus status, String category, String notes, String delegatedTo, DateTime createdAt, DateTime? completedAt, DateTime? deferredUntil, String? recurringTodoId
});




}
/// @nodoc
class __$TodoItemCopyWithImpl<$Res>
    implements _$TodoItemCopyWith<$Res> {
  __$TodoItemCopyWithImpl(this._self, this._then);

  final _TodoItem _self;
  final $Res Function(_TodoItem) _then;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? timeBlock = null,Object? durationPreset = null,Object? priority = null,Object? status = null,Object? category = null,Object? notes = null,Object? delegatedTo = null,Object? createdAt = null,Object? completedAt = freezed,Object? deferredUntil = freezed,Object? recurringTodoId = freezed,}) {
  return _then(_TodoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,timeBlock: null == timeBlock ? _self.timeBlock : timeBlock // ignore: cast_nullable_to_non_nullable
as TodoTimeBlock,durationPreset: null == durationPreset ? _self.durationPreset : durationPreset // ignore: cast_nullable_to_non_nullable
as TodoDurationPreset,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TodoPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TodoStatus,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,delegatedTo: null == delegatedTo ? _self.delegatedTo : delegatedTo // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deferredUntil: freezed == deferredUntil ? _self.deferredUntil : deferredUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,recurringTodoId: freezed == recurringTodoId ? _self.recurringTodoId : recurringTodoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
