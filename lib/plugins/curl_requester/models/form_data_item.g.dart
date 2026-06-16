// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_data_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FormDataItem _$FormDataItemFromJson(Map<String, dynamic> json) =>
    _FormDataItem(
      id: json['id'] as String,
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      filePath: json['filePath'] as String?,
      isFile: json['isFile'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$FormDataItemToJson(_FormDataItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'key': instance.key,
      'value': instance.value,
      'filePath': instance.filePath,
      'isFile': instance.isFile,
      'isActive': instance.isActive,
    };
