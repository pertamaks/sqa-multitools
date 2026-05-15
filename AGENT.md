# SQA-Multitools: Agent Guidelines

## 1. Development Principles
* **Unit Tests Mandatory:** Automated unit tests MUST be generated for each newly developed feature or plugin logic before it is considered complete. Use `flutter_test` along with Mockito if necessary.
* **Strict Dependency Pinning:** Never use `any` version constraints in `pubspec.yaml`. All dependencies MUST be pinned to specific version ranges (e.g., `^1.2.3`) based on verified stable versions to ensure supply chain security and build reproducibility.
* **Zero Warnings:** All code must pass `dart analyze` and `dart format` flawlessly. Treat syntax hints and styling rules as strict errors.
* **Centralized Logging:** Avoid raw `print` or `debugPrint`. Always use the `LoggingService` to capture structured events, warnings, and errors.
* **Build Validation:** Before declaring a feature "Done", verify that the project builds successfully (`flutter build windows` or equivalent) and passes all CI quality gates. Never leave the codebase in a broken state.
* **State Management:** Always use `flutter_riverpod` (specifically annotations from `riverpod_generator` when appropriate). State must be highly modular and isolated per plugin.
* **Immutability:** Force all states to be immutable, utilizing `freezed` or raw immutable classes.
* **Proper Framework Usage (No UI Hacks):** Avoid "hacky" UI workarounds. Always seek the correct Flutter framework property or configuration to modify behavior cleanly.
* **Step File Discipline:** During execution, the "step file" (e.g., `task.md`) MUST be updated after every significant sub-task completion. It is the source of truth for progress.
* **Second Questioning The Decision:** During analysis and decision making, always make a second opposite opinion. Question: Is the decision the best approach we are going to implement?

## 2. Code Organization
`lib/`
  ├─ `core/` (Interfaces, Engine logic, unified models)
  │   └─ `models/` (Data shapes like `SqaPlugin.dart`)
  │   └─ `providers/` (Core state like active_plugin_provider)
  │   └─ `window/` (Frameless window handling utilities)
  ├─ `ui/` (Shared Fluent Design theme components, the main toolbar UI)
  └─ `plugins/` (All plugins. Each gets its own isolated sub-folder).

## 3. The Contract
Every plugin MUST implement the `SqaPlugin` interface from the core package to ensure seamless registration and initialization by the core engine. Do NOT tightly couple core and plugin logic.

## 4. Documentation & Guidelines Liveness
To ensure that the project documentation reflects the current state of the application:
* **Mandatory Update:** Any changes to core features or plugins MUST be accompanied by an update to the corresponding SRS document in `docs/srs/`. 
* **Guideline Evolution:** If a feature change affects these guidelines (`GEMINI.md`) or introduces a NEW centralized pattern/widget, these guidelines MUST be updated immediately to maintain "Agent Awareness" for future sessions.
* **Context Sync:** Proactively update the "Step File" and "SRS" to reflect architectural decisions made during development.

## 5. UI Standards
To ensure a consistent and premium experience across all plugins:
* **Navigation Tabs**: Use `fontSize: 12`, `iconSize: 18`, and `iconMargin` of 4.0 (bottom).
* **Typography**:
    - **Plugin Titles/Headers**: Use `headlineSmall` (approx. 24px) for major features.
    - **Section Titles**: Use `titleSmall` with `FontWeight.bold` (14px).
    - **Labels**: Use `labelSmall` with `FontWeight.bold` (11px).
    - **Hero Numbers**: Use `displaySmall` (36px) or `headlineMedium` (28px) for large counters.
* **Iconography**: Standard UI icons should be `18` or `20`. Use `32` for large decorative headers only.
* **Layout**: 
    - Use `EdgeInsets.all(24.0)` for primary plugin views and `16.0` for nested cards/containers.
    - **Vertical Centering**: Always wrap primary plugin content in `SqaPluginScrollableContent` to ensure it is centered when the window is expanded.
