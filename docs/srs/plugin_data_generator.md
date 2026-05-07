# SRS: Data Generator (plugin_data_generator)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the Data Generator utility within SQA-Multitools.

### Scope
The tool is called **Data Generator**. It automates the creation of mock test data across Identity, Text, and Developer-centric categories.

### Definitions & Abbreviations
- **TBD:** To Be Defined.

### References
- [Core Architecture SRS](file:///e:/Github/sqa-tools/docs/srs/00_core.md)

## 2. Overall Description
### Product Perspective
This is a modular plugin for SQA-Multitools, utilizing the standard `SqaPlugin` interface.

### Product Functions
- **Identity Generation:** Create mock Names, Emails, Addresses, and Phone Numbers.
- **Lorem Generation:** Create mock text based on Character count (Bytes), Words (Sentences), Sentences (Paragraphs), and Chapters.
- **Glyphs Generation:** Quick access to localized snippets (JA, ZH, AR, VI) and Special Characters.
- **Developer Utilities:** 
    - **UUIDs**: Generates V4 UUIDs with a rolling history of the last 10 items.
    - **JSON**: Tiered generation (Simple, Medium, Complex) with realistic nested structures.
    - **Dates**: Past/Future generation with multiple top-N popular formats (ISO, RFC, SQL, Unix, Human).

### User Classes & Characteristics
- **Standard User:** QA Engineers needing mock data for testing.

### Operating Environment
- **Platform:** Windows Desktop.

### Design & Implementation Constraints
- **Framework:** Flutter.
- **Icon:** `Symbols.wand_stars`.

## 3. System Features (Functional Requirements)
### Categorized Mock Data
- **Description:** Grouped generators for Identity, Text, and Dev data.
- **Inputs:** User clicks standardized "Generate" button (wand icon) present in every tab.
- **Processing:** Pseudo-random generation for each data type based on selected type and locale.
- **Locale Support:** Full support for all 55 locales provided by the `faker_dart` library (e.g. English, French, Japanese, Indonesian, Arabic, etc.).
- **Data Sanitization:** Implements a centralized `FakerFix` utility to ensure third-party mock data (from `faker_dart`) is free of placeholder artifacts like `!` or `#`.
- **Options:** 
  - **Include Formatting:** Prefix each result with a bullet point (`•`) for improved readability.
  - **Include Extension:** Toggle to optionally strip or keep phone extensions (e.g. `x123`) from generated numbers.
  - **Lorem Types:** Supports Bytes (Characters), Sentence (Words), Paragraph (Sentences), and Chapter (Paragraphs).
  - **Scripts Tab:** Provides instant access to localized text (JA, ZH, AR, VI) and Special Characters regardless of the global locale setting.
  - **Dynamic Input:** The configuration field label updates based on the selected text type (e.g., "CHARACTERS", "WORDS", etc.).
  - **Identity Tabs**: Use `SqaSegmentedButton` to switch between generator types (Email, Address, etc.).
- **Layout**: Use `SqaPluginScrollableContent` to vertically center the generator form and results in the primary window.
- **Result Preview**: For multi-line text (Paragraphs, Chapters, JSON), results are displayed in formatted monospace blocks.
- **Date Facets**: Generates 5 separate, individual `SqaField` segments for different date formats (ISO, RFC, SQL, etc.) to allow granular copying.
- **UUID History**: Displays the latest UUID in a primary field, with a dedicated "HISTORY (LAST 10)" `SqaField` below it.
- **UI Architecture**: The plugin UI is modularized into dedicated tab view components: `IdentityTabView`, `LoremTabView`, `GlyphsTabView`, and `DevTabView`.
- **Layout**: Use `SqaPluginScrollableContent` to vertically center the generator form and results in the primary window.
- **Safety**: Destructive "Clear" actions (e.g. wiping UUID history or discarding generated results) require explicit confirmation via `SqaModal.showConfirm` or `SqaModal.showDanger`.

## 4. External Interface Requirements
### User Interface (UI)
- **Style:** Standard SQA Unified Design System.
- **Components:**
  - `SqaTabBar` for Identity/Lorem/Glyphs/Dev categories.
  - `SqaSegmentedButton` for specific type selection.
  - `SqaField` for displaying and copying bulk results.
  - `SqaButton.primary` for the "Generate" action in each tab's configuration panel.
  - `SqaSettingsButton` to access locale/count configuration (next to the Generate button).
- **Feedback:** `SqaToast` on result copy.

### Hardware Interfaces
- **Not implemented**.

### Software Interfaces
- **Direct Link:** Clipboard integration to output results.

### Communication Interfaces
- **Not implemented**.

## 5. Non-Functional Requirements (Quality Attributes)
### Performance
- Speed: Immediate generation on click.

### Safety & Security
- **Data Protection**: `SqaModal.showConfirm` and `SqaModal.showDanger` prompts protect against accidental data loss when clearing history or results.
- **Data Privacy**: **Not implemented**.

### Reliability
- Randomness consistency: High.

### Maintainability
- Isolated plugin structure.
