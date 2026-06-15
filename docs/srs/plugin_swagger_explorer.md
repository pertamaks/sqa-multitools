# SRS: Swagger Explorer Plugin

## 1. Introduction
The **Swagger Explorer** is a high-fidelity discovery tool for SQA-Multitools. It allows QA engineers to natively parse, browse, and inspect OpenAPI/Swagger schemas. Its primary function is to serve as a bridge to the existing cURL Requester, allowing users to discover APIs cleanly and execute them robustly.

## 2. Core Features
### 2.1 Native Parsing & Discovery
* **Local & Remote Support:** Ingest OpenAPI/Swagger specs via a direct URL (e.g., `http://localhost:8080/v3/api-docs`) or a local file upload.
* **Native Rendering:** The schema is parsed into internal models and rendered using native Flutter widgets (Material 3/SQA UI) rather than a heavy, unstable WebView.
* **Tag Grouping:** Endpoints are intelligently grouped by their Swagger tags for easy navigation.
* **Method Color Coding:** Standardized colors for HTTP methods (GET, POST, PUT, DELETE).

### 2.2 The Execution Bridge (cURL Requester)
* **Zero-Execution Architecture:** The Swagger Explorer *does not* execute HTTP requests natively. It completely removes the bloated "Try it out" feature found in standard Swagger UI.
* **One-Click Hand-Off:** Every endpoint view features a prominent "Send to cURL Requester" button.
* **Smart Schema Parsing:** Intelligent mapping of OpenAPI 3 request bodies. Safely maps `application/octet-stream` and image types to `binaryFile` bodies, avoiding multipart mismatching.
* **Global Authorization:** Supports schema-level Security Schemes. Users can globally authorize via a dedicated dialog (Bearer, Basic, API Key). The active tokens are injected directly into the cURL hand-off automatically.
* **State Transfer:** Clicking the hand-off button automatically translates the endpoint (URL, Method, Headers, Body template, auth values) into a valid raw cURL string and injects it directly into the `curlRequesterProvider` state.

### 2.3 Persistence (List View)
* **History Management:** The plugin maintains a history of previously loaded schemas.
* **Quick Access:** The default plugin view is a "List View" allowing one-click reloading of past API specs.

## 3. UI/UX Design
* **Master-Detail Flow:** Transitions smoothly between the History List and the deeply nested Endpoint Details.
* **High-Fidelity Aesthetics:** Uses centralized `SqaTokens` for margin, typography, and corner radiuses.

## 4. Technical Stack
* **Parsing:** Native JSON/YAML decoding or a lightweight OpenAPI Dart parser.
* **State Management:** `flutter_riverpod` (specifically `riverpod_generator`) with immutable `freezed` states.
* **Integration:** Direct bridging to the `plugin_curl_requester` using the global `activePluginProvider`.
