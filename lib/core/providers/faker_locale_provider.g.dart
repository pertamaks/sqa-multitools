// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faker_locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FakerLocale)
final fakerLocaleProvider = FakerLocaleProvider._();

final class FakerLocaleProvider
    extends $NotifierProvider<FakerLocale, FakerLocaleType> {
  FakerLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fakerLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fakerLocaleHash();

  @$internal
  @override
  FakerLocale create() => FakerLocale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakerLocaleType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakerLocaleType>(value),
    );
  }
}

String _$fakerLocaleHash() => r'75b925cb364713e753641869da674dbc3c8f7263';

abstract class _$FakerLocale extends $Notifier<FakerLocaleType> {
  FakerLocaleType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FakerLocaleType, FakerLocaleType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FakerLocaleType, FakerLocaleType>,
              FakerLocaleType,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
