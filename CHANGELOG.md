# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-06-16

### Added
- **Swagger Explorer Plugin:** Complete plugin to parse and explore Swagger/OpenAPI documentation.
- **Media Annotator:** Integrated native annotator for modifying captured media.
- **Linux Support:** Added Linux AppImage build pipeline and platform compatibility improvements.
- **Taskbar/Dock Visibility:** Added toggle to show or hide the application icon in the system taskbar/dock.
- **Auto Run on Startup:** Added toggle in Settings to automatically launch the app on login, featuring self-healing paths for portable versions.

### Changed
- **cURL Requester:** Overhauled integration, added inline variable feedback, binary uploads, and synchronized docs.
- **Architecture:** Standardized state management using Riverpod code generation and resolved major technical debt across the application.
- **UI:** Fixed text editor view padding and resolved global hover bleeding.

## [0.3.0] - 2026-05-26

### Added
- **Long Screenshot:** Capture scrollable areas and stitch frames into a single long screenshot. Supports both vertical and horizontal scroll directions with manual toggle.
- **Hotkey Support:** Global hotkeys for recorder (start/stop, area recording, fullscreen recording) and screenshot modes (area capture toggle, fullscreen capture).
- **Zero-Distortion Screenshot Capture:** New native FFI-based background extraction (`silent_frozen_canvas.dart`) replaces FFmpeg for screenshots, eliminating DPI scaling artifacts on multi-monitor setups.

### Changed
- **Screenshot Engine:** Moved screenshot capture away from FFmpeg dependency to native DirectX/GDI extraction, improving capture speed and removing the engine requirement for screenshots.
- **Capture Overlay:** Replaced the modal display picker with a transparent spanning overlay for click-to-select monitor targeting across all capture modes.
- **UI:** Unified recording tile layout with full date in history. Enhanced long screenshot UX with capture history auto-scrolling.
- **Window Mode:** Removed window capture mode entirely from both screen recorder and screenshot plugins.

### Fixed
- **FFmpeg Download:** Resolved a critical bug where `_extractZipSync` called archive v4's async `extractFileToDisk` without `await`, causing extraction to return immediately and every download to fail with "ffmpeg.exe not found."
- **Download Validation:** Added HTTP timeouts, received-bytes-vs-Content-Length checks, and ZIP header/EOCD integrity verification. The archive is now retained on failure and reused on retry.
- **Dynamic Size Display:** The download prompt now fetches the actual remote file size instead of showing a hardcoded "~30MB" estimate.
- **Capture Pathing:** Fixed an issue where save directories were forcibly appended to custom user-selected paths. Long screenshot intermediate videos now use temp storage.
- **Format Conversion:** Fixed normal and long screenshots writing raw PNG data with incorrect file extensions by routing through FFmpeg transcoding.

## [0.2.0] - 2026-05-22

### Added
- **New Plugin:** **Document Obfuscator** to easily anonymize sensitive information.
- **System Tray Deep-linking:** Enhanced system tray to dynamically populate enabled plugins. Clicking a plugin now brings the window to the foreground and resizes it automatically.
- Centralized history list management across plugins.

### Changed
- **UI/UX Improvements:**
  - Standardized app-wide plugin and modal padding.
  - Fixed plugin header typography.
  - Improved search field size consistency.

### Fixed
- **Screenshot Engine:** Resolved a critical Windows DWM UI corruption bug during screenshot capture by optimizing `RepaintBoundary` texture handling and enforcing programmatic layout invalidation.
- Fixed overlay window restoration logic.
- Fixed non-functional "Settings" system tray menu item.
- **CI/CD & Tests:** Fixed FFmpeg path issues on CI runs, `getApplicationSupportPath` resolution in tests, and GitHub Actions test execution.
- Cleaned up analyzer warnings and deprecated member usage.

## [0.1.0] - 2026-05-07

### Added
- **Initial Production Release (Soft Launch)**
- Core Plugin Architecture with Material 3 Fluent design.
- **New Core Plugins:**
  - **Text Editor**: Premium Markdown editor with "Smart Paste" and local persistence.
  - **cURL Requester**: HTTP client with history and transaction inspection.
  - **TODO & Tasks**: Lightweight developer task tracking.
  - **QA Cheatsheet**: Standard and project-specific testing checklists.
  - **Timer & Countdown**: Stopwatch, Unix converter, and countdown tools.
  - **Data Generator**: Mock UUID, Identity, and Glyphs generation.
  - **Code Beautifier**: Formatter for JSON, XML, YAML, and Dart.
  - **QA Oracle**: Interactive decision-making tool.
  - **Security Payloads**: Common XSS/SQLi test strings.
  - **Screen Recorder & Screenshot**: High-performance capture suite.
- **Windows Integration**:
  - Single Instance enforcement (Mutex).
  - Background-to-Foreground restoration logic.
  - Frameless custom window decoration.
- **CI/CD**: Automated Windows release pipeline with manual approval gate.

### Fixed
- Resolved Text Editor navigation regression when creating documents from templates.
- Removed artificial document count limits in Text Editor.
- Optimized window transition synchronization for capture tools.
