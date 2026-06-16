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
- `[ ]` **High:** Standardize provider patterns. Convert hand-rolled `NotifierProvider` implementations (e.g., in `plugin_provider.dart`, `timer`, `todo`, `beautifier`, `screenshot`) to use `@Riverpod` code generation for consistency with newer plugins.
- `[ ]` **Medium:** Introduce basic integration/smoke tests (e.g., verifying all plugins successfully register and build).
- `[ ]` **Medium:** Standardize provider naming conventions across the codebase to ensure generated vs hand-rolled parity.

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

---

## 📜 Resolved Improvements Log

Completed tech debt and architectural milestones are archived here for historical tracking.

* *(No items resolved yet. Check off items from the roadmap above and move them here!)*
