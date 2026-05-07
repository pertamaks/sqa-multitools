# Changelog

All notable changes to this project will be documented in this file.

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
