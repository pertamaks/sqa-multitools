// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'omniconverter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OmniConverterState {

 ConversionCategory get category; EncodingSubMode get encodingMode; FormatSubMode get formatMode; TextCaseSubMode get textCaseMode; ConversionDirection get direction; String get input; String get output; bool get wrapText; String? get errorMessage; bool get isProcessing; List<HashResult> get hashes; JwtInfo? get jwtInfo;
/// Create a copy of OmniConverterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OmniConverterStateCopyWith<OmniConverterState> get copyWith => _$OmniConverterStateCopyWithImpl<OmniConverterState>(this as OmniConverterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OmniConverterState&&(identical(other.category, category) || other.category == category)&&(identical(other.encodingMode, encodingMode) || other.encodingMode == encodingMode)&&(identical(other.formatMode, formatMode) || other.formatMode == formatMode)&&(identical(other.textCaseMode, textCaseMode) || other.textCaseMode == textCaseMode)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.input, input) || other.input == input)&&(identical(other.output, output) || other.output == output)&&(identical(other.wrapText, wrapText) || other.wrapText == wrapText)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&const DeepCollectionEquality().equals(other.hashes, hashes)&&(identical(other.jwtInfo, jwtInfo) || other.jwtInfo == jwtInfo));
}


@override
int get hashCode => Object.hash(runtimeType,category,encodingMode,formatMode,textCaseMode,direction,input,output,wrapText,errorMessage,isProcessing,const DeepCollectionEquality().hash(hashes),jwtInfo);

@override
String toString() {
  return 'OmniConverterState(category: $category, encodingMode: $encodingMode, formatMode: $formatMode, textCaseMode: $textCaseMode, direction: $direction, input: $input, output: $output, wrapText: $wrapText, errorMessage: $errorMessage, isProcessing: $isProcessing, hashes: $hashes, jwtInfo: $jwtInfo)';
}


}

/// @nodoc
abstract mixin class $OmniConverterStateCopyWith<$Res>  {
  factory $OmniConverterStateCopyWith(OmniConverterState value, $Res Function(OmniConverterState) _then) = _$OmniConverterStateCopyWithImpl;
@useResult
$Res call({
 ConversionCategory category, EncodingSubMode encodingMode, FormatSubMode formatMode, TextCaseSubMode textCaseMode, ConversionDirection direction, String input, String output, bool wrapText, String? errorMessage, bool isProcessing, List<HashResult> hashes, JwtInfo? jwtInfo
});




}
/// @nodoc
class _$OmniConverterStateCopyWithImpl<$Res>
    implements $OmniConverterStateCopyWith<$Res> {
  _$OmniConverterStateCopyWithImpl(this._self, this._then);

  final OmniConverterState _self;
  final $Res Function(OmniConverterState) _then;

/// Create a copy of OmniConverterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? encodingMode = null,Object? formatMode = null,Object? textCaseMode = null,Object? direction = null,Object? input = null,Object? output = null,Object? wrapText = null,Object? errorMessage = freezed,Object? isProcessing = null,Object? hashes = null,Object? jwtInfo = freezed,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ConversionCategory,encodingMode: null == encodingMode ? _self.encodingMode : encodingMode // ignore: cast_nullable_to_non_nullable
as EncodingSubMode,formatMode: null == formatMode ? _self.formatMode : formatMode // ignore: cast_nullable_to_non_nullable
as FormatSubMode,textCaseMode: null == textCaseMode ? _self.textCaseMode : textCaseMode // ignore: cast_nullable_to_non_nullable
as TextCaseSubMode,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as ConversionDirection,input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as String,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String,wrapText: null == wrapText ? _self.wrapText : wrapText // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,hashes: null == hashes ? _self.hashes : hashes // ignore: cast_nullable_to_non_nullable
as List<HashResult>,jwtInfo: freezed == jwtInfo ? _self.jwtInfo : jwtInfo // ignore: cast_nullable_to_non_nullable
as JwtInfo?,
  ));
}

}


