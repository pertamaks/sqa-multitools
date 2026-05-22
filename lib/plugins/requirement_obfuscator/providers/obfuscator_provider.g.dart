// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obfuscator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(filteredObfuscatorDocuments)
final filteredObfuscatorDocumentsProvider =
    FilteredObfuscatorDocumentsProvider._();

final class FilteredObfuscatorDocumentsProvider
    extends
        $FunctionalProvider<
          List<ImportedDocument>,
          List<ImportedDocument>,
          List<ImportedDocument>
        >
    with $Provider<List<ImportedDocument>> {
  FilteredObfuscatorDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredObfuscatorDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredObfuscatorDocumentsHash();

  @$internal
  @override
  $ProviderElement<List<ImportedDocument>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ImportedDocument> create(Ref ref) {
    return filteredObfuscatorDocuments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ImportedDocument> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ImportedDocument>>(value),
    );
  }
}

String _$filteredObfuscatorDocumentsHash() =>
    r'be37d6ea03d12a849887a310789c28b5a3b214e4';

@ProviderFor(filteredObfuscatorDictionary)
final filteredObfuscatorDictionaryProvider =
    FilteredObfuscatorDictionaryProvider._();

final class FilteredObfuscatorDictionaryProvider
    extends
        $FunctionalProvider<
          List<DictionaryEntry>,
          List<DictionaryEntry>,
          List<DictionaryEntry>
        >
    with $Provider<List<DictionaryEntry>> {
  FilteredObfuscatorDictionaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredObfuscatorDictionaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredObfuscatorDictionaryHash();

  @$internal
  @override
  $ProviderElement<List<DictionaryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DictionaryEntry> create(Ref ref) {
    return filteredObfuscatorDictionary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DictionaryEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DictionaryEntry>>(value),
    );
  }
}

String _$filteredObfuscatorDictionaryHash() =>
    r'f7638c5394c75bf8534bc9f53c0526054a614036';

@ProviderFor(Obfuscator)
final obfuscatorProvider = ObfuscatorProvider._();

final class ObfuscatorProvider
    extends $NotifierProvider<Obfuscator, ObfuscatorState> {
  ObfuscatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'obfuscatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$obfuscatorHash();

  @$internal
  @override
  Obfuscator create() => Obfuscator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ObfuscatorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ObfuscatorState>(value),
    );
  }
}

String _$obfuscatorHash() => r'65294967ec6916c25e5ffe320b576d70f3e92029';

abstract class _$Obfuscator extends $Notifier<ObfuscatorState> {
  ObfuscatorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ObfuscatorState, ObfuscatorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ObfuscatorState, ObfuscatorState>,
              ObfuscatorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
