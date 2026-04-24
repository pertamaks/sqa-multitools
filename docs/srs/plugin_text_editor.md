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
- **Adaptive Floating Toolbar**: Contextual "Action-First" multi-expansion (Primary action + secondary options on hover).
- **Sync-Scroll Anchoring**: High-fidelity expansion with 150ms stabilization lock and frame-perfect retraction sync.
- **Smart Copy**: Ability to copy content as both Plain Text (Raw MD) and Rich Text to preserve formatting in Office apps.

### 2.4 Table Editor
- **Contextual Actions**: Click-triggered `MenuAnchor` system for row/column operations (insert, delete, clear).
- **Styling Control**: High-fidelity background color picker and standardized 1.0px grid lines with a subtle 0.4 alpha transparency.

## 3. Technical Implementation
- **State management**: `flutter_riverpod` with generated notifiers.
- **Immutability**: `freezed` for `TextEditorState` and `TextDocument`.
- **Block Customization Pattern**: 
    - **Inheritance**: Custom builders inherit from `appflowy_editor` base classes to inject SQA logic.
    - **Stabilization**: Structural mutations (e.g., column deletion) utilize `addPostFrameCallback` to prevent indexing race conditions.
    - **Themed Wrapping**: `SqaBlockComponentWrapper` standardizes action handle behavior and local block themes.
- **Adaptive Physics**: Custom `AnimationController` listeners with scroll-offset compensation and `_lastWidth` tracking for drift-free retraction.
- **Peeking Logic**: `SqaScrollVisibilityTrigger` (centralized widget) for intelligent clipping detection.
- **Editor Engine**: `appflowy_editor` for block-based document handling and seamless Markdown round-trip serialization.

## 4. UI Standards
- **Standardized Layout**: Follows the global SQA standard: **800px Max-Width** (Centered) with a seamless `surfaceContainerLow` background filling the window edges.
- **Plugin Host**: Integrated host in `MainToolbar` with removed island constraints for a modern, fluid aesthetic.
- **Typography**: Standardized to **Inter (14px)** for body content, with a hierarchical scale of **24px (H1)**, **20px (H2)**, and **18px (H3)**.
- **Seamless Mode**: Implements zero vertical padding between blocks with a **1.5 line-height** for a professional, high-density vertical flow.
- **Interactions**:
    - **Clean UI**: All hover-activated block action handles are removed.
    - **Table Precision**: Outer borders are kept minimal (0.4 alpha) to maintain a lightweight, integrated feel.
    - **Markdown Paste**: Prioritized `Ctrl+V` handler for instant structural rendering of raw Markdown.
- **Components**: Utilizes `SqaCard` for document list items for a consistent Fluent Design aesthetic.

## 5. Compliance
- Zero Warnings: Passes `dart analyze`.
- Modular Architecture: Plugin is isolated in `lib/plugins/text_editor/`.
- Cross-Platform: Windows-first focus with path abstractions.
