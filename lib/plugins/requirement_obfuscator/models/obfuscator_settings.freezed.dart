// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'obfuscator_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ObfuscatorSettings {

 SubstitutionStrategy get defaultStrategy; String get obfuscateHighlightColor; String get deobfuscateHighlightColor; String get unrecognizedAliasColor; bool get autoScanOnOpen;
/// Create a copy of ObfuscatorSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObfuscatorSettingsCopyWith<ObfuscatorSettings> get copyWith => _$ObfuscatorSettingsCopyWithImpl<ObfuscatorSettings>(this as ObfuscatorSettings, _$identity);

  /// Serializes this ObfuscatorSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ObfuscatorSettings&&(identical(other.defaultStrategy, defaultStrategy) || other.defaultStrategy == defaultStrategy)&&(identical(other.obfuscateHighlightColor, obfuscateHighlightColor) || other.obfuscateHighlightColor == obfuscateHighlightColor)&&(identical(other.deobfuscateHighlightColor, deobfuscateHighlightColor) || other.deobfuscateHighlightColor == deobfuscateHighlightColor)&&(identical(other.unrecognizedAliasColor, unrecognizedAliasColor) || other.unrecognizedAliasColor == unrecognizedAliasColor)&&(identical(other.autoScanOnOpen, autoScanOnOpen) || other.autoScanOnOpen == autoScanOnOpen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultStrategy,obfuscateHighlightColor,deobfuscateHighlightColor,unrecognizedAliasColor,autoScanOnOpen);

@override
String toString() {
  return 'ObfuscatorSettings(defaultStrategy: $defaultStrategy, obfuscateHighlightColor: $obfuscateHighlightColor, deobfuscateHighlightColor: $deobfuscateHighlightColor, unrecognizedAliasColor: $unrecognizedAliasColor, autoScanOnOpen: $autoScanOnOpen)';
}


}

