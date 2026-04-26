import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show Color, Rect, Size, Offset, Colors;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:path_provider/path_provider.dart';
import '../models/screen_recorder_state.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/annotation.dart';
import '../../../core/models/screenshot_tool.dart';
import '../../../core/engine/ffmpeg_engine.dart';
import '../../../core/providers/ffmpeg_provider.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/providers/hotkey_provider.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../../core/window/window_utils.dart';
import '../../../core/window/window_transition_coordinator.dart';

part 'screen_recorder_provider.g.dart';

@riverpod
class ScreenRecorderNotifier extends _$ScreenRecorderNotifier {
  Timer? _timer;
  Process? _ffmpegProcess;
  bool _isStopping = false;
  Timer? _laserTimer;

  @override
  ScreenRecorderState build() {
    // Kill any orphaned FFmpeg process when the provider is destroyed
    ref.onDispose(() {
      _laserTimer?.cancel();
      if (_ffmpegProcess != null) {
        _ffmpegProcess?.kill();
        _ffmpegProcess = null;
      }
    });

    // Listen to engine status changes
    ref.listen(ffmpegProvider, (previous, next) {
      if (!previous!.isReady && next.isReady) {
        refreshMonitors();
        refreshAudioDevices();
      }
    });

    // Trigger side-effects after the provider is initialized
    Future.microtask(() {
      refreshRecentRecordings();
    });

    return const ScreenRecorderState();
  }

  /// Refreshes the list of available monitors and their friendly names.
  Future<void> refreshMonitors() async {
    final displays = await screenRetriever.getAllDisplays();
    final names = await WindowUtils.getFriendlyMonitorNames();
    final primary = await screenRetriever.getPrimaryDisplay();

    final Map<String, String> monitorNames = {};

    // 2. Simple Mapping: Trust discovery order + Thumbnail for identification
    for (int i = 0; i < displays.length; i++) {
      final display = displays[i];
      monitorNames[display.id] = names.length > i
          ? names[i]
          : 'Monitor ${i + 1}';
    }

    state = state.copyWith(
      availableDisplays: displays,
      monitorNames: monitorNames,
      primaryDisplayId: primary.id,
    );

    // Trigger visual thumbnail refresh
    await refreshThumbnails();
  }

  /// Manually refreshes the visual snapshots of all monitors.
  Future<void> refreshThumbnails() async {
    final engineReady = ref.read(ffmpegProvider).isReady;
    if (!engineReady) return;

    final Map<String, String> newThumbnails = Map.from(state.displayThumbnails);

    // Capture each display SEQUENTIALLY to avoid GDI race conditions
    for (final display in state.availableDisplays) {
      final bounds = Rect.fromLTWH(
        display.visiblePosition?.dx ?? 0,
        display.visiblePosition?.dy ?? 0,
        display.size.width,
        display.size.height,
      );

      /* debugPrint(
        '[ScreenRecorder] Capturing thumbnail for ${display.id}: bounds=$bounds',
      ); */
      final file = await FfmpegEngine.captureDisplayThumbnail(
        bounds,
        state.availableDisplays,
      );
      if (file != null) {
        newThumbnails[display.id] = file.path;
      }
    }

    state = state.copyWith(displayThumbnails: newThumbnails);
  }

  /// Refreshes the list of available audio input devices.
  Future<void> refreshAudioDevices() async {
    final engineReady = ref.read(ffmpegProvider).isReady;
    if (!engineReady) return;

    final devices = await FfmpegEngine.listAudioDevices();
    state = state.copyWith(
      availableAudioDevices: devices,
      selectedAudioDevice: (devices.contains(state.selectedAudioDevice))
          ? state.selectedAudioDevice
          : (devices.isNotEmpty ? devices.first : null),
    );
  }

  /// Downloads the engine
  Future<void> installEngine() async {
    await ref.read(ffmpegProvider.notifier).download();
  }

