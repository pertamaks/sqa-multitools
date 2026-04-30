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
