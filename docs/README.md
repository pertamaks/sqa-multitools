# SQA-Multitools: Documentation

This folder contains the Software Requirements Specification (SRS) and project-wide guidelines for SQA-Multitools.

## Modular SRS

The SRS is split into feature-specific documents to ensure clarity and maintainability.

### [00. Core Architecture](srs/00_core.md)
Introduction, technology stack (Material 3, Flutter, Riverpod), and plugin contract.

### Features & Plugins
- **[Code Beautifier](srs/plugin_beautifier.md)**
- **[cURL Requester](srs/plugin_curl_requester.md)**
- **[Data Generator](srs/plugin_data_generator.md)**
- **[QA Oracle](srs/plugin_magic_8ball.md)**
- **[QA Cheatsheet](srs/plugin_qa_cheatsheet.md)**
- **[Screen Recorder](srs/plugin_screen_recorder.md)**
- **[Screenshot Tool](srs/plugin_screenshot.md)**
- **[Security Payloads](srs/plugin_security_payloads.md)**
- **[Settings Dashboard](srs/plugin_settings.md)**
- **[Text Editor](srs/plugin_text_editor.md)**
- **[Timer / Countdown](srs/plugin_timer.md)**
- **[TODO & Tasks](srs/plugin_todo.md)**
- **[Coffee Shop & Squash the Bug](srs/feature_coffee_shop.md)**

## Document Liveness

To ensure these documents accurately reflect the state of the project, please adhere to the following rule:
> **Any changes to features MUST be accompanied by an update to the corresponding SRS document in `docs/srs/`.**