* **Scrollbars (Sliders)**: 
    - **Visibility**: Always set `thumbVisibility` to `true` via the global `ScrollbarThemeData` to ensure sliders are visible without hovering.
    - **Draggability**: Every scrollable region MUST be wrapped in a `Scrollbar` widget with an explicitly linked `ScrollController` to ensure the thumb is draggable.
* **Submenu Artifacts**: To remove or replace the default black triangle from `SubmenuButton`, do NOT attempt to hide it via the `child` or `trailingIcon` properties (which results in double icons). Use the `submenuIcon` property with a `WidgetStatePropertyAll` (e.g., `submenuIcon: WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14))`) to correctly override the framework's default arrow.

## 6. Asset & Audio Optimization
* **Lazy Loading**: Never pre-load large assets during global app startup.
* **Plug-in Initialization**: Implement `initialize()` in `SqaPlugin` to trigger pre-loading of assets specific to that tool.
* **Sound Warm-up**: For audio assets, use `preLoad(path)` with `preload: true` inside a plugin's `initialize()` method to prevent first-stutter.

## 7. Atomic Component Design (Centralized)
To ensure long-term maintainability and a consistent "Single Product" feel:
* **Search Before Build:** Before creating ANY new UI component or utility, SEARCH `lib/ui/` and `lib/core/`. If a similar component exists, extend it or use it.
* **Proactive Centralization:** If a plugin requirement involves a pattern likely useful to other plugins, do NOT build it inside the plugin. Build it as a centralized widget in `lib/ui/` and then consume it.
* **Plugins as Consumers:** Plugins MUST remain as simple "consumers" of shared widgets. They should only pass data, labels, and basic configuration.
* **Smart Widgets:** All complex layout logic, feature-specific expansion, or specialized visual decorations MUST be implemented inside the core widget itself.
* **No Plugin-Level Hacks:** Never apply manual layout workarounds within a plugin's `build` method. Extend the core widget's API instead.

## 8. Cross-Platform Strategy & Native Interop
* **Platform Guarding**: Guard all platform-specific code (e.g., `win32`) with `if (Platform.isWindows)`.
* **Abstraction**: Define shared interfaces in `lib/core/` for native behaviors and implement platform-specific versions.
* **Build Safety**: Use conditional imports for platform-specific libraries to prevent compilation errors on non-target platforms.

## 9. Feature Development Workflow
* **The Mock-up Phase & Systematic Tagging:** When building a new UI or decoupling an existing one, all missing dynamic logic, hardcoded mock data, and pending architectural splits MUST be explicitly tagged. Use standard markers (`// TODO(Logic): ...`, `// TODO(UI): ...`, `// TODO(Refactor): ...`) to create a clear, searchable integration roadmap before any backend or provider code is written.
* **Strict Integration Phase (No Unprompted UI/Features):** Once the mock-up phase is complete and TODOs are placed, the backend implementation and integration phase begins. During this phase, the Agent MUST strictly focus on resolving the TODO tags and wiring the state to the existing UI. **NEVER** implement new UI components, alter existing layouts, or introduce unprompted new features unless explicitly requested by the user. The goal is logic integration, not scope creep.
* **Atomic Use Case Identification:** Before writing code, the Implementation Plan MUST identify specific use cases and edge cases.
* **Coverage Check:** The final implementation must be verified against EVERY identified use case.
* **Checklist Verification:** Before closing a task, walk through sections 1-8 of these guidelines to ensure NO mandatory points were skipped (e.g., "Did I update the SRS?", "Did I check for UI hacks?", "Is the state immutable?").

## 10. Dependency Guarding
To ensure a robust user experience across all plugins:
* **Graceful Handling in Settings**: If a plugin requires an external dependency (e.g., FFmpeg) to fetch or modify certain settings, the UI MUST gracefully handle the absence of that dependency. 
* **Hiding vs Disabling**: It is preferred to **HIDE** settings that are non-functional without the dependency and instead show a clear call-to-action (e.g., a "Download Engine" button) to resolve the missing requirement.
* **Clear Feedback**: Never leave a user wondering why a setting is missing. Provide context within the plugin settings panel.

