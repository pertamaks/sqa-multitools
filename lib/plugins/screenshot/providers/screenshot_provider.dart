import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show Color, Rect, Size, Offset, Colors;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../models/screenshot_state.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/screenshot_tool.dart';
import '../../../core/models/annotation.dart';
import '../../screen_recorder/engine/ffmpeg_engine.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/providers/hotkey_provider.dart';
import '../../../core/window/window_utils.dart';

part 'screenshot_provider.g.dart';

@riverpod
class ScreenshotNotifier extends _$ScreenshotNotifier {
  @override
  ScreenshotState build() {
    // Initial data refresh
    Future.microtask(() {
      _loadPreferences();
      refreshRecentCaptures();
    });

    return const ScreenshotState();
  }

  void _loadPreferences() {
    final prefs = ref.read(preferencesServiceProvider);
    final saveDir = prefs.rawPrefs.getString(PreferencesService.keyScreenshotSaveDir);
    final format = prefs.rawPrefs.getString(PreferencesService.keyScreenshotFormat) ?? 'PNG';
    final delay = prefs.rawPrefs.getInt(PreferencesService.keyScreenshotDelay) ?? 0;

    state = state.copyWith(
      saveDirectory: saveDir,
      format: format,
      delaySeconds: delay,
    );
  }

  Future<void> refreshRecentCaptures() async {
    final dir = state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final saveDir = Directory('$dir\\SQA_Screenshots');
    
    if (!await saveDir.exists()) {
      state = state.copyWith(recentCaptures: []);
      return;
    }

    try {
      final fileList = await saveDir
          .list()
          .where((entity) => entity is File && 
                ['.png', '.jpg', '.webp'].any((ext) => entity.path.toLowerCase().endsWith(ext)))
          .cast<File>()
          .toList();

      final infoList = await Future.wait(
        fileList.map((file) async {
          try {
            final stats = await file.stat();
            return CaptureInfo(
              file: file,
              size: stats.size,
              modified: stats.modified,
            );
          } catch (e) {
            return null;
          }
        }),
      );

      final validInfo = infoList.whereType<CaptureInfo>().toList();
      validInfo.sort((a, b) => b.modified.compareTo(a.modified));

      state = state.copyWith(
        recentCaptures: validInfo.length > 10 ? validInfo.sublist(0, 10) : validInfo,
      );
    } catch (e) {
      debugPrint('[Screenshot] Failed to refresh captures: $e');
    }
  }

  void setSaveDirectory(String path) {
    state = state.copyWith(saveDirectory: path);
    ref.read(preferencesServiceProvider).rawPrefs.setString(PreferencesService.keyScreenshotSaveDir, path);
    refreshRecentCaptures();
  }

  void setCaptureMode(CaptureMode mode) {
    state = state.copyWith(captureMode: mode);
  }

  void setFormat(String format) {
    state = state.copyWith(format: format);
    ref.read(preferencesServiceProvider).rawPrefs.setString(PreferencesService.keyScreenshotFormat, format);
  }

