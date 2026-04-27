// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodoNotification)
final todoNotificationProvider = TodoNotificationProvider._();

final class TodoNotificationProvider
    extends $NotifierProvider<TodoNotification, bool> {
  TodoNotificationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoNotificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoNotificationHash();

  @$internal
  @override
  TodoNotification create() => TodoNotification();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$todoNotificationHash() => r'5a9d4b9f46bf55ff476bc10a6eb141a07c457a74';

abstract class _$TodoNotification extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provides a list of 90-minute block start times for the current day

@ProviderFor(todoCycles)
final todoCyclesProvider = TodoCyclesProvider._();

/// Provides a list of 90-minute block start times for the current day

final class TodoCyclesProvider
    extends $FunctionalProvider<List<DateTime>, List<DateTime>, List<DateTime>>
    with $Provider<List<DateTime>> {
  /// Provides a list of 90-minute block start times for the current day
  TodoCyclesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoCyclesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoCyclesHash();

  @$internal
  @override
  $ProviderElement<List<DateTime>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<DateTime> create(Ref ref) {
    return todoCycles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DateTime>>(value),
    );
  }
}

String _$todoCyclesHash() => r'dc8412597671ad92bf7aee168324bc29f8300f0d';
