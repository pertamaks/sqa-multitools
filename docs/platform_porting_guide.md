# Platform Porting Guide

This document describes how to extend SQA-Multitools to a new desktop platform
(macOS, Linux, or other future targets). It is the companion to the
**Platform Interface Pattern** refactor applied to `lib/core/window/`.

---

## 1. Architecture Overview

SQA-Multitools uses the **Platform Interface Pattern** to isolate OS-specific
native code from shared application logic. The pattern mirrors how Flutter's
official plugins (e.g. `path_provider`, `url_launcher`) handle multi-platform
support, adapted for app-level code.

```
lib/core/window/
  window_native_api.dart               ← Abstract contract (pure Dart)
  window_native_api_windows.dart       ← Windows implementation (win32 / PowerShell)
  window_native_api_macos.dart         ← (future) macOS implementation
  window_native_api_linux.dart         ← (future) Linux implementation
  window_utils.dart                    ← Facade — callers only ever touch this
```

**Key rule:** `win32`, `AppKit`, or any OS-specific FFI package is imported in
**exactly one file** — the platform implementation file. No other file
(facade, callers, tests) ever imports it.

---

## 2. The `WindowNativeApi` Contract

Every platform implementation must subclass `WindowNativeApi` from
`lib/core/window/window_native_api.dart` and implement the following methods:

| Method | Return Type | Description |
|--------|-------------|-------------|
| `getWindowInfoAt()` | `WindowInfo?` | Returns info about the topmost app window under the cursor, excluding our own process. Returns `null` if unavailable. |
| `getAppWindowPosition()` | `Offset` | Returns the current logical position of the SQA-Multitools window. Returns `Offset.zero` if unavailable. |
| `getActiveWindowTitles()` | `Future<List<String>>` | Returns a list of all visible application window titles. Returns `[]` if unavailable. |
| `getFriendlyMonitorNames()` | `Future<List<String>>` | Returns human-readable monitor names (e.g. "BenQ RL2455"). Returns `[]` if unavailable. |
| `isLeftMouseDown()` | `bool` | Synchronous check: is the left mouse button currently held? Returns `false` if unavailable. |
| `isRightMouseDown()` | `bool` | Synchronous check: is the right mouse button currently held? Returns `false` if unavailable. |
| `focusWindow(int hwnd)` | `void` | Brings the given window to the foreground. On non-Windows, `hwnd` may be 0 — implementations should no-op gracefully. |

> **Safe defaults matter.** If a method cannot be implemented on your platform,
> return the safe default (`null`, `Offset.zero`, `false`, `[]`). The overlay
> and recorder logic already handles these gracefully — they are guarded by
> `winInfo != null` and similar null checks.

---

## 3. Adding a New Platform — Step by Step

### Step 1: Create the implementation file

Create `lib/core/window/window_native_api_<platform>.dart`.

```dart
// lib/core/window/window_native_api_macos.dart (example)
import 'dart:io';
import 'package:flutter/material.dart';
import 'window_native_api.dart';

class WindowNativeApiMacOs implements WindowNativeApi {

  @override
  WindowInfo? getWindowInfoAt() {
    // Use CGWindowListCopyWindowInfo via dart:ffi
    // or `osascript` via Process.run to discover the topmost window.
    // Return null until implemented.
    return null;
  }

  @override
  Offset getAppWindowPosition() {
    // window_manager.getPosition() is cross-platform and already available.
    // But this is synchronous — use the cached value from a periodic poll
    // or return Offset.zero until a native solution is in place.
    return Offset.zero;
  }

  @override
  Future<List<String>> getActiveWindowTitles() async {
    // macOS: use `osascript` to list visible windows
    try {
      final result = await Process.run('osascript', [
        '-e',
        'tell application "System Events" to get name of every process whose visible is true',
      ]);
      if (result.exitCode == 0) {
        return result.stdout.toString().split(',').map((e) => e.trim()).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<String>> getFriendlyMonitorNames() async {
    // macOS: `system_profiler SPDisplaysDataType` lists monitor info
    try {
      final result = await Process.run('system_profiler', ['SPDisplaysDataType']);
      if (result.exitCode == 0) {
        // Parse display names from output
        final regex = RegExp(r'^\s{6}(.+):$', multiLine: true);
        return regex.allMatches(result.stdout.toString())
            .map((m) => m.group(1)!.trim())
            .toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  bool isLeftMouseDown() {
    // macOS: use CGEventSourceButtonState via dart:ffi
    // For now, return false until native FFI is implemented.
    return false;
  }

  @override
  bool isRightMouseDown() => false;

  @override
  void focusWindow(int hwnd) {
    // hwnd is not meaningful on macOS.
    // Use `NSRunningApplication.activate` via AppKit FFI,
    // or `osascript` with the app name if tracked separately.
  }
}
```

