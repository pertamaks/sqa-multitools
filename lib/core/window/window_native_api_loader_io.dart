import 'dart:io';
import 'window_native_api.dart';
import 'window_native_api_windows.dart';

/// IO-specific setup that checks for the OS at runtime but
/// allows the compiler to resolve the imports on any desktop platform.
void setupNativeApi() {
  if (Platform.isWindows) {
    WindowNativeApi.register(WindowNativeApiWindows());
  }
  // Future: Add macOS/Linux registration here
  // else if (Platform.isMacOS) { ... }
}
