# SRS: Screenshot Tool (plugin_screenshot)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the Screenshot utility in SQA-Multitools.

### Scope
The tool is called **Screenshot**. It captures image data from the screen. It will **not** provide high-end image editing features.

### Definitions & Abbreviations
- **TBD:** To Be Defined.

### References
- [Core Architecture SRS](00_core.md)

## 2. Overall Description
### Product Perspective
This is a modular plugin for SQA-Multitools, utilizing the standard `SqaPlugin` interface.

### Product Functions
- **Capture Full Screen:** Capture any selected monitor in its entirety.
- **Capture Selection:** Interactive region selection.
- **Long Screenshot:** Capture scrollable areas and stitch frames into a single long image. Supports both vertical and horizontal scroll directions.
- **Realtime Annotation:** Draw on the screen or capture preview using various tools (Pen, Line, Arrow, Marker, Rectangle, Text).
- **Color Selection:** Change the color of annotations.

### User Classes & Characteristics
- **Standard User:** QA Engineers and Developers.

### Operating Environment
- **Platform:** Windows Desktop.

### Design & Implementation Constraints
- **Framework:** Flutter.
- **Icon:** `Symbols.crop`.

## 3. System Features (Functional Requirements)
### Take Screenshot
- **Description:** Capture a high-quality image of the desktop or selected region using native FFI-based extraction (`silent_frozen_canvas.dart`) for zero-distortion multi-monitor capture.
- **Inputs:** User clicks the "Crop" icon or uses a global hotkey (area capture toggle, fullscreen capture).
- **Processing:** DirectX/GDI background extraction encodes frame data into an image format (PNG/JPG/WebP). No longer depends on FFmpeg for capture.
- **Outputs:** An image file saved or copied to the clipboard.

### Annotate Capture
- **Description:** Allow users to draw shapes, lines, arrows, and text on the screen or preview.
- **Tools:** Pen, Line, Arrow, Rectangle, Text, Eraser.
- **Color Selection:** A palette or picker to choose annotation colors.
- **Interactivity:** Real-time feedback during drawing.

### Screenshot Hub
- **Description**: Centralized dashboard to configure and trigger captures, and manage recent files.
- **Recent Captures**: A list of the latest screenshots allowing for:
    - **Playback**: Immediate preview or "Open File" action.
    - **Renaming**: Standardized **SqaModal.showPrompt** for safe file renaming with real-time character validation and duplicate checking.
    - **Deletion**: Protected by **SqaModal.showDanger** confirmation prompt.
    - **Action Management**: Secondary actions are consolidated into a **SqaPopupMenu** to maintain a consistent UI standard across plugins.

## 4. External Interface Requirements
### User Interfaces (UI)
- **Style:** Material 3 capture interface/overlay.
- **Capture Overlay**: Built on the core `SqaCaptureOverlay` component for high-performance selection and flicker-free transitions. Includes `SqaFloatingBar` for annotation tool selection and export actions.

- **Layout**: Use `SqaPluginScrollableContent` to vertically center the capture mode selection and configuration cards.
- **Action Button**: Primary action for capturing with an integrated loading state.
- **Settings:** Moved configuration (format, quality, shortcut) to a dedicated settings panel accessed via the `Settings` plugin.

### Hardware Interfaces
- **Not implemented**.

### Software Interfaces
- **API:** Platform-specific Windows capture APIs via native FFI (`silent_frozen_canvas.dart`) for high-fidelity, zero-distortion screenshot encoding. FFmpeg is no longer required for screenshots.

## 5. Non-Functional Requirements (Quality Attributes)
### Dependency Guarding
- **FFmpeg Independence**: Screenshot capture no longer depends on FFmpeg. The native FFI pipeline eliminates the engine requirement, reducing the download burden for screenshot-only users. Long screenshots use FFmpeg for intermediate video capture and frame extraction.

### Communication Interfaces
- **Not implemented**.

## 5. Non-Functional Requirements (Quality Attributes)
### Performance
- Capture Speed: <500ms on click.

### Safety & Security
- Data privacy: Local only.

### Reliability
- Pixel-perfect capture: Guaranteed.

### Maintainability
- Isolated plugin structure.
