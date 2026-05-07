# SRS: Code Beautifier Plugin

## Overview
The **Code Beautifier** plugin is a utility for formatting raw code into a human-readable structure. It leverages professional-grade formatting engines to provide high-quality output for multiple programming and data languages.

## Features

### 1. Language Support
Manual selection of languages powered by `flutter_code_editor` and `highlight`:
- **XML**: Strict tree-based formatting using the `xml` package.
- **HTML**: Robust HTML5-compliant parsing and pretty-printing using the `html` package. Handles void elements, fragments, and doctypes correctly.
- **SQL**: Professional token-based formatting with clause-aware layout and subquery nesting.
- **YAML**: Powered by `yaml` and `yaml_writer` for clean normalization.
- **Dart**: Official formatting using the `dart_style` package.
- **JavaScript**: Professional token-based formatting with support for ES6+, arrow functions, template literals, and class structures.
- **CSS**: Professional token-based formatting with support for media queries, variables, and minified expansion.

### 2. Formatting Logic
- **Professional Engines**: Uses official Dart and XML/YAML libraries, plus a custom Native-Dart Token Engine for SQL.
- **Error Handling**: Gracefully handles invalid syntax and provides inline error feedback.
- **Auto-Format**: Optional "Auto-format on change" setting, persisted across sessions.
- **Parameterized Indentation**: Configurable indentation width (2, 4, or 8 spaces) for SQL and native formats.

### 3. UI Features
- **Monospace Editor**: Uses `CodeField` for a professional IDE-like experience.
- **Syntax Highlighting**: Real-time coloring for 100+ languages.
- **Line Numbers**: Integrated gutter for navigating large code blocks.
- **Relocated Primary Action**: The "Format" button is placed between input and output for natural workflow.
- **Plugin Settings**: Dedicated settings panel for configuration toggles.

## UI Standards
- Use `SqaPluginLayout` with a split view for input and output.
- `CodeField` for both input and output sections.
- `SqaDropdown` for language selection.
- `SqaSettingsButton` for accessing plugin-specific options.

## Architecture
The plugin follows a modular structure for maintainability and consistency:
- **`beautifier_plugin.dart`**: Main entry point and registration.
- **`ui/beautifier_view.dart`**: Primary application logic and layout.
- **`ui/beautifier_settings.dart`**: Dedicated configuration panel.
- **`widgets/beautifier_highlighter.dart`**: Encapsulated highlighter logic and language definitions.

## Safety & Confirmation
To prevent data loss of unsaved source code, the plugin implements strict confirmation logic (GEMINI.md Rule 17):
- **Clear Action**: Clicking the "Clear" button triggers a red `SqaModal.showDanger` modal if the input or output fields contain text.
- **Discard Label**: The confirmation action is explicitly labeled "Clear" to signal destruction.

## Implementation Details
- **ID**: `com.sqa.beautifier`
- **Icon**: `Symbols.code_blocks`
- **Badge**: `null` (Stable)
- **State Management**: `flutter_riverpod` with `freezed` for immutable `BeautifierState`.
- **Provider**: `beautifierProvider`.