/// Adds pattern-matching-related methods to [OmniConverterState].
extension OmniConverterStatePatterns on OmniConverterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OmniConverterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OmniConverterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OmniConverterState value)  $default,){
final _that = this;
switch (_that) {
case _OmniConverterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OmniConverterState value)?  $default,){
final _that = this;
switch (_that) {
case _OmniConverterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConversionCategory category,  EncodingSubMode encodingMode,  FormatSubMode formatMode,  TextCaseSubMode textCaseMode,  ConversionDirection direction,  String input,  String output,  bool wrapText,  String? errorMessage,  bool isProcessing,  List<HashResult> hashes,  JwtInfo? jwtInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OmniConverterState() when $default != null:
return $default(_that.category,_that.encodingMode,_that.formatMode,_that.textCaseMode,_that.direction,_that.input,_that.output,_that.wrapText,_that.errorMessage,_that.isProcessing,_that.hashes,_that.jwtInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConversionCategory category,  EncodingSubMode encodingMode,  FormatSubMode formatMode,  TextCaseSubMode textCaseMode,  ConversionDirection direction,  String input,  String output,  bool wrapText,  String? errorMessage,  bool isProcessing,  List<HashResult> hashes,  JwtInfo? jwtInfo)  $default,) {final _that = this;
switch (_that) {
case _OmniConverterState():
return $default(_that.category,_that.encodingMode,_that.formatMode,_that.textCaseMode,_that.direction,_that.input,_that.output,_that.wrapText,_that.errorMessage,_that.isProcessing,_that.hashes,_that.jwtInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConversionCategory category,  EncodingSubMode encodingMode,  FormatSubMode formatMode,  TextCaseSubMode textCaseMode,  ConversionDirection direction,  String input,  String output,  bool wrapText,  String? errorMessage,  bool isProcessing,  List<HashResult> hashes,  JwtInfo? jwtInfo)?  $default,) {final _that = this;
switch (_that) {
case _OmniConverterState() when $default != null:
return $default(_that.category,_that.encodingMode,_that.formatMode,_that.textCaseMode,_that.direction,_that.input,_that.output,_that.wrapText,_that.errorMessage,_that.isProcessing,_that.hashes,_that.jwtInfo);case _:
  return null;

}
}

}

/// @nodoc


class _OmniConverterState implements OmniConverterState {
  const _OmniConverterState({this.category = ConversionCategory.encoding, this.encodingMode = EncodingSubMode.base64, this.formatMode = FormatSubMode.jsonToYaml, this.textCaseMode = TextCaseSubMode.camelCase, this.direction = ConversionDirection.forward, this.input = '', this.output = '', this.wrapText = true, this.errorMessage, this.isProcessing = false, final  List<HashResult> hashes = const [], this.jwtInfo}): _hashes = hashes;
  

@override@JsonKey() final  ConversionCategory category;
@override@JsonKey() final  EncodingSubMode encodingMode;
@override@JsonKey() final  FormatSubMode formatMode;
@override@JsonKey() final  TextCaseSubMode textCaseMode;
@override@JsonKey() final  ConversionDirection direction;
@override@JsonKey() final  String input;
@override@JsonKey() final  String output;
@override@JsonKey() final  bool wrapText;
@override final  String? errorMessage;
@override@JsonKey() final  bool isProcessing;
 final  List<HashResult> _hashes;
@override@JsonKey() List<HashResult> get hashes {
  if (_hashes is EqualUnmodifiableListView) return _hashes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hashes);
}

@override final  JwtInfo? jwtInfo;

/// Create a copy of OmniConverterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OmniConverterStateCopyWith<_OmniConverterState> get copyWith => __$OmniConverterStateCopyWithImpl<_OmniConverterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OmniConverterState&&(identical(other.category, category) || other.category == category)&&(identical(other.encodingMode, encodingMode) || other.encodingMode == encodingMode)&&(identical(other.formatMode, formatMode) || other.formatMode == formatMode)&&(identical(other.textCaseMode, textCaseMode) || other.textCaseMode == textCaseMode)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.input, input) || other.input == input)&&(identical(other.output, output) || other.output == output)&&(identical(other.wrapText, wrapText) || other.wrapText == wrapText)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&const DeepCollectionEquality().equals(other._hashes, _hashes)&&(identical(other.jwtInfo, jwtInfo) || other.jwtInfo == jwtInfo));
}


@override
int get hashCode => Object.hash(runtimeType,category,encodingMode,formatMode,textCaseMode,direction,input,output,wrapText,errorMessage,isProcessing,const DeepCollectionEquality().hash(_hashes),jwtInfo);

@override
String toString() {
  return 'OmniConverterState(category: $category, encodingMode: $encodingMode, formatMode: $formatMode, textCaseMode: $textCaseMode, direction: $direction, input: $input, output: $output, wrapText: $wrapText, errorMessage: $errorMessage, isProcessing: $isProcessing, hashes: $hashes, jwtInfo: $jwtInfo)';
}


}

/// @nodoc
abstract mixin class _$OmniConverterStateCopyWith<$Res> implements $OmniConverterStateCopyWith<$Res> {
  factory _$OmniConverterStateCopyWith(_OmniConverterState value, $Res Function(_OmniConverterState) _then) = __$OmniConverterStateCopyWithImpl;
@override @useResult
$Res call({
 ConversionCategory category, EncodingSubMode encodingMode, FormatSubMode formatMode, TextCaseSubMode textCaseMode, ConversionDirection direction, String input, String output, bool wrapText, String? errorMessage, bool isProcessing, List<HashResult> hashes, JwtInfo? jwtInfo
});




}
/// @nodoc
class __$OmniConverterStateCopyWithImpl<$Res>
    implements _$OmniConverterStateCopyWith<$Res> {
  __$OmniConverterStateCopyWithImpl(this._self, this._then);

  final _OmniConverterState _self;
  final $Res Function(_OmniConverterState) _then;

/// Create a copy of OmniConverterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? encodingMode = null,Object? formatMode = null,Object? textCaseMode = null,Object? direction = null,Object? input = null,Object? output = null,Object? wrapText = null,Object? errorMessage = freezed,Object? isProcessing = null,Object? hashes = null,Object? jwtInfo = freezed,}) {
  return _then(_OmniConverterState(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ConversionCategory,encodingMode: null == encodingMode ? _self.encodingMode : encodingMode // ignore: cast_nullable_to_non_nullable
as EncodingSubMode,formatMode: null == formatMode ? _self.formatMode : formatMode // ignore: cast_nullable_to_non_nullable
as FormatSubMode,textCaseMode: null == textCaseMode ? _self.textCaseMode : textCaseMode // ignore: cast_nullable_to_non_nullable
as TextCaseSubMode,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as ConversionDirection,input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as String,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String,wrapText: null == wrapText ? _self.wrapText : wrapText // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,hashes: null == hashes ? _self._hashes : hashes // ignore: cast_nullable_to_non_nullable
as List<HashResult>,jwtInfo: freezed == jwtInfo ? _self.jwtInfo : jwtInfo // ignore: cast_nullable_to_non_nullable
as JwtInfo?,
  ));
}


}

// dart format on
