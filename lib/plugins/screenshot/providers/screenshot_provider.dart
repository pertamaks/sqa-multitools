import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show debugPrint, Uint8List;
import 'package:flutter/material.dart' show Color, Rect, Size, Offset, Colors;
import 'package:flutter/rendering.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:path_provider/path_provider.dart';

import '../models/screenshot_state.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/screenshot_tool.dart';
import '../../../core/models/annotation.dart';
import '../../../core/engine/ffmpeg_engine.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/providers/hotkey_provider.dart';
import '../../../core/window/window_utils.dart';
import '../../../core/window/window_transition_coordinator.dart';
import '../../../core/providers/capture_key_provider.dart';

part 'screenshot_provider.g.dart';

@riverpod
class ScreenshotNotifier extends _$ScreenshotNotifier {
  @override
  ScreenshotState build() {
    // Initial data refresh
    Future.microtask(() {
      _loadPreferences();
      refreshRecentCaptures();
      // Register global hotkey callback
      ref.read(hotkeySettingsProvider.notifier).setScreenshotToggleCallback(() {
        capture();
      });
    });

    return const ScreenshotState();
  }

  void _loadPreferences() {
    final prefs = ref.read(preferencesServiceProvider);
    final saveDir = prefs.rawPrefs.getString(
      PreferencesService.keyScreenshotSaveDir,
    );
    final format =
        prefs.rawPrefs.getString(PreferencesService.keyScreenshotFormat) ??
        'PNG';
    state = state.copyWith(saveDirectory: saveDir, format: format);
  }

