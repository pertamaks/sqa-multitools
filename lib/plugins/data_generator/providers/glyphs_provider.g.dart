// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glyphs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GlyphsGenerator)
final glyphsGeneratorProvider = GlyphsGeneratorProvider._();

final class GlyphsGeneratorProvider
    extends $NotifierProvider<GlyphsGenerator, GlyphsState> {
  GlyphsGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'glyphsGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$glyphsGeneratorHash();

  @$internal
  @override
  GlyphsGenerator create() => GlyphsGenerator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlyphsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlyphsState>(value),
    );
  }
}

String _$glyphsGeneratorHash() => r'8ffcdf8cb12934d6d074f4a97a6bb0027252b333';

abstract class _$GlyphsGenerator extends $Notifier<GlyphsState> {
  GlyphsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GlyphsState, GlyphsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GlyphsState, GlyphsState>,
              GlyphsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
