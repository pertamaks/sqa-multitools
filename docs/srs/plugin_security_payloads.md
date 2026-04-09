# SRS: Security Payloads Plugin

## Overview
The **Security Payloads** plugin is a dedicated tool for security testing and fuzzing. It provides a collection of common payloads for web and system-level vulnerability testing, along with utility tools for data manipulation (e.g., Base64).

## Features

### 1. Web Payloads
A collection of payloads for web-specific vulnerabilities:
- **SQL Injection**: Payloads like `' OR 1=1 --`, `admin' --`, and union-based injections.
- **XSS (Cross-Site Scripting)**: Payloads like `<script>alert(1)</script>`, `onerror` events, etc.
- **Path Traversal**: Payloads like `../../../../etc/passwd`, `..\..\..\..\windows\win.ini`.

### 2. System Payloads
Payloads for system-level testing:
- **Command Injection**: Payloads like `; ls -la`, `| id`, `&& cat /etc/shadow`.
- **Header Injection**: CRLF injections, host header manipulation.

### 3. Utils
Utility tools for security-related data manipulation:
- **Base64 Encode/Decode**: Straightforward conversion for encoded strings often found in security contexts.

## UI Standards
- Use `SqaPluginLayout` for a consistent look.
- Tabs for **Web**, **System**, and **Utils**.
- Use `SqaField` for inputs and copyable outputs.
- Category headers for clear grouping within tabs.

## Implementation Details
- **ID**: `com.sqa.plugin.security_payloads`
- **Icon**: `Symbols.security` or `Symbols.lock`.
- **Badge**: `ALPHA` (initial version).
