// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodoStorage)
final todoStorageProvider = TodoStorageProvider._();

final class TodoStorageProvider
    extends $NotifierProvider<TodoStorage, TodoStorageService> {
  TodoStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoStorageHash();

  @$internal
  @override
  TodoStorage create() => TodoStorage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoStorageService>(value),
    );
  }
}

String _$todoStorageHash() => r'a6c47d8a77503f119e4db27ab3d837a079f8475a';

abstract class _$TodoStorage extends $Notifier<TodoStorageService> {
  TodoStorageService build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TodoStorageService, TodoStorageService>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodoStorageService, TodoStorageService>,
              TodoStorageService,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TodoSettingsNotifier)
final todoSettingsProvider = TodoSettingsNotifierProvider._();

final class TodoSettingsNotifierProvider
    extends $AsyncNotifierProvider<TodoSettingsNotifier, TodoSettings> {
  TodoSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoSettingsNotifierHash();

  @$internal
  @override
  TodoSettingsNotifier create() => TodoSettingsNotifier();
}

String _$todoSettingsNotifierHash() =>
    r'ba8df4e426c6ff67667eddac2e8f8f2059e49a96';

abstract class _$TodoSettingsNotifier extends $AsyncNotifier<TodoSettings> {
  FutureOr<TodoSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TodoSettings>, TodoSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TodoSettings>, TodoSettings>,
              AsyncValue<TodoSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Todo)
final todoProvider = TodoProvider._();

final class TodoProvider extends $AsyncNotifierProvider<Todo, TodoState> {
  TodoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoHash();

  @$internal
  @override
  Todo create() => Todo();
}

String _$todoHash() => r'69e3e33b0a927435861c95b0fda7cd471e623873';

abstract class _$Todo extends $AsyncNotifier<TodoState> {
  FutureOr<TodoState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TodoState>, TodoState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TodoState>, TodoState>,
              AsyncValue<TodoState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
