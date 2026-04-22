// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'md_editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MdEditor)
final mdEditorProvider = MdEditorProvider._();

final class MdEditorProvider
    extends $NotifierProvider<MdEditor, MdEditorState> {
  MdEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mdEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mdEditorHash();

  @$internal
  @override
  MdEditor create() => MdEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MdEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MdEditorState>(value),
    );
  }
}

String _$mdEditorHash() => r'cefaaf40659600d16a96bac038b9f24fb99c8d5b';

abstract class _$MdEditor extends $Notifier<MdEditorState> {
  MdEditorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MdEditorState, MdEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MdEditorState, MdEditorState>,
              MdEditorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
