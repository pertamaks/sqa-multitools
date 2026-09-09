import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show debugPrint, Uint8List;
import 'package:flutter/material.dart' show Color, Rect, Size, Offset, Colors;
import 'package:flutter/rendering.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../../../core/utils/platform_utils.dart';

import '../models/screenshot_state.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/screenshot_tool.dart';
import '../../../core/models/annotation.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/providers/hotkey_provider.dart';
import '../../../core/window/window_utils.dart';
import '../../../core/window/window_transition_coordinator.dart';
import '../../../core/providers/capture_key_provider.dart';
import '../../../core/services/logging_service.dart';
import '../../../core/engine/silent_frozen_canvas.dart';
import '../../../core/engine/ffmpeg_engine.dart';
import '../../screen_recorder/providers/screen_recorder_provider.dart';

part 'screenshot_provider.g.dart';

@Riverpod(keepAlive: true)
class IsScreenshotProcessing extends _$IsScreenshotProcessing {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

@riverpod
class ScreenshotNotifier extends _$ScreenshotNotifier {
  StreamSubscription<FileSystemEvent>? _watchSubscription;
  /// True when the window was hidden (in tray) at the moment the overlay was
  /// launched via hotkey. We restore this state when the overlay closes.
  bool _wasHiddenBeforeOverlay = false;

