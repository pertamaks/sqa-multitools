# 🏗️ SQA-Multitools: Tech Debt & Architecture Roadmap

This is a living document that tracks active technical debt, planned architectural improvements, and serves as the ledger for Architecture Decision Records (ADRs).

**Baseline Audit Origin:** [Codebase Review (2026-06-16)](file:///e:/Github/sqa-multitools/docs/codebase_review.md)

---

## 🛠️ Active Tech Debt & Improvement Roadmap

This checklist is derived from the baseline audit and ongoing development. Items should be checked off as they are resolved.

### Phase 1: Quick Wins (High Impact, Low Effort)
- `[x]` **Critical:** Add test coverage for the `SettingsPlugin` (vital for theme/hotkey stability).
- `[x]` **High:** Fix the orphan `TextEditingController` fallback inside `SqaPluginLayout` (line 155).
- `[x]` **High:** Add missing `Scrollbar` wrappers in `Beautifier` and `Security Payloads` scrollable regions.
- `[x]` **Medium:** Fix the dead `GEMINI.md` reference in `AGENT.md` (should point to `AGENT.md`).
- `[x]` **Medium:** Resolve phantom SRS documents (`plugin_clipboard.md`, `plugin_color_picker.md`) by moving them to a planned folder or marking them explicitly.
- `[x]` **Low:** Add basic state and shake animation tests for the Magic 8-Ball plugin.

### Phase 2: Architectural Standardization
- `[x]` **High:** Standardize provider patterns. Convert hand-rolled `NotifierProvider` implementations (e.g., in `plugin_provider.dart`, `timer`, `todo`, `beautifier`, `screenshot`) to use `@Riverpod` code generation for consistency with newer plugins.
- `[x]` **Medium:** Introduce basic integration/smoke tests (e.g., verifying all plugins successfully register and build).
- `[x]` **Medium:** Standardize provider naming conventions across the codebase to ensure generated vs hand-rolled parity.

---

## 🏛️ Architecture Decision Records (ADRs)

A ledger of foundational technical decisions to provide context for future developers and AI agents.

### ADR-001: Riverpod over BLoC for State Management
**Date:** 2026-06-16 (Documented)
* **Context:** The app requires complex, cross-plugin state sharing (e.g., Swagger Explorer talking to cURL Requester) and dynamic plugin registration.
* **Decision:** We use Riverpod (specifically `riverpod_generator`) for state management.
* **Reasoning:** Riverpod's global, context-free provider access perfectly suits a modular desktop application where plugins need to maintain state independently of the widget tree. `keepAlive: true` allows us to preserve heavy plugin states (like cURL history or Text Editor drafts) when navigating away.

### ADR-002: The `SqaPlugin` Contract & Modular Isolation
**Date:** 2026-06-16 (Documented)
* **Context:** A multi-tool application runs the risk of becoming a monolithic ball of mud where tools become tightly coupled.
* **Decision:** Every tool MUST implement the `SqaPlugin` interface and reside in its own isolated folder within `lib/plugins/`.
* **Reasoning:** This creates a strict boundary. Plugins act as independent mini-apps. It ensures that adding or removing a tool does not require modifying core framework logic (outside of the central provider registration), reducing merge conflicts and improving team velocity.

### ADR-003: AppFlowy Base for the Text Editor
**Date:** 2026-06-16 (Documented)
* **Context:** The Text Editor plugin requires complex block-level editing (tables, code blocks) with Markdown round-trip fidelity.
* **Decision:** We build on top of `appflowy_editor` rather than standard `TextField` or `flutter_quill`.
* **Reasoning:** `appflowy_editor` provides a block-based document model (similar to Notion) which is strictly necessary for our high-fidelity Markdown encoders/decoders and custom block components. To maintain stability, we do not fork the package, but inherit from its builders (wrapped in `SqaBlockComponentWrapper`).

### ADR-004: Single Window Pivot (Media Annotator)
**Date:** 2026-06-16 (Documented)
* **Context:** Using `desktop_multi_window` for the annotator caused critical EGL context teardown crashes and IPC messaging failures between isolates.
* **Decision:** The Media Annotator operates entirely inside the main application instance using a Single Window Architecture (expanding to cover the screen).
* **Reasoning:** This bypasses instability vectors, eliminates cross-isolate IPC requirements, and provides rock-solid stability for native video rendering.

### ADR-005: Resolution-Preserving FFmpeg Pipeline & Decoupling
**Date:** 2026-06-16 (Documented)
* **Context:** Annotations must not degrade the original high-resolution captures, and encoding must not freeze the application.
* **Decision:** We use a dynamic `pixelRatio` to capture the UI canvas at 2.5K+, and scale/composite it perfectly onto the source video using FFmpeg in a decoupled background task.
* **Reasoning:** Aspect ratio locking (`StackFit.expand`) guarantees perfect coordinate translation. Running FFmpeg on the global provider container allows the user to instantly exit the annotator while a root-level `GlobalProcessingNotifier` frosts the application, creating a seamless UX without blocking loading screens.

### ADR-006: Self-Healing Linux Desktop Integration
**Date:** 2026-06-16 (Documented)
* **Context:** The app is distributed as a portable binary on Linux. This causes issues with Wayland recognizing the app icon and the app appearing in the desktop launcher.
* **Decision:** We implemented a "self-healing" `.desktop` integration service. If enabled, the app ensures `~/.local/share/applications/com.sqa.sqa_multitools.desktop` and the icon asset exist. On startup, it checks if the `.desktop` file points to the current binary path and dynamically updates it if the user moved the folder.
* **Reasoning:** This allows the app to maintain native desktop integration while retaining the convenience of a portable installation. It eliminates the need for a global installer like `.deb` or `Flatpak` for core usability.

### ADR-007: Background Daemon Window Hiding vs Opacity
**Date:** 2026-06-16 (Documented)
* **Context:** Originally, the app used `opacity = 0.0` to "hide" the window when dismissed, preserving the GPU surface for zero-latency reopening and bypassing Windows focus-stealing prevention. However, this caused Z-order focus stealing bugs where closing other unrelated apps would forcefully give keyboard focus to the transparent SQA window. It also caused Wayland docks to constantly show the app as running.
* **Decision:** We migrated `WindowUtils.safeHide()` to use a true `windowManager.hide()` command across all platforms.
* **Reasoning:** Unmapping the window (`hide()`) completely removes it from the OS Z-order stack, guaranteeing it will never intercept focus when the user is working in other apps. It also perfectly satisfies Linux/GNOME dock restrictions, allowing the app to act as a true, invisible background system daemon without being pinned to the dock.

---

## 📜 Resolved Improvements Log

Completed tech debt and architectural milestones are archived here for historical tracking.

* *(No items resolved yet. Check off items from the roadmap above and move them here!)*