  /// Called when the user presses start from the main UI
  Future<void> startOverlay([Rect? targetBounds]) async {
    final engineReady = ref.read(ffmpegProvider).isReady;
    if (!engineReady) {
      throw 'Engine not ready.';
    }

    final currentSize = await windowManager.getSize();
    final currentPos = await windowManager.getPosition();

    // Determine target bounds
    final displays = await screenRetriever.getAllDisplays();

    // overlayRect: the physical Flutter window bounds (covers all monitors for Window/Area)
    // captureRect: the intended recording region (single monitor for fullScreen, null until selection for others)
    Rect overlayRect;
    Rect? captureRect;

    if (targetBounds != null) {
      // A specific monitor was selected (fullScreen/area from picker dialog)
      overlayRect = targetBounds;
      captureRect = targetBounds;
    } else {
      // No target specified — span the entire virtual desktop
      // This allows Window/Area mode to target windows on any monitor
      double minX = 0;
      double minY = 0;
      double maxX = 0;
      double maxY = 0;

      for (final display in displays) {
        final pos = display.visiblePosition ?? Offset.zero;
        final size = display.size;
        minX = math.min(minX, pos.dx);
        minY = math.min(minY, pos.dy);
        maxX = math.max(maxX, pos.dx + size.width);
        maxY = math.max(maxY, pos.dy + size.height);
      }
      overlayRect = Rect.fromLTRB(minX, minY, maxX, maxY);
      // captureRect stays null — it will be set when the user selects a window or draws an area
    }

    final coordinator = ref.read(windowTransitionProvider);

    // 1. Ghost the window instantly and wait for OS commitment
    await windowManager.setOpacity(0.0);
    await coordinator.waitForSync(resize: false, move: false);

    // 2. Prepare the background state while invisible
    await windowManager.setAsFrameless();
    await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);

    // 3. Update state early so Flutter starts building the transparent overlay UI
    final hotkeyInfo = ref.read(hotkeySettingsProvider).recordToggle;
    final registeredHotKey = hotkeyInfo.toHotKey();

    state = state.copyWith(
      previousWindowSize: currentSize,
      previousWindowPos: currentPos,
      isOverlayVisible: true,
      selectionRect: null,
      captureRect: captureRect,
      availableDisplays: displays,
      lockedDisplay: null,
      registeredHotKey: registeredHotKey,
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

    // Register hotkey with the stored instance
    await hotKeyManager.register(
      registeredHotKey,
      keyDownHandler: (hk) => toggleRecording(),
    );

    // 6. Finally reveal and focus
    await windowManager.setOpacity(1.0);
    await windowManager.focus();
  }

