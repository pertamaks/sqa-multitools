# SRS - Requirement Obfuscator Plugin

## 1. Overview
The **Requirement Obfuscator Plugin** is a premium, high-security data masking and sanitization utility for SQA-Multitools. It allows QA Engineers, Product Managers, and Developers to sanitize sensitive information (such as client names, proprietary system components, configuration secrets, IP addresses, and database schema mappings) from software requirements, design specifications, or bug reports before sharing them with external vendors or posting them on public bug trackers.

## 2. Key Features
### 2.1 Workspace and Project Scoping
- **Isolated Workspaces**: Allows users to manage multiple independent projects, each maintaining its own dedicated configuration, dictionary, and document states.
- **Substitution Strategy Customization**: Configurable obfuscation approaches per workspace:
  - **Semantic (Faker)**: Uses advanced localized mock-data generation (via `faker_dart`) to produce authentic-looking replacements (e.g. replacing `HerculesService` with `OrionService` or `/payment/checkout` with `/faker/route`).
  - **Token**: Formats replacements as standardized sequential placeholders (e.g. `[MODEL-1]`, `[ENDPOINT-3]`).
  - **Codename**: Generates creative codenames utilizing metal-animal prefix-suffix matching (e.g. `PlatinumFalcon`, `GoldPanther`).
- **Interactive Metrics Dashboard**: High-fidelity hero numbers illustrating dictionary size and cumulative processed characters.

### 2.2 Advanced Technical Scanner & Engine
- **SubstitutionEngine**: A case-preserving, non-overlapping replacement system employing a **longest-match-first** algorithm. Prevents partial substring corruption and seamlessly processes all active dictionary terms.
- **VariantResolver**: An automated casing variation generator that automatically produces and maps matching styles across all major developer conventions (camelCase, snake_case, SCREAMING_SNAKE, kebab-case, space-separated, PascalCase, lowercase, and uppercase).
- **AliasGenerator**: Generates high-fidelity replacements mapped to structured database models, configuration variables, API endpoints, services, or general terminology based on the selected substitution strategy.
- **TermScanner**: A rule-based heuristic scan engine featuring 10 customized pattern rules (including system codes, emails, IP addresses, PascalCase services/models, screaming config variables, database snake_case tables, and nested API paths) filtered against an extensive technical skip-list of ~200 common keywords.

### 2.3 Integrated Markdown Viewers
- **AppFlowy Read-Only Integration**: Dual side-by-side structured viewers presenting the original text alongside the masked obfuscated text.
- **Dynamic Highlights**: Custom decoration overlays identifying all matched terms in the active document.
- **SqaSwitch Mode Toggle**: A clean, premium toggling component featuring micro-animations and explanatory tooltips to instantly switch the viewer between original and masked states.
- **Immediate Obfuscated Scan**: Initiates an automated dictionary populated heuristics scan the moment the toggle is engaged, providing immediate visual feedback.

### 2.4 Dictionary Management & Interactive Highlighting
- **Manual Highlight Selection**: Users can highlight any term in the original document viewer and click a contextual button to add it directly to the dictionary with auto-generated variants.
- **Dictionary Panel**: An expandable side sidebar presenting all dictionary terms with category tags, toggle states (enable/disable), and safe deletion confirmations (with confirm modals).

## 3. Technical Implementation
- **State Management**: Highly modular `flutter_riverpod` state notifier implementing `ObfuscatorState` and `ObfuscatorWorkspace`.
- **Immutability**: Freezed annotations for state models and `DictionaryEntry`.
- **Engine Components**:
  - `SubstitutionEngine`: Implements `obfuscate()`, `deobfuscate()`, and `findMatches()`. Performs non-overlapping searches utilizing a matched byte flag mask.
  - `VariantResolver`: Resolves multiple word divisions and generates casing variants dynamically.
  - `AliasGenerator`: Integrates `Faker` alongside randomized codename selectors.
  - `TermScanner`: Filters noise using `skipList` and extracts raw strings case-insensitively.
- **Read-Only Rendering**: Incorporates unified block definitions via `SqaAppFlowyBuilders` to ensure visual parity and zero interaction interference.
- **Safety confirms**: Integrates `SqaModal.showDanger` for destructive workspace and dictionary deletions.

## 4. UI Standards
- **Standardized Typography**: Title scales using `headlineSmall` (24px) for dashboard views, `titleSmall` (14px) for panel sections, and `labelSmall` (11px) for category tags.
- **Spacing and Borders**: Rigid adherence to `SqaTokens` spacing and borders to enforce a premium, cohesive Fluent Design aesthetic.
- **Aesthetic Accents**: Harmonies tailored to high-fidelity dark/light mode toggles with glassmorphism backgrounds.
- **Zero Hacks**: No manual positioning offsets in build scripts. Extended core widget properties cleanly.

## 5. Compliance
- Zero Warnings: Fully passes `dart analyze`.
- Automated Tests: Full coverage on all 4 core engine components (`obfuscator_engine_test.dart`).
