# SRS: Swagger Explorer Plugin

## 1. Introduction
The **Swagger Explorer** is a high-fidelity discovery tool for SQA-Multitools. It allows QA engineers to natively parse, browse, and inspect OpenAPI/Swagger schemas. Its primary function is to serve as a bridge to the existing cURL Requester, allowing users to discover APIs cleanly and execute them robustly.

## 2. Core Features
### 2.1 Native Parsing & Discovery
* **Local & Remote Support:** Ingest OpenAPI/Swagger specs via a direct URL (e.g., `http://localhost:8080/v3/api-docs`) or a local JSON file upload.
* **Schema Format Support:** Parses **OpenAPI 3.0** (`openapi: 3.x`) and **Swagger 2.0** (`swagger: 2.0`) document formats. Only JSON serialization is supported (YAML is not implemented).
* **Native Rendering:** The schema is parsed into internal models and rendered using native Flutter widgets (Material 3/SQA UI) rather than a heavy, unstable WebView.
* **Tag Grouping:** Endpoints are intelligently grouped by their Swagger tags for easy navigation.
* **Method Color Coding:** Standardized colors for HTTP methods (GET, POST, PUT, DELETE, PATCH).
* **$ref Resolution:** Recursive resolution of `$ref` pointers with circular-reference detection.
* **Isolate-Based Parsing:** Heavy schema parsing is offloaded to a background isolate via `compute()` to keep the UI thread responsive.

### 2.2 Security Authorization
* **Dedicated Authorize Dialog:** A modal dialog lists all security schemes defined in the schema (apiKey, http/bearer, http/basic, oauth2, openIdConnect).
* **Global Token Storage:** Users can enter bearer tokens, API keys, or basic auth credentials. These are stored in provider state and automatically injected into cURL commands.
* **Per-Endpoint Lock Status:** Each endpoint row shows a lock icon indicating whether all its security requirements are currently satisfied.

### 2.3 The Execution Bridge (cURL Requester)
* **Zero-Execution Architecture:** The Swagger Explorer *does not* execute HTTP requests natively. It completely removes the bloated "Try it out" feature found in standard Swagger UI.
* **One-Click Hand-Off:** Every endpoint view features a prominent "Send to cURL Requester" button.
* **SwaggerCurlService:** A dedicated service maps endpoint parameters, request body schemas, and security tokens into a fully-formed `CurlCommand`. This includes:
  - Path parameter substitution into the URL template
  - Query parameter injection with dummy example values
  - Request body generation from schema `properties` with example data
  - Correct Content-Type header selection (application/json, form-urlencoded, multipart)
* **State Transfer:** Clicking the hand-off button automatically navigates to the cURL Requester plugin, preserving navigation history for back-navigation.

### 2.4 Persistence (List View)
* **History Management:** The plugin maintains a history of previously loaded schemas with deduplication by URL/file path.
* **Quick Access:** The default plugin view is a "List View" allowing one-click reloading of past API specs.
* **Remove Individual:** Each history item has a context menu option to remove it from the list.

## 3. UI/UX Design
* **Master-Detail Flow:** Transitions smoothly between the History List and the deeply nested Endpoint Details via a `SwaggerViewMode` enum.
* **ExpansionTile Details:** Endpoints are rendered as expandable cards with structured sections for Parameters, Request Body (with generated example JSON), and Responses.
* **High-Fidelity Aesthetics:** Uses centralized `SqaTokens` for margin, typography, and corner radiuses.
* **Loading States:** Linear progress indicators are shown during schema fetch operations.

## 4. Technical Stack
* **Parsing:** Native JSON decoding via `dart:convert`. Recursive `$ref` resolution with linear memory usage via backtracking. YAML is not supported.
* **State Management:** `flutter_riverpod` with `@Riverpod(keepAlive: true)` annotation via `riverpod_generator` and immutable `freezed` states.
* **Public Parser API:** `SwaggerParserService` is a public, testable class in `services/swagger_parser_service.dart` with a `parse()` entry point and a `resolveRefs()` utility.
* **HTTP Client:** Shared `Dio` instance with 15s connect / 30s read timeouts for schema fetching.
* **Integration:** Direct bridging to the `curl_requester` plugin via `curlRequesterProvider` and `activePluginProvider`.
