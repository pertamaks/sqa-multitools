# SRS: cURL Requester Plugin

## 1. Introduction
The **cURL Requester** is a high-speed HTTP client plugin for SQA-Multitools. It is designed for QA engineers who need to quickly verify API endpoints with dynamically generated test data (Faker).

## 2. Core Features
### 2.1 cURL-First Architecture
* **The Command Deck**: A prominent, multiline `SqaField` for raw cURL command input. This is the primary "Source of Truth".
* **Bidirectional Sync**: 
    * **cURL to Grid**: Pasting or typing a cURL command automatically populates the URL and the structured Grid reflector.
    * **Grid to cURL**: Modifying any value in the structured grid (Params, Headers, Method) instantly updates the cURL string.
* **Instant Execution**: One-click "Execute cURL" button to trigger the request.

### 2.2 Two-Tab Navigation with Dynamic Inspector
* **Request Tab**: Features the Command Deck and the "Reflector" (Unified Grid Editor).
* **History Tab**: List of past 50 requests. Clicking an item opens the Transaction Inspector.
* **Transaction Inspector (Modal)**: A detailed overlay that appears post-execution or via History, showing:
    * **REQ Tab**: The specific cURL command (resolved) used for the request.
    * **RES Tab**: High-fidelity response body with automatic JSON formatting.
    * **Metadata**: Status code, latency (ms), and payload size (KB).

### 2.3 Structured Reflector (The Grid)
* **Unified Mode**: A toggleable view that transforms the raw cURL into a structured list of parameters and headers.
* **Faker Integration (Magic Wand)**: A hierarchical, categorized submenu for injecting dynamic data (Personal, Technical, Business, etc.) directly into grid values.

### 2.4 Persistence
* **State Recovery**: The last active cURL command and full 50-item history are persisted across sessions using local storage.

## 3. UI/UX Design
* **Safety First**: Destructive actions (Clear History, Clear Request) utilize confirmation patterns (Modal or Two-Click Inline) to prevent data loss.
* **Faker Discoverability**: Categorized submenus organize the 20+ supported data types for easy access.

## 4. Technical Stack
* **Networking**: `dio` (Planned) for robust request handling, interceptors, and timing.
* **State Management**: `flutter_riverpod`.
* **Data Generation**: `faker_dart` integrated via `FakerResolutionService`.

## 5. Implementation Roadmap
1. [DONE] **Core Service**: Build the cURL parsing and execution logic.
2. [DONE] **Faker Expansion**: Implement hierarchical categorized data generation.
3. [DONE] **Persistence**: Implement history and state restoration.
4. [PENDING] **Dio Migration**: Switch from `http` to `dio` for advanced networking features.
