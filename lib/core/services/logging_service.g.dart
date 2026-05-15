// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logging_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A centralized service for application-wide logging.
/// This service captures structured logs and can eventually be configured
/// to persist them to a file or send them to an external observability tool.

@ProviderFor(LoggingService)
final loggingServiceProvider = LoggingServiceProvider._();

/// A centralized service for application-wide logging.
/// This service captures structured logs and can eventually be configured
/// to persist them to a file or send them to an external observability tool.
final class LoggingServiceProvider
    extends $NotifierProvider<LoggingService, void> {
  /// A centralized service for application-wide logging.
  /// This service captures structured logs and can eventually be configured
  /// to persist them to a file or send them to an external observability tool.
  LoggingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggingServiceHash();

  @$internal
  @override
  LoggingService create() => LoggingService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$loggingServiceHash() => r'112fa08eed81dc9c14331c830c926888aed82edf';

/// A centralized service for application-wide logging.
/// This service captures structured logs and can eventually be configured
/// to persist them to a file or send them to an external observability tool.

abstract class _$LoggingService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
