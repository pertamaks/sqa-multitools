// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obfuscator_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ObfuscatorSettings _$ObfuscatorSettingsFromJson(Map<String, dynamic> json) =>
    _ObfuscatorSettings(
      defaultStrategy:
          $enumDecodeNullable(
            _$SubstitutionStrategyEnumMap,
            json['defaultStrategy'],
          ) ??
          SubstitutionStrategy.semantic,
      obfuscateHighlightColor:
          json['obfuscateHighlightColor'] as String? ?? '#FFF3E0',
      deobfuscateHighlightColor:
          json['deobfuscateHighlightColor'] as String? ?? '',
      unrecognizedAliasColor:
          json['unrecognizedAliasColor'] as String? ?? '#FFF3E0',
      autoScanOnOpen: json['autoScanOnOpen'] as bool? ?? false,
    );

Map<String, dynamic> _$ObfuscatorSettingsToJson(
  _ObfuscatorSettings instance,
) => <String, dynamic>{
  'defaultStrategy': _$SubstitutionStrategyEnumMap[instance.defaultStrategy]!,
  'obfuscateHighlightColor': instance.obfuscateHighlightColor,
  'deobfuscateHighlightColor': instance.deobfuscateHighlightColor,
  'unrecognizedAliasColor': instance.unrecognizedAliasColor,
  'autoScanOnOpen': instance.autoScanOnOpen,
};

const _$SubstitutionStrategyEnumMap = {
  SubstitutionStrategy.semantic: 'semantic',
  SubstitutionStrategy.token: 'token',
  SubstitutionStrategy.codename: 'codename',
};
