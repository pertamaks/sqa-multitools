# Contributing to SQA-Multitools

Thank you for your interest in contributing! This document outlines the development standards, code organization, and conventions that all contributors must follow.

---

## 1. Development Principles

### Unit Tests Are Mandatory
Every new feature or plugin must include automated unit tests before it's considered complete. Use `flutter_test` with [Mockito](https://pub.dev/packages/mockito) for mocking when necessary.

### Zero Warnings Policy
All code must pass both `dart analyze` and `dart format` with **zero** warnings or issues. Treat lints and formatting violations as hard errors.

```bash
# Run before every commit
dart format .
dart analyze
flutter test
```

### State Management
Use **Riverpod** (`flutter_riverpod`) for all state management. When adding new providers, prefer `riverpod_generator` annotations. State must be:
- **Modular:** Isolated per plugin — no cross-plugin state leakage.
- **Immutable:** Use `freezed` or raw immutable Dart classes. Mutable state objects are not accepted.

### No UI Hacks
Avoid "hacky" workarounds like:
- Using `Colors.transparent` to hide default elements
- Wrapping widgets awkwardly to fix alignment
- Hardcoded pixel offsets or magic numbers

Always use the correct Flutter framework property or `ThemeData` override to modify behavior cleanly.

---

## 2. Code Organization

```
lib/
├── core/              # Interfaces, engine logic, unified models
│   ├── models/        # Data shapes (SqaPlugin interface, etc.)
│   ├── providers/     # Core state (active plugin, preferences)
│   ├── services/      # Shared services
│   ├── utils/         # Utilities
│   └── window/        # Frameless window handling
├── ui/                # Shared component library & main toolbar
│   └── widgets/       # Standardized Material 3 widgets
└── plugins/           # All plugins — each in its own isolated sub-folder
    └── <plugin_name>/
        ├── <plugin_name>_plugin.dart   # SqaPlugin implementation
        ├── ui/                         # Plugin-specific views
        ├── models/                     # Freezed state classes
        └── providers/                  # Riverpod providers
```

**Rules:**
- Core logic and plugin logic must **never** be tightly coupled.
- Shared UI components go in `lib/ui/widgets/`, not inside plugins.
- Each plugin folder must be fully self-contained.

---

## 3. The Plugin Contract

Every plugin **must** implement the `SqaPlugin` interface from `lib/core/models/`. This guarantees seamless registration by the core engine.

Key methods:
| Method | Purpose |
|---|---|
| `buildPluginWindow()` | Returns the plugin's main UI |
| `buildSettingsPanel()` | Returns the plugin's settings view |
| `initialize()` | Lazy-load assets when the user enters the plugin |
| `dispose()` | Clean up resources when the plugin is deactivated |

**Do not** pre-load assets in `main.dart`. Always use `initialize()` for lazy loading (see §6).

---

## 4. UI Standards

To maintain a consistent, premium look across all plugins:

### Typography
| Role | Style | Size |
|---|---|---|
| Plugin Title / Header | `headlineSmall` | ~24px |
| Section Title | `titleSmall` + **bold** | 14px |
| Label | `labelSmall` + **bold** | 11px |
| Hero Number (timer, clock) | `displaySmall` or `headlineMedium` | 36px / 28px |

### Navigation Tabs
- Font size: `12`
- Icon size: `18`
- Icon margin: `4.0` (bottom)

### Iconography
- Standard UI icons: `18` or `20`
- Large decorative headers only: `32`

### Layout & Spacing
- Primary plugin views: `EdgeInsets.all(24.0)`
- Nested cards/containers: `EdgeInsets.all(16.0)`
- Always wrap primary content in `SqaPluginScrollableContent` for vertical centering (except list-heavy plugins like Clipboard).

---

## 5. Atomic Component Design

All plugins consume a shared widget library in `lib/ui/widgets/`. This ensures a unified "Single Product" feel.

### Rules

- **Plugins are consumers.** They pass data, labels, and config parameters — they don't implement complex layout logic.
- **Smart widgets.** Expansion toggles, horizontal scrolling, scroll-fade effects, and code gutters are implemented inside the widget, not in the plugin.
- **No plugin-level layout hacks.** If a plugin needs behavior a widget doesn't support, extend the widget's API so **all** plugins benefit.

### Available Components

| Widget | Purpose |
|---|---|
| `SqaButton` | Primary, tonal, outlined, and text actions |
| `SqaCard` | Standard surface with consistent radius/border |
| `SqaField` | Copyable text display with sticky copy button, snap-height expansion, line numbers |
| `SqaTabBar` | Optimized navigation tabs |
| `SqaSegmentedButton` | Compact multi-option switcher |
| `SqaDropdown` | Selection menus |
| `SqaFloatingBar` | Draggable control bar for capture tools |
| `SqaPluginLayout` | Standardized window structure (header + tabs + body) |
| `SqaPluginHeader` | Title/description with vertical fade |
| `SqaPluginScrollableContent` | Centering wrapper with overflow scrolling |
| `SqaSettingsButton` | Gear icon for plugin settings |
| `SqaSettingsTile` | Configuration rows |
| `SqaSwitch` | 0.6-scale toggle for preferences |
| `SqaIconContainer` | Background-icon patterns |
| `SqaInfoBanner` | Tips and notes |
| `SqaToast` | Notification popups |
| `SqaFadeWrapper` | Scroll-aware edge fading |

---

## 6. Asset & Audio Optimization

- **Never** pre-load large assets (audio, images, JSON) during app startup.
- **Always** use the plugin's `initialize()` method for lazy loading.
- **Audio warm-up:** Use `preLoad(path)` with `preload: true` inside `initialize()` to prevent cold-start silence on Windows.

---

## 7. Documentation Liveness

- Any change to a core feature or plugin **must** include an update to the corresponding SRS document in `docs/srs/`.
- If your change affects these contributing guidelines, update this file as well.

---

## Pull Request Checklist

Before submitting a PR, verify:

- [ ] `dart format .` — no formatting issues
- [ ] `dart analyze` — zero warnings
- [ ] `flutter test` — all tests pass
- [ ] New features include unit tests
- [ ] Relevant SRS documents are updated in `docs/srs/`
- [ ] No hardcoded pixel values or layout workarounds
- [ ] Plugin state is immutable (Freezed or raw immutable classes)
- [ ] Assets are lazy-loaded via `initialize()`, not in `main.dart`
