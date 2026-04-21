# SRS: Screen Recorder (plugin_screen_recorder)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the Screen Recorder plugin in SQA-Multitools.

### Scope
The tool is called **Screen Recorder**. It captures screen video for bug reports. It will **not** provide professional video editing features.

### Definitions & Abbreviations
- **TBD:** To Be Defined.
- **JIT:** Just-In-Time download.

### References
- [Core Architecture SRS](file:///e:/Github/sqa-tools/docs/srs/00_core.md)
- [Agent Guidelines (GEMINI.md)](file:///e:/Github/sqa-multitools/GEMINI.md)

## 2. Overall Description
### Product Perspective
This is a modular plugin for SQA-Multitools, utilizing the standard `SqaPlugin` interface.

### Product Functions
- **Capture:** Recording selecting window areas or full screen.
- **Export:** Saving video files locally to a user-selectable directory.
- **Management:** View and manage previous recordings directly from the Recording Hub.

### User Classes & Characteristics
- **Standard User:** QA Engineers recording bugs for developers.

### Operating Environment
- **Platform:** Windows Desktop.

### Design & Implementation Constraints
- **Framework:** Flutter.
- **Icon:** `Symbols.videocam`.

## 3. System Features (Functional Requirements)
### Capture Modes
- **Full Screen**: Capture any selected monitor in its entirety.
- **Selected Area**: User-defined rectangular region of the desktop.
- **Selected Window**: Specific application window, captured via spatial coordinate mapping (highly stable).

### Recording Controls
- **Description**: Standard Start, Stop, and Pause controls. Use of a Draggable Floating Bar during active recording.
- **Inputs**: User interaction via primary action button or floating bar.
- **Processing**: Real-time encoding of screen frames via FFmpeg.
- **Outputs**: MP4 or MKV local video file using the `SQA_REC_YYYYMMDD_HHMMSS` naming convention.

### Recording Hub
- **Config Summary**: Real-time summary of the active session configuration (Mode, Audio, Quality) shown in the main view.
- **Tune Shortcut**: An interactive `Symbols.tune` button replaces the static recorder icon, providing a direct jump to the technical settings panel.
- **Recent Recordings**: A list of the latest captures allowing for immediate playback (via system explorer) or deletion. Deletions must be preceded by a **SqaModal** confirmation prompt to prevent accidental data loss.

### Recording Settings
Settings are organized into logical groups within the dedicated settings panel:
- **Audio Configuration**: Explicit microphone toggle and device selection from available system inputs.
- **Visual Feedback**: Toggle visibility of the mouse cursor and independent customization of **Left-Click** and **Right-Click** ripple colors.
- **Recording Setup**: Quality selection (1080p, 720p), Framerate (60fps, 30fps), and initial **Start Delay** (Countdown).
- **System & Files**: Custom directory selection utilizing native Windows folder picker and export format selection (MP4, MKV).
- **Dependency Guarding**: Settings panel utilizes `SqaDependencyCard` to track if FFmpeg (required for audio discovery and recording) is missing and provides a unified download UI. Technical settings are hidden until resolved.

## 4. Implementation Strategy (Technical Analysis)
### Capture Mechanism
- **Engine**: Implementation via the centralized `FfmpegEngine` in `core/engine/`.
- **Absolute Coordinate Mapping**: Uses an absolute physical mapping system relative to the virtual desktop origin (top-left-most monitor). This ensures 100% precision for secondary monitors and negative logical offsets.
- **Spatial Targetting**: All capture modes (Full Screen, Area, Window) resolve to a global logical `Rect`. Window mode uses spatial confirmation via a blue shade overlay instead of brittle title matching, ensuring stability even if window titles change.
- **Crop Filter Strategy**: Uses the FFmpeg `crop` video filter to extract the target region from the global virtual desktop buffer, providing robust performance across mixed-DPI arrangements.
- **Global Input Feedback**: Uses `win32` polling to detect system-wide mouse clicks and render visual ripple animations (`ClickRipple`) in the transparent overlay. Supports distinct color configurations for **Left-Click** and **Right-Click** events to provide maximum clarity for recorded tutorials. 

- **Audio Discovery**: Uses `ffmpeg -f dshow -list_devices true` to parse and list DirectShow-compatible audio input devices for high-fidelity recording.

### UI Integration
- **Capture Overlay (Desktop-Wide)**: Built on the core `SqaCaptureOverlay` component, which manages a full-screen transparent layer across all monitors. It implements the "Passive Exit" pattern and `WindowTransitionCoordinator` synchronization to eliminate flicker when starting/stopping recordings.
- **Draggable Floating Controller**: Shows the `SqaFloatingBar` at a user-draggable position for real-time control.
- **Click-Through Logic**: The overlay intelligently toggles its own hit-test visibility (`setIgnoreMouseEvents`) based on hover state.

- **Live Annotations**: Annotations made via the floating bar are rendered over the recorded zone.

## 5. External Interface Requirements
### User Interfaces (UI)
- **Style**: Fluent Design / Material 3 recording controls.
- **Capture Overlay**: Built on the core `SqaCaptureOverlay` component for high-performance selection and flicker-free transitions.
- **Floating Bar**: Use `SqaFloatingBar` to control active sessions and monitor status. Draggable via a dedicated handle.

- **Layout**: Use `SqaPluginScrollableContent` to vertically center the recording configuration and primary status card.

### Software Interfaces
- **API**: Platform-specific Windows capture APIs and FFmpeg CLI wrapper managed by the centralized `FfmpegEngine` service.

## 6. Non-Functional Requirements (Quality Attributes)
### Performance
- Frame Rate: Stable 30fps or 60fps at 1080p/720p.
- CPU Usage: Minimized via x264 defaults.

### Safety & Security
- Data privacy: All recordings are stored locally; no cloud transmission. Downloads happen safely via HTTPS with explicit UI consent.