### Step 2: Register in `main.dart`

```dart
import 'core/window/window_native_api.dart';
import 'core/window/window_native_api_windows.dart';
import 'core/window/window_native_api_macos.dart'; // add this

void main() async {
  // ... existing setup ...

  if (Platform.isWindows) {
    WindowNativeApi.register(WindowNativeApiWindows());
  } else if (Platform.isMacOS) {
    WindowNativeApi.register(WindowNativeApiMacOs()); // add this
  }
  // else: stub defaults are used (safe no-ops)
}
```

### Step 3: Update `pubspec.yaml`

If your platform implementation requires a new native package (e.g. `macos_window_utils`),
add it to `pubspec.yaml`. Check the package's `platforms:` field — if it restricts to a
single OS, document it here and ensure the build pipeline handles it.

```yaml
dependencies:
  # Windows-specific (remove for non-Windows builds or use a build script)
  win32: ^5.15.0

  # Future: macOS-specific helpers (if needed)
  # macos_window_utils: ^x.y.z
```

> **Build pipeline note:** `pubspec.yaml` does not support platform-conditional
> dependencies. If a package declares `platforms: [windows]`, it will cause
> `flutter build macos` to fail. The recommended approach is a separate
> `pubspec_override` per platform or a build script that swaps the dependency
> before building. See §6 below.

### Step 4: Verify

```bash
dart analyze lib/
flutter build <platform> --release
```

---

## 4. Known Platform-Specific Gaps (Beyond `WindowNativeApi`)

The following areas are **also platform-specific** and will need attention when
porting. They are listed in priority order.

### 4.1 FFmpeg Capture Engine (`lib/core/engine/ffmpeg_engine.dart`)

| Item | Windows | macOS | Linux |
|------|---------|-------|-------|
| Download URL | `BtbN win64-gpl.zip` | Needs macOS binary | Needs Linux binary |
| Capture input | `gdigrab` | `avfoundation` + screen index | `x11grab` or `kmsgrab` |
| Audio device listing | `dshow` | `avfoundation` audio sources | `pulse` / `alsa` |
| Binary name | `ffmpeg.exe` | `ffmpeg` | `ffmpeg` |
| Path separator | `\\` (hardcoded) | `/` | `/` |

**Recommended approach:** Apply the same Platform Interface Pattern to create a
`CaptureBackendWindows` / `CaptureBackendMacOs` abstraction inside `ffmpeg_engine.dart`.
The `buildArguments()` method is the primary place to branch.

### 4.2 Screenshot Clipboard Copy (`lib/plugins/screenshot/providers/screenshot_provider.dart`)

| Platform | Current Approach | Status |
|----------|-----------------|--------|
| Windows | `Set-Clipboard -Path "..."` via PowerShell | ✅ Works |
| macOS | PowerShell not available | ❌ Broken |
| Linux | PowerShell not available | ❌ Broken |

**Recommended fix:** Replace with `super_clipboard` (already a project dependency)
to write image bytes directly to the clipboard in a platform-agnostic way.
This is a straightforward fix that removes the platform branch entirely.

