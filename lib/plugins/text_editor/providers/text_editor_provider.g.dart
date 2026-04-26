// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(filteredDocuments)
final filteredDocumentsProvider = FilteredDocumentsProvider._();

final class FilteredDocumentsProvider
    extends
        $FunctionalProvider<
          List<TextDocument>,
          List<TextDocument>,
          List<TextDocument>
        >
    with $Provider<List<TextDocument>> {
  FilteredDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredDocumentsHash();

  @$internal
  @override
  $ProviderElement<List<TextDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TextDocument> create(Ref ref) {
    return filteredDocuments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TextDocument> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TextDocument>>(value),
    );
  }
}

String _$filteredDocumentsHash() => r'696dcd53ddccdf919ccc9bb842bf64c7ba242fb1';

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

String _$textEditorHash() => r'e8e9d8d26c2a80b993ec244634632007417066ee';

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
