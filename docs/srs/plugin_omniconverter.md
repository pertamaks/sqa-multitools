# Software Requirements Specification (SRS) - OmniConverter Plugin

## 1. Overview
OmniConverter is an all-in-one data transformation and inspection plugin for SQA-Multitools. It facilitates daily QA engineering operations by providing immediate, local, and secure conversions across multiple encodings, serialization formats, security tokens, cryptographic hashes, and text cases without leaving the application.

## 2. Supported Categories & Capabilities

### 2.1 Encodings
- **Base64**: Encodes text to Base64 (Standard & URL-Safe). Decodes Base64 with automatic padding recovery and newline sanitization.
- **URL**: Full URI component encoding and decoding.
- **HTML Entities**: Encodes special characters (`<`, `>`, `&`, quotes) and decodes entity strings into raw text.
- **Hexadecimal**: Converts ASCII/UTF-8 characters into 2-digit hex values and vice-versa.
- **Binary**: Converts characters into 8-bit padded binary strings and vice-versa.

### 2.2 Formats & Structured Data
- **JSON ➔ YAML**: Formats JSON strings into YAML markup.
- **YAML ➔ JSON**: Parses YAML markup into indented JSON.
- **JSON ➔ XML**: Maps JSON object trees to XML structures with standard headers.
- **XML ➔ JSON**: Parses XML tags and attributes into equivalent JSON objects.

### 2.3 JWT (JSON Web Token) Inspector
- Parses 3-part JWT tokens into header and payload JSON representations.
- Live claims analysis:
  - Expiration timestamp (`exp`) with `ACTIVE` or `EXPIRED` status badge.
  - Issued at (`iat`) and subject (`sub`).
  - Algorithm (`alg`) identification.

### 2.4 Cryptographic Hashes & Checksums
- Calculates instant hashes: `MD5`, `SHA-1`, `SHA-256`, and `SHA-512`.
- Direct one-click copy buttons for each algorithm output.

### 2.5 Text Case & String Utilities
- Casing conversions: `camelCase`, `PascalCase`, `snake_case`, `kebab-case`, `CONSTANT_CASE`, and `Title Case`.
- Line utilities: Duplicate line removal, alphabetical line sorting, line whitespace trimming.

## 3. UI/UX Standards
- Built entirely with centralized SQA UI tokens and components (`SqaPluginLayout`, `SqaCard`, `SqaSegmentedButton`, `SqaField`, `SqaHoverIconButton`).
- Live debounce processing (150ms) to ensure smooth user typing experience.
- Error banner notifying syntax errors (e.g. malformed Base64 or invalid JSON) without application crashes.
- Four-step interactive Coachmark tutorial (`coachmarkSteps`).
