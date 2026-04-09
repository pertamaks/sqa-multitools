# SRS: Screen Recorder (plugin_screen_recorder)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the Screen Recorder plugin in SQA-Multitools.

### Scope
The tool is called **Screen Recorder**. It captures screen video for bug reports. It will **not** provide professional video editing features.

### Definitions & Abbreviations
- **TBD:** To Be Defined.

### References
- [Core Architecture SRS](file:///e:/Github/sqa-tools/docs/srs/00_core.md)

## 2. Overall Description
### Product Perspective
This is a modular plugin for SQA-Multitools, utilizing the standard `SqaPlugin` interface.

### Product Functions
- **Capture:** Recording selecting window areas.
- **Export:** Saving video files locally.

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
- **Selected Window**: Specific application window identified by its handle (HWND).

### Recording Controls
- **Description**: Standard Start, Stop, and Pause controls.
- **Inputs**: User interaction via primary action button.
- **Processing**: Real-time encoding of screen frames.
- **Outputs**: MP4 or MKV local video file.

### Recording Settings
- **Audio**: Optional capture of Microphone and System Audio.
- **Visuals**: Toggle visibility of the mouse cursor and click highlights.
- **Quality**: Resolution selection (1080p, 720p) and format selection (MP4, MKV).

## 4. Implementation Strategy (Technical Analysis)
### Capture Mechanism
- **Full Screen / Area**: Implementation via **FFmpeg** bundled with the application.
  - Full Screen: `ffmpeg -f gdigrab -i desktop ...`
  - Area: `ffmpeg -f gdigrab -offset_x [X] -offset_y [Y] -video_size [WxH] -i desktop ...`
- **Windows Capture**: Modern **Windows Graphics Capture API** or Win32 `PrintWindow`/`BitBlt` for targeted window recording.

### UI Integration
- **Area Selection**: A transparent, borderless Flutter window will be used as an overlay to allow users to drag and define the capture region.
- **Window Picker**: Enumeration of active windows using Win32 API (`EnumWindows`) to provide a list of targets.

## 5. External Interface Requirements
### User Interfaces (UI)
- **Style**: Material 3 recording controls.
- **Floating Bar**: Use `SqaFloatingBar` to control active sessions and monitor status.
- **Layout**: Use `SqaPluginScrollableContent` to vertically center the recording configuration and primary status card.
- **Status Indicator**: Uses a high-contrast Red color with **Pulsing Pulse Effect** during recording.
- **Settings**: Moved configuration (audio, cursor, quality) to a dedicated settings panel in the `Settings` plugin.
- **Mode Selection**: `SqaSegmentedButton` for switching between Full Screen, Area, and Window modes.

### Hardware Interfaces
- **Direct Link**: GPU acceleration (nvenc/qsv/vaapi) for encoding where available.

### Software Interfaces
- **API**: Platform-specific Windows capture APIs and FFmpeg CLI wrapper.

## 6. Non-Functional Requirements (Quality Attributes)
### Performance
- Frame Rate: Stable 30fps minimum at 1080p.
- CPU Usage: Minimized through hardware acceleration.

### Safety & Security
- Data privacy: All recordings are stored locally; no cloud transmission.

### Reliability
- File Integrity: Guaranteed on save, with temporary file recovery (MKV).

### Maintainability
- Isolated plugin structure with decoupled capture logic.
