// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TextEditor)
final textEditorProvider = TextEditorProvider._();

final class TextEditorProvider
    extends $NotifierProvider<TextEditor, TextEditorState> {
  TextEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textEditorHash();

  @$internal
  @override
  TextEditor create() => TextEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextEditorState>(value),
    );
  }
}

String _$textEditorHash() => r'875b0dba7e6a7dbd57052bf1e46ec4c663e0d53c';

abstract class _$TextEditor extends $Notifier<TextEditorState> {
  TextEditorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TextEditorState, TextEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TextEditorState, TextEditorState>,
              TextEditorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