  @override
  ScreenshotState build() {
    ref.onDispose(() {
      _watchSubscription?.cancel();
    });

    // Initial data refresh
    Future.microtask(() {
      if (!ref.mounted) return;
      _loadPreferences();
      refreshRecentCaptures();
      // Register global hotkey callbacks
      ref.read(hotkeySettingsProvider.notifier).setScreenshotToggleCallback(() {
        capture();
      });
      ref.read(hotkeySettingsProvider.notifier).setSsFullscreenCallback(() {
        setCaptureMode(CaptureMode.fullScreen);
        capture();
      });
      ref.read(hotkeySettingsProvider.notifier).setSsAreaCallback(() {
        setCaptureMode(CaptureMode.area);
        capture();
      });
      ref.read(hotkeySettingsProvider.notifier).setSsLongCallback(() {
        setCaptureMode(CaptureMode.scrolling);
        ref.read(screenRecorderProvider.notifier).startLongScreenshotSession();
      });
      _setupDirectoryWatcher();
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
    if (!ref.mounted) return;
    final documentsDir = await getApplicationDocumentsDirectory();
    if (!ref.mounted) return;
    final saveDirPath =
        state.saveDirectory ?? p.join(documentsDir.path, 'SQA_Screenshots');
    final saveDir = Directory(saveDirPath);

    if (!await saveDir.exists()) {
      if (!ref.mounted) return;
      state = state.copyWith(recentCaptures: []);
      return;
    }

    try {
      final entities = await saveDir.list().toList();
      if (!ref.mounted) return;

      final fileList = entities
          .whereType<File>()
          .where(
            (file) => [
              '.png',
              '.jpg',
              '.webp',
            ].any((ext) => file.path.toLowerCase().endsWith(ext)),
          )
          .toList();

      if (!ref.mounted) return;

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

      if (!ref.mounted) return;

      final validInfo = infoList.whereType<CaptureInfo>().toList();
      validInfo.sort((a, b) => b.modified.compareTo(a.modified));

      state = state.copyWith(
        recentCaptures: validInfo.length > 10
            ? validInfo.sublist(0, 10)
            : validInfo,
      );
    } catch (e) {
      if (ref.mounted) {
        debugPrint('[Screenshot] Failed to refresh captures: $e');
      }
    }
  }

  void _setupDirectoryWatcher() async {
    await _watchSubscription?.cancel();
    _watchSubscription = null;

    final documentsDir = await getApplicationDocumentsDirectory();
    if (!ref.mounted) return;
    final saveDirPath =
        state.saveDirectory ?? p.join(documentsDir.path, 'SQA_Screenshots');
    final saveDir = Directory(saveDirPath);

    if (!await saveDir.exists()) {
      try {
        await saveDir.create(recursive: true);
      } catch (_) {}
    }

    if (!ref.mounted) return;
    if (await saveDir.exists()) {
      try {
        final stream = saveDir.watch();
        _watchSubscription = stream.handleError((e) {
          debugPrint('[Screenshot] Directory watcher error: $e');
        }).listen(
          (event) {
            refreshRecentCaptures();
          },
          onError: (e) {
            debugPrint('[Screenshot] Directory watcher error: $e');
          },
          cancelOnError: true,
        );
      } catch (e) {
        debugPrint('[Screenshot] Could not watch directory: $e');
      }
    }
  }

  void setSaveDirectory(String path) {
    state = state.copyWith(saveDirectory: path);
    ref
        .read(preferencesServiceProvider)
        .rawPrefs
        .setString(PreferencesService.keyScreenshotSaveDir, path);
    _setupDirectoryWatcher();
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> startMonitorSelection() async {
    final displays = await screenRetriever.getAllDisplays();
    if (displays.length <= 1) {
      await capture();
      return;
    }

    final currentSize = await windowManager.getSize();
    final currentPos = await windowManager.getPosition();

    // Spawn spanning window without frozen background
    final coordinator = ref.read(windowTransitionProvider);
    if (!_wasHiddenBeforeOverlay) {
      _wasHiddenBeforeOverlay = !(await windowManager.isVisible());
    }
    // Show the window: if it was hidden, keep opacity 0 so it appears invisibly.
    if (_wasHiddenBeforeOverlay) {
      await windowManager.setOpacity(0.0);
      await windowManager.show();
    } else {
      await WindowUtils.safeShow();
    }
    await windowManager.setOpacity(0.01);
    await coordinator.waitForSync(resize: false, move: false);

    if (!Platform.isLinux) await windowManager.setAsFrameless();
    if (!Platform.isLinux) await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);

    state = state.copyWith(
      previousWindowSize: currentSize,
      previousWindowPos: currentPos,
      isOverlayVisible: true,
      selectionRect: null,
      availableDisplays: displays,
      lockedDisplay: null, // this will make it span all monitors
      frozenBackgroundBytes: null, // no background = transparent
      annotations: [],
    );

    await coordinator.waitForSync(resize: false, move: false, frame: true);

    // Calculate spanning rect
    double minX = 0, minY = 0, maxX = 0, maxY = 0;
    for (final d in displays) {
      final left = d.visiblePosition?.dx ?? 0;
      final top = d.visiblePosition?.dy ?? 0;
      final right = left + d.size.width;
      final bottom = top + d.size.height;
      if (left < minX) minX = left;
      if (top < minY) minY = top;
      if (right > maxX) maxX = right;
      if (bottom > maxY) maxY = bottom;
    }
    await windowManager.setBounds(Rect.fromLTRB(minX, minY, maxX, maxY));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setOpacity(1.0);
    await windowManager.focus();
  }

  Future<void> startOverlayWithBytes(Uint8List bytes) async {
    final currentSize = await windowManager.getSize();
    final currentPos = await windowManager.getPosition();
    final displays = await screenRetriever.getAllDisplays();

    Display activeDisplay = await screenRetriever.getPrimaryDisplay();

    final overlayRect = Rect.fromLTWH(
      activeDisplay.visiblePosition?.dx ?? 0,
      activeDisplay.visiblePosition?.dy ?? 0,
      activeDisplay.size.width,
      activeDisplay.size.height,
    );

    final coordinator = ref.read(windowTransitionProvider);
    if (!_wasHiddenBeforeOverlay) {
      _wasHiddenBeforeOverlay = !(await windowManager.isVisible());
    }
    // Show the window: if it was hidden, keep opacity 0 so it appears invisibly.
    if (_wasHiddenBeforeOverlay) {
      await windowManager.setOpacity(0.0);
      await windowManager.show();
    } else {
      await WindowUtils.safeShow();
    }
    await windowManager.setOpacity(0.0);
    await coordinator.waitForSync(resize: false, move: false);
    if (!Platform.isLinux) await windowManager.setAsFrameless();
    if (!Platform.isLinux) await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);

    final savedSize = state.isOverlayVisible
        ? state.previousWindowSize
        : currentSize;
    final savedPos = state.isOverlayVisible
        ? state.previousWindowPos
        : currentPos;

    state = state.copyWith(
      previousWindowSize: savedSize,
      previousWindowPos: savedPos,
      isOverlayVisible: true,
      lockedDisplay: activeDisplay,
      annotations: [],
      selectionRect: Rect.fromLTWH(
        0,
        0,
        activeDisplay.size.width,
        activeDisplay.size.height,
      ), // Provide full area for annotation
      availableDisplays: displays,
      frozenBackgroundBytes: bytes,
      captureMode: CaptureMode.area,
    );

    await coordinator.waitForSync(resize: false, move: false, frame: true);
    await windowManager.setBounds(overlayRect);
    await windowManager.setAlwaysOnTop(true);
    try {
      await windowManager.setIgnoreMouseEvents(false);
    } catch (_) {}
    await coordinator.waitForSync(
      resize: true,
      move: true,
      frame: false,
      targetSize: overlayRect.size,
      targetOffset: overlayRect.topLeft,
    );
    await windowManager.setOpacity(1.0);
    await windowManager.focus();
  }

  Future<void> startOverlay([Display? targetDisplay]) async {
    final currentSize = await windowManager.getSize();
    final currentPos = await windowManager.getPosition();
    final displays = await screenRetriever.getAllDisplays();

    Display? activeDisplay = targetDisplay;

    if (activeDisplay == null) {
      // Snap window only to the active display (where the cursor is)
      final cursor = await screenRetriever.getCursorScreenPoint();
      for (final display in displays) {
        final rect = Rect.fromLTWH(
          display.visiblePosition?.dx ?? 0,
          display.visiblePosition?.dy ?? 0,
          display.size.width,
          display.size.height,
        );
        if (rect.contains(cursor)) {
          activeDisplay = display;
          break;
        }
      }
    }
    activeDisplay ??= await screenRetriever.getPrimaryDisplay();

    final overlayRect = Rect.fromLTWH(
      activeDisplay.visiblePosition?.dx ?? 0,
      activeDisplay.visiblePosition?.dy ?? 0,
      activeDisplay.size.width,
      activeDisplay.size.height,
    );

    final coordinator = ref.read(windowTransitionProvider);
    // 0. Remember if the window was hidden so we can restore that state later.
    if (!_wasHiddenBeforeOverlay) {
      _wasHiddenBeforeOverlay = !(await windowManager.isVisible());
    }
    // Show the window: if it was hidden, keep opacity 0 so it appears invisibly.
    if (_wasHiddenBeforeOverlay) {
      await windowManager.setOpacity(0.0);
      await windowManager.show();
    } else {
      await WindowUtils.safeShow();
    }

    // 1. Ghost the window instantly
    await windowManager.setOpacity(0.0);

    // 2. Prepare the background style while invisible
    if (!Platform.isLinux) await windowManager.setAsFrameless();
    if (!Platform.isLinux) await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);

    // 3. Move and expand the invisible window to the target display FIRST
    // This forces Windows DWM to send WM_DPICHANGED and adapt Flutter viewport to the target display's DPI
    await windowManager.setBounds(overlayRect);
    await coordinator.waitForSync(
      resize: true,
      move: true,
      frame: false,
      targetSize: overlayRect.size,
      targetOffset: overlayRect.topLeft,
    );

    // 4. Capture the clean desktop on that monitor using native Win32 monitor bounds
    Uint8List? frozenBytes;
    final result = await freezeScreen();
    if (result is CaptureSuccess<FrozenCanvas>) {
      frozenBytes = Uint8List.fromList(result.data.bytes);
    } else if (result is CaptureFailure<FrozenCanvas>) {
      ref
          .read(loggingServiceProvider.notifier)
          .logError(
            '[Screenshot] Frozen background snapshot failed: ${result.message}',
            'ScreenshotProvider',
            result.cause,
          );
    }

    Rect? initialSelection;
    if (state.captureMode == CaptureMode.fullScreen && frozenBytes != null) {
      initialSelection = Rect.fromLTWH(
        0,
        0,
        activeDisplay.size.width,
        activeDisplay.size.height,
      );
    }

    // Only save previous bounds if we aren't already in the overlay state
    final savedSize = state.isOverlayVisible
        ? state.previousWindowSize
        : currentSize;
    final savedPos = state.isOverlayVisible
        ? state.previousWindowPos
        : currentPos;

    // 5. Update state so Flutter builds the overlay UI with the correct viewport
    state = state.copyWith(
      previousWindowSize: savedSize,
      previousWindowPos: savedPos,
      isOverlayVisible: true,
      lockedDisplay: activeDisplay,
      annotations: [],
      selectionRect: initialSelection,
      availableDisplays: displays,
      frozenBackgroundBytes: frozenBytes,
    );

    // Wait for Flutter to commit the first frame of the overlay on the new DPI context
    await coordinator.waitForSync(resize: false, move: false, frame: true);

    // 6. Ensure bounds, set always on top, and reveal
    await windowManager.setBounds(overlayRect);
    await windowManager.setAlwaysOnTop(true);
    try {
      await windowManager.setIgnoreMouseEvents(false);
    } catch (_) {}

    await windowManager.setOpacity(1.0);
    await windowManager.focus();
  }

