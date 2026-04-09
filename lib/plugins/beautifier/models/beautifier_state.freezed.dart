// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'beautifier_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BeautifierState {

 String get input; String get output; BeautifierLanguage get language; bool get autoFormat; bool get inputWrapText; bool get outputWrapText; bool get isLoading; int get indentWidth; String? get error;
/// Create a copy of BeautifierState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BeautifierStateCopyWith<BeautifierState> get copyWith => _$BeautifierStateCopyWithImpl<BeautifierState>(this as BeautifierState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BeautifierState&&(identical(other.input, input) || other.input == input)&&(identical(other.output, output) || other.output == output)&&(identical(other.language, language) || other.language == language)&&(identical(other.autoFormat, autoFormat) || other.autoFormat == autoFormat)&&(identical(other.inputWrapText, inputWrapText) || other.inputWrapText == inputWrapText)&&(identical(other.outputWrapText, outputWrapText) || other.outputWrapText == outputWrapText)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.indentWidth, indentWidth) || other.indentWidth == indentWidth)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,input,output,language,autoFormat,inputWrapText,outputWrapText,isLoading,indentWidth,error);

@override
String toString() {
  return 'BeautifierState(input: $input, output: $output, language: $language, autoFormat: $autoFormat, inputWrapText: $inputWrapText, outputWrapText: $outputWrapText, isLoading: $isLoading, indentWidth: $indentWidth, error: $error)';
}


}

/// @nodoc
abstract mixin class $BeautifierStateCopyWith<$Res>  {
  factory $BeautifierStateCopyWith(BeautifierState value, $Res Function(BeautifierState) _then) = _$BeautifierStateCopyWithImpl;
@useResult
$Res call({
 String input, String output, BeautifierLanguage language, bool autoFormat, bool inputWrapText, bool outputWrapText, bool isLoading, int indentWidth, String? error
});




}
/// @nodoc
class _$BeautifierStateCopyWithImpl<$Res>
    implements $BeautifierStateCopyWith<$Res> {
  _$BeautifierStateCopyWithImpl(this._self, this._then);

  final BeautifierState _self;
  final $Res Function(BeautifierState) _then;

/// Create a copy of BeautifierState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? input = null,Object? output = null,Object? language = null,Object? autoFormat = null,Object? inputWrapText = null,Object? outputWrapText = null,Object? isLoading = null,Object? indentWidth = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as String,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as BeautifierLanguage,autoFormat: null == autoFormat ? _self.autoFormat : autoFormat // ignore: cast_nullable_to_non_nullable
as bool,inputWrapText: null == inputWrapText ? _self.inputWrapText : inputWrapText // ignore: cast_nullable_to_non_nullable
as bool,outputWrapText: null == outputWrapText ? _self.outputWrapText : outputWrapText // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,indentWidth: null == indentWidth ? _self.indentWidth : indentWidth // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BeautifierState].
extension BeautifierStatePatterns on BeautifierState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BeautifierState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BeautifierState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BeautifierState value)  $default,){
final _that = this;
switch (_that) {
case _BeautifierState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BeautifierState value)?  $default,){
final _that = this;
switch (_that) {
case _BeautifierState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String input,  String output,  BeautifierLanguage language,  bool autoFormat,  bool inputWrapText,  bool outputWrapText,  bool isLoading,  int indentWidth,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BeautifierState() when $default != null:
return $default(_that.input,_that.output,_that.language,_that.autoFormat,_that.inputWrapText,_that.outputWrapText,_that.isLoading,_that.indentWidth,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String input,  String output,  BeautifierLanguage language,  bool autoFormat,  bool inputWrapText,  bool outputWrapText,  bool isLoading,  int indentWidth,  String? error)  $default,) {final _that = this;
switch (_that) {
case _BeautifierState():
return $default(_that.input,_that.output,_that.language,_that.autoFormat,_that.inputWrapText,_that.outputWrapText,_that.isLoading,_that.indentWidth,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String input,  String output,  BeautifierLanguage language,  bool autoFormat,  bool inputWrapText,  bool outputWrapText,  bool isLoading,  int indentWidth,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _BeautifierState() when $default != null:
return $default(_that.input,_that.output,_that.language,_that.autoFormat,_that.inputWrapText,_that.outputWrapText,_that.isLoading,_that.indentWidth,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _BeautifierState implements BeautifierState {
  const _BeautifierState({this.input = '', this.output = '', this.language = BeautifierLanguage.json, this.autoFormat = true, this.inputWrapText = true, this.outputWrapText = true, this.isLoading = false, this.indentWidth = 2, this.error});
  

@override@JsonKey() final  String input;
@override@JsonKey() final  String output;
@override@JsonKey() final  BeautifierLanguage language;
@override@JsonKey() final  bool autoFormat;
@override@JsonKey() final  bool inputWrapText;
@override@JsonKey() final  bool outputWrapText;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  int indentWidth;
@override final  String? error;

/// Create a copy of BeautifierState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BeautifierStateCopyWith<_BeautifierState> get copyWith => __$BeautifierStateCopyWithImpl<_BeautifierState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BeautifierState&&(identical(other.input, input) || other.input == input)&&(identical(other.output, output) || other.output == output)&&(identical(other.language, language) || other.language == language)&&(identical(other.autoFormat, autoFormat) || other.autoFormat == autoFormat)&&(identical(other.inputWrapText, inputWrapText) || other.inputWrapText == inputWrapText)&&(identical(other.outputWrapText, outputWrapText) || other.outputWrapText == outputWrapText)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.indentWidth, indentWidth) || other.indentWidth == indentWidth)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,input,output,language,autoFormat,inputWrapText,outputWrapText,isLoading,indentWidth,error);

@override
String toString() {
  return 'BeautifierState(input: $input, output: $output, language: $language, autoFormat: $autoFormat, inputWrapText: $inputWrapText, outputWrapText: $outputWrapText, isLoading: $isLoading, indentWidth: $indentWidth, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BeautifierStateCopyWith<$Res> implements $BeautifierStateCopyWith<$Res> {
  factory _$BeautifierStateCopyWith(_BeautifierState value, $Res Function(_BeautifierState) _then) = __$BeautifierStateCopyWithImpl;
@override @useResult
$Res call({
 String input, String output, BeautifierLanguage language, bool autoFormat, bool inputWrapText, bool outputWrapText, bool isLoading, int indentWidth, String? error
});




}
/// @nodoc
class __$BeautifierStateCopyWithImpl<$Res>
    implements _$BeautifierStateCopyWith<$Res> {
  __$BeautifierStateCopyWithImpl(this._self, this._then);

  final _BeautifierState _self;
  final $Res Function(_BeautifierState) _then;

/// Create a copy of BeautifierState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? input = null,Object? output = null,Object? language = null,Object? autoFormat = null,Object? inputWrapText = null,Object? outputWrapText = null,Object? isLoading = null,Object? indentWidth = null,Object? error = freezed,}) {
  return _then(_BeautifierState(
input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as String,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as BeautifierLanguage,autoFormat: null == autoFormat ? _self.autoFormat : autoFormat // ignore: cast_nullable_to_non_nullable
as bool,inputWrapText: null == inputWrapText ? _self.inputWrapText : inputWrapText // ignore: cast_nullable_to_non_nullable
as bool,outputWrapText: null == outputWrapText ? _self.outputWrapText : outputWrapText // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,indentWidth: null == indentWidth ? _self.indentWidth : indentWidth // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
