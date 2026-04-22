# SRS - MD Editor Plugin

## 1. Overview
The **MD Editor Plugin** is a premium Markdown management and editing tool for SQA-Multitools. It allows QA Engineers and Developers to quickly create structured bug reports, dev tickets, or general documentation using a human-readable, live-styling editor.

## 2. Key Features
### 2.1 Document Management
- **List View**: Displays all stored `.md` files with last-modified timestamps.
- **Kebab Actions**: Smart shortcuts for Editing, Deleting, and Copying content.
- **Persistence**: Store files in a user-configurable directory (defaults to AppData).

### 2.2 Template System
- **Empty Canvas**: A blank Markdown file.
- **Bug Report Template**: Standardized structure covering Summary, Steps to Reproduce, Expected vs. Actual, and Logs.
- **Dev Ticket Template**: Standardized structure for requirements and acceptance criteria.

### 2.3 Human-Readable Editor
- **Live Styling**: Real-time rendering of headers (larger font), bold/italic text, and code blocks within the editing area.
- **Floating Toolbar**: Contextual actions for Markdown formatting and secondary copy functions.
- **Smart Copy**: Ability to copy content as both Plain Text (Raw MD) and Rich Text (HTML) to preserve formatting in Office apps.

## 3. Technical Implementation
- **State management**: `flutter_riverpod` with generated notifiers.
- **Immutability**: `freezed` for `MdEditorState` and `MdDocument`.
- **Text Rendering**: `SqaMdTextController` (centralized widget) for inline styling.
- **Clipboard**: `super_clipboard` for multi-format HTML/Plain Text injection.

## 4. UI Standards
- Uses `SqaPluginLayout` for a consistent header and back-navigation feel.
- Uses `SqaPluginScrollableContent` to ensure content is centered and scrollable on all monitor sizes.
- Utilizes `SqaCard` for document list items for a consistent Fluent Design aesthetic.

## 5. Compliance
- Zero Warnings: Passes `dart analyze`.
- Modular Architecture: Plugin is isolated in `lib/plugins/md_editor/`.
- Cross-Platform: Windows-first focus with path abstractions.