### 4.3 Screenshot Save Path (`lib/plugins/screenshot/providers/screenshot_provider.dart`, line ~359)

```dart
// Current — Windows-specific backslash:
final savePath = '${saveDir.path}\\$filename';

// Fix — use path package (already a dependency):
import 'package:path/path.dart' as p;
final savePath = p.join(saveDir.path, filename);
```

### 4.4 Audio Backend (`pubspec.yaml`)

`just_audio_windows: ^0.2.1` is Windows-only. `just_audio` automatically selects
the correct backend per platform — **removing this dependency is all that is needed**
for macOS and Linux audio to work.

### 4.5 Window Opacity (`setHasShadow`, `setIgnoreMouseEvents`)

These `window_manager` APIs are cross-platform and work on macOS and Linux.
No code change required. However, the **Ghost-First transition sequence**
(AGENT.md §11) was tuned for Windows DWM — timing behaviour under macOS Quartz
and Linux compositors must be validated on a real device.

### 4.6 System Tray (`lib/core/window/tray_manager.dart`)

Already platform-guarded:
```dart
String path = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';
```
An `.icns` file would improve Retina quality on macOS but is cosmetic.
`system_tray: ^2.0.3` supports macOS and Linux natively.

### 4.7 Hotkeys (`hotkey_manager`)

`hotkey_manager: ^0.2.3` supports macOS and Linux. Requires:
- macOS: Add `NSAppleEventsUsageDescription` to `macos/Runner/Info.plist`
- Linux: Ensure `libkeybinder-3.0` is available on the target system

---

## 5. macOS Entitlements Checklist

Before any macOS feature can work, add these to
`macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<!-- Screen recording (Screenshot / Screen Recorder plugins) -->
<key>com.apple.security.device.screen-capture</key>
<true/>

<!-- Microphone (Screen Recorder audio) -->
<key>com.apple.security.device.microphone</key>
<true/>

<!-- File system access (save paths) -->
<key>com.apple.security.files.user-selected.read-write</key>
<true/>

<!-- Accessibility (global hotkeys — or disable sandbox for dev) -->
<key>com.apple.security.automation.apple-events</key>
<true/>
```

---

## 6. Build Pipeline — Adding a New Platform

When macOS or Linux builds are ready, add a job to `.github/workflows/build_release.yml`:

```yaml
build-macos:
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with:
        channel: 'stable'
    - name: Enable macOS Support
      run: |
        flutter config --enable-macos-desktop
        flutter create --platforms=macos .
    - name: Remove Windows-only dependencies
      run: |
        # Remove win32 from pubspec before macOS build
        sed -i '' '/win32:/d' pubspec.yaml
        flutter pub get
    - name: Build macOS
      run: flutter build macos --release
    - name: Package
      run: |
        cd build/macos/Build/Products/Release
        zip -r ../../../../../sqa-multitools-${{ github.ref_name }}-macos.zip *.app
```

> The `sed` step above is the pragmatic solution to the `pubspec.yaml` platform
> dependency problem. An alternative is to move `win32` to a Windows-only
> Dart package inside the repo and reference it as a path dependency.

---

## 7. Porting Confidence Summary

| Feature | Effort | Blocker? |
|---------|--------|---------|
| `WindowNativeApi` impl | Medium | Only until implemented |
| FFmpeg `avfoundation` | High | Yes — screenshot/recorder broken without it |
| Remove `just_audio_windows` | Very Low | Yes — compile fails |
| Fix path separator | Very Low | No — silent data issue |
| Replace PowerShell clipboard | Low | No — clipboard just won't work |
| macOS entitlements | Low–Medium | Yes — OS silently blocks features |
| Overlay timing tuning | Medium | No — functional, may look off |
| CI pipeline job | Low | No — can build locally first |

---

*Last updated after the `WindowNativeApi` Platform Interface refactor (May 2026).*
*Update this document whenever a new platform implementation is added or a new*
*platform-specific gap is discovered.*