## 11. Window Transition Synchronization
To eliminate flickers and visual artifacts during complex window transitions (e.g., overlay entries/exits):
* **No Hardcoded Delays**: Never use `Future.delayed` with magic numbers (e.g. 250ms) to synchronize window state.
* **Event-Driven Sync**: Use the `windowTransitionProvider` to wait for specific OS and Flutter events.
* **Passive Exit Pattern**: Follow the staged reveal sequence:
    1. Ghost (`setOpacity(0.01)`)
    2. Sync (`waitForSync(resize: false, move: false)`)
    3. Structural Move (`setBounds`)
    4. Sync (`waitForSync(resize: true, move: false, frame: false)`)
    5. UI Switch (update state)
    6. Sync (`waitForSync(resize: false, move: false, frame: true)`)
    7. Reveal/Focus (`setHasShadow`, `setOpacity(1.0)`)

## 12. The "Devil’s Advocate" & Impact Protocol
Before any architectural decision or significant code change is finalized, the Agent MUST perform a structured **Contrarian Analysis** and **Impact Audit**.

### 12.1. Contrarian Analysis (Second Opinion)
The Agent must explicitly challenge its own proposal:
* **Proposed Approach:** [Summary of intended change]
* **Contrarian View:** [Reasoned argument for an alternative approach or why the proposed change might be risky/redundant/over-engineered]
* **Synthesis & Decision:** [Final justification of why the chosen path is superior after considering the opposition]

### 12.2. Zero-Touch Impact Analysis
To ensure code changes do not accidentally affect unrelated modules:
* **Blast Radius:** List every file that imports the module being modified.
* **Signature Check:** If changing a function signature or provider, identify all call sites.
* **Linter-Only Boundary:** Changes outside the immediate task scope are ONLY permitted for `dart fix` or `const` additions to maintain the "Zero Warnings" rule.

## 13. Adaptive Floating Bar Physics
To ensure a premium, border-aware experience for floating toolbars (like in the MD Editor or Screenshot overlays):
* **Adaptive Pivot Logic**: Use screen-relative boundary detection (via `MediaQuery`). If expanding to the right would hit the window border (48px threshold), the button MUST pivot to expand to the left instead.
* **Sync-Scroll Compensation**: For left-ward expansions, utilize an `AnimationController` listener to calculate width deltas. You MUST simultaneously adjust the toolbar's `scrollOffset` by the same amount to keep the primary icon mathematically static on the screen.
* **Intelligent Clipping Detection**: Always wrap expanding secondary widgets in the `SqaScrollVisibilityTrigger`. This ensures the toolbar only scrolls if the new UI element is physically hidden, preventing the "Auto-Snap" jitter observed in standard `ensureVisible` implementations.
* **Build-Phase Safety**: Never perform scroll adjustments or `setState` calls directly inside a `build` method during an animation frame. Use event-driven listeners or post-frame callbacks to maintain Flutter framework compliance.

## 14. Block Component Customization (AppFlowy Integration `assets\appflowy-editor-main`)
To ensure the AppFlowy-based editor maintains SQA-level premium aesthetics and structural stability:
* **Inheritance over Forking**: Never modify the underlying `appflowy_editor` package. Instead, inherit from its base builders (e.g., `TableBlockComponentBuilder`, `TableCellBlockComponentBuilder`) to inject custom logic.
* **Themed Wrapper Pattern**: Always wrap custom builders in the `SqaBlockComponentWrapper`. This centralizes the handling of action handles, margins, and focused block decorations.
* **Local Theme Injection**: Use local `Theme` widgets within the `build` method of custom builders to override specific icons and colors (e.g., `iconTheme`, `menuTheme`) without affecting the global app state.
* **Post-Frame Stabilization**: Any structural document mutation (e.g., deleting a column, changing block type) MUST be wrapped in `WidgetsBinding.instance.addPostFrameCallback`. This prevents "Null check operator" crashes by ensuring the editor's internal re-indexing is complete before external listeners (like Markdown encoders) are triggered.
* **Zero-Artifact UI**: If the framework introduces stubborn default artifacts (like vertical indentation lines), surgically remove them by overriding the `blockDecorationBuilder` or using precise `ClipRect` viewports, provided it doesn't break interactive elements.

