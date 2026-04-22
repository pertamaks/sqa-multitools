# SRS - Text Editor Plugin

## 1. Overview
The **Text Editor Plugin** is a premium Text management and editing tool for SQA-Multitools. It allows QA Engineers and Developers to quickly create structured bug reports, dev tickets, or general documentation using a human-readable, live-styling editor.

## 2. Key Features
### 2.1 Document Management
- **List View**: Displays all stored `.md` files with last-modified timestamps.
- **Pinned Documents**: Ability to anchor important documents to the top of the list for quick access.
- **Kebab Actions**: Smart shortcuts for Editing, Deleting (with confirmation), Pinning, and Copying content.
- **Persistence**: Store files (and pinned state) in a user-configurable directory.

### 2.2 Template System
- **Empty Canvas**: A blank Text file.
- **Bug Report Template**: Standardized structure covering Summary, Steps to Reproduce, Expected vs. Actual, and Logs.
- **Dev Ticket Template**: Standardized structure for requirements and acceptance criteria.

### 2.3 WYSIWYG Markdown Editor
- **Block-Based Editing**: Implements a Notion-like block editor powered by `appflowy_editor`, allowing users to edit formatted text directly without raw syntax characters (WYSIWYG).
- **Discard Confirmation**: Safety check when leaving the editor with unsaved changes.
- **Adaptive Floating Toolbar**: Contextual actions for Markdown formatting featuring screen-aware pivot logic to prevent interface clipping.
- **Sync-Scroll Anchoring**: High-fidelity expansion that keeps the primary button pinned to the mouse coordinate during width growth.
- **Smart Copy**: Ability to copy content as both Plain Text (Raw MD) and Rich Text to preserve formatting in Office apps.

## 3. Technical Implementation
- **State management**: `flutter_riverpod` with generated notifiers.
- **Immutability**: `freezed` for `TextEditorState` and `TextDocument`.
- **Adaptive Physics**: Custom `AnimationController` listeners with scroll-offset compensation for frame-perfect expansion.
- **Peeking Logic**: `SqaScrollVisibilityTrigger` (centralized widget) for intelligent clipping detection.
- **Editor Engine**: `appflowy_editor` for block-based document handling and seamless Markdown round-trip serialization.

## 4. UI Standards
- Uses `SqaPluginLayout` for a consistent header and back-navigation feel. The Editor View utilizes an icon-less header to reduce visual noise and maximize focus.
- Uses `SqaPluginScrollableContent` to ensure content is centered and scrollable on all monitor sizes.
- Utilizes `SqaCard` for document list items for a consistent Fluent Design aesthetic.

## 5. Compliance
- Zero Warnings: Passes `dart analyze`.
- Modular Architecture: Plugin is isolated in `lib/plugins/text_editor/`.
- Cross-Platform: Windows-first focus with path abstractions.
