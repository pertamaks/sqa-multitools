// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_picker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ColorPickerNotifier)
final colorPickerProvider = ColorPickerNotifierProvider._();

final class ColorPickerNotifierProvider
    extends $NotifierProvider<ColorPickerNotifier, ColorPickerState> {
  ColorPickerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorPickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorPickerNotifierHash();

  @$internal
  @override
  ColorPickerNotifier create() => ColorPickerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ColorPickerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ColorPickerState>(value),
    );
  }
}

String _$colorPickerNotifierHash() =>
    r'10104186a3423b3df51fb7ce3c1e2c9c65944f03';

abstract class _$ColorPickerNotifier extends $Notifier<ColorPickerState> {
  ColorPickerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ColorPickerState, ColorPickerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ColorPickerState, ColorPickerState>,
              ColorPickerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
