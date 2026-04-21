# SRS: Core Architecture (00)

## 1. Introduction
### Purpose
This document provides a comprehensive Software Requirements Specification (SRS) for the core engine of SQA-Multitools. It serves as a guide for developers and stakeholders to understand the product's foundation.

### Scope
The software is called **SQA-Multitools**. It is a modular desktop utility suite. The core engine manages window handling, theme orchestration, and plugin registration. It will *not* contain specific feature logic, which is delegated to plugins.

### Definitions & Abbreviations
- **SRS:** Software Requirements Specification.
- **Plugin:** A modular component implementing the `SqaPlugin` interface.
- **Material 3:** Google's latest design system.

### References
- [Main Documentation Index](file:///e:/Github/sqa-tools/docs/README.md)
- [Agent Guidelines (gemini.md)](file:///e:/Github/sqa-tools/gemini.md)

## 2. Overall Description
### Product Perspective
SQA-Multitools is a standalone Windows desktop application designed to improve QA efficiency through a unified toolbar interface.

### Product Functions
- **Plugin Discovery:** Automatically loading classes that implement the core plugin contract.
- **Window Management:** Frameless custom window handling.
- **Theme Orchestration:** Centralized Material 3 seed-color applying.

### User Classes & Characteristics
- **QA Engineers:** High technical capability, focused on testing efficiency.
- **Developers:** High technical capability, focused on extension and tool customization.

### Operating Environment
- **Platform:** Windows Desktop.
- **Framework:** Flutter.

### Design & Implementation Constraints
- **Language:** Dart.
- **State Management:** Riverpod.
- **UI:** Material 3 standards.

## 3. System Features (Functional Requirements)
### Core Plugin Manager
- **Description:** Central mechanism to load and toggle plugins in the toolbar.
- **Inputs:** Plugin classes implementing `SqaPlugin`.
- **Processing:** Validates and registers plugins, updating the global `availablePluginsProvider`.
- **Outputs:** An interactive icon in the main toolbar.

## 4. External Interface Requirements
### User Interfaces (UI)
- **Style:** Material 3 compliant with custom frameless window decoration.
- **Design System:** Use mandatory SQA-Multitools component library:
  - **SqaButton:** Standardized primary, tonal, outlined, and text actions.
  - **SqaCard:** Standard surface with consistent radius/border.
  - **SqaTabBar:** Optimized navigation tabs for plugins.
  - **SqaSegmentedButton:** Standardized compact switchers.
  - **SqaField:** Unified input and copyable display field with optimized **1.3 line-height** for readability. Features include:
    - **Smart Sticky Copy Button:** Keeps the copy action visible at the top-right of the viewport during scrolling. Includes a **reserved 44px right gutter** to prevent text and horizontal scrollbars from passing under the button.
    - **Snap-Height Expansion:** Integrated toggle (Show All/Less) that snaps to `collapsedMaxLines` when minimized, featuring a gradient-fade footer.
    - **Horizontal Scroll:** Support for mandatory single-line horizontal scrolling via `horizontalScrollController`.
  - **SqaDropdown:** Standardized selection menus.
  - **SqaFloatingBar:** Centralized draggable controls for capture tools. Features theme-aware styling for all internal components (e.g., recording timers) to ensure maximum legibility in both light and dark modes.
  - **SqaCaptureOverlay:** Centralized foundation for high-performance, flicker-free capture tools (Screenshot, Screen Recorder). Implements the "Passive Exit" pattern for stable transitions.
  - **SqaPluginLayout:** Standardized window architecture (header + tabs + body).

  - **SqaSettingsButton:** Quick-access gear icons for plugin-specific settings.
  - **SqaSettingsTile:** Standardized rows for configuration panels.
  - **SqaSwitch:** Unified 0.6 scale toggles for preferences.
  - **SqaIconContainer:** Unified background-icon patterns.
  - **SqaInfoBanner:** Unified styling for tips and notes.
  - **SqaPluginHeader:** Standardized title/description headers with a subtle vertical fade effect.
  - **SqaPluginScrollableContent:** A standard wrapper that centers content vertically when the window is expanded and provides scrolling for tall content.
  - **SqaToast:** Centralized notification system featuring a minimalist, translucent "Fluent Pill" design with zero elevation and 11px bold typography for non-intrusive feedback.
- **Navigation:** Horizontally scrollable toolbar at the top.
- **Visual Cues:** 
  - `drag_indicator` icon to clearly denote the draggable window area.
  - Scroll-aware edge fades (gradients) on the plugin icon area when content is scrollable.

### Hardware Interfaces
- **Not implemented** (Standard HID input only).

### Software Interfaces
- **Direct Link:** `window_manager` for OS-level window control.
- **Persistence:** `shared_preferences` for local storage.

### Communication Interfaces
- **Not implemented** (Standalone local app).

## 5. Non-Functional Requirements (Quality Attributes)
### Performance
- Startup time: TBD.
- Plugin toggle response time: <100ms.

### Safety & Security
- Local data only. Encryption is **TBD**.

### Reliability
- Uptime: 99.9% during active sessions.
- Crash recovery: TBD.

### Maintainability
- Modular design with isolated plugin logic to allow independent updates.

## 6. Optimization & Robustness
### Window Transition Synchronization
- **Description:** Centralized mechanism (`WindowTransitionCoordinator`) to manage complex window state changes.
- **Strategy:** Replaces hardcoded delays with event-driven synchronization (native OS events + Flutter frame callbacks).
- **Core Benefit:** Eliminates flickering and visual artifacts during large-scale structural window moves.

### Centralized FFmpeg Engine
- **Description:** A shared utility service in `core/engine/` that manages FFmpeg lifecycle and execution.
- **DPI-Aware Capture:** Implements robust coordinate mapping and mixed-DPI scaling logic to ensure pixel-perfect crops across multi-monitor setups.
- **Unified Dependency Management:** Provides a global Riverpod provider (`ffmpegProvider`) for tracking installation progress and engine readiness across all capturing plugins.
- **Decoupled Architecture:** Uses a generic `FfmpegVideoConfig` DTO to allow both Screen Recorder and Screenshot plugins to share the same capture logic without circular dependencies.
