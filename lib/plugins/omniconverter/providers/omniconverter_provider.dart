import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/conversion_types.dart';
import '../models/omniconverter_state.dart';
import '../services/encoding_service.dart';
import '../services/format_service.dart';
import '../services/jwt_service.dart';
import '../services/hash_service.dart';
import '../services/text_case_service.dart';

part 'omniconverter_provider.g.dart';

@Riverpod(keepAlive: true)
class OmniConverterNotifier extends _$OmniConverterNotifier {
  final EncodingService _encodingService = const EncodingService();
  final FormatService _formatService = const FormatService();
  final JwtService _jwtService = const JwtService();
  final HashService _hashService = const HashService();
  final TextCaseService _textCaseService = const TextCaseService();

  Timer? _debounceTimer;

  @override
  OmniConverterState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return const OmniConverterState();
  }


  void setCategory(ConversionCategory category) {
    if (state.category == category) return;
    state = state.copyWith(
      category: category,
      errorMessage: null,
    );
    _processConversion(state.input);
  }

  void setEncodingMode(EncodingSubMode mode) {
    state = state.copyWith(encodingMode: mode, errorMessage: null);
    _processConversion(state.input);
  }

  void setFormatMode(FormatSubMode mode) {
    state = state.copyWith(formatMode: mode, errorMessage: null);
    _processConversion(state.input);
  }

  void setTextCaseMode(TextCaseSubMode mode) {
    state = state.copyWith(textCaseMode: mode, errorMessage: null);
    _processConversion(state.input);
  }

  void setDirection(ConversionDirection direction) {
    if (state.direction == direction) return;
    state = state.copyWith(direction: direction, errorMessage: null);
    _processConversion(state.input);
  }

  void toggleDirection() {
    final next = state.direction == ConversionDirection.forward
        ? ConversionDirection.reverse
        : ConversionDirection.forward;
    setDirection(next);
  }

  void swapInputOutput() {
    if (state.output.isEmpty && state.input.isEmpty) return;
    final oldOutput = state.output;
    final nextDirection = state.direction == ConversionDirection.forward
        ? ConversionDirection.reverse
        : ConversionDirection.forward;

    state = state.copyWith(
      input: oldOutput,
      direction: nextDirection,
      errorMessage: null,
    );
    _processConversion(oldOutput);
  }

  void updateInput(String input) {
    state = state.copyWith(input: input);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      _processConversion(input);
    });
  }

  void setWrapText(bool wrap) {
    state = state.copyWith(wrapText: wrap);
  }

  void convert() {
    _debounceTimer?.cancel();
    _processConversion(state.input);
  }

  void clear() {
    _debounceTimer?.cancel();
    state = state.copyWith(
      input: '',
      output: '',
      errorMessage: null,
      hashes: const [],
      jwtInfo: null,
    );
  }


  void _processConversion(String input) {
    if (input.trim().isEmpty) {
      state = state.copyWith(
        output: '',
        errorMessage: null,
        hashes: const [],
        jwtInfo: null,
      );
      return;
    }

    try {
      switch (state.category) {
        case ConversionCategory.encoding:
          _processEncoding(input);
          break;
        case ConversionCategory.format:
          _processFormat(input);
          break;
        case ConversionCategory.jwt:
          _processJwt(input);
          break;
        case ConversionCategory.hash:
          _processHash(input);
          break;
        case ConversionCategory.textCase:
          _processTextCase(input);
          break;
      }
    } catch (e) {
      state = state.copyWith(
        output: '',
        errorMessage: e.toString().replaceFirst(RegExp(r'^[A-Za-z]+Exception: '), ''),
      );
    }
  }

  void _processEncoding(String input) {
    final isForward = state.direction == ConversionDirection.forward;
    String result;

    switch (state.encodingMode) {
      case EncodingSubMode.base64:
        result = isForward
            ? _encodingService.encodeBase64(input)
            : _encodingService.decodeBase64(input);
        break;
      case EncodingSubMode.url:
        result = isForward
            ? _encodingService.encodeUrl(input)
            : _encodingService.decodeUrl(input);
        break;
      case EncodingSubMode.html:
        result = isForward
            ? _encodingService.encodeHtml(input)
            : _encodingService.decodeHtml(input);
        break;
      case EncodingSubMode.hex:
        result = isForward
            ? _encodingService.encodeHex(input)
            : _encodingService.decodeHex(input);
        break;
      case EncodingSubMode.binary:
        result = isForward
            ? _encodingService.encodeBinary(input)
            : _encodingService.decodeBinary(input);
        break;
    }

    state = state.copyWith(output: result, errorMessage: null);
  }

  void _processFormat(String input) {
    String result;
    switch (state.formatMode) {
      case FormatSubMode.jsonToYaml:
        result = _formatService.jsonToYaml(input);
        break;
      case FormatSubMode.yamlToJson:
        result = _formatService.yamlToJson(input);
        break;
      case FormatSubMode.jsonToXml:
        result = _formatService.jsonToXml(input);
        break;
      case FormatSubMode.xmlToJson:
        result = _formatService.xmlToJson(input);
        break;
    }
    state = state.copyWith(output: result, errorMessage: null);
  }

  void _processJwt(String input) {
    final jwt = _jwtService.decode(input);
    final formattedPayload = _jwtService.formatMap(jwt.payload);
    state = state.copyWith(
      output: formattedPayload,
      jwtInfo: jwt,
      errorMessage: null,
    );
  }

  void _processHash(String input) {
    final hashes = _hashService.computeAll(input);
    final sha256 = hashes.firstWhere((h) => h.algorithm == 'SHA-256').value;
    state = state.copyWith(
      output: sha256,
      hashes: hashes,
      errorMessage: null,
    );
  }

  void _processTextCase(String input) {
    String result;
    switch (state.textCaseMode) {
      case TextCaseSubMode.camelCase:
        result = _textCaseService.toCamelCase(input);
        break;
      case TextCaseSubMode.pascalCase:
        result = _textCaseService.toPascalCase(input);
        break;
      case TextCaseSubMode.snakeCase:
        result = _textCaseService.toSnakeCase(input);
        break;
      case TextCaseSubMode.kebabCase:
        result = _textCaseService.toKebabCase(input);
        break;
      case TextCaseSubMode.constantCase:
        result = _textCaseService.toConstantCase(input);
        break;
      case TextCaseSubMode.titleCase:
        result = _textCaseService.toTitleCase(input);
        break;
      case TextCaseSubMode.cleanDuplicates:
        result = _textCaseService.cleanDuplicateLines(input);
        break;
      case TextCaseSubMode.sortLines:
        result = _textCaseService.sortLines(input);
        break;
      case TextCaseSubMode.trimLines:
        result = _textCaseService.trimLines(input);
        break;
    }
    state = state.copyWith(output: result, errorMessage: null);
  }
}
