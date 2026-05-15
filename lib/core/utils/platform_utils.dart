import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

/// Centralized utilities for platform-specific interactions.
class PlatformUtils {
  /// Opens a file or directory in the native file manager (Explorer, Finder, Nautilus, etc.).
  ///
  /// Uses [url_launcher] as the primary method and falls back to platform-specific
  /// shell commands if [url_launcher] is unavailable.
  static Future<void> openPath(String path) async {
    final uri = Uri.file(path);
    
    // 1. Try url_launcher (cross-platform primary)
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (e) {
      debugPrint('[PlatformUtils] url_launcher failed for $path: $e');
    }

    // 2. Platform-specific fallbacks
    try {
      if (Platform.isWindows) {
        // For directories, explorer.exe <path> works.
        // For files, explorer.exe /select,<path> or just start works.
        // Process.start with 'explorer.exe' and the path is the standard Windows fallback.
        await Process.start('explorer.exe', [path]);
      } else if (Platform.isMacOS) {
        await Process.start('open', [path]);
      } else if (Platform.isLinux) {
        await Process.start('xdg-open', [path]);
      }
    } catch (e) {
      debugPrint('[PlatformUtils] Shell fallback failed for $path: $e');
    }
  }

  /// Returns a regex of characters prohibited in filenames for the current platform.
  static RegExp get prohibitedFilenameRegex {
    if (Platform.isWindows) {
      // Windows prohibited characters: < > : " / \ | ? *
      return RegExp(r'[<>:"/\\|?*]');
    } else {
      // macOS and Linux primarily prohibit the forward slash '/'
      // (and the null character, which Dart handles separately)
      return RegExp(r'[/]');
    }
  }
  
  /// Checks if a filename is valid for the current platform.
  static bool isValidFilename(String name) {
    if (name.isEmpty || name.length > 255) return false;
    return !prohibitedFilenameRegex.hasMatch(name);
  }
}