  void setTool(ScreenshotTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setColor(Color color) {
    state = state.copyWith(annotationColor: color);
  }

  Future<void> startOverlay() async {
    final currentSize = await windowManager.getSize();
    final currentPos = await windowManager.getPosition();
    final displays = await screenRetriever.getAllDisplays();

    // Span the entire virtual desktop
    double minX = 0, minY = 0, maxX = 0, maxY = 0;
    for (final display in displays) {
      final pos = display.visiblePosition ?? Offset.zero;
      final size = display.size;
      minX = math.min(minX, pos.dx);
      minY = math.min(minY, pos.dy);
      maxX = math.max(maxX, pos.dx + size.width);
      maxY = math.max(maxY, pos.dy + size.height);
    }
    final overlayRect = Rect.fromLTRB(minX, minY, maxX, maxY);

    await windowManager.hide();
    await windowManager.setBounds(overlayRect);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setIgnoreMouseEvents(false);

    state = state.copyWith(
      previousWindowSize: currentSize,
      previousWindowPos: currentPos,
      isOverlayVisible: true,
      annotations: [],
      selectionRect: null,
      targetedWindowRect: null,
      targetWindowName: null,
      availableDisplays: displays,
      isTargetingWindow: state.captureMode == CaptureMode.window,
    );

    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> stopCapture() async {
    state = state.copyWith(isOverlayVisible: false);
    await _restoreWindow();
  }

  Future<void> _restoreWindow() async {
    final size = state.previousWindowSize ?? const Size(450, 500);
    final pos = state.previousWindowPos ?? const Offset(100, 100);

    await windowManager.setHasShadow(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    
    final alwaysOnTop = ref.read(themeSettingsProvider).alwaysOnTop;
    await windowManager.setAlwaysOnTop(alwaysOnTop);
    await windowManager.setBounds(Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height));
    await windowManager.setIgnoreMouseEvents(false);
  }

  void setSelection(Rect? rect) {
    state = state.copyWith(selectionRect: rect);
  }

  void addAnnotation(Annotation annotation) {
    state = state.copyWith(annotations: [...state.annotations, annotation]);
  }

  void updateLastAnnotation(Annotation annotation) {
    if (state.annotations.isEmpty) return;
    final updated = [...state.annotations.sublist(0, state.annotations.length - 1), annotation];
    state = state.copyWith(annotations: updated);
  }

  void clearAnnotations() {
    state = state.copyWith(annotations: []);
  }

  Future<void> finalize({bool shouldCopy = false}) async {
    if (state.selectionRect == null && state.captureMode != CaptureMode.fullScreen) return;

    state = state.copyWith(isCapturing: true);

    // Calculate final capture rect
    Rect finalRect;
    final windowPos = await windowManager.getPosition();

    if (state.selectionRect != null) {
      finalRect = state.selectionRect!.shift(Offset(windowPos.dx, windowPos.dy));
    } else {
      // Full screen fallback
      final primary = state.availableDisplays.firstWhere(
        (d) => d.visiblePosition?.dx == 0 && d.visiblePosition?.dy == 0,
        orElse: () => state.availableDisplays.first,
      );
      finalRect = Rect.fromLTWH(
        primary.visiblePosition?.dx ?? 0,
        primary.visiblePosition?.dy ?? 0,
        primary.size.width,
        primary.size.height,
      );
    }

    // Construct save path
    final dir = state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final saveDir = Directory('$dir\\SQA_Screenshots');
    if (!await saveDir.exists()) await saveDir.create(recursive: true);

    final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[:.-]'), '').replaceAll(' ', '_');
    final filename = 'SQA_SS_$timestamp.${state.format.toLowerCase()}';
    final savePath = '${saveDir.path}\\$filename';

    try {
      // Capture
      final file = await FfmpegEngine.takeScreenshot(
        logicalBounds: finalRect,
        displays: state.availableDisplays,
        format: state.format,
        savePath: savePath,
      );

      if (file != null && shouldCopy) {
        // Implement standard system clipboard copy
        // We can use Process.run to use powershell to copy file to clipboard
        // Since user didn't want sqa-clipboard plugin but wants "copy button"
        await Process.run('powershell', [
          '-Command', 
          'Set-Clipboard -Path "$savePath"'
        ]);
      }
    } catch (e) {
      debugPrint('[Screenshot] Finalize failed: $e');
    } finally {
      state = state.copyWith(isCapturing: false, isOverlayVisible: false);
      await _restoreWindow();
      refreshRecentCaptures();
    }
  }

  Future<void> capture() async {
    await startOverlay();
  }

  Future<void> openSaveDirectory() async {
    final dir = state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final saveDir = Directory('$dir\\SQA_Screenshots');
    final targetDir = await saveDir.exists() ? saveDir : Directory(dir);

    if (await targetDir.exists()) {
      await Process.start('explorer.exe', [targetDir.path]);
    }
  }

  Future<void> deleteCapture(CaptureInfo info) async {
    try {
      if (await info.file.exists()) {
        await info.file.delete();
        await refreshRecentCaptures();
      }
    } catch (e) {
      debugPrint('[Screenshot] Failed to delete capture: $e');
    }
  }

  // Hotkey registration
  Future<void> registerGlobalHotkeys() async {
    try {
      final hotkeyInfo = ref.read(hotkeySettingsProvider).screenshotToggle;
      // Note: screenshotToggle needs to be added to HotkeySettings
      final hotKey = hotkeyInfo.toHotKey(identifier: 'screenshot_toggle');
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (hotKey) => capture(),
      );
    } catch (e) {
      debugPrint('[Screenshot] Hotkey registration failed: $e');
    }
  }

  // Window Targeting
  void setTargetingWindow(bool value) {
    state = state.copyWith(isTargetingWindow: value);
  }

  void updateTargetedWindow(Rect? rect, String? name, [int? hwnd]) {
    state = state.copyWith(
      targetedWindowRect: rect,
      targetWindowName: name ?? 'Active Window',
      targetedWindowHwnd: hwnd,
    );
  }

  void confirmTargetWindow(Rect rect, String title) {
    state = state.copyWith(
      isTargetingWindow: false,
      selectionRect: rect,
      targetWindowName: title,
    );

    if (state.targetedWindowHwnd != null && state.targetedWindowHwnd != 0) {
      WindowUtils.focusWindow(state.targetedWindowHwnd!);
    }
  }
}
