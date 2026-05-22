import 'package:freezed_annotation/freezed_annotation.dart';

part 'obfuscator_workspace.freezed.dart';
part 'obfuscator_workspace.g.dart';

enum SubstitutionStrategy { semantic, token, codename }

@freezed
abstract class ObfuscatorWorkspace with _$ObfuscatorWorkspace {
  const factory ObfuscatorWorkspace({
    required String id,
    required String name,
    required DateTime createdAt,
    @Default(SubstitutionStrategy.semantic) SubstitutionStrategy strategy,
    @Default(0) int dictionarySize,
    @Default(0) int totalProcessed,
  }) = _ObfuscatorWorkspace;

  factory ObfuscatorWorkspace.fromJson(Map<String, dynamic> json) =>
      _$ObfuscatorWorkspaceFromJson(json);
}
