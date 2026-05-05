// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curl_requester_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurlRequester)
final curlRequesterProvider = CurlRequesterProvider._();

final class CurlRequesterProvider
    extends $NotifierProvider<CurlRequester, CurlRequesterState> {
  CurlRequesterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'curlRequesterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$curlRequesterHash();

  @$internal
  @override
  CurlRequester create() => CurlRequester();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurlRequesterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurlRequesterState>(value),
    );
  }
}

String _$curlRequesterHash() => r'db1ff6bcae88ce64b249a0b83d208131cbd64183';

abstract class _$CurlRequester extends $Notifier<CurlRequesterState> {
  CurlRequesterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CurlRequesterState, CurlRequesterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CurlRequesterState, CurlRequesterState>,
              CurlRequesterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
