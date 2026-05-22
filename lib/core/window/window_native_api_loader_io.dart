import 'dart:io';
import 'window_native_api.dart';
import 'window_native_api_windows.dart';
import 'window_native_api_macos.dart';
import 'window_native_api_linux.dart';

/// IO-specific setup that checks for the OS at runtime but
/// allows the compiler to resolve the imports on any desktop platform.
void setupNativeApi() {
  if (Platform.isWindows) {
    WindowNativeApi.register(WindowNativeApiWindows());
  } else if (Platform.isMacOS) {
    WindowNativeApi.register(WindowNativeApiMacOS());
  } else if (Platform.isLinux) {
    WindowNativeApi.register(WindowNativeApiLinux());
  }
}
