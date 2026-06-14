// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnnotatorNotifier)
final annotatorProvider = AnnotatorNotifierFamily._();

final class AnnotatorNotifierProvider
    extends $NotifierProvider<AnnotatorNotifier, AnnotatorState> {
  AnnotatorNotifierProvider._({
    required AnnotatorNotifierFamily super.from,
    required ({String filePath, String format}) super.argument,
  }) : super(
         retry: null,
         name: r'annotatorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$annotatorNotifierHash();

  @override
  String toString() {
    return r'annotatorProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  AnnotatorNotifier create() => AnnotatorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnotatorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnotatorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AnnotatorNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$annotatorNotifierHash() => r'521858bcc0c20e92b36606e6994a47c0c2164169';

final class AnnotatorNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          AnnotatorNotifier,
          AnnotatorState,
          AnnotatorState,
          AnnotatorState,
          ({String filePath, String format})
        > {
  AnnotatorNotifierFamily._()
    : super(
        retry: null,
        name: r'annotatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AnnotatorNotifierProvider call({
    required String filePath,
    required String format,
  }) => AnnotatorNotifierProvider._(
    argument: (filePath: filePath, format: format),
    from: this,
  );

  @override
  String toString() => r'annotatorProvider';
}

abstract class _$AnnotatorNotifier extends $Notifier<AnnotatorState> {
  late final _$args = ref.$arg as ({String filePath, String format});
  String get filePath => _$args.filePath;
  String get format => _$args.format;

  AnnotatorState build({required String filePath, required String format});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AnnotatorState, AnnotatorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnnotatorState, AnnotatorState>,
              AnnotatorState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(filePath: _$args.filePath, format: _$args.format),
    );
  }
}
