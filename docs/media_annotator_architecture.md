# Cross-Platform In-App Media Annotator Architecture

This document serves as a technical hand-off and development summary for the Media Annotator feature. This tool acts as a cross-platform fallback and alternative to live OS-level transparency recording (which is unsupported on native Wayland without XWayland) and provides robust image editing capabilities.

## Implementation Highlights

### 1. Single Window Pivot (Crash Prevention & UX)
We encountered critical bugs when attempting to use `desktop_multi_window` for the annotator, including aggressive EGL context teardown crashes (`eglMakeCurrent failed`), IPC messaging failures between isolates, and `media_kit` MPV disposal segfaults during rapid isolate teardowns.

To bypass these instability vectors entirely, we pivoted to a **Single Window Architecture**:
- The Media Annotator now operates entirely inside the main application instance (`SqaMultitoolsApp`).
- When a user triggers an annotation, the main window immediately expands to cover the screen and navigates to the `MediaAnnotatorView`. 
- This eliminated all cross-isolate IPC requirements and provided rock-solid stability for native video rendering.

### 2. Resolution-Preserving FFmpeg Pipeline
To ensure annotations don't degrade the quality of the original high-resolution captures, we developed a highly robust `RepaintBoundary` and FFmpeg composite logic:
- **Aspect Ratio Locking**: The drawing canvas is perfectly locked to the native source media using `AspectRatio` and `StackFit.expand`. This guarantees that drawing coordinates translate exactly to the source material without letterbox drifting.
- **Dynamic Supersampling**: When extracting the UI canvas to an image, the system calculates a dynamic `pixelRatio` based on the current window size to guarantee at least a 2.5K high-fidelity PNG extraction.
- **Scale and Composite**: We utilize FFmpeg for **both** images and videos with the filter `[1:v][0:v]scale2ref[ovrl][main];[main][ovrl]overlay=0:0`. This perfectly scales the extracted transparent overlay to the pristine source resolution and burns it into the file without quality degradation.

### 3. Decoupled Asynchronous Processing (Zero-Block UX)
To prevent the application from freezing while FFmpeg encodes the final media, the save pipeline was heavily decoupled:
- **Instant Close**: The moment the user clicks "Save", the transparent PNG overlay is immediately captured synchronously (`boundary.toImage()`).
- **Global Background Task**: The heavy FFmpeg execution is handed off to an asynchronous background task (`_processSaveInBackground`). Because the task uses the root `globalProviderContainer`, it survives the immediate `Navigator.pop()` of the annotator screen.
- **Global Blur Feedback**: A root-level `GlobalProcessingNotifier` dynamically frosts the entire application (including the main toolbar) while the background FFmpeg encode happens, creating a seamless and beautiful user experience without blocking them on a loading screen.

### 4. Unified Interface & Media Controls
- For videos, a custom floating media controller (Play/Pause, scrub slider, digital timecode) is dynamically injected into the `leading` section of the `SqaAnnotationToolbar`.
- This unifies the media controls and the drawing tools into a single, wide horizontal command center that floats safely above the drawing canvas, avoiding both visual clutter and click-interception issues.
- The `pointer` tool was eliminated in favor of an `eraser` tool since the canvas explicitly absorbs pointer events to allow drawing.
