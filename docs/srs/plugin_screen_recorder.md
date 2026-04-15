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

### User Classes & Characteristics
- **Standard User:** QA Engineers recording bugs for developers.

### Operating Environment
- **Platform:** Windows Desktop.

### Design & Implementation Constraints
- **Framework:** Flutter.
- **Icon:** `Symbols.videocam`.

## 3. System Features (Functional Requirements)
### Capture Modes
- **Full Screen**: Capture the entire primary monitor.
- **Selected Area**: User-defined rectangular region of the screen.
- **Selected Window**: Specific application window (planned/supported via ffmpeg title match).

### Recording Controls
- **Description**: Standard Start, Stop, and Pause controls. Use of a Draggable Floating Bar during active recording.
- **Inputs**: User interaction via primary action button or floating bar.
- **Processing**: Real-time encoding of screen frames via FFmpeg.
- **Outputs**: MP4 or MKV local video file.

### Recording Settings
- **Audio**: Capture of Microphone inputs.
- **Visuals**: Toggle visibility of the mouse cursor and **global click feedback** (visual ripples on click).
- **Quality**: Resolution selection (1080p, 720p) and Framerate (60fps, 30fps).
- **Save Path**: Custom directory selection utilizing native Windows folder picker.
- **Window Targeting**: High-fidelity window discovery with searching and "System Junk" filtering.

## 4. Implementation Strategy (Technical Analysis)
### Capture Mechanism
- **Full Screen / Area**: Implementation via **FFmpeg**.
- **Window Selection**: Uses PowerShell-based discovery to fetch friendly window names and process handles, filtered to exclude system processes. UI is presented in a searchable `SqaPickerDialog`.
- **Global Input Feedback**: Uses `win32` `GetAsyncKeyState` polling to detect system-wide mouse clicks and render visual ripple animations (`ClickRipple`) in the transparent overlay, even when clicking through to other applications.

### UI Integration
- **Area Selection (Desktop-Wide Overlay)**: The existing `MainToolbar` window is temporarily set to borderless and fully transparent, artificially stretching across the bounds of all connected desktop monitors (via `screen_retriever`). 
- **Draggable Floating Controller**: Upon selecting an area or starting a full screen record, the transparent boundary stays full-screen to allow for desktop-wide annotations while showing the `SqaFloatingBar` at a user-draggable position.
- **Click-Through Logic**: The overlay intelligently toggles its own hit-test visibility (`setIgnoreMouseEvents`) based on whether the user's cursor is hovering over the floating toolbar. This ensures underlying applications remain interactable while recording.
- **Live Annotations**: Annotations made via the floating bar are rendered over the recorded zone.

## 5. External Interface Requirements
### User Interfaces (UI)
- **Style**: Fluent Design / Material 3 recording controls.
- **Floating Bar**: Use `SqaFloatingBar` to control active sessions and monitor status. Now draggable via a dedicated drag handle.
- **Layout**: Use `SqaPluginScrollableContent` to vertically center the recording configuration and primary status card.

### Software Interfaces
- **API**: Platform-specific Windows capture APIs and FFmpeg CLI wrapper managed by the internal `FfmpegEngine` class.

## 6. Non-Functional Requirements (Quality Attributes)
### Performance
- Frame Rate: Stable 30fps or 60fps at 1080p/720p.
- CPU Usage: Minimized via x264 defaults.

### Safety & Security
- Data privacy: All recordings are stored locally; no cloud transmission. Downloads happen safely via HTTPS with explicit UI consent.
