// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TodoSettings {

 int? get wakeHour; int? get wakeMinute; bool get askWakeTimeDaily; bool get autoOpenOnReminder; int get historyRetentionDays; DateTime? get lastWakeTimePromptDate;
/// Create a copy of TodoSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoSettingsCopyWith<TodoSettings> get copyWith => _$TodoSettingsCopyWithImpl<TodoSettings>(this as TodoSettings, _$identity);

  /// Serializes this TodoSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoSettings&&(identical(other.wakeHour, wakeHour) || other.wakeHour == wakeHour)&&(identical(other.wakeMinute, wakeMinute) || other.wakeMinute == wakeMinute)&&(identical(other.askWakeTimeDaily, askWakeTimeDaily) || other.askWakeTimeDaily == askWakeTimeDaily)&&(identical(other.autoOpenOnReminder, autoOpenOnReminder) || other.autoOpenOnReminder == autoOpenOnReminder)&&(identical(other.historyRetentionDays, historyRetentionDays) || other.historyRetentionDays == historyRetentionDays)&&(identical(other.lastWakeTimePromptDate, lastWakeTimePromptDate) || other.lastWakeTimePromptDate == lastWakeTimePromptDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wakeHour,wakeMinute,askWakeTimeDaily,autoOpenOnReminder,historyRetentionDays,lastWakeTimePromptDate);

@override
String toString() {
  return 'TodoSettings(wakeHour: $wakeHour, wakeMinute: $wakeMinute, askWakeTimeDaily: $askWakeTimeDaily, autoOpenOnReminder: $autoOpenOnReminder, historyRetentionDays: $historyRetentionDays, lastWakeTimePromptDate: $lastWakeTimePromptDate)';
}


}