## 15. Markdown Round-Trip Fidelity
To ensure absolute data parity across save/load cycles for the Text Editor:
* **High-Fidelity Encoders**: Always implement custom `NodeParser` overrides for structural nodes (e.g. `Table`, `CodeBlock`, `RawHTML`) to preserve metadata like column alignment, language, and nested indentation.
* **HTML Safety Net**: For structures the editor doesn't natively support (e.g. raw HTML tables or complex `<div>` blocks), utilize a `raw_html` node type. Use a recursive loader to capture full tag trees and a direct-text encoder to ensure 100% preservation.
* **Rich Text Preservation**: Custom text-based encoders (e.g. for Headings or Paragraphs) MUST utilize `SqaDeltaMarkdownEncoder` (extending `DeltaMarkdownEncoder`) to preserve bold, italics, links, strikethrough, and colors (via HTML spans).
* **Inline Style Reconstruction**: Utilize `SqaSpanInlineSyntax` during Markdown decoding to reconstruct colors from HTML spans back into AppFlowy attributes.

## 16. The Whitespace Firewall (Block Separation)
To prevent structural "bleeding" and the "Heading Virus" (paragraphs accidentally merging into headers or triggering Setext heading rules):
* **Mandatory Double Newline**: All top-level block encoders (Heading, Paragraph, Table, Code, HTML) MUST terminate with a clean **`\n\n`** suffix. 
* **Firewall Logic**: Never rely on single newlines for block separation. The "Whitespace Firewall" ensures that the Markdown parser treats each section as a distinct atomic unit.
* **Smart Nesting Exception**: When encoding paragraphs within nested structures (like Lists), use a single `\n` to maintain the parent's structural numbering and indentation.

## 17. Destructive UX Patterns (Safety First)
To prevent accidental data loss and maintain a premium, safe-feeling environment:
* **Mandatory Confirmation**: ALL destructive actions (e.g., deleting a task, clearing history, discarding unsaved changes) MUST require a confirmation step.
* **Modal Pattern**: Use `SqaModal.showDanger` for high-risk system deletions or infrequent destructive actions. This ensures consistent use of the `error` color scheme, destructive iconography (`Symbols.delete`), and clear "Delete/Discard" labeling.
* **Two-Click Inline Pattern (Fast Actions)**: For high-frequency actions (e.g., clearing a request field, pasting over data, clearing a 50-item history), use the "Two-Click Inline" pattern to maintain workflow speed.
    - **Visual State**: The button MUST transition from a subtle grey (`Colors.grey.withValues(alpha: 0.5)`) to a highlight color on the first click.
    - **Highlight Color**: Use the `error` color for deletions and the `primary` color for overwrites (like Paste).
    - **Safety Window**: Provide a 3-second auto-reset timer. The action only executes on the second click within this window.
    - **Tooltips**: Update the tooltip during the active window (e.g., "Click again to confirm").
* **No Single-Click Deletion**: Never provide a direct delete action without one of the two intermediate confirmation steps above.

