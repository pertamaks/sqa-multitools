// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'magic_8ball_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OracleSettings)
final oracleSettingsProvider = OracleSettingsProvider._();

final class OracleSettingsProvider
    extends $NotifierProvider<OracleSettings, OracleSettingsData> {
  OracleSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oracleSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oracleSettingsHash();

  @$internal
  @override
  OracleSettings create() => OracleSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OracleSettingsData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OracleSettingsData>(value),
    );
  }
}

String _$oracleSettingsHash() => r'36e12d479071593b6c050d87f594868e6e6b4cbf';

abstract class _$OracleSettings extends $Notifier<OracleSettingsData> {
  OracleSettingsData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OracleSettingsData, OracleSettingsData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OracleSettingsData, OracleSettingsData>,
              OracleSettingsData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(oracleResponses)
final oracleResponsesProvider = OracleResponsesProvider._();

final class OracleResponsesProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  OracleResponsesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oracleResponsesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oracleResponsesHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return oracleResponses(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$oracleResponsesHash() => r'9503c5af3999becb4778b06aba9f1a38bcf29ff6';
