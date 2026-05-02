// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cheatsheet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cheatsheetRaw)
final cheatsheetRawProvider = CheatsheetRawProvider._();

final class CheatsheetRawProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  CheatsheetRawProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cheatsheetRawProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cheatsheetRawHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return cheatsheetRaw(ref);
  }
}

String _$cheatsheetRawHash() => r'9bb8f15998a5f74c1c9bb8e37f16f1daea928da4';

@ProviderFor(cheatsheetData)
final cheatsheetDataProvider = CheatsheetDataProvider._();

final class CheatsheetDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CheatsheetCategory>>,
          List<CheatsheetCategory>,
          FutureOr<List<CheatsheetCategory>>
        >
    with
        $FutureModifier<List<CheatsheetCategory>>,
        $FutureProvider<List<CheatsheetCategory>> {
  CheatsheetDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cheatsheetDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cheatsheetDataHash();

  @$internal
  @override
  $FutureProviderElement<List<CheatsheetCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CheatsheetCategory>> create(Ref ref) {
    return cheatsheetData(ref);
  }
}

String _$cheatsheetDataHash() => r'2e23dfb283100b5dfbe356ae3154f21d6a8e7e8a';

@ProviderFor(CheatsheetSearch)
final cheatsheetSearchProvider = CheatsheetSearchProvider._();

final class CheatsheetSearchProvider
    extends $NotifierProvider<CheatsheetSearch, String> {
  CheatsheetSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cheatsheetSearchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cheatsheetSearchHash();

  @$internal
  @override
  CheatsheetSearch create() => CheatsheetSearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$cheatsheetSearchHash() => r'bfc6a7844d1a58e4f76c1b706cdd47e476cc5420';

abstract class _$CheatsheetSearch extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
