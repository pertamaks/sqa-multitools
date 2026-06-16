import 'package:freezed_annotation/freezed_annotation.dart';

part 'form_data_item.freezed.dart';
part 'form_data_item.g.dart';

@freezed
abstract class FormDataItem with _$FormDataItem {
  const factory FormDataItem({
    required String id,
    @Default('') String key,
    @Default('') String value,
    String? filePath,
    @Default(false) bool isFile,
    @Default(true) bool isActive,
  }) = _FormDataItem;

  factory FormDataItem.fromJson(Map<String, dynamic> json) =>
      _$FormDataItemFromJson(json);
}