  /// Registers global hotkeys for the recorder.
  /// Moved to a separate method to ensure stability during window transitions.
  Future<void> registerGlobalHotkeys() async {
    try {
      final hotkeyInfo = ref.read(hotkeySettingsProvider).recordToggle;
      final hotKey = hotkeyInfo.toHotKey(identifier: 'recorder_toggle');

      // We should not use unregisterAll() here as it would clear the toolbar hotkey.
      // Instead, we just register this one. hotkey_manager handles duplicates if identifier is same.
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (hotKey) => toggleRecording(),
      );
    } catch (e) {
      debugPrint('[ScreenRecorder] Hotkey registration failed: $e');
    }
  }

  /// Toggles whether the window intercepts mouse events.
  /// Used to allow clicking THROUGH the overlay to reach underlying apps.
  Future<void> setIgnoreMouseEvents(bool ignore) async {
    await windowManager.setIgnoreMouseEvents(ignore);
  }

  Future<void> toggleRecording() async {
    if (state.isRecording) {
      await _stopRecording();
    } else if (state.countdownSeconds > 0) {
      // Already counting down — ignore duplicate presses
      return;
    } else if (state.delaySeconds > 0) {
      // Start countdown
      state = state.copyWith(countdownSeconds: state.delaySeconds);
      for (int i = state.delaySeconds; i > 0; i--) {
        if (state.countdownSeconds == 0) return; // Cancelled
        state = state.copyWith(countdownSeconds: i);
        await Future<void>.delayed(const Duration(seconds: 1));
        if (state.countdownSeconds == 0) return; // Cancelled during wait
      }
      state = state.copyWith(countdownSeconds: 0);
      await _startRecording();
    } else {
      await _startRecording();
    }
  }

  /// Cancels an active countdown without closing the overlay.
  void cancelCountdown() {
    state = state.copyWith(countdownSeconds: 0);
  }

  Future<void> _startRecording() async {
    // Finalize capture bounds based on mode
    Rect? finalRect;
    final windowPos = await windowManager.getPosition();

    if (state.captureMode == CaptureMode.area && state.selectionRect != null) {
      // selectionRect is in LOCAL overlay coordinates.
      // Shift by the window's actual position to get global logical coords.
      finalRect = state.selectionRect!.shift(
        Offset(windowPos.dx, windowPos.dy),
      );
    } else if ((state.captureMode == CaptureMode.window ||
            state.captureMode == CaptureMode.fullScreen) &&
        state.selectionRect != null) {
      // Use the spatially confirmed region (from shaded window or monitor selection)
      finalRect = state.selectionRect!.shift(
        Offset(windowPos.dx, windowPos.dy),
      );
    } else if (state.captureMode == CaptureMode.fullScreen) {
      // Fallback for picker-based or direct targeting
      if (state.captureRect != null) {
        finalRect = state.captureRect;
      } else {
        // Fallback: primary display
        final displays = await screenRetriever.getAllDisplays();
        final primary = displays.cast<Display?>().firstWhere(
          (d) => d?.visiblePosition?.dx == 0 && d?.visiblePosition?.dy == 0,
          orElse: () => displays.isNotEmpty ? displays.first : null,
        );
        if (primary != null) {
          finalRect = Rect.fromLTWH(
            primary.visiblePosition?.dx ?? 0,
            primary.visiblePosition?.dy ?? 0,
            primary.size.width,
            primary.size.height,
          );
        }
      }
    }

    state = state.copyWith(
      isRecording: true,
      isPaused: false,
      durationSeconds: 0,
      annotations: [],
      currentTool: ScreenshotTool.pointer,
      captureRect: finalRect,
    );
    // Construct save path
    final dir =
        state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final saveDir = Directory('$dir\\SQA_Recordings');
    if (!await saveDir.exists()) await saveDir.create(recursive: true);

    final filename =
        'SQA_REC_${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}_${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}.${state.format.toLowerCase()}';
    final savePath = '${saveDir.path}\\$filename';

    try {
      final config = FfmpegVideoConfig(
        framerate: state.framerate,
        resolution: state.resolution,
        showCursor: state.showCursor,
        captureMode: state.captureMode,
        captureRect: state.captureRect,
        microphoneEnabled: state.microphoneEnabled,
        selectedAudioDevice: state.selectedAudioDevice,
      );

      _ffmpegProcess = await FfmpegEngine().startRecording(
        config: config,
        savePath: savePath,
        displays: state.availableDisplays,
      );

      // Listener for unexpected exit
      _ffmpegProcess!.exitCode.then((code) {
        if (state.isRecording) {
          _stopRecording();
        }
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!state.isPaused) {
          state = state.copyWith(durationSeconds: state.durationSeconds + 1);
        }
      });
    } catch (e) {
      await _restoreWindowInternal();
      state = state.copyWith(isRecording: false);
      throw 'Failed to start recording: $e';
    }
  }

  Future<void> _stopRecording() async {
    if (_isStopping) return;
    _isStopping = true;

    // 1. Immediately stop the timer and ensure interaction is restored
    _timer?.cancel();
    _timer = null;
    await setIgnoreMouseEvents(false);

    try {
      // 2. Gracefully stop ffmpeg by sending 'q'
      if (_ffmpegProcess != null) {
        try {
          _ffmpegProcess!.stdin.writeln('q');
          // Give it 2 seconds to close gracefully, then force kill if needed
          await _ffmpegProcess!.exitCode.timeout(const Duration(seconds: 2));
        } catch (_) {
          _ffmpegProcess?.kill();
        }
        _ffmpegProcess = null;
      }
    } finally {
      _isStopping = false;
      // Use the hardened Ghost-First sequence for a clean transition back to toolbar
      await cancelOverlay();
      refreshRecentRecordings();
    }
  }

  Future<void> refreshRecentRecordings() async {
    if (!ref.mounted) return;
    final dir =
        state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    if (!ref.mounted) return;
    final saveDir = Directory('$dir\\SQA_Recordings');
    if (!await saveDir.exists()) {
      if (!ref.mounted) return;
      state = state.copyWith(recentRecordings: []);
      return;
    }

    try {
      final fileList = await saveDir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();

      // Fetch metadata asynchronously for all files
      final infoList = await Future.wait(
        fileList.map((file) async {
          try {
            final stats = await file.stat();
            return RecordingInfo(
              file: file,
              size: stats.size,
              modified: stats.modified,
            );
          } catch (e) {
            debugPrint('[ScreenRecorder] Failed to stat file ${file.path}: $e');
            return null; // Skip files that result in errors
          }
        }),
      );

      final validInfo = infoList.whereType<RecordingInfo>().toList();

      // Sort by modified date descending
      validInfo.sort((a, b) => b.modified.compareTo(a.modified));

      if (!ref.mounted) return;

      // Take top 10
      state = state.copyWith(
        recentRecordings: validInfo.length > 10
            ? validInfo.sublist(0, 10)
            : validInfo,
      );
    } catch (e) {
      // Silent catch for unexpected file system errors
    }
  }

  Future<void> deleteRecording(RecordingInfo info) async {
    try {
      if (await info.file.exists()) {
        await info.file.delete();
        await refreshRecentRecordings();
      }
    } catch (e) {
      debugPrint('[ScreenRecorder] Failed to delete recording: $e');
    }
  }

  Future<void> openSaveDirectory() async {
    final dir =
        state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final saveDir = Directory('$dir\\SQA_Recordings');

    // fallback to root dir if subfolder doesn't exist yet
    final targetDir = await saveDir.exists() ? saveDir : Directory(dir);

    if (await targetDir.exists()) {
      await Process.start('explorer.exe', [targetDir.path]);
    }
  }

  Future<void> cancelOverlay() async {
    final coordinator = ref.read(windowTransitionProvider);

    // 1. Ghost the window instantly as the absolute FIRST step
    // Use 0.01 temporarily to keep the layered context warm
    await windowManager.setOpacity(0.01);
    await coordinator.waitForSync(resize: false, move: false);

    // 2. Perform background cleanup while invisible
    // (WE DEFER setIgnoreMouseEvents(false) to the very end)

    // 3. Unregister recorder hotkey immediately (using MATCHED instance)
    if (state.registeredHotKey != null) {
      try {
        await hotKeyManager.unregister(state.registeredHotKey!);
      } catch (e) {
        // Silent catch for hotkey cleanup
      }
    }

    // 4. Physically restore window bounds BEFORE switching UI state
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

    // 5. NOW switch the UI state to Toolbar mode
    state = state.copyWith(
      isOverlayVisible: false,
      selectionRect: null,
      targetedWindowRect: null,
      lockedDisplay: null,
      registeredHotKey: null,
      isRecording: false,
      isPaused: false,
      durationSeconds: 0,
      annotations: [],
      currentTool: ScreenshotTool.pointer,
    );

    // 6. Wait for Flutter to commit the first frame of the Small UI
    await coordinator.waitForSync(resize: false, move: false, frame: true);
    final theme = ref.read(themeSettingsProvider);

    // 7. Finally restore attributes, reveal and focus
    // Move all attribute changes here to prevent DWM flushes on giant window
    await Future.wait([
      windowManager.setHasShadow(true),
      windowManager.setTitleBarStyle(TitleBarStyle.hidden),
      windowManager.setAlwaysOnTop(theme.alwaysOnTop),
      setIgnoreMouseEvents(false),
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

  void togglePause() {
    if (state.isRecording) {
      state = state.copyWith(isPaused: !state.isPaused);
      // Ffmpeg pausing on windows usually requires sending suspending signals to the process
      // which is complex. For now, UI pauses but ffmpeg doesn't.
      // This is a known limitation in v1.
    }
  }

  void setMicrophone(bool value) =>
      state = state.copyWith(microphoneEnabled: value);
  void toggleMicrophone() =>
      state = state.copyWith(microphoneEnabled: !state.microphoneEnabled);
  void setSystemAudio(bool value) =>
      state = state.copyWith(systemAudioEnabled: value);
  void setShowCursor(bool value) => state = state.copyWith(showCursor: value);
  void setResolution(String value) => state = state.copyWith(resolution: value);
  void setFormat(String value) => state = state.copyWith(format: value);
  void setDelay(int value) => state = state.copyWith(delaySeconds: value);
  void setTargetWindow(String name) =>
      state = state.copyWith(targetWindowName: name);
  void setFramerate(int hz) => state = state.copyWith(framerate: hz);
  void setSaveDirectory(String path) {
    state = state.copyWith(saveDirectory: path);
    refreshRecentRecordings();
  }

  void setCaptureMode(CaptureMode mode) =>
      state = state.copyWith(captureMode: mode);

  void setSelectedAudioDevice(String? device) =>
      state = state.copyWith(selectedAudioDevice: device);

  void setClickFeedbackColor(Color color) =>
      state = state.copyWith(clickFeedbackColor: color);
  void setRightClickFeedbackColor(Color color) =>
      state = state.copyWith(rightClickFeedbackColor: color);

  // Annotation Methods
  void setSelection(Rect? rect, [Display? display]) {
    if (display != null && state.lockedDisplay != display) {
      state = state.copyWith(lockedDisplay: display);
    }

    state = state.copyWith(selectionRect: rect);

    // If we just finished a drag (rect is final) and have a logical lock, trigger physical lock
    if (rect != null && state.lockedDisplay != null && !state.isRecording) {
      _lockToMonitor(rect, providedDisplay: state.lockedDisplay);
    }
  }

  void setTool(ScreenshotTool tool) =>
      state = state.copyWith(currentTool: tool);

  // Laser Pointer Pruning Logic
  void _startLaserTimer() {
    if (_laserTimer != null) return;
    _laserTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _pruneLasers();
    });
  }

  void _stopLaserTimer() {
    _laserTimer?.cancel();
    _laserTimer = null;
  }

  void _pruneLasers() {
    final now = DateTime.now();
    final updatedAnnotations = <Annotation>[];
    bool hasLaser = false;

    for (final ann in state.annotations) {
      if (ann.tool == ScreenshotTool.laser) {
        final newPoints = <Offset>[];
        final newTimestamps = <DateTime>[];

        for (int i = 0; i < ann.points.length; i++) {
          if (now.difference(ann.pointTimestamps[i]).inMilliseconds < 1000) {
            newPoints.add(ann.points[i]);
            newTimestamps.add(ann.pointTimestamps[i]);
          }
        }

        if (newPoints.isNotEmpty) {
          updatedAnnotations.add(
            ann.copyWith(points: newPoints, pointTimestamps: newTimestamps),
          );
          hasLaser = true;
        }
        // If empty, it's naturally removed by not being added to updatedAnnotations
      } else {
        updatedAnnotations.add(ann);
      }
    }

    state = state.copyWith(annotations: updatedAnnotations);
    if (!hasLaser) {
      _stopLaserTimer();
    }
  }

  void addAnnotation(Annotation annotation) {
    state = state.copyWith(annotations: [...state.annotations, annotation]);
    if (annotation.tool == ScreenshotTool.laser) {
      _startLaserTimer();
    }
  }

  void updateLastAnnotation(Annotation annotation) {
    if (state.annotations.isEmpty) return;
    final updated = [
      ...state.annotations.sublist(0, state.annotations.length - 1),
      annotation,
    ];
    state = state.copyWith(annotations: updated);
    if (annotation.tool == ScreenshotTool.laser) {
      _startLaserTimer();
    }
  }

  void removeAnnotation(Annotation annotation) {
    final updated = state.annotations.where((a) => a != annotation).toList();
    state = state.copyWith(annotations: updated);
  }

  void clearAnnotations() => state = state.copyWith(annotations: []);
  void setColor(Color color) => state = state.copyWith(annotationColor: color);
  void setTextHasBackground(bool value) =>
      state = state.copyWith(textHasBackground: value);

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

  Future<void> confirmTargetWindow(Rect rect, String title) async {
    final hwnd = state.targetedWindowHwnd;

    state = state.copyWith(
      isTargetingWindow: false,
      selectionRect: rect,
      targetWindowName: title,
    );

    await _lockToMonitor(rect);

    // Bring the window to front
    if (hwnd != null && hwnd != 0) {
      WindowUtils.focusWindow(hwnd);
    }
  }

  void startAreaSelection() {
    startOverlay().catchError((e) {
      // Intentionally ignore for now, UI handles error.
    });
  }

  /// Physically shrinks the overlay window to cover only the target monitor.
  /// This reduces DWM overhead and constrains interaction boundaries.
  Future<void> _lockToMonitor(
    Rect targetRect, {
    Display? providedDisplay,
  }) async {
    if (!state.isOverlayVisible || state.isRecording) return;

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
    // We must shift local coordinates to stay spatially consistent after the window moves.
    final windowPos = WindowUtils.getAppWindowPosition();
    final globalSelection = state.selectionRect?.shift(windowPos);
    final globalTargeted = state.targetedWindowRect?.shift(windowPos);

    final newWindowPos = targetDisplayRect.topLeft;
    final newLocalSelection = globalSelection?.shift(-newWindowPos);
    final newLocalTargeted = globalTargeted?.shift(-newWindowPos);

    // 4. Physical Move
    await windowManager.setBounds(targetDisplayRect);

    // 5. High-fidelity Sync
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
