# SRS: QA Cheatsheet Plugin (High-Fidelity)

## 1. Overview
The **QA Cheatsheet Plugin** provides a centralized, high-fidelity reference of essential Quality Assurance concepts, technical guides, and matrices. It utilizes a dual-engine Markdown architecture to ensure absolute structural parity with the source compilation asset.

## 2. Requirements

### 2.1 UI/UX
- **Hierarchical Navigation**: Two-level navigation using Category Tabs (Top) and Section Segmented Buttons (Contextual).
- **Icons**: Every tab and section button must display a representative symbol.
- **High-Fidelity Rendering**: Support for complex tables, GFM callouts, and correctly aligned ASCII diagrams.
- **Deep Linking**: Support for internal anchor navigation within long documents.

### 2.2 Functional
- **Asset Warm-up**: Pre-load large Markdown assets during plugin initialization.
- **Interactive Code Blocks**: One-click copy support for all code snippets and command lines.
- **Responsive Layout**: Content must be centered and scrollable, adapting to window resizing without structural bleeding.

### 2.3 Technical
- **State Management**: `riverpod_generator` with immutable `freezed` models.
- **Rendering Engine**: Hybrid `SqaMarkdownViewer` using `markdown` AST and `html` fragment parsing.
- **Whitespace Firewall**: Enforced double-newline padding in the parser to prevent structural corruption.

## 3. Architecture

### 3.1 Data Model
- `CheatsheetCategory`: Top-level grouping (Tabs).
- `CheatsheetSection`: Individual document topics with raw Markdown source.

### 3.2 UI Components
- `QaCheatsheetView`: Main orchestrator.
- `SqaMarkdownViewer`: Central rendering engine for document content.
- `SqaSegmentedButton`: Inline section switcher.

## 4. Guidelines Compliance
- **Zero Warnings**: Strict adherence to `dart analyze`.
- **Atomic Design**: Utilization of centralized widgets from `lib/ui/widgets/`.
- **Performance**: Pre-loading and lazy-rendering via standard Flutter scroll views.
