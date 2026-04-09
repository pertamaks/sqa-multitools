# SRS: Screenshot Tool (plugin_screenshot)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the Screenshot utility in SQA-Multitools.

### Scope
The tool is called **Screenshot**. It captures image data from the screen. It will **not** provide high-end image editing features.

### Definitions & Abbreviations
- **TBD:** To Be Defined.

### References
- [Core Architecture SRS](file:///e:/Github/sqa-tools/docs/srs/00_core.md)

## 2. Overall Description
### Product Perspective
This is a modular plugin for SQA-Multitools, utilizing the standard `SqaPlugin` interface.

### Product Functions
- **Capture Window:** Single window screen capture.
- **Capture Selection:** Interactive region selection.
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
- **Description:** Capture a high-quality image of the desktop or active application.
- **Inputs:** User clicks the "Crop" icon or uses a hotkey.
- **Processing:** Encodes frame data into an image format (PNG/JPG).
- **Outputs:** An image file saved or copied to the clipboard.

### Annotate Capture
- **Description:** Allow users to draw shapes, lines, arrows, and text on the screen or preview.
- **Tools:** Pen, Line, Arrow, Marker, Rectangle, Text.
- **Color Selection:** A palette or picker to choose annotation colors.
- **Interactivity:** Real-time feedback during drawing.

## 4. External Interface Requirements
### User Interfaces (UI)
- **Style:** Material 3 capture interface/overlay.
- **Capture Overlay**: Use `SqaFloatingBar` to draw and export.
- **Layout**: Use `SqaPluginScrollableContent` to vertically center the capture mode selection and configuration cards.
- **Action Button**: Primary action for capturing with an integrated loading state.
- **Settings:** Moved configuration (format, quality, shortcut) to a dedicated settings panel accessed via the `Settings` plugin.

### Hardware Interfaces
- **Not implemented**.

### Software Interfaces
- **API:** Platform-specific Windows capture APIs.

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
