# cURL Requester - Future Roadmap & TODOs

This document outlines the planned improvements for the **cURL Requester** plugin to bring it up to parity with robust, industry-standard REST clients (like Postman or Insomnia). These items will be tackled after the Swagger Explorer plugin reaches maturity.

## 1. Multipart Form Data (Media Uploads)
**Goal:** Allow users to construct `multipart/form-data` requests to upload files from their local system.
- **Model Updates:** Extend `CurlCommand` to support a `List<FormDataItem>` or similar structure that can hold both raw text values and file paths.
- **UI Updates:** Add a new "FORM DATA" tab to the Grid Editor that includes a file picker button for uploading media.
- **Execution:** Update the Dio integration in `CurlRequesterProvider` to build and send `MultipartFile` objects.

## 2. Dedicated Authentication Tab
**Goal:** Simplify authentication by automatically injecting required headers.
- **UI Updates:** Add an "AUTH" tab next to Headers/Params.
- **Features:** 
  - Support `Bearer Token`, `Basic Auth`, and `API Key` (Header/Query).
  - Automatically parse these from incoming Swagger/cURL strings.
  - Dynamically inject the resulting `Authorization` headers into the final executed request.

## 3. Environment Variables & Workspaces
**Goal:** Allow users to define custom variables (e.g., `{{BASE_URL}}`) and switch between environments (Staging vs. Production).
- **Core Updates:** Build an Environment Manager state.
- **UI Updates:** Add a dropdown in the UI to select the active environment.
- **Execution:** Hook the user-defined variables into the existing `FakerResolutionService` so `{{myVar}}` is resolved at runtime.

## 4. Collections / Saved Requests
**Goal:** Persist and organize frequently used requests beyond just the chronological History tab.
- **Data Layer:** Create a persistence mechanism for `RequestCollection` and `SavedRequest` models.
- **UI Updates:** Add a "Collections" sidebar or tab where users can group requests into folders, rename them, and trigger them instantly.

## 5. `x-www-form-urlencoded` & Advanced Body Editor
**Goal:** Better handling of non-JSON body payloads.
- **UI Updates:** Add a dropdown to the Body section to toggle between `JSON`, `x-www-form-urlencoded`, and `Raw Text`.
- **Parsing:** Ensure that if a user selects `x-www-form-urlencoded`, the UI renders a grid editor (similar to Query Parameters) and correctly URL-encodes the body before sending.
