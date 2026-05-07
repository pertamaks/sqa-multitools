# SRS: Security Payloads Plugin

## Overview
The **Security Payloads** plugin is an educational testing lab designed for QA testers and security researchers. Unlike a static list of scripts, it provides context, "How-to-test" guides, and success indicators for each payload, along with an interactive generator for Path Traversal vulnerabilities.

## Features

### 1. Web Payloads
A collection of payloads for web-specific vulnerabilities, each accompanied by an educational context panel:
- **SQL Injection**: Payloads for auth bypass, error-based discovery, and union-based extraction.
- **XSS (Cross-Site Scripting)**: Various vectors including `<script>`, `onerror`, and SVG-based injections.
- **Path Traversal Generator**: An interactive tool that takes a target URL, parses its parameters, and automatically injects traversal strings (e.g., `../../etc/passwd`) for instant testing.

### 2. System Payloads
Payloads for system-level testing:
- **Command Injection**: Payloads utilizing piping (`;`), chaining (`&&`), and redirection.
- **Header Injection**: Payloads for CRLF and Host header manipulation.

### 3. Educational Context (The "Lab" System)
Every payload is contained within an expandable card that provides:
- **Vulnerability Primer**: A high-level explanation of the vulnerability type.
- **Technical Description**: What the specific payload string performs.
- **How to Test**: Step-by-step instructions for the tester.
- **Success Indicators**: Visual cues (e.g., alert boxes, system files) that signify a successful exploit.
- **Risk Badges**: Color-coded severity indicators (Low to Critical).

## UI Standards
- Use `SqaPluginLayout` for a consistent look.
- **Tabs**: Web and System.
- **Vertical-First Design**: Optimized for 450px width using vertical expansion (Accordions) instead of side panels.
- **Monospace Typography**: All payloads and injected URLs use monospace fonts for clarity.
- **Zero Hacks**: Built strictly using `SqaCard`, `SqaField`, and `SqaInfoBanner`.

## Architecture
The plugin follows a modular structure for maintainability and consistency:
- **`security_payloads_plugin.dart`**: Main entry point and registration.
- **`ui/security_payloads_view.dart`**: Primary application layout and tab coordination.
- **`ui/tabs/`**: Contains tab-specific views (`WebTabView`, `SystemTabView`).
- **`ui/widgets/`**: Shared components like `PayloadCard` and `SecurityDisclaimer`.

## Implementation Details
- **ID**: `com.sqa.plugin.security_payloads`
- **Icon**: `Symbols.security`
- **Badge**: `null` (Stable)
- **State Management**: `flutter_riverpod` with `freezed` for immutable `SecurityPayloadsState`.
- **Provider**: `securityPayloadsProvider`.