## 18. High-Fidelity "Read-Only" Rendering (Viewer Architecture)
To ensure that documents rendered for viewing (Read-Only mode) maintain absolute structural parity with complex Markdown/HTML source:
* **The Dual-Engine Pattern**: Use a hybrid visitor approach. Utilize the `markdown` package for high-level AST structure, but immediately hand off `md.Text` nodes containing HTML tags to a secondary `html` (HTML5) parser. This prevents data loss in complex hybrid blocks.
* **Structural Table Layout**: For tables requiring `rowspan` or `colspan`, utilize a column-major grid architecture (`SqaGridTable`). This allows individual cells to span multiple vertical grid slots without breaking the alignment of adjacent columns.
* **Stable Anchor Mapping**: Maintain a `Map<String, GlobalKey>` for document anchors. Always use `putIfAbsent` during the visitation phase to ensure keys are stable across rebuilds, which is mandatory for reliable `Scrollable.ensureVisible` navigation.
* **Semantic Admonition Stripping**: When rendering GFM callouts (`[!NOTE]`), the visitor MUST surgically strip the marker text from the content body to prevent visual redundancy, as the type is already represented in the container header.
* **Recursive List Rendering**: When a list item contains block-level elements (tables, code blocks, nested lists), the viewer MUST utilize a sub-visitor to render the item content as a `Column` of widgets instead of a flattened `RichText`.

## 19. Supply Chain Security (Strict Pinning)
* **No `any` Constraints**: Every package in `pubspec.yaml` MUST have a version range. 
* **Build Reproducibility**: If adding a new dependency, always check `pub.dev` for the latest stable version and use the caret syntax (e.g., `^1.0.0`) to allow safe patches while preventing major breaking changes during CI.

## 20. Observability & Global Error Handling
* **Logging Layer**: All critical services and providers MUST utilize `ref.read(loggingServiceProvider.notifier)` to log significant state transitions or external API failures.
* **Error Reporting**: Severe errors caught at the service level should be logged as `logError`. This automatically triggers a global user-facing toast via the `PlatformDispatcher` error boundary.
* **Navigator Safety**: Global error feedback (toasts) MUST use the `navigatorKey` to ensure a valid `BuildContext` is available even during asynchronous background operations.

## 21. Plugin Safety & Isolation (Defensive Guarding)
* **The Safety Wrapper**: Every call to a plugin's `buildPluginWindow` or `buildSettingsPanel` MUST be wrapped in the `SqaSafePluginBuilder`. This ensures that a UI crash in one plugin does not affect the main application or other active tools.
* **Lifecycle Isolation**: Plugin `initialize()` and `dispose()` calls MUST be caught individually. Use the `LoggingService` to report initialization failures while allowing the rest of the application to continue booting.
* **Recovery UI**: The safety builder MUST provide a clear "Error" state for the plugin area, allowing the user to understand which specific component failed and providing a way to retry or reload if possible.

## 22. Design Token Discipline
To ensure visual coherence and facilitate rapid branding updates:
* **Single Source of Truth**: All UI components MUST consume `SqaTokens` for spacing, border radii, durations, and typography.
* **No Magic Numbers**: Never hardcode values like `16.0` for padding or `12.0` for radius in component builds. Always use the semantic tokens (e.g., `SqaTokens.spacingLarge`).
* **Animation Harmony**: Use `SqaTokens.durationNormal` and `SqaTokens.curveStandard` for all UI transitions to maintain a unified "physics" across the suite.

## 23. Data Sovereignty & Secure Preferences
* **Encryption by Default**: Sensitive user data (license codes, emails, API keys) MUST be stored via `flutter_secure_storage` through the `PreferencesService`.
* **Async Awareness**: UI components consuming secure data MUST utilize `FutureProvider` or `AsyncValue` to handle the decryption latency gracefully.
* **Migration Integrity**: Any change to preference keys or underlying storage mechanisms MUST be accompanied by a logic update in `PreferencesService.migrate()` to prevent data loss.

## 24. Operational Stability & Diagnostics
* **Shared Context**: Never create ad-hoc `ProviderContainer` instances. All global error handlers and background tasks must utilize the `globalProviderContainer` initialized in `main.dart`.
* **Post-Mortem Readiness**: The application maintains a persistent `app.log` file on disk. When a feature fails in production, the first step is to instruct the user to provide this log via the "Diagnostic Logs" button in Settings.
* **Atomic Integrity**: For plugins that persist user-generated content (like Todo or Text Editor), ensure data is saved atomically to prevent file corruption during unexpected application termination.
