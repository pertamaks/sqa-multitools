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
import '../engine/ffmpeg_engine.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/providers/hotkey_provider.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../../core/window/window_utils.dart';

part 'screen_recorder_provider.g.dart';

@riverpod
class ScreenRecorderNotifier extends _$ScreenRecorderNotifier {
  Timer? _timer;
  Process? _ffmpegProcess;
  late final FfmpegEngine _engine;
  bool _isStopping = false;
  Timer? _laserTimer;

  @override
  ScreenRecorderState build() {
    _engine = FfmpegEngine();

    // Kill any orphaned FFmpeg process when the provider is destroyed
    ref.onDispose(() {
      _laserTimer?.cancel();
      if (_ffmpegProcess != null) {
        _ffmpegProcess?.kill();
        _ffmpegProcess = null;
      }
    });

    // Trigger side-effects after the provider is initialized
    Future.microtask(() {
      _checkEngine();
      refreshRecentRecordings();
    });

    return const ScreenRecorderState();
  }

  Future<void> _checkEngine() async {
    final ready = await FfmpegEngine.isEngineAvailable();
    state = state.copyWith(engineReady: ready);
    if (ready) {
      await refreshMonitors();
      await refreshAudioDevices();
    }
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
    if (!state.engineReady) return;

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
    if (!state.engineReady) return;

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
    state = state.copyWith(engineDownloadProgress: 0.0);
    try {
      await FfmpegEngine.downloadEngine((progress) {
        state = state.copyWith(engineDownloadProgress: progress);
      });
      state = state.copyWith(engineReady: true, engineDownloadProgress: null);
    } catch (e) {
      state = state.copyWith(engineDownloadProgress: null);
      throw 'Failed to download FFmpeg: $e';
    }
  }

  /// Called when the user presses start from the main UI
  Future<void> startOverlay([Rect? targetBounds]) async {
    if (!state.engineReady) {
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

    // 1. Hide the window to prevent intermediate redraw artifacts during transition
    await windowManager.hide();
    await windowManager.setBounds(overlayRect);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await windowManager.setAsFrameless();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setIgnoreMouseEvents(false);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // 5. Update state to trigger UI rendering
    state = state.copyWith(
      previousWindowSize: currentSize,
      previousWindowPos: currentPos,
      isOverlayVisible: true,
      selectionRect: null,
      captureRect: captureRect,
      availableDisplays: displays,
    );
    await windowManager.show();
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

  Future<void> _restoreWindow() async {
    final size = state.previousWindowSize ?? const Size(450, 500);
    final pos = state.previousWindowPos ?? const Offset(100, 100);

    // Restore standard window decorations to ensure rounded corners on Windows 11
    await windowManager.setHasShadow(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

    final alwaysOnTop = ref.read(themeSettingsProvider).alwaysOnTop;
    await windowManager.setAlwaysOnTop(alwaysOnTop);
    await windowManager.setBounds(
      Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height),
    );
    await windowManager.setIgnoreMouseEvents(false);
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
      _ffmpegProcess = await _engine.startRecording(
        state,
        savePath,
        state.availableDisplays,
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
      // 3. Always reset state and restore window even if ffmpeg fails
      state = state.copyWith(
        isRecording: false,
        isPaused: false,
        durationSeconds: 0,
        isOverlayVisible: false,
        annotations: [],
      );

      await _restoreWindow();
      await setIgnoreMouseEvents(false); // Hard reset last
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
        recentRecordings:
            validInfo.length > 10 ? validInfo.sublist(0, 10) : validInfo,
      );
    } catch (e) {
      debugPrint('[ScreenRecorder] Failed to refresh recordings: $e');
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
    // Unregister recorder hotkey only
    final hotkeyInfo = ref.read(hotkeySettingsProvider).recordToggle;
    await hotKeyManager.unregister(hotkeyInfo.toHotKey());

    state = state.copyWith(isOverlayVisible: false, selectionRect: null);
    await setIgnoreMouseEvents(false);
    await _restoreWindow();
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
  void setSelection(Rect? rect) {
    state = state.copyWith(selectionRect: rect);
    // Don't shrink anymore, stay full screen for annotations
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

  void clearAnnotations() => state = state.copyWith(annotations: []);
  void setColor(Color color) => state = state.copyWith(annotationColor: color);

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
}
