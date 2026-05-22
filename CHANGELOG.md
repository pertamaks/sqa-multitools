# Changelog

All notable changes to this project will be documented in this file.

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