/// @nodoc
abstract mixin class $ObfuscatorSettingsCopyWith<$Res>  {
  factory $ObfuscatorSettingsCopyWith(ObfuscatorSettings value, $Res Function(ObfuscatorSettings) _then) = _$ObfuscatorSettingsCopyWithImpl;
@useResult
$Res call({
 SubstitutionStrategy defaultStrategy, String obfuscateHighlightColor, String deobfuscateHighlightColor, String unrecognizedAliasColor, bool autoScanOnOpen
});




}
/// @nodoc
class _$ObfuscatorSettingsCopyWithImpl<$Res>
    implements $ObfuscatorSettingsCopyWith<$Res> {
  _$ObfuscatorSettingsCopyWithImpl(this._self, this._then);

  final ObfuscatorSettings _self;
  final $Res Function(ObfuscatorSettings) _then;

/// Create a copy of ObfuscatorSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultStrategy = null,Object? obfuscateHighlightColor = null,Object? deobfuscateHighlightColor = null,Object? unrecognizedAliasColor = null,Object? autoScanOnOpen = null,}) {
  return _then(_self.copyWith(
defaultStrategy: null == defaultStrategy ? _self.defaultStrategy : defaultStrategy // ignore: cast_nullable_to_non_nullable
as SubstitutionStrategy,obfuscateHighlightColor: null == obfuscateHighlightColor ? _self.obfuscateHighlightColor : obfuscateHighlightColor // ignore: cast_nullable_to_non_nullable
as String,deobfuscateHighlightColor: null == deobfuscateHighlightColor ? _self.deobfuscateHighlightColor : deobfuscateHighlightColor // ignore: cast_nullable_to_non_nullable
as String,unrecognizedAliasColor: null == unrecognizedAliasColor ? _self.unrecognizedAliasColor : unrecognizedAliasColor // ignore: cast_nullable_to_non_nullable
as String,autoScanOnOpen: null == autoScanOnOpen ? _self.autoScanOnOpen : autoScanOnOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ObfuscatorSettings].
extension ObfuscatorSettingsPatterns on ObfuscatorSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ObfuscatorSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ObfuscatorSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ObfuscatorSettings value)  $default,){
final _that = this;
switch (_that) {
case _ObfuscatorSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ObfuscatorSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ObfuscatorSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SubstitutionStrategy defaultStrategy,  String obfuscateHighlightColor,  String deobfuscateHighlightColor,  String unrecognizedAliasColor,  bool autoScanOnOpen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ObfuscatorSettings() when $default != null:
return $default(_that.defaultStrategy,_that.obfuscateHighlightColor,_that.deobfuscateHighlightColor,_that.unrecognizedAliasColor,_that.autoScanOnOpen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SubstitutionStrategy defaultStrategy,  String obfuscateHighlightColor,  String deobfuscateHighlightColor,  String unrecognizedAliasColor,  bool autoScanOnOpen)  $default,) {final _that = this;
switch (_that) {
case _ObfuscatorSettings():
return $default(_that.defaultStrategy,_that.obfuscateHighlightColor,_that.deobfuscateHighlightColor,_that.unrecognizedAliasColor,_that.autoScanOnOpen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SubstitutionStrategy defaultStrategy,  String obfuscateHighlightColor,  String deobfuscateHighlightColor,  String unrecognizedAliasColor,  bool autoScanOnOpen)?  $default,) {final _that = this;
switch (_that) {
case _ObfuscatorSettings() when $default != null:
return $default(_that.defaultStrategy,_that.obfuscateHighlightColor,_that.deobfuscateHighlightColor,_that.unrecognizedAliasColor,_that.autoScanOnOpen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ObfuscatorSettings implements ObfuscatorSettings {
  const _ObfuscatorSettings({this.defaultStrategy = SubstitutionStrategy.semantic, this.obfuscateHighlightColor = '#FFF3E0', this.deobfuscateHighlightColor = '', this.unrecognizedAliasColor = '#FFF3E0', this.autoScanOnOpen = false});
  factory _ObfuscatorSettings.fromJson(Map<String, dynamic> json) => _$ObfuscatorSettingsFromJson(json);

@override@JsonKey() final  SubstitutionStrategy defaultStrategy;
@override@JsonKey() final  String obfuscateHighlightColor;
@override@JsonKey() final  String deobfuscateHighlightColor;
@override@JsonKey() final  String unrecognizedAliasColor;
@override@JsonKey() final  bool autoScanOnOpen;

/// Create a copy of ObfuscatorSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ObfuscatorSettingsCopyWith<_ObfuscatorSettings> get copyWith => __$ObfuscatorSettingsCopyWithImpl<_ObfuscatorSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObfuscatorSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ObfuscatorSettings&&(identical(other.defaultStrategy, defaultStrategy) || other.defaultStrategy == defaultStrategy)&&(identical(other.obfuscateHighlightColor, obfuscateHighlightColor) || other.obfuscateHighlightColor == obfuscateHighlightColor)&&(identical(other.deobfuscateHighlightColor, deobfuscateHighlightColor) || other.deobfuscateHighlightColor == deobfuscateHighlightColor)&&(identical(other.unrecognizedAliasColor, unrecognizedAliasColor) || other.unrecognizedAliasColor == unrecognizedAliasColor)&&(identical(other.autoScanOnOpen, autoScanOnOpen) || other.autoScanOnOpen == autoScanOnOpen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultStrategy,obfuscateHighlightColor,deobfuscateHighlightColor,unrecognizedAliasColor,autoScanOnOpen);

@override
String toString() {
  return 'ObfuscatorSettings(defaultStrategy: $defaultStrategy, obfuscateHighlightColor: $obfuscateHighlightColor, deobfuscateHighlightColor: $deobfuscateHighlightColor, unrecognizedAliasColor: $unrecognizedAliasColor, autoScanOnOpen: $autoScanOnOpen)';
}


}

/// @nodoc
abstract mixin class _$ObfuscatorSettingsCopyWith<$Res> implements $ObfuscatorSettingsCopyWith<$Res> {
  factory _$ObfuscatorSettingsCopyWith(_ObfuscatorSettings value, $Res Function(_ObfuscatorSettings) _then) = __$ObfuscatorSettingsCopyWithImpl;
@override @useResult
$Res call({
 SubstitutionStrategy defaultStrategy, String obfuscateHighlightColor, String deobfuscateHighlightColor, String unrecognizedAliasColor, bool autoScanOnOpen
});




}
/// @nodoc
class __$ObfuscatorSettingsCopyWithImpl<$Res>
    implements _$ObfuscatorSettingsCopyWith<$Res> {
  __$ObfuscatorSettingsCopyWithImpl(this._self, this._then);

  final _ObfuscatorSettings _self;
  final $Res Function(_ObfuscatorSettings) _then;

/// Create a copy of ObfuscatorSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultStrategy = null,Object? obfuscateHighlightColor = null,Object? deobfuscateHighlightColor = null,Object? unrecognizedAliasColor = null,Object? autoScanOnOpen = null,}) {
  return _then(_ObfuscatorSettings(
defaultStrategy: null == defaultStrategy ? _self.defaultStrategy : defaultStrategy // ignore: cast_nullable_to_non_nullable
as SubstitutionStrategy,obfuscateHighlightColor: null == obfuscateHighlightColor ? _self.obfuscateHighlightColor : obfuscateHighlightColor // ignore: cast_nullable_to_non_nullable
as String,deobfuscateHighlightColor: null == deobfuscateHighlightColor ? _self.deobfuscateHighlightColor : deobfuscateHighlightColor // ignore: cast_nullable_to_non_nullable
as String,unrecognizedAliasColor: null == unrecognizedAliasColor ? _self.unrecognizedAliasColor : unrecognizedAliasColor // ignore: cast_nullable_to_non_nullable
as String,autoScanOnOpen: null == autoScanOnOpen ? _self.autoScanOnOpen : autoScanOnOpen // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