  Future<void> stopCapture() async {
    final coordinator = ref.read(windowTransitionProvider);

    // 1. Ghost the window instantly as the absolute FIRST step
    await windowManager.setOpacity(0.01);
    await coordinator.waitForSync(resize: false, move: false);

    // 2. Physically restore window bounds BEFORE switching UI state
    await _restoreWindowInternal();
    final targetSize = state.previousWindowSize ?? const Size(450, 500);
    final targetPos = state.previousWindowPos ?? const Offset(100, 100);
    await coordinator.waitForSync(
      resize: true,
      move: true,
      frame: false,
      targetSize: targetSize,
      targetOffset: targetPos,
    );

    // 3. NOW switch UI to Toolbar mode
    state = state.copyWith(
      isCapturing: false,
      isOverlayVisible: false,
      selectionRect: null,
      lockedDisplay: null,
      annotations: [],
    );
    ref.read(isScreenshotProcessingProvider.notifier).set(false);

    // Wait for Flutter render to commit the Toolbar frame
    await coordinator.waitForSync(resize: false, move: false, frame: true);
    final theme = ref.read(themeSettingsProvider);

    // 4. Finally restore native attributes, reveal and focus
    await Future.wait([
      if (!Platform.isLinux) windowManager.setAsFrameless(),
      if (!Platform.isLinux) windowManager.setHasShadow(false),
      windowManager.setAlwaysOnTop(theme.alwaysOnTop),
      _safeSetIgnoreMouseEvents(false),
    ]);

    // Now either re-hide (if window was hidden before overlay) or reveal.
    if (_wasHiddenBeforeOverlay) {
      _wasHiddenBeforeOverlay = false;
      await windowManager.setOpacity(0.0);
      await WindowUtils.safeHide();
    } else {
      // DWM 1-pixel resize hack: ALWAYS flush the swap chain after returning from
      // a (potentially different-DPI) overlay window. Without this, the Flutter
      // renderer keeps the wrong pixel-ratio and the toolbar UI is visually
      // distorted the next time the window is shown.
      final s = await windowManager.getSize();
      await windowManager.setSize(Size(s.width + 1, s.height));
      await coordinator.waitForSync(resize: true, move: false, frame: false);
      await windowManager.setSize(s);
      await coordinator.waitForSync(resize: true, move: false, frame: true);

      await windowManager.setOpacity(1.0);
      await windowManager.focus();
    }
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

    if (state.frozenBackgroundBytes == null && display != null) {
      _restartOverlayForMonitor(display);
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

    final logger = ref.read(loggingServiceProvider.notifier);

    state = state.copyWith(isCapturing: true);
    final coordinator = ref.read(windowTransitionProvider);

    // 1. Ghost the window instantly
    await windowManager.setOpacity(0.01);
    await coordinator.waitForSync(resize: false, move: false);

    final documentsDir = await getApplicationDocumentsDirectory();
    final saveDirPath =
        state.saveDirectory ?? p.join(documentsDir.path, 'SQA_Screenshots');
    final saveDir = Directory(saveDirPath);
    if (!await saveDir.exists()) await saveDir.create(recursive: true);

    final timestamp = DateTime.now()
        .toString()
        .replaceAll(RegExp(r'[:.-]'), '')
        .replaceAll(' ', '_');
    final filename = 'SQA_SS_$timestamp.${state.format.toLowerCase()}';
    final savePath = p.join(saveDir.path, filename);

    try {
      // 1. Capture Annotations (Foreground) in memory
      final captureKey = ref.read(captureKeyProvider);
      ui.Image? annotationImage;
      final ratio = (state.lockedDisplay?.scaleFactor ?? 1.0).toDouble();
      Size? boundarySize;

      try {
        final boundary =
            captureKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary != null) {
          boundarySize = boundary.size;
          annotationImage = await boundary.toImage(pixelRatio: ratio);
        }
      } catch (e) {
        logger.logError(
          '[Screenshot] Annotation capture failed',
          'ScreenshotProvider',
          e,
        );
      }

      // 2. UNMOUNT heavy UI
      ref.read(isScreenshotProcessingProvider.notifier).set(true);
      await coordinator.waitForSync(resize: false, move: false, frame: true);

      // 3. Background Capture via screen_capturer

      final frozenBytes = state.frozenBackgroundBytes;
      if (frozenBytes != null) {
        final activeDisplay =
            state.lockedDisplay ?? state.availableDisplays.first;
        final targetCanvasSize = boundarySize ?? activeDisplay.size;
        final sel =
            state.selectionRect ??
            Rect.fromLTWH(
              0,
              0,
              targetCanvasSize.width,
              targetCanvasSize.height,
            );

        // Load Background Image first to get exact physical pixel dimensions
        final bgCodec = await ui.instantiateImageCodec(frozenBytes);
        final bgImage = (await bgCodec.getNextFrame()).image;

        // Compute exact scale ratio from bitmap pixels to Flutter logical coordinates
        final double scaleX = bgImage.width / targetCanvasSize.width;
        final double scaleY = bgImage.height / targetCanvasSize.height;

        final double cropX = (sel.left * scaleX).clamp(
          0.0,
          bgImage.width.toDouble(),
        );
        final double cropY = (sel.top * scaleY).clamp(
          0.0,
          bgImage.height.toDouble(),
        );
        final double cropW = (sel.width * scaleX).clamp(
          1.0,
          bgImage.width - cropX,
        );
        final double cropH = (sel.height * scaleY).clamp(
          1.0,
          bgImage.height - cropY,
        );

        final srcBgRect = Rect.fromLTWH(cropX, cropY, cropW, cropH);
        final dstRect = Rect.fromLTWH(0, 0, cropW, cropH);

        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);

        // Draw cropped background
        canvas.drawImageRect(bgImage, srcBgRect, dstRect, ui.Paint());

        // Draw foreground annotations if any
        if (annotationImage != null) {
          final fgWidth = annotationImage.width.toDouble();
          final fgHeight = annotationImage.height.toDouble();
          final fgScaleX = fgWidth / targetCanvasSize.width;
          final fgScaleY = fgHeight / targetCanvasSize.height;

          final offX = (sel.left * fgScaleX).clamp(0.0, fgWidth);
          final offY = (sel.top * fgScaleY).clamp(0.0, fgHeight);
          final width = (sel.width * fgScaleX).clamp(1.0, fgWidth - offX);
          final height = (sel.height * fgScaleY).clamp(1.0, fgHeight - offY);

          final srcFgRect = Rect.fromLTWH(offX, offY, width, height);

          canvas.drawImageRect(annotationImage, srcFgRect, dstRect, ui.Paint());
        }

        // Export Final Image
        final picture = recorder.endRecording();
        final finalImage = await picture.toImage(cropW.toInt(), cropH.toInt());
        final byteData = await finalImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();

          if (state.format.toLowerCase() == 'png') {
            await File(savePath).writeAsBytes(pngBytes);
          } else {
            final tempDir = await getTemporaryDirectory();
            final tempFile = File(
              p.join(
                tempDir.path,
                'sqa_ss_temp_${DateTime.now().millisecondsSinceEpoch}.png',
              ),
            );
            await tempFile.writeAsBytes(pngBytes);

            final success = await FfmpegEngine.convertImage(
              inputPath: tempFile.path,
              outputPath: savePath,
            );

            if (await tempFile.exists()) await tempFile.delete();

            if (!success) {
              // Fallback to saving as PNG if conversion fails
              final fallbackPath = savePath.replaceAll(
                RegExp(r'\.[^.]+$'),
                '.png',
              );
              await File(fallbackPath).writeAsBytes(pngBytes);
              logger.logWarning(
                '[Screenshot] Image conversion to ${state.format} failed. Saved as PNG instead.',
                'ScreenshotProvider',
              );
            }
          }

          if (shouldCopy) {
            final clipboard = SystemClipboard.instance;
            if (clipboard != null) {
              final item = DataWriterItem();
              item.add(Formats.png(pngBytes));
              await clipboard.write([item]);
            }
          }
        }
      } else {
        logger.logError(
          '[Screenshot] Frozen background is missing',
          'ScreenshotProvider',
        );
      }
    } catch (e, stack) {
      logger.logError(
        '[Screenshot] Finalize Error',
        'ScreenshotProvider',
        e,
        stack,
      );
    } finally {
      // Restore UI State
      await windowManager.setOpacity(0.01);
      await coordinator.waitForSync(resize: false, move: false);

      await _restoreWindowInternal();
      await coordinator.waitForSync(resize: true, move: false, frame: false);

      state = state.copyWith(
        isCapturing: false,
        isOverlayVisible: false,
        selectionRect: null,
        lockedDisplay: null,
        annotations: [],
      );
      ref.read(isScreenshotProcessingProvider.notifier).set(false);

      await coordinator.waitForSync(resize: false, move: false, frame: true);
      final theme = ref.read(themeSettingsProvider);

      await Future.wait([
        if (!Platform.isLinux) windowManager.setAsFrameless(),
        if (!Platform.isLinux) windowManager.setHasShadow(false),
        windowManager.setAlwaysOnTop(theme.alwaysOnTop),
        _safeSetIgnoreMouseEvents(false),
      ]);

      // Now either re-hide (if window was hidden before overlay) or reveal.
      if (_wasHiddenBeforeOverlay) {
        _wasHiddenBeforeOverlay = false;
        await windowManager.setOpacity(0.0);
        await WindowUtils.safeHide();
      } else {
        // DWM 1-pixel resize hack: ALWAYS flush the swap chain after returning from
        // a (potentially different-DPI) overlay window. Without this, the Flutter
        // renderer keeps the wrong pixel-ratio and the toolbar UI is visually
        // distorted the next time the window is shown.
        final s = await windowManager.getSize();
        await windowManager.setSize(Size(s.width + 1, s.height));
        await coordinator.waitForSync(resize: true, move: false, frame: false);
        await windowManager.setSize(s);
        await coordinator.waitForSync(resize: true, move: false, frame: true);

        await windowManager.setOpacity(1.0);
        await windowManager.focus();
      }

      refreshRecentCaptures();
    }
  }

  Future<void> capture([Display? display]) async {
    if (Platform.isLinux) {
      ref.read(isScreenshotProcessingProvider.notifier).set(true);
      final logger = ref.read(loggingServiceProvider.notifier);
      await WindowUtils.safeHide();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      try {
        final engine = SilentFrozenCanvasEngine();
        final result = await engine.capture(
          state.captureMode == CaptureMode.fullScreen
              ? const CaptureRegion.fullscreen()
              : const CaptureRegion(x: 0, y: 0, width: 0, height: 0),
        );

        if (result is CaptureSuccess<FrozenCanvas>) {
          final documentsDir = await getApplicationDocumentsDirectory();
          final saveDirPath =
              state.saveDirectory ??
              p.join(documentsDir.path, 'SQA_Screenshots');
          final saveDir = Directory(saveDirPath);
          if (!await saveDir.exists()) await saveDir.create(recursive: true);

          final timestamp = DateTime.now()
              .toString()
              .replaceAll(RegExp(r'[:.-]'), '')
              .replaceAll(' ', '_');
          final filename = 'SQA_SS_$timestamp.${state.format.toLowerCase()}';
          final savePath = p.join(saveDir.path, filename);

          final pngBytes = Uint8List.fromList(result.data.bytes);

          if (state.format.toLowerCase() == 'png') {
            await File(savePath).writeAsBytes(pngBytes);
          } else {
            final tempDir = await getTemporaryDirectory();
            final tempFile = File(
              p.join(
                tempDir.path,
                'sqa_ss_temp_${DateTime.now().millisecondsSinceEpoch}.png',
              ),
            );
            await tempFile.writeAsBytes(pngBytes);

            final success = await FfmpegEngine.convertImage(
              inputPath: tempFile.path,
              outputPath: savePath,
            );

            if (await tempFile.exists()) await tempFile.delete();

            if (!success) {
              final fallbackPath = savePath.replaceAll(
                RegExp(r'\.[^.]+$'),
                '.png',
              );
              await File(fallbackPath).writeAsBytes(pngBytes);
              logger.logWarning(
                '[Screenshot] Image conversion to ${state.format} failed. Saved as PNG instead.',
                'ScreenshotProvider',
              );
            }
          }

          final clipboard = SystemClipboard.instance;
          if (clipboard != null) {
            final item = DataWriterItem();
            item.add(Formats.png(pngBytes));
            await clipboard.write([item]);
          }

          refreshRecentCaptures();
        } else if (result is CaptureFailure) {
          logger.logError(
            '[Screenshot] Linux capture failed: ${(result as CaptureFailure).message}',
            'ScreenshotProvider',
            (result as CaptureFailure).cause,
          );
        }
      } catch (e, st) {
        logger.logError(
          '[Screenshot] Linux capture crashed',
          'ScreenshotProvider',
          e,
          st,
        );
      } finally {
        ref.read(isScreenshotProcessingProvider.notifier).set(false);
        await WindowUtils.safeShow();
      }
      return;
    }

    await startOverlay(display);
  }

  Future<void> openSaveDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final saveDirPath =
        state.saveDirectory ?? p.join(documentsDir.path, 'SQA_Screenshots');
    final saveDir = Directory(saveDirPath);

    if (await saveDir.exists()) {
      await PlatformUtils.openPath(saveDir.path);
    } else {
      await PlatformUtils.openPath(documentsDir.path);
    }
  }

  Future<void> deleteCapture(CaptureInfo info) async {
    try {
      if (await info.file.exists()) {
        await info.file.delete();
        await refreshRecentCaptures();
      }
    } catch (e) {
      ref
          .read(loggingServiceProvider.notifier)
          .logError(
            '[Screenshot] Failed to delete capture',
            'ScreenshotProvider',
            e,
          );
    }
  }

  Future<void> renameCapture(CaptureInfo info, String newName) async {
    try {
      if (await info.file.exists()) {
        final dir = info.file.parent.path;
        final extension = info.file.path.split('.').last;
        final newPath = p.join(dir, '$newName.$extension');

        await info.file.rename(newPath);
        await refreshRecentCaptures();
      }
    } catch (e) {
      ref
          .read(loggingServiceProvider.notifier)
          .logError(
            '[Screenshot] Failed to rename capture',
            'ScreenshotProvider',
            e,
          );
    }
  }

  String? validateNewName(String name, CaptureInfo currentInfo) {
    if (name.trim().isEmpty) return 'Name cannot be empty';

    if (!PlatformUtils.isValidFilename(name)) {
      return 'Contains invalid characters for your platform';
    }

    // Check for duplicates
    final filename = currentInfo.file.uri.pathSegments.last;
    final nameWithoutExt = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;

    if (name == nameWithoutExt) return null; // No change

    final extension = filename.split('.').last;
    final targetPath = p.join(currentInfo.file.parent.path, '$name.$extension');

    if (File(targetPath).existsSync()) {
      return 'A file with this name already exists';
    }

    return null;
  }

  // Window Targeting
  void setTargetingWindow(bool value) {}

  void updateTargetedWindow(Rect? rect, String? name, [int? hwnd]) {}

  void confirmTargetWindow(Rect rect, String title) {
    if (state.frozenBackgroundBytes == null && title.startsWith('Display ')) {
      // We are in "Select Monitor" spanning mode!
      final displayIndex = int.tryParse(title.split(' ').last) ?? 1;
      final display = state.availableDisplays.length >= displayIndex
          ? state.availableDisplays[displayIndex - 1]
          : state.availableDisplays.first;

      // Launch the real capture on that monitor
      _restartOverlayForMonitor(display);
      return;
    }

    state = state.copyWith(selectionRect: rect);
  }

  Future<void> _restartOverlayForMonitor(Display display) async {
    // Hide spanning window instantly
    await windowManager.setOpacity(0.01);

    // Start real overlay on that display
    await startOverlay(display);
  }

  Future<void> _safeSetIgnoreMouseEvents(bool ignore) async {
    if (Platform.isLinux) return;
    try {
      await windowManager.setIgnoreMouseEvents(ignore);
    } catch (_) {}
  }
}
