import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
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
import 'package:uuid/uuid.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../../core/window/window_utils.dart';

part 'screen_recorder_provider.g.dart';

@riverpod
class ScreenRecorderNotifier extends _$ScreenRecorderNotifier {
  Timer? _timer;
  Process? _ffmpegProcess;
  late final FfmpegEngine _engine;
  bool _isStopping = false;

  @override
  ScreenRecorderState build() {
    _engine = FfmpegEngine();

    // Kill any orphaned FFmpeg process when the provider is destroyed
    ref.onDispose(() {
      if (_ffmpegProcess != null) {
        _ffmpegProcess?.kill();
        _ffmpegProcess = null;
      }
    });

    // Check engine availability on init without downloading
    _checkEngine();
    return const ScreenRecorderState();
  }

  Future<void> _checkEngine() async {
    final ready = await FfmpegEngine.isEngineAvailable();
    state = state.copyWith(engineReady: ready);
    if (ready) {
      await refreshMonitors();
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
      monitorNames[display.id] = names.length > i ? names[i] : 'Monitor ${i + 1}';
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

      debugPrint('[ScreenRecorder] Capturing thumbnail for ${display.id}: bounds=$bounds');
      final file = await FfmpegEngine.captureDisplayThumbnail(bounds, state.availableDisplays);
      if (file != null) {
        newThumbnails[display.id] = file.path;
      }
    }

    state = state.copyWith(displayThumbnails: newThumbnails);
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
    debugPrint('[ScreenRecorder] Hiding window...');
    await windowManager.hide();

    // 2. Move to target virtual bounds FIRST while hidden.
    debugPrint('[ScreenRecorder] Moving window to: $overlayRect');
    await windowManager.setBounds(overlayRect);
    
    // 3. Wait for the OS to settle the DPI/Monitor shift
    debugPrint('[ScreenRecorder] Waiting for OS to settle...');
    await Future<void>.delayed(const Duration(milliseconds: 150));

    // 4. Prepare native window properties
    debugPrint('[ScreenRecorder] Applying frameless style...');
    await windowManager.setAsFrameless();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    
    debugPrint('[ScreenRecorder] Removing shadow and applying transparency...');
    await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    
    debugPrint('[ScreenRecorder] Setting always-on-top...');
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setIgnoreMouseEvents(false);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // 5. Update state to trigger UI rendering
    debugPrint('[ScreenRecorder] Updating state...');
    state = state.copyWith(
      previousWindowSize: currentSize,
      previousWindowPos: currentPos,
      isOverlayVisible: true,
      selectionRect: null,
      captureRect: captureRect,
      availableDisplays: displays,
    );

    // 6. Finally, show and focus the window
    debugPrint('[ScreenRecorder] Showing window...');
    await windowManager.show();
    await windowManager.focus();

    debugPrint('[ScreenRecorder] Transition complete.');
  }

  /// Registers global hotkeys for the recorder.
  /// Moved to a separate method to ensure stability during window transitions.
  Future<void> registerGlobalHotkeys() async {
    try {
      debugPrint('[ScreenRecorder] Registering hotkey (Alt + R)...');
      await hotKeyManager.unregisterAll();
      
      final hotKey = HotKey(
        key: PhysicalKeyboardKey.keyR,
        modifiers: [HotKeyModifier.alt],
        scope: HotKeyScope.system,
      );
      
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (hotKey) => toggleRecording(),
      );
      debugPrint('[ScreenRecorder] Hotkey registration successful.');
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

    debugPrint('[ScreenRecorder] Restoring window decorations and bounds...');
    
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
      finalRect = state.selectionRect!.shift(Offset(windowPos.dx, windowPos.dy));
    } else if ((state.captureMode == CaptureMode.window || state.captureMode == CaptureMode.fullScreen) && state.selectionRect != null) {
      // Use the spatially confirmed region (from shaded window or monitor selection)
      finalRect = state.selectionRect!.shift(Offset(windowPos.dx, windowPos.dy));
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
        'Rec_${const Uuid().v4().substring(0, 8)}.${state.format.toLowerCase()}';
    final savePath = '${saveDir.path}\\$filename';

    try {
      _ffmpegProcess = await _engine.startRecording(state, savePath, state.availableDisplays);

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
    }
  }

  Future<void> openSaveDirectory() async {
    final dir =
        state.saveDirectory ?? (await getApplicationDocumentsDirectory()).path;
    final saveDir = Directory('$dir\\SQA_Recordings');
    if (await saveDir.exists()) {
      await Process.start('explorer.exe', [saveDir.path]);
    }
  }

  Future<void> cancelOverlay() async {
    // Unregister hotkey
    await hotKeyManager.unregisterAll();

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
  void setSystemAudio(bool value) =>
      state = state.copyWith(systemAudioEnabled: value);
  void setShowCursor(bool value) => state = state.copyWith(showCursor: value);
  void setResolution(String value) => state = state.copyWith(resolution: value);
  void setFormat(String value) => state = state.copyWith(format: value);
  void setDelay(int value) => state = state.copyWith(delaySeconds: value);
  void setTargetWindow(String name) =>
      state = state.copyWith(targetWindowName: name);
  void setFramerate(int hz) => state = state.copyWith(framerate: hz);
  void setSaveDirectory(String path) =>
      state = state.copyWith(saveDirectory: path);
  void setCaptureMode(CaptureMode mode) =>
      state = state.copyWith(captureMode: mode);

  // Annotation Methods
  void setSelection(Rect? rect) {
    state = state.copyWith(selectionRect: rect);
    // Don't shrink anymore, stay full screen for annotations
  }

  void addAnnotation(Annotation annotation) =>
      state = state.copyWith(annotations: [...state.annotations, annotation]);
  void updateLastAnnotation(Annotation annotation) {
    if (state.annotations.isEmpty) return;
    final updated = [
      ...state.annotations.sublist(0, state.annotations.length - 1),
      annotation,
    ];
    state = state.copyWith(annotations: updated);
  }

  void clearAnnotations() => state = state.copyWith(annotations: []);
  void setTool(ScreenshotTool tool) =>
      state = state.copyWith(currentTool: tool);
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
