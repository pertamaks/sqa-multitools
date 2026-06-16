import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as path;
import 'logging_service.dart';

part 'linux_integration_service.g.dart';

@Riverpod(keepAlive: true)
LinuxIntegrationService linuxIntegrationService(Ref ref) {
  return LinuxIntegrationService(ref.watch(loggingServiceProvider.notifier));
}

class LinuxIntegrationService {
  final LoggingService _logger;

  LinuxIntegrationService(this._logger);

  String get _appId => 'com.sqa.sqa_multitools';

  String? get _localShareAppsPath {
    final home = Platform.environment['HOME'];
    if (home == null) return null;
    return path.join(home, '.local', 'share', 'applications');
  }

  String? get _localShareIconsPath {
    final home = Platform.environment['HOME'];
    if (home == null) return null;
    return path.join(
      home,
      '.local',
      'share',
      'icons',
      'hicolor',
      '512x512',
      'apps',
    );
  }

  String? get _desktopFilePath {
    final appsDir = _localShareAppsPath;
    if (appsDir == null) return null;
    return path.join(appsDir, '$_appId.desktop');
  }

  String? get _iconFilePath {
    final iconsDir = _localShareIconsPath;
    if (iconsDir == null) return null;
    return path.join(iconsDir, 'sqa_multitools.png');
  }

  Future<void> integrate() async {
    if (!Platform.isLinux) return;

    try {
      final exePath = Platform.resolvedExecutable;
      final exeDir = path.dirname(exePath);

      // Path to flutter assets in the release bundle
      final assetIconPath = path.join(
        exeDir,
        'data',
        'flutter_assets',
        'assets',
        'app_icon_linux.png',
      );

      final iconsDir = _localShareIconsPath;
      final appsDir = _localShareAppsPath;
      final desktopFile = _desktopFilePath;
      final iconFile = _iconFilePath;

      if (iconsDir == null ||
          appsDir == null ||
          desktopFile == null ||
          iconFile == null) {
        _logger.logError(
          'Cannot resolve ~/.local paths',
          'LinuxIntegration',
          null,
          null,
        );
        return;
      }

      // Create directories
      await Directory(iconsDir).create(recursive: true);
      await Directory(appsDir).create(recursive: true);

      // Copy icon
      final assetFile = File(assetIconPath);
      if (await assetFile.exists()) {
        await assetFile.copy(iconFile);
      } else {
        _logger.logWarning(
          'Icon asset not found at $assetIconPath',
          'LinuxIntegration',
        );
      }

      // Write .desktop file
      final desktopContent =
          '''
[Desktop Entry]
Version=1.0
Name=SQA-Multitools
GenericName=SQA-Multitools
Comment=A powerful desktop suite of quality assurance tools
Terminal=false
Type=Application
Categories=Utility;Development;
Icon=sqa_multitools
Exec=$exePath %U
StartupNotify=true
StartupWMClass=$_appId
''';
      await File(desktopFile).writeAsString(desktopContent);

      // Update desktop database and icon cache
      await Process.run('update-desktop-database', [appsDir]);
      final iconCacheDir = path.join(
        Platform.environment['HOME']!,
        '.local',
        'share',
        'icons',
        'hicolor',
      );
      await Process.run('gtk-update-icon-cache', [iconCacheDir, '-f', '-t']);

      _logger.logInfo(
        'Successfully integrated Linux desktop file to $desktopFile',
        'LinuxIntegration',
      );
    } catch (e, stack) {
      _logger.logError(
        'Failed to integrate Linux desktop',
        'LinuxIntegration',
        e,
        stack,
      );
    }
  }

  Future<void> removeIntegration() async {
    if (!Platform.isLinux) return;

    try {
      final desktopFile = _desktopFilePath;
      final iconFile = _iconFilePath;

      if (desktopFile != null && await File(desktopFile).exists()) {
        await File(desktopFile).delete();
      }

      if (iconFile != null && await File(iconFile).exists()) {
        await File(iconFile).delete();
      }

      final appsDir = _localShareAppsPath;
      if (appsDir != null && await Directory(appsDir).exists()) {
        await Process.run('update-desktop-database', [appsDir]);
      }

      final home = Platform.environment['HOME'];
      if (home != null) {
        final iconCacheDir = path.join(
          home,
          '.local',
          'share',
          'icons',
          'hicolor',
        );
        await Process.run('gtk-update-icon-cache', [iconCacheDir, '-f', '-t']);
      }

      _logger.logInfo(
        'Successfully removed Linux desktop integration',
        'LinuxIntegration',
      );
    } catch (e, stack) {
      _logger.logError(
        'Failed to remove Linux desktop integration',
        'LinuxIntegration',
        e,
        stack,
      );
    }
  }

  Future<void> selfHeal() async {
    if (!Platform.isLinux) return;

    try {
      final desktopFile = _desktopFilePath;
      if (desktopFile == null) return;

      final file = File(desktopFile);
      if (!await file.exists()) return; // Not integrated

      final exePath = Platform.resolvedExecutable;
      final content = await file.readAsString();

      // Simple regex to find the Exec line
      final execRegex = RegExp(r'^Exec=(.*)$', multiLine: true);
      final match = execRegex.firstMatch(content);

      if (match != null) {
        final currentExec = match.group(1)?.trim();
        // The desktop file appends %U, so we compare without it
        final currentPath = currentExec?.replaceAll(' %U', '');

        if (currentPath != exePath) {
          _logger.logInfo(
            'Self-healing Linux desktop file from $currentPath to $exePath',
            'LinuxIntegration',
          );

          final newContent = content.replaceFirst(
            execRegex,
            'Exec=$exePath %U',
          );
          await file.writeAsString(newContent);

          final appsDir = _localShareAppsPath;
          if (appsDir != null) {
            await Process.run('update-desktop-database', [appsDir]);
          }
        }
      }
    } catch (e, stack) {
      _logger.logError(
        'Failed to self-heal Linux desktop file',
        'LinuxIntegration',
        e,
        stack,
      );
    }
  }
}