/// @nodoc
abstract mixin class $TodoSettingsCopyWith<$Res>  {
  factory $TodoSettingsCopyWith(TodoSettings value, $Res Function(TodoSettings) _then) = _$TodoSettingsCopyWithImpl;
@useResult
$Res call({
 int? wakeHour, int? wakeMinute, bool askWakeTimeDaily, bool autoOpenOnReminder, int historyRetentionDays, DateTime? lastWakeTimePromptDate
});




}
/// @nodoc
class _$TodoSettingsCopyWithImpl<$Res>
    implements $TodoSettingsCopyWith<$Res> {
  _$TodoSettingsCopyWithImpl(this._self, this._then);

  final TodoSettings _self;
  final $Res Function(TodoSettings) _then;

/// Create a copy of TodoSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wakeHour = freezed,Object? wakeMinute = freezed,Object? askWakeTimeDaily = null,Object? autoOpenOnReminder = null,Object? historyRetentionDays = null,Object? lastWakeTimePromptDate = freezed,}) {
  return _then(_self.copyWith(
wakeHour: freezed == wakeHour ? _self.wakeHour : wakeHour // ignore: cast_nullable_to_non_nullable
as int?,wakeMinute: freezed == wakeMinute ? _self.wakeMinute : wakeMinute // ignore: cast_nullable_to_non_nullable
as int?,askWakeTimeDaily: null == askWakeTimeDaily ? _self.askWakeTimeDaily : askWakeTimeDaily // ignore: cast_nullable_to_non_nullable
as bool,autoOpenOnReminder: null == autoOpenOnReminder ? _self.autoOpenOnReminder : autoOpenOnReminder // ignore: cast_nullable_to_non_nullable
as bool,historyRetentionDays: null == historyRetentionDays ? _self.historyRetentionDays : historyRetentionDays // ignore: cast_nullable_to_non_nullable
as int,lastWakeTimePromptDate: freezed == lastWakeTimePromptDate ? _self.lastWakeTimePromptDate : lastWakeTimePromptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoSettings].
extension TodoSettingsPatterns on TodoSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoSettings value)  $default,){
final _that = this;
switch (_that) {
case _TodoSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoSettings value)?  $default,){
final _that = this;
switch (_that) {
case _TodoSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? wakeHour,  int? wakeMinute,  bool askWakeTimeDaily,  bool autoOpenOnReminder,  int historyRetentionDays,  DateTime? lastWakeTimePromptDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoSettings() when $default != null:
return $default(_that.wakeHour,_that.wakeMinute,_that.askWakeTimeDaily,_that.autoOpenOnReminder,_that.historyRetentionDays,_that.lastWakeTimePromptDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? wakeHour,  int? wakeMinute,  bool askWakeTimeDaily,  bool autoOpenOnReminder,  int historyRetentionDays,  DateTime? lastWakeTimePromptDate)  $default,) {final _that = this;
switch (_that) {
case _TodoSettings():
return $default(_that.wakeHour,_that.wakeMinute,_that.askWakeTimeDaily,_that.autoOpenOnReminder,_that.historyRetentionDays,_that.lastWakeTimePromptDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? wakeHour,  int? wakeMinute,  bool askWakeTimeDaily,  bool autoOpenOnReminder,  int historyRetentionDays,  DateTime? lastWakeTimePromptDate)?  $default,) {final _that = this;
switch (_that) {
case _TodoSettings() when $default != null:
return $default(_that.wakeHour,_that.wakeMinute,_that.askWakeTimeDaily,_that.autoOpenOnReminder,_that.historyRetentionDays,_that.lastWakeTimePromptDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoSettings implements TodoSettings {
  const _TodoSettings({this.wakeHour, this.wakeMinute, this.askWakeTimeDaily = true, this.autoOpenOnReminder = false, this.historyRetentionDays = 30, this.lastWakeTimePromptDate});
  factory _TodoSettings.fromJson(Map<String, dynamic> json) => _$TodoSettingsFromJson(json);

@override final  int? wakeHour;
@override final  int? wakeMinute;
@override@JsonKey() final  bool askWakeTimeDaily;
@override@JsonKey() final  bool autoOpenOnReminder;
@override@JsonKey() final  int historyRetentionDays;
@override final  DateTime? lastWakeTimePromptDate;

/// Create a copy of TodoSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoSettingsCopyWith<_TodoSettings> get copyWith => __$TodoSettingsCopyWithImpl<_TodoSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodoSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoSettings&&(identical(other.wakeHour, wakeHour) || other.wakeHour == wakeHour)&&(identical(other.wakeMinute, wakeMinute) || other.wakeMinute == wakeMinute)&&(identical(other.askWakeTimeDaily, askWakeTimeDaily) || other.askWakeTimeDaily == askWakeTimeDaily)&&(identical(other.autoOpenOnReminder, autoOpenOnReminder) || other.autoOpenOnReminder == autoOpenOnReminder)&&(identical(other.historyRetentionDays, historyRetentionDays) || other.historyRetentionDays == historyRetentionDays)&&(identical(other.lastWakeTimePromptDate, lastWakeTimePromptDate) || other.lastWakeTimePromptDate == lastWakeTimePromptDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wakeHour,wakeMinute,askWakeTimeDaily,autoOpenOnReminder,historyRetentionDays,lastWakeTimePromptDate);

@override
String toString() {
  return 'TodoSettings(wakeHour: $wakeHour, wakeMinute: $wakeMinute, askWakeTimeDaily: $askWakeTimeDaily, autoOpenOnReminder: $autoOpenOnReminder, historyRetentionDays: $historyRetentionDays, lastWakeTimePromptDate: $lastWakeTimePromptDate)';
}


}

/// @nodoc
abstract mixin class _$TodoSettingsCopyWith<$Res> implements $TodoSettingsCopyWith<$Res> {
  factory _$TodoSettingsCopyWith(_TodoSettings value, $Res Function(_TodoSettings) _then) = __$TodoSettingsCopyWithImpl;
@override @useResult
$Res call({
 int? wakeHour, int? wakeMinute, bool askWakeTimeDaily, bool autoOpenOnReminder, int historyRetentionDays, DateTime? lastWakeTimePromptDate
});




}
/// @nodoc
class __$TodoSettingsCopyWithImpl<$Res>
    implements _$TodoSettingsCopyWith<$Res> {
  __$TodoSettingsCopyWithImpl(this._self, this._then);

  final _TodoSettings _self;
  final $Res Function(_TodoSettings) _then;

/// Create a copy of TodoSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wakeHour = freezed,Object? wakeMinute = freezed,Object? askWakeTimeDaily = null,Object? autoOpenOnReminder = null,Object? historyRetentionDays = null,Object? lastWakeTimePromptDate = freezed,}) {
  return _then(_TodoSettings(
wakeHour: freezed == wakeHour ? _self.wakeHour : wakeHour // ignore: cast_nullable_to_non_nullable
as int?,wakeMinute: freezed == wakeMinute ? _self.wakeMinute : wakeMinute // ignore: cast_nullable_to_non_nullable
as int?,askWakeTimeDaily: null == askWakeTimeDaily ? _self.askWakeTimeDaily : askWakeTimeDaily // ignore: cast_nullable_to_non_nullable
as bool,autoOpenOnReminder: null == autoOpenOnReminder ? _self.autoOpenOnReminder : autoOpenOnReminder // ignore: cast_nullable_to_non_nullable
as bool,historyRetentionDays: null == historyRetentionDays ? _self.historyRetentionDays : historyRetentionDays // ignore: cast_nullable_to_non_nullable
as int,lastWakeTimePromptDate: freezed == lastWakeTimePromptDate ? _self.lastWakeTimePromptDate : lastWakeTimePromptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
