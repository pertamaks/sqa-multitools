# SRS: API Requester Plugin (QuickRequest)

## 1. Introduction
The **API Requester** (QuickRequest) is a high-speed HTTP client plugin for SQA-Multitools. It is designed for QA engineers who need to quickly verify API endpoints with dynamically generated test data (Faker).

## 2. Core Features
### 2.1 cURL-First Architecture
* **The Command Deck**: A prominent, multiline `SqaField` for raw cURL command input. This is the primary "Source of Truth".
* **Bidirectional Sync**: 
    * **cURL to Grid**: Pasting or typing a cURL command automatically populates the Params, Headers, and Body grids.
    * **Grid to cURL**: Modifying any value in the structured grids (including Method/URL) instantly updates the cURL string in the Command Deck.
* **Instant Execution**: One-click "Execute cURL" button to bypass manual grid configuration.

### 2.2 Three-Tab Navigation
* **Request Tab**: Features the Command Deck and parsed sub-sections (Params, Body, Headers).
* **Response Tab**: Read-only view of execution results (Status, Time, Size, Body).
* **History Tab**: List of past requests. Clicking an item restores the full cURL state.

### 2.3 Structured Data Editors (The Reflector)
All request parts (Params, Headers, Body) support a "Dual-Mode" visual toggle:
* **Grid Mode**: Key-Value tree for structured editing.
    * **Faker Integration**: Each value row provides a **Combo Field** (Picker) to link that field to a specific Faker category.
* **Raw Mode**: Monospaced DSL editor (JSON or GraphQL).

### 2.4 Response Handling
* **Status Badge**: Visual indicator of HTTP status (Green for 2xx, Red for 4xx/5xx).
* **Timed Metadata**: Display total request duration and response size.
* **Formatted Output**: Automatic JSON formatting for response bodies.

## 3. UI/UX Design
* **Navigation**: Uses `SqaTabBar` with three distinct sections: Request, Response, History.
* **Grid Interface**: A clean, row-based editor for Key-Value pairs with inline Faker selectors.
* **Typography**: Monospace font for the Raw Editor and Response body.

## 4. Technical Stack
* **Networking**: `dio` for robust request handling and timing.
* **State Management**: `flutter_riverpod` with `riverpod_generator`.
* **Persistence**: Local storage for the last used URL, Method, and Body.

## 5. Implementation Roadmap
1. **Core Service**: Build the `ApiRequesterService` using Dio.
2. **Faker Utility**: Create `FakerInjectionService` to bridge with `data_generator`.
3. **UI Components**: Build the `ApiRequesterView` with the integrated "Magic Wand".
4. **Integration**: Register the plugin in `lib/plugins/`.
