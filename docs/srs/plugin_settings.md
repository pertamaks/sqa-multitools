# SRS: Settings Dashboard (plugin_settings)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the central configuration hub of SQA-Multitools.

### Scope
The tool is called **Settings Dashboard**. It manages app-wide preferences, plugin activation, and tiered support rewards. It will **not** manage external system settings.

### Definitions & Abbreviations
- **Supporter Tier:** A classification of user contribution levels (1-3).
- **Redemption Code:** A unique string used to unlock tiers.

### References
- [Core Architecture SRS](file:///e:/Github/sqa-tools/docs/srs/00_core.md)

## 2. Overall Description
### Product Perspective
This is a core standalone plugin for SQA-Multitools, utilizing the standard `SqaPlugin` interface.

### Product Functions
- **Theme Selection:** User switches between Light/Dark/System.
- **Accent Customization:** Standardized Material 3 seed colors.
- **Plugin Management:** Toggling individual plugin visibility.
- **General Menu**: Use `SqaPluginScrollableContent` to center the primary settings cards (Appearance, Locale).
- **Plugins List**: Uses `ListView` for efficient scrolling and top-alignment of the toggle list.
- **Coffee Shop**: Use `SqaPluginScrollableContent` to center the donation and meta-game stats.
- **Standard User:** QA Engineers and Developers using the tool.

### Operating Environment
- **Platform:** Windows Desktop.

### Design & Implementation Constraints
- **Framework:** Flutter.
- **Icon:** `Symbols.settings`.

## 3. System Features (Functional Requirements)
### Theme Configuration
- **Description:** Allow user to change the visual app experience.
- **Inputs:** User clicks Theme/Accent menu options.
- **Processing:** Updates the `themeSettingsProvider`, which triggers a global repaint.
- **Outputs:** Updated UI colors and modes.

### Plugin Management
- **Description:** Enable/Disable plugins at runtime.
- **Inputs:** Toggle switch state.
- **Processing:** Updates `enabledPluginsProvider` and persists state.
- **Outputs:** Main toolbar icons update dynamically.

### Lab Features & Personalization
- **Description:** Allow supporters to toggle specific Easter eggs and lab features like "Bug Squash".
- **Inputs:** User toggles the Bug Squash switch in the Coffee Shop tab.
- **Processing:** Updates `bugSquashEnabledProvider` and persists setting.
- **Outputs:** Easter egg animation is enabled/disabled immediately.

## 4. External Interface Requirements
### User Interface (UI)
- **Style:** Standard SQA Unified Design System.
- **Layout:** Vertical column of `SqaCard` components.
- **Components:** 
  - `SqaTabBar` for General/Plugins/Coffee sections.
  - `SqaSettingsTile` for all functional rows.
  - `SqaSwitch` for standardized 0.6 scaled toggles.
  - `SqaSegmentedButton` for selection modes (Theme).
  - `SqaInfoBanner` for headers and notes.
- **Colors:** Seed based.
- **External:** `url_launcher` for donation links (HTTPS).

## 5. Non-Functional Requirements (Quality Attributes)
### Performance
- Setting application speed: <50ms.

### Safety & Security
- Receipt validation: SHA-256 local checksum.

### Reliability
- Preference persistence: 100% data recovery on startup.

### Maintainability
- Isolated plugin structure.
