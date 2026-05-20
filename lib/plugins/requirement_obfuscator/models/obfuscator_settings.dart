import 'package:freezed_annotation/freezed_annotation.dart';
import 'obfuscator_workspace.dart';

part 'obfuscator_settings.freezed.dart';
part 'obfuscator_settings.g.dart';

@freezed
abstract class ObfuscatorSettings with _$ObfuscatorSettings {
  const factory ObfuscatorSettings({
    @Default(SubstitutionStrategy.semantic)
    SubstitutionStrategy defaultStrategy,
    @Default('#FFF3E0') String obfuscateHighlightColor,
    @Default('') String deobfuscateHighlightColor,
    @Default('#FFF3E0') String unrecognizedAliasColor,
    @Default(false) bool autoScanOnOpen,
  }) = _ObfuscatorSettings;

  factory ObfuscatorSettings.fromJson(Map<String, dynamic> json) =>
      _$ObfuscatorSettingsFromJson(json);
}
