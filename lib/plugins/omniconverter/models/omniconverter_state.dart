import 'package:freezed_annotation/freezed_annotation.dart';
import 'conversion_types.dart';
import '../services/hash_service.dart';
import '../services/jwt_service.dart';

part 'omniconverter_state.freezed.dart';

@freezed
abstract class OmniConverterState with _$OmniConverterState {
  const factory OmniConverterState({
    @Default(ConversionCategory.encoding) ConversionCategory category,
    @Default(EncodingSubMode.base64) EncodingSubMode encodingMode,
    @Default(FormatSubMode.jsonToYaml) FormatSubMode formatMode,
    @Default(TextCaseSubMode.camelCase) TextCaseSubMode textCaseMode,
    @Default(ConversionDirection.forward) ConversionDirection direction,
    @Default('') String input,
    @Default('') String output,
    @Default(true) bool wrapText,
    String? errorMessage,
    @Default(false) bool isProcessing,
    @Default([]) List<HashResult> hashes,
    JwtInfo? jwtInfo,
  }) = _OmniConverterState;
}

