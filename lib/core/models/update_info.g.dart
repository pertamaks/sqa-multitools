// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateInfo _$UpdateInfoFromJson(Map<String, dynamic> json) => _UpdateInfo(
  version: json['version'] as String,
  downloadUrl: json['downloadUrl'] as String,
  releaseNotes: json['releaseNotes'] as String,
  isCritical: json['isCritical'] as bool? ?? false,
  releaseDate: json['releaseDate'] == null
      ? null
      : DateTime.parse(json['releaseDate'] as String),
);

Map<String, dynamic> _$UpdateInfoToJson(_UpdateInfo instance) =>
    <String, dynamic>{
      'version': instance.version,
      'downloadUrl': instance.downloadUrl,
      'releaseNotes': instance.releaseNotes,
      'isCritical': instance.isCritical,
      'releaseDate': instance.releaseDate?.toIso8601String(),
    };