  Future<void> refreshRecentCaptures() async {
    final dir =
        state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final saveDir = Directory('$dir\\SQA_Screenshots');

    if (!await saveDir.exists()) {
      state = state.copyWith(recentCaptures: []);
      return;
    }

    try {
      final fileList = await saveDir
          .list()
          .where(
            (entity) =>
                entity is File &&
                [
                  '.png',
                  '.jpg',
                  '.webp',
                ].any((ext) => entity.path.toLowerCase().endsWith(ext)),
          )
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
        recentCaptures: validInfo.length > 10
            ? validInfo.sublist(0, 10)
            : validInfo,
      );
    } catch (e) {
      debugPrint('[Screenshot] Failed to refresh captures: $e');
    }
  }

  void setSaveDirectory(String path) {
    state = state.copyWith(saveDirectory: path);
    ref
        .read(preferencesServiceProvider)
        .rawPrefs
        .setString(PreferencesService.keyScreenshotSaveDir, path);
    refreshRecentCaptures();
  }

  void setCaptureMode(CaptureMode mode) {
    state = state.copyWith(captureMode: mode);
  }

  void setFormat(String format) {
    state = state.copyWith(format: format);
    ref
        .read(preferencesServiceProvider)
        .rawPrefs
        .setString(PreferencesService.keyScreenshotFormat, format);
  }

  void setTool(ScreenshotTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setColor(Color color) {
    state = state.copyWith(annotationColor: color);
  }

  void setTextHasBackground(bool value) {
    state = state.copyWith(textHasBackground: value);
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

    final coordinator = ref.read(windowTransitionProvider);
    // 0. Ensure window is active and visible (even if from tray)
    await WindowUtils.safeShow();
 
    // 1. Ghost the window instantly and wait for OS commitment
    await windowManager.setOpacity(0.0);
    await coordinator.waitForSync(resize: false, move: false);

    // 2. Prepare the background state while invisible
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);

    // 3. Update state early so Flutter starts building the transparent overlay UI
    state = state.copyWith(
      previousWindowSize: currentSize,
      previousWindowPos: currentPos,
      isOverlayVisible: true,
      annotations: [],
      selectionRect: null,
      targetedWindowRect: null,
      targetWindowName: null,
      availableDisplays: displays,
      lockedDisplay: null,
      isTargetingWindow: state.captureMode == CaptureMode.window,
    );

    // Wait for Flutter to commit the first frame of the overlay
    await coordinator.waitForSync(resize: false, move: false, frame: true);

    // 4. Expand the window while it is ghosted and Flutter is ready
    await windowManager.setBounds(overlayRect);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setIgnoreMouseEvents(false);

    // 5. Robust sync delay for Windows DWM buffer allocation
    await coordinator.waitForSync(
      resize: true,
      move: true,
      frame: false,
      targetSize: overlayRect.size,
      targetOffset: overlayRect.topLeft,
    );

    // 6. Finally reveal and focus
    await windowManager.setOpacity(1.0);
    await windowManager.focus();
  }

  Future<void> stopCapture() async {
    final coordinator = ref.read(windowTransitionProvider);

    // 1. Ghost the window instantly as the absolute FIRST step
    // Use 0.01 to keep the layered window context active during transformation
    await windowManager.setOpacity(0.01);
    await coordinator.waitForSync(resize: false, move: false);

    // 2. Physically restore window bounds BEFORE switching UI state
    await _restoreWindowInternal();
    await coordinator.waitForSync(
      resize: true,
      move: true,
      frame: false,
      targetSize: state.previousWindowSize,
      targetOffset: state.previousWindowPos,
    );

    // 3. NOW switch UI to Toolbar mode
    state = state.copyWith(
      isOverlayVisible: false,
      selectionRect: null,
      targetedWindowRect: null,
      lockedDisplay: null,
      annotations: [],
    );

    // 4. Wait for Flutter render to commit the Toolbar frame
    await coordinator.waitForSync(resize: false, move: false, frame: true);
    final theme = ref.read(themeSettingsProvider);

    // 5. Finally restore native attributes, reveal and focus
    // Move all attribute changes here to prevent DWM flushes on giant window
    await Future.wait([
      windowManager.setHasShadow(true),
      windowManager.setTitleBarStyle(TitleBarStyle.hidden),
      windowManager.setAlwaysOnTop(theme.alwaysOnTop),
      windowManager.setIgnoreMouseEvents(false),
    ]);

    await windowManager.setOpacity(1.0);
    await windowManager.focus();
  }

  Future<void> _restoreWindowInternal() async {
    final size = state.previousWindowSize ?? const Size(450, 500);
    final pos = state.previousWindowPos ?? const Offset(100, 100);

    // Structural Move Only (Isolate from attribute changes to prevent flicker)
    await windowManager.setBounds(
      Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height),
    );
  }

  void setSelection(Rect? rect, [Display? display]) {
    if (display != null && state.lockedDisplay != display) {
      state = state.copyWith(lockedDisplay: display);
    }

    state = state.copyWith(selectionRect: rect);

    // Physical lock on Drag End
    if (rect != null && state.lockedDisplay != null && !state.isCapturing) {
      _lockToMonitor(rect, providedDisplay: state.lockedDisplay);
    }
  }

  void addAnnotation(Annotation annotation) {
    state = state.copyWith(annotations: [...state.annotations, annotation]);
  }

  void updateLastAnnotation(Annotation annotation) {
    if (state.annotations.isEmpty) return;
    final updated = [
      ...state.annotations.sublist(0, state.annotations.length - 1),
      annotation,
    ];
    state = state.copyWith(annotations: updated);
  }

  void removeAnnotation(Annotation annotation) {
    final updated = state.annotations.where((a) => a != annotation).toList();
    state = state.copyWith(annotations: updated);
  }

  void clearAnnotations() {
    state = state.copyWith(annotations: []);
  }

  Future<void> finalize({bool shouldCopy = false}) async {
    if (state.selectionRect == null &&
        state.captureMode != CaptureMode.fullScreen) {
      return;
    }

    state = state.copyWith(isCapturing: true);
    final coordinator = ref.read(windowTransitionProvider);

    // 1. Ghost the window instantly as the absolute FIRST step
    // This makes the UI feel responsive and ensures the overlay doesn't appear in the screenshot
    await windowManager.setOpacity(0.01);

    // Give Flutter and DWM a moment to hide the window
    await coordinator.waitForSync(resize: false, move: false);

    // Calculate final capture rect
    Rect finalRect;
    final windowPos = await windowManager.getPosition();

    if (state.selectionRect != null) {
      finalRect = state.selectionRect!.shift(
        Offset(windowPos.dx, windowPos.dy),
      );
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
    final dir =
        state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final saveDir = Directory('$dir\\SQA_Screenshots');
    if (!await saveDir.exists()) await saveDir.create(recursive: true);

    final timestamp = DateTime.now()
        .toString()
        .replaceAll(RegExp(r'[:.-]'), '')
        .replaceAll(' ', '_');
    final filename = 'SQA_SS_$timestamp.${state.format.toLowerCase()}';
    final savePath = '${saveDir.path}\\$filename';

    try {
      // 1. Capture Annotations (Foreground) - High DPI Aware
      final captureKey = ref.read(captureKeyProvider);
      Uint8List? annotationBytes;

      try {
        final boundary =
            captureKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary != null) {
          // Determine the scale factor of the locked monitor
          final ratio = (state.lockedDisplay?.scaleFactor ?? 1.0).toDouble();
          final image = await boundary.toImage(pixelRatio: ratio);
          final byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (byteData != null) {
            annotationBytes = byteData.buffer.asUint8List();
          }
        }
      } catch (e) {
        debugPrint('[Screenshot] Annotation capture failed: $e');
      }

      final tempDir = await getTemporaryDirectory();
      final fgPath =
          '${tempDir.path}\\sqa_ss_fg_${DateTime.now().millisecondsSinceEpoch}.png';
      final bgPath =
          '${tempDir.path}\\sqa_ss_bg_${DateTime.now().millisecondsSinceEpoch}.png';

      if (annotationBytes != null) {
        await File(fgPath).writeAsBytes(annotationBytes);
      }

      // 2. Perform the Background Capture (Clean Screen)
      // Visual ghosting already handled above, giving OS time to hide window.
      await coordinator.waitForSync(resize: false, move: false, frame: true);

      final bgFile = await FfmpegEngine.takeScreenshot(
        logicalBounds: finalRect,
        displays: state.availableDisplays,
        format: 'PNG',
        savePath: bgPath,
      );

      if (bgFile != null) {
        if (annotationBytes != null) {
          // 3. Composite FG + BG via FFmpeg
          // Calculate pixel-perfect offsets
          final ratio = (state.lockedDisplay?.scaleFactor ?? 1.0).toDouble();

          // The foreground image is the size of the whole overlay window.
          // We need to crop it to match the background screenshot's selectionRect.
          final rect =
              state.selectionRect ??
              Rect.fromLTWH(
                0,
                0,
                finalRect.width / ratio,
                finalRect.height / ratio,
              );

          final offX = (rect.left * ratio).round();
          final offY = (rect.top * ratio).round();
          final width = (rect.width * ratio).round();
          final height = (rect.height * ratio).round();

          final success = await FfmpegEngine.compositeImages(
            backgroundPath: bgPath,
            foregroundPath: fgPath,
            outputPath: savePath,
            cropX: offX,
            cropY: offY,
            cropW: width,
            cropH: height,
          );

          if (!success) {
            await bgFile.copy(savePath);
          }
        } else {
          await bgFile.copy(savePath);
        }
      }

      if (await File(savePath).exists() && shouldCopy) {
        await Process.run('powershell', [
          '-Command',
          'Set-Clipboard -Path "$savePath"',
        ]);
      }

      // Cleanup temp bits
      try {
        if (await File(fgPath).exists()) await File(fgPath).delete();
        if (await File(bgPath).exists()) await File(bgPath).delete();
      } catch (_) {}
    } catch (e) {
      debugPrint('[Screenshot] Finalize Error: $e');
    } finally {
      final coordinator = ref.read(windowTransitionProvider);

      // 1. Ghost instantly (already nearly invisible from isCapturing, but set 0.01 for structural move)
      await windowManager.setOpacity(0.01);
      await coordinator.waitForSync(resize: false, move: false);

      // 2. Perform background structural restoration while invisible
      await _restoreWindowInternal();
      await coordinator.waitForSync(resize: true, move: false, frame: false);

      // 3. NOW switch the UI state to Toolbar mode
      state = state.copyWith(
        isCapturing: false,
        isOverlayVisible: false,
        selectionRect: null,
        targetedWindowRect: null,
        lockedDisplay: null,
        annotations: [],
      );

      // 4. Wait for Flutter to commit the Toolbar frame
      await coordinator.waitForSync(resize: false, move: false, frame: true);
      final theme = ref.read(themeSettingsProvider);

      // 5. Finally restore attributes, reveal and focus
      // Move all attribute changes here to prevent DWM flushes on giant window
      await Future.wait([
        windowManager.setHasShadow(true),
        windowManager.setTitleBarStyle(TitleBarStyle.hidden),
        windowManager.setAlwaysOnTop(theme.alwaysOnTop),
        windowManager.setIgnoreMouseEvents(false),
      ]);

      await windowManager.setOpacity(1.0);
      await windowManager.focus();

      refreshRecentCaptures();
    }
  }

  Future<void> capture() async {
    await startOverlay();
  }

  Future<void> openSaveDirectory() async {
    final dir =
        state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
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

  Future<void> renameCapture(CaptureInfo info, String newName) async {
    try {
      if (await info.file.exists()) {
        final dir = info.file.parent.path;
        final extension = info.file.path.split('.').last;
        final newPath = '$dir/$newName.$extension';

        await info.file.rename(newPath);
        await refreshRecentCaptures();
      }
    } catch (e) {
      debugPrint('[Screenshot] Failed to rename capture: $e');
    }
  }

  String? validateNewName(String name, CaptureInfo currentInfo) {
    if (name.trim().isEmpty) return 'Name cannot be empty';

    // Windows prohibited characters: < > : " / \ | ? *
    final prohibited = RegExp(r'[<>:"/\\|?*]');
    if (prohibited.hasMatch(name)) {
      return 'Contains invalid characters: < > : " / \\ | ? *';
    }

    // Check for duplicates
    final filename = currentInfo.file.uri.pathSegments.last;
    final nameWithoutExt = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;

    if (name == nameWithoutExt) return null; // No change

    final extension = filename.split('.').last;
    final targetPath = '${currentInfo.file.parent.path}/$name.$extension';

    if (File(targetPath).existsSync()) {
      return 'A file with this name already exists';
    }

    return null;
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

    _lockToMonitor(rect);

    if (state.targetedWindowHwnd != null && state.targetedWindowHwnd != 0) {
      WindowUtils.focusWindow(state.targetedWindowHwnd!);
    }
  }

  /// Physically shrinks the overlay window to cover only the target monitor.
  Future<void> _lockToMonitor(
    Rect targetRect, {
    Display? providedDisplay,
  }) async {
    if (!state.isOverlayVisible || state.isCapturing) return;

    final displays = state.availableDisplays;
    if (displays.isEmpty) return;

    // 1. Identify Target Display
    Display? targetDisplay = providedDisplay;
    if (targetDisplay == null) {
      final windowPos = WindowUtils.getAppWindowPosition();
      final center = targetRect.center.translate(windowPos.dx, windowPos.dy);

      for (final d in displays) {
        final dPos = d.visiblePosition ?? Offset.zero;
        final dRect = Rect.fromLTWH(
          dPos.dx,
          dPos.dy,
          d.size.width,
          d.size.height,
        );
        if (dRect.contains(center)) {
          targetDisplay = d;
          break;
        }
      }
    }

    if (targetDisplay == null) return;

    final targetDisplayRect = Rect.fromLTWH(
      targetDisplay.visiblePosition?.dx ?? 0,
      targetDisplay.visiblePosition?.dy ?? 0,
      targetDisplay.size.width,
      targetDisplay.size.height,
    );

    final coordinator = ref.read(windowTransitionProvider);

    // 2. Ghost for transition safety
    await windowManager.setOpacity(0.01);
    await coordinator.waitForSync(resize: false, move: false);

    // 3. Coordinate Remapping
    final windowPos = WindowUtils.getAppWindowPosition();
    final globalSelection = state.selectionRect?.shift(windowPos);
    final globalTargeted = state.targetedWindowRect?.shift(windowPos);

    final newWindowPos = targetDisplayRect.topLeft;
    final newLocalSelection = globalSelection?.shift(-newWindowPos);
    final newLocalTargeted = globalTargeted?.shift(-newWindowPos);

    // 4. Physical Move
    await windowManager.setBounds(targetDisplayRect);

    // 5. Sync
    await coordinator.waitForSync(
      resize: true,
      move: true,
      targetSize: targetDisplayRect.size,
      targetOffset: targetDisplayRect.topLeft,
    );

    // 6. Update State
    state = state.copyWith(
      selectionRect: newLocalSelection,
      targetedWindowRect: newLocalTargeted,
      lockedDisplay: targetDisplay,
    );

    // 7. Reveal
    await windowManager.setOpacity(1.0);
  }
}
