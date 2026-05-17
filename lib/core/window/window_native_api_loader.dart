import 'window_native_api_loader_stub.dart'
    if (dart.library.io) 'window_native_api_loader_io.dart';

/// Entry point for platform-specific native API registration.
///
/// This uses conditional imports to ensure that platform-specific
/// dependencies (like win32) are not pulled into the compilation
/// graph on unsupported targets.
void initializePlatformNativeApi() {
  setupNativeApi();
}
