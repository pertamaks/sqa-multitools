# SQA-Multitools

A modular desktop utility suite built for QA Engineers and Developers. SQA-Multitools brings together everyday testing tools into a single, lightweight toolbar that floats on your desktop.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows)
[![License](https://img.shields.io/badge/License-Proprietary-gray)](LICENSE)

---

## Features

| Tool | Description |
|---|---|
| **Timer & Countdown** | Stopwatch, countdown timer, and Unix timestamp converter |
| **Data Generator** | Generate mock UUIDs, emails, names, addresses, and glyphs on the fly |
| **Code Beautifier** | Format and syntax-highlight JSON, XML, YAML, and Dart with line numbers |
| **Text Editor** | Premium Markdown editor for bug reports and dev tickets with "Smart Paste" support |
| **cURL Requester** | Simplified HTTP client with history and "Mini-Postman" transaction inspection |
| **Screen Recorder** | Record your screen with a draggable floating control bar |
| **Screenshot** | Capture full-screen or region-select screenshots |
| **TODO & Tasks** | Lightweight task management for development sprints |
| **QA Cheatsheet** | Quick access to standard QA checklists and project-specific guides |
| **Security Payloads** | Quick-access XSS/SQL injection test strings |
| **Settings** | Theme selection, preferences, and Coffee Shop license manager |
| **QA Oracle** | The essential QA decision-making tool 🎱 |

## Architecture

SQA-Multitools uses a **plugin-based architecture**. The core engine handles window management, theming, and plugin registration — all feature logic lives in isolated plugin modules.

```
lib/
├── core/              # Engine: plugin contract, providers, window management
│   ├── models/        # SqaPlugin interface, data shapes
│   ├── providers/     # Global state (active plugin, preferences)
│   ├── services/      # Shared services (preferences, licensing)
│   ├── utils/         # Utilities (locale, formatting)
│   └── window/        # Frameless window handling
├── ui/                # Shared component library (SqaButton, SqaField, etc.)
│   └── widgets/       # 18 standardized Material 3 widgets
└── plugins/           # Feature modules (each self-contained)
    ├── beautifier/
    ├── curl_requester/
    ├── data_generator/
    ├── magic_8ball/
    ├── qa_cheatsheet/
    ├── screen_recorder/
    ├── screenshot/
    ├── security_payloads/
    ├── settings/
    ├── text_editor/
    ├── timer/
    └── todo/
```

## Tech Stack

- **Framework:** Flutter (Windows desktop)
- **State Management:** Riverpod + Riverpod Generator
- **Immutability:** Freezed
- **UI:** Material 3 with custom frameless window chrome
- **Native:** Windows Mutex for single-instance enforcement
- **CI/CD:** GitHub Actions — automated Windows release builds on version tags with manual approval gate

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart ≥ 3.11.3)
- Windows 10/11
- [Rust toolchain](https://rustup.rs/) (required by `super_native_extensions`)

### Setup

```bash
# Clone the repository
git clone https://github.com/pertamaks/sqa-multitools.git
cd sqa-multitools

# Install dependencies
flutter pub get

# Generate code (Freezed models, Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run -d windows
```

### Running Tests

```bash
flutter test
```

### Building a Release

```bash
flutter build windows --release
```

The compiled bundle will be at `build/windows/x64/runner/Release/`.

### Automated Pipeline
Releases are automatically triggered by pushing a version tag (e.g., `v0.1.0`). This process is guarded by a manual approval gate in GitHub Actions. 

For full details on the release workflow and branching strategy, see **[RELEASE.md](RELEASE.md)**.

## Data Privacy & AI Disclosure

**Privacy First:** SQA-Multitools is built on a **Local-First** architecture. 
- 🔒 **100% Local:** All data (recordings, screenshots, notes, logs, and cURL history) stays on your machine.
- 🚫 **No AI Analysis:** Your data is never sent to external AI models for processing or training.
- 📡 **Offline Ready:** Core features do not require an internet connection.

**Development Disclosure:** We use AI coding assistants to accelerate development. However, SQA-Multitools is **not** an "AI Agent" app. Every line of code is human-verified, passes strict automated tests, and the source is available for your audit.

## Documentation

- **[Project Docs](docs/README.md)** — SRS index and feature specifications
- **[Core Architecture SRS](docs/srs/00_core.md)** — Engine design, plugin contract, UI system
- **[Contributing Guidelines](CONTRIBUTING.md)** — Code standards, conventions, and PR requirements

## Contributing

Please read **[CONTRIBUTING.md](CONTRIBUTING.md)** before submitting any changes. It covers development principles, code organization rules, UI standards, and the plugin contract.
