// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TextGenerator)
final textGeneratorProvider = TextGeneratorProvider._();

final class TextGeneratorProvider
    extends $NotifierProvider<TextGenerator, TextState> {
  TextGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textGeneratorHash();

  @$internal
  @override
  TextGenerator create() => TextGenerator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextState>(value),
    );
  }
}

String _$textGeneratorHash() => r'b9a58f8d9ca6b92c19615f11c877e21047684576';

abstract class _$TextGenerator extends $Notifier<TextState> {
  TextState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TextState, TextState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TextState, TextState>,
              TextState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
