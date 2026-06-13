# Cross-Platform In-App Media Annotator Architecture

This document serves as a technical hand-off and development summary for the Media Annotator feature. This tool acts as a cross-platform fallback and alternative to live OS-level transparency recording (which is unsupported on native Wayland without XWayland).

## Implementation Highlights

### 1. Window Reuse Architecture (Crash Prevention)
We encountered a critical, low-level engine bug on Linux where destroying an `FlView` (the native Flutter View inside a GTK window) via `desktop_multi_window` would crash the application due to an aggressive EGL context teardown (`eglMakeCurrent failed`).

To bypass this entirely, we implemented a **Window Reuse Strategy**:
- The "Close" and "Save" operations now use `windowManager.hide()` instead of `pop()` or `close()`.
- When the user clicks "Annotate" on a media file, the main window searches for an existing annotator window in the background.
- If it exists, it sends an asynchronous payload (`invokeMethod('setMedia')`) containing the new file path, allowing the isolated annotator to rebuild dynamically without ever tearing down the OpenGL context.

### 2. Resolution-Preserving FFmpeg Pipeline
To ensure annotations don't degrade the quality of the original high-resolution captures, we revamped the `RepaintBoundary` and FFmpeg composite logic:
- **Tight Bounding**: The `RepaintBoundary` is now tightly coupled to the exact dimensions of the source `Image` or `Video` using a loosely fitted `Stack`. This ensures the transparent PNG extracted contains *only* the annotations without any letterboxed window artifacts.
- **Scale and Composite**: We utilize FFmpeg for **both** images and videos with the filter `[1:v]scale=iw:ih[ovrl];[0:v][ovrl]overlay=0:0`. This perfectly scales the extracted transparent overlay to the pristine source resolution and burns it into the file without quality degradation.

## Known Issues for Future Development

The following bugs require addressing in future development sessions to achieve complete stability:

### 1. Multi-Window IPC Crash
When clicking "Save", the annotator window attempts to trigger a refresh in the main window using `WindowController.fromWindowId('0').invokeMethod('refresh')`. However, `desktop_multi_window` v0.3.0 enforces that `invokeMethod` can *only* be called on the current window controller. Attempting to call it on window `0` from the annotator isolate throws an `Async Error`. 

**Suggested Fix:** We need to establish a bidirectional `WindowChannel` or explore the proper cross-window messaging syntax supported in v0.3.0.

### 2. `media_kit` MPV Disposal Segfault
When the annotator's `MaterialApp` rebuilds entirely (via changing the `ValueKey` upon receiving a new media payload), the old `MediaAnnotatorView` is disposed. This triggers `media_kit` to release its native resources. If MPV callbacks are still active during this rapid teardown, it causes a `Callback invoked after it has been deleted` segfault in `libmpv.so.2`. 

**Suggested Fix:** We need to ensure a graceful asynchronous disposal of the `VideoController` and `Player` instances *before* the UI tree rebuilds or the isolate forces garbage collection on the native references.

---
*This architecture fundamentally solves the Wayland constraints while retaining high-fidelity outputs. Fixing the IPC messaging and native player disposal will finalize its stability.*
