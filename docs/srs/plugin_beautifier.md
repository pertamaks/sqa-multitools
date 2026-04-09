# SRS: Code Beautifier Plugin

## Overview
The **Code Beautifier** plugin is a utility for formatting raw code into a human-readable structure. It leverages professional-grade formatting engines to provide high-quality output for multiple programming and data languages.

## Features

### 1. Language Support
Manual selection of languages powered by `flutter_code_editor` and `highlight`:
- **JSON**: Integrated `dart:convert` with custom indentation.
- **XML/HTML**: Robust tree-based formatting using the `xml` package.
- **SQL**: Syntax-aware highlighting with basic indentation.
- **YAML**: Powered by `yaml` and `yaml_writer` for clean normalization.
- **Dart**: Official formatting using the `dart_style` package.
- **JavaScript/CSS**: Syntax-highlighted editing with general indentation logic.

### 2. Formatting Logic
- **Professional Engines**: Uses official Dart and XML/YAML libraries for reliable output.
- **Error Handling**: Gracefully handles invalid syntax and provides inline error feedback.
- **Auto-Format**: Optional "Auto-format on change" setting, persisted across sessions.

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

## Implementation Details
- **ID**: `com.sqa.beautifier`
- **Icon**: `Symbols.code_blocks`.
- **Badge**: `ALPHA`.
- **State Management**: `flutter_riverpod` with `freezed` for immutable `BeautifierState`.
- **Provider**: `beautifierProvider`.
