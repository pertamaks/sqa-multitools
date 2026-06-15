// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SwaggerNotifier)
final swaggerProvider = SwaggerNotifierProvider._();

final class SwaggerNotifierProvider
    extends $NotifierProvider<SwaggerNotifier, SwaggerState> {
  SwaggerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'swaggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$swaggerNotifierHash();

  @$internal
  @override
  SwaggerNotifier create() => SwaggerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SwaggerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SwaggerState>(value),
    );
  }
}

String _$swaggerNotifierHash() => r'dc79ec2a7ff0e4e37e3b7ab0251ed0893ddfb517';

abstract class _$SwaggerNotifier extends $Notifier<SwaggerState> {
  SwaggerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SwaggerState, SwaggerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SwaggerState, SwaggerState>,
              SwaggerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
